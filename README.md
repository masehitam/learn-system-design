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

## Login, sinkron progres, dan admin konten

Tanpa konfigurasi, situs berjalan dalam mode demo. Tombol login nonaktif, dan menu Admin menyimpan perubahan hanya di browser.

Untuk mengaktifkan login dan admin sungguhan (paket gratis Supabase cukup):

1. Buat proyek di [supabase.com](https://supabase.com).
2. Buka SQL Editor, lalu jalankan [supabase/schema.sql](supabase/schema.sql). File ini aman dijalankan ulang setiap kali diperbarui.
3. Buka Authentication > Providers, lalu aktifkan Google dan GitHub.
   - Google: buat OAuth client di Google Cloud Console.
   - GitHub: buat OAuth App di GitHub Settings > Developer settings.
   - Untuk keduanya, isi callback URL dengan yang ditampilkan Supabase, yaitu `https://<proyek>.supabase.co/auth/v1/callback`.
   - Login lewat tautan email memakai provider Email, yang sudah aktif secara bawaan. Pengirim email bawaan Supabase hanya mengirim beberapa email per jam, jadi pasang SMTP sendiri (Authentication > Emails > SMTP Settings) sebelum dipakai banyak orang.
4. Buka Authentication > URL Configuration, lalu tambahkan alamat situsmu ke Redirect URLs. Contohnya `https://<user>.github.io/<repo>/` dan `http://localhost:4173/`.
5. Isi `supabaseUrl` dan `supabaseAnonKey` di [prototype/config.js](prototype/config.js). Nilainya ada di Project Settings > API. Anon key memang dirancang untuk publik; hak tulis dijaga oleh Row Level Security.
6. Login sekali lewat situs, lalu jadikan akunmu admin lewat SQL Editor:

   ```sql
   insert into public.admins (user_id) select id from auth.users where email = 'email-kamu@contoh.com';
   ```

Setelah login, progres, simpanan, catatan, hasil kuis, dan tantangan disinkronkan ke akun. Saat login pertama, data di perangkat digabung dengan data di akun: progres diambil yang tertinggi, sisanya digabung. Simpanan atau catatan yang dihapus di satu perangkat ikut terhapus di perangkat lain, karena aplikasi mencatat waktu setiap tambah dan hapus lalu memakai perubahan yang paling akhir.

Setiap pelajaran punya kuis 3–5 soal yang bisa diubah di menu Admin dengan format teks sederhana. Pelajaran tanpa kuis sendiri memakai satu soal dari animasinya.

Simpan pertama dari menu Admin otomatis menyalin konten bawaan ke database. Setelah itu, database menjadi sumber konten untuk semua pengunjung.

## Lab teknologi

Menu Lab berisi dua lab:

- **Redis:** emulator Redis di JS. Isi memori dan sisa TTL setiap kunci tampil langsung.
- **SQL:** SQLite asli lewat [sql.js](https://sql.js.org) dengan 100.000 user dan 300.000 pesanan. Setiap query menampilkan rencana eksekusi dan waktunya, jadi efek indeks langsung terlihat.

sql.js (sekitar 700 KB) hanya diunduh saat lab SQL dibuka.

## Pasang di HP dan mode offline

Situs ini bisa dipasang sebagai aplikasi (PWA) dari menu browser, misalnya "Tambahkan ke layar utama". [prototype/sw.js](prototype/sw.js) menyimpan salinan halaman dan font setiap kali dibuka. Jadi pelajaran dan playground tetap jalan tanpa internet, setelah situs pernah dibuka sekali. Saat online, versi terbaru selalu diambil lebih dulu.
