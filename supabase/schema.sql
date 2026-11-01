-- Jalankan di Supabase: SQL Editor > New query > Run. Aman dijalankan ulang setelah file ini diperbarui.

create table if not exists public.admins (
  user_id uuid primary key references auth.users on delete cascade
);
create table if not exists public.diagrams (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
create table if not exists public.lessons (
  id text primary key,
  data jsonb not null,
  sort int not null default 0,
  updated_at timestamptz not null default now()
);

-- Progres, simpanan, catatan, kuis, dan tantangan per user, disimpan utuh sebagai satu dokumen.
create table if not exists public.user_state (
  user_id uuid primary key references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.admins enable row level security;
alter table public.user_state enable row level security;
alter table public.diagrams enable row level security;
alter table public.lessons enable row level security;

-- security definer agar policy bisa membaca tabel admins tanpa membuka isinya ke publik.
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- Siapa pun boleh membaca konten; hanya admin yang boleh menulis.
drop policy if exists "baca konten" on public.lessons;
create policy "baca konten" on public.lessons for select using (true);
drop policy if exists "baca animasi" on public.diagrams;
create policy "baca animasi" on public.diagrams for select using (true);
drop policy if exists "admin tulis konten" on public.lessons;
create policy "admin tulis konten" on public.lessons for all to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin tulis animasi" on public.diagrams;
create policy "admin tulis animasi" on public.diagrams for all to authenticated using (public.is_admin()) with check (public.is_admin());
-- User hanya bisa melihat baris admin miliknya sendiri (dipakai aplikasi untuk menampilkan menu Admin).
drop policy if exists "lihat status admin sendiri" on public.admins;
create policy "lihat status admin sendiri" on public.admins for select to authenticated using (user_id = auth.uid());

-- Setiap user hanya bisa membaca dan menulis progresnya sendiri.
drop policy if exists "progres milik sendiri" on public.user_state;
create policy "progres milik sendiri" on public.user_state for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Analitik (PRD §12): event anonim tanpa akun. Siapa pun boleh menulis, hanya admin yang boleh membaca.
-- vid = id acak per perangkat, sid = id acak per sesi tab. Tidak ada user_id, IP, atau teks pencarian.
create table if not exists public.events (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  name text not null check (name ~ '^[a-z_]{1,40}$'),
  vid uuid not null,
  sid uuid not null,
  props jsonb not null default '{}'::jsonb check (jsonb_typeof(props) = 'object' and pg_column_size(props) <= 2000)
);
create index if not exists events_at on public.events (at);
create index if not exists events_vid on public.events (vid, at);
alter table public.events enable row level security;
drop policy if exists "kirim event" on public.events;
create policy "kirim event" on public.events for insert to anon, authenticated with check (at between now() - interval '5 minutes' and now() + interval '5 minutes');
drop policy if exists "admin baca event" on public.events;
create policy "admin baca event" on public.events for select to authenticated using (public.is_admin());

-- Metrik keberhasilan PRD §5. security_invoker membuat view mengikuti RLS events, jadi hanya admin yang mendapat hasil.
create or replace view public.metrics_summary with (security_invoker = true) as
with
ev as (select * from public.events),
first_seen as (select vid, min(at) as first_at from ev group by vid),
first_session as (select distinct on (vid) vid, sid from ev order by vid, at),
active7 as (select distinct vid from ev where at > now() - interval '7 days'),
done7 as (select vid, count(*) as n from ev where name = 'lesson_complete' and at > now() - interval '7 days' group by vid),
vitals as (select props from ev where name = 'perf_vitals' and at > now() - interval '7 days')
select 'north_star' as key, count(*)::numeric as value, count(*) as n from ev where name = 'lesson_complete' and at > now() - interval '7 days'
union all
select 'activation', avg((exists (select 1 from ev e where e.sid = fs.sid and e.name = 'lesson_complete'))::int), count(*)
  from first_session fs join first_seen f using (vid) where f.first_at > now() - interval '30 days'
union all
select 'depth', (select percentile_cont(0.5) within group (order by coalesce(d.n, 0)) from active7 a left join done7 d using (vid))::numeric, (select count(*) from active7)
union all
select 'd7', avg((exists (select 1 from ev e where e.vid = f.vid and e.at >= f.first_at + interval '7 days' and e.at < f.first_at + interval '14 days'))::int), count(*)
  from first_seen f where f.first_at between now() - interval '60 days' and now() - interval '14 days'
union all
select 'd30', avg((exists (select 1 from ev e where e.vid = f.vid and e.at >= f.first_at + interval '30 days' and e.at < f.first_at + interval '37 days'))::int), count(*)
  from first_seen f where f.first_at between now() - interval '120 days' and now() - interval '37 days'
union all
select 'comprehension', avg((props->>'correct')::boolean::int), count(*)
  from ev where name = 'quiz_answer' and props->>'attempt' = '1' and jsonb_typeof(props->'correct') = 'boolean' and at > now() - interval '30 days'
union all
select 'pg_adoption', avg((exists (select 1 from ev e where e.vid = a.vid and e.name = 'pg_open' and e.at > now() - interval '7 days'))::int), count(*) from active7 a
union all
select 'challenge', avg((exists (select 1 from ev e where e.vid = p.vid and e.name = 'pg_challenge_complete' and e.at > now() - interval '30 days'))::int), count(*)
  from (select distinct vid from ev where name = 'pg_open' and at > now() - interval '30 days') p
union all
select 'search_ctr', least(1, (select count(*) from ev where name = 'lesson_open' and props->>'source' = 'search' and at > now() - interval '7 days')::numeric / nullif(count(*), 0)), count(*)
  from ev where name = 'search' and at > now() - interval '7 days'
union all
select 'js_error', avg((exists (select 1 from ev e where e.sid = s.sid and e.name = 'js_error'))::int), count(*)
  from (select distinct sid from ev where at > now() - interval '7 days') s
union all
select 'lcp_p75', percentile_cont(0.75) within group (order by (props->>'lcp')::numeric)::numeric, count(*) from vitals where jsonb_typeof(props->'lcp') = 'number'
union all
select 'inp_p75', percentile_cont(0.75) within group (order by (props->>'inp')::numeric)::numeric, count(*) from vitals where jsonb_typeof(props->'inp') = 'number'
union all
select 'cls_p75', percentile_cont(0.75) within group (order by (props->>'cls')::numeric)::numeric, count(*) from vitals where jsonb_typeof(props->'cls') = 'number';

-- Setelah kamu login sekali lewat aplikasi, jadikan akunmu admin:
-- insert into public.admins (user_id) select id from auth.users where email = 'email-kamu@contoh.com';
