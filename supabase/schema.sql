-- Jalankan sekali di Supabase: SQL Editor > New query > Run.

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

alter table public.admins enable row level security;
alter table public.diagrams enable row level security;
alter table public.lessons enable row level security;

-- security definer agar policy bisa membaca tabel admins tanpa membuka isinya ke publik.
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- Siapa pun boleh membaca konten; hanya admin yang boleh menulis.
create policy "baca konten" on public.lessons for select using (true);
create policy "baca animasi" on public.diagrams for select using (true);
create policy "admin tulis konten" on public.lessons for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin tulis animasi" on public.diagrams for all to authenticated using (public.is_admin()) with check (public.is_admin());
-- User hanya bisa melihat baris admin miliknya sendiri (dipakai aplikasi untuk menampilkan menu Admin).
create policy "lihat status admin sendiri" on public.admins for select to authenticated using (user_id = auth.uid());

-- Setelah kamu login sekali lewat aplikasi, jadikan akunmu admin:
-- insert into public.admins (user_id) select id from auth.users where email = 'email-kamu@contoh.com';
