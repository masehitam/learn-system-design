# Alur

Belajar system design lewat animasi dan playground. Rencana produk lengkap ada di [PRD.md](PRD.md).

Aplikasinya satu file statis, [prototype/index.html](prototype/index.html), tanpa proses build.

## Menjalankan di komputer

```bash
python3 -m http.server 4173 --directory prototype
```

Buka http://localhost:4173.

## Deploy

Setiap push ke `main` otomatis di-deploy ke GitHub Pages oleh [.github/workflows/pages.yml](.github/workflows/pages.yml).

Untuk Cloudflare Pages: buat proyek baru, sambungkan repo ini, kosongkan build command, lalu isi output directory dengan `prototype`.

## Login Google/GitHub dan admin konten

Tanpa konfigurasi, situs berjalan dalam mode demo. Tombol login nonaktif, dan menu Admin menyimpan perubahan hanya di browser.

Untuk mengaktifkan login dan admin sungguhan (paket gratis Supabase cukup):

1. Buat proyek di [supabase.com](https://supabase.com).
2. Buka SQL Editor, lalu jalankan [supabase/schema.sql](supabase/schema.sql).
3. Buka Authentication > Providers, lalu aktifkan Google dan GitHub.
   - Google: buat OAuth client di Google Cloud Console.
   - GitHub: buat OAuth App di GitHub Settings > Developer settings.
   - Untuk keduanya, isi callback URL dengan yang ditampilkan Supabase, yaitu `https://<proyek>.supabase.co/auth/v1/callback`.
4. Buka Authentication > URL Configuration, lalu tambahkan alamat situsmu ke Redirect URLs. Contohnya `https://<user>.github.io/<repo>/` dan `http://localhost:4173/`.
5. Isi `supabaseUrl` dan `supabaseAnonKey` di [prototype/config.js](prototype/config.js). Nilainya ada di Project Settings > API. Anon key memang dirancang untuk publik; hak tulis dijaga oleh Row Level Security.
6. Login sekali lewat situs, lalu jadikan akunmu admin lewat SQL Editor:

   ```sql
   insert into public.admins (user_id) select id from auth.users where email = 'email-kamu@contoh.com';
   ```

Simpan pertama dari menu Admin otomatis menyalin konten bawaan ke database. Setelah itu, database menjadi sumber konten untuk semua pengunjung.
