# PRD: Alur, belajar system design lewat animasi

| | |
|---|---|
| Versi | 1.0 (draf untuk review) |
| Tanggal | 31 Oktober 2026 |
| Pemilik | Wiwid Widyanto |
| Status | Discovery selesai, siap dipecah menjadi tiket MVP |
| Prototype | [`prototype/index.html`](prototype/index.html), jalankan `python3 -m http.server 4173 --directory prototype` |

---

## 1. Ringkasan

**Alur** adalah web app untuk belajar system design dengan cara melihat data bergerak. Setiap pelajaran berupa animasi diagram arsitektur yang bisa diputar, dijeda, dan dilompati per langkah, mirip pengalaman menonton YouTube. Pengguna menjelajah katalog lewat thumbnail yang hidup, pencarian, kategori, dan tingkat kesulitan. Setelah memahami konsep, pengguna masuk ke **Playground**: kanvas tempat mereka merakit arsitektur sendiri, mengalirkan trafik, dan melihat komponen mana yang pertama kewalahan.

Satu keputusan inti membedakan Alur dari kursus video: **animasi adalah data, bukan video.** Setiap pelajaran disimpan sebagai JSON (node, edge, langkah). Satu engine menggambarnya untuk thumbnail, pemutar, dan playground. Hasilnya: ukuran sekitar 2 KB per pelajaran (bukan puluhan MB), teks yang bisa dicari dan dibaca screen reader, terjemahan murah, dan performa tetap ringan walau katalog berisi ratusan animasi.

## 2. Masalah

1. **System design itu abstrak.** Materi berupa teks dan diagram statis memaksa pembaca membayangkan sendiri bagaimana request mengalir, kapan cache miss terjadi, atau kenapa queue menahan lonjakan.
2. **Video terlalu linier dan berat.** Sulit dilompati per konsep, tidak bisa dicari isinya, boros kuota (masalah nyata di Indonesia), dan mahal diproduksi ulang saat materi berubah.
3. **Tidak ada tempat mencoba.** Belajar trade-off (biaya vs latensi vs ketersediaan) butuh eksperimen, tapi menyiapkan Redis, Kafka, dan load balancer sungguhan terlalu mahal untuk pemula.
4. **Materi berbahasa Indonesia yang terstruktur masih sedikit.** Kebanyakan sumber berbahasa Inggris dan tidak punya jalur belajar yang jelas.

## 3. Tujuan dan bukan tujuan

### Tujuan
- G1. Pengguna memahami konsep inti system design lebih cepat dibanding membaca teks, diukur lewat kuis per pelajaran.
- G2. Pengguna kembali belajar secara rutin karena jalur belajar dan progres yang terlihat.
- G3. Pengguna bisa menguji intuisi arsitektur di playground tanpa infrastruktur sungguhan.
- G4. Aplikasi tetap cepat di HP kelas menengah dengan koneksi 4G, walau setiap kartu berisi animasi.

### Bukan tujuan (untuk MVP)
- Video dengan narator manusia.
- Menjalankan infrastruktur sungguhan (VM, kontainer) per pengguna.
- Sertifikasi resmi atau kelas berbayar.
- Fitur sosial (komentar, forum, profil publik).
- Aplikasi native iOS dan Android. Web harus responsif dan bisa dipasang sebagai PWA.

## 4. Persona

| Persona | Profil | Kebutuhan utama | Kebiasaan |
|---|---|---|---|
| **Raka**, mahasiswa tingkat akhir | Bisa membuat CRUD, belum pernah berpikir soal skala | Fondasi yang runtut, bahasa sederhana | Belajar di HP saat di perjalanan, kuota terbatas |
| **Sinta**, backend engineer 2 tahun | Bersiap interview di perusahaan besar | Studi kasus (URL shortener, chat, news feed), latihan trade-off | Sesi 30–60 menit di laptop malam hari |
| **Dimas**, tech lead | Menjelaskan arsitektur ke tim | Animasi yang bisa ditunjukkan saat diskusi, playground untuk demo | Membuka satu pelajaran spesifik lewat pencarian |

## 5. Metrik keberhasilan

**North Star Metric:** jumlah *pelajaran tuntas mingguan*, yaitu pelajaran yang animasinya diputar sampai habis **dan** kuisnya dijawab benar.

| Metrik | Definisi | Target 3 bulan setelah rilis MVP |
|---|---|---|
| Aktivasi | % pengguna baru yang menuntaskan 1 pelajaran di sesi pertama | ≥ 45% |
| Kedalaman | Median pelajaran tuntas per pengguna aktif per minggu | ≥ 3 |
| Retensi D7 | % pengguna yang kembali di hari ke-7 | ≥ 25% |
| Retensi D30 | % pengguna yang kembali di hari ke-30 | ≥ 12% |
| Pemahaman | % jawaban kuis benar pada percobaan pertama | 60–80% (di bawah 60% berarti materi kurang jelas, di atas 80% berarti kuis terlalu mudah) |
| Adopsi playground | % pengguna aktif mingguan yang membuka playground | ≥ 30% |
| Tantangan | % pengguna playground yang menyelesaikan ≥ 1 tantangan | ≥ 40% |
| Pencarian | % pencarian yang diikuti klik ke pelajaran | ≥ 55% |
| Kualitas teknis | Lihat anggaran performa di §10 | 100% halaman lolos di CI |

**Guardrail:** tingkat error JavaScript per sesi < 0,5%; skor aksesibilitas Lighthouse ≥ 95; tidak ada pelajaran dengan rating "membingungkan" > 20%.

## 6. Ruang lingkup per rilis

| Fitur | MVP (v1.0) | v1.1 | v2.0 |
|---|---|---|---|
| Katalog, thumbnail hidup, kategori, kesulitan | ✓ | | |
| Pencarian | ✓ (lokal, judul + isi) | Typo-tolerant (sudah di prototype), sinonim | Pencarian di dalam langkah animasi |
| Peta belajar (jalur metro) | ✓ | Jalur kustom ("Persiapan interview 2 minggu") | |
| Pemutar animasi per langkah | ✓ | Narasi audio TTS opsional | Mode presentasi layar penuh |
| Penjelasan, poin kunci, transkrip langkah | ✓ | | |
| Kuis per pelajaran | ✓ (1 soal) | 3–5 soal (sudah di prototype, dengan penjelasan per soal), pengulangan berjarak | |
| Catatan pribadi bertimestamp | ✓ (lokal) | Sinkron akun | Ekspor Markdown |
| Simpan, progres, riwayat | ✓ (lokal) | Sinkron akun | |
| Akun dan login | | ✓ (Google, GitHub, magic link email) — sudah di prototype | |
| Playground: kanvas + simulasi aliran | ✓ | Simpan dan bagikan desain lewat tautan (bagikan sudah di prototype) | |
| Tantangan playground | ✓ (3) | 15 tantangan, papan skor pribadi | |
| Sandbox teknologi (Redis, SQL, Kafka) | | ✓ Redis dan SQL di browser (sudah di prototype) | Kafka, consistent hashing, CAP lab |
| Editor konten internal | Format JSON + validasi CI | Editor visual | Kontributor komunitas |
| PWA + offline | | ✓ (sudah di prototype) | |

## 7. Kebutuhan fungsional

Format: user story, lalu kriteria penerimaan (KP) yang bisa diuji.

### 7.1 Beranda dan katalog

**US-1.** Sebagai pelajar, saya ingin melihat semua pelajaran dalam grid bergaya YouTube agar bisa memilih yang menarik.
- KP1. Kartu menampilkan thumbnail diagram, durasi belajar (menit), judul (maks. 2 baris), kategori, ikon dan label kesulitan, serta bar progres bila pernah diputar.
- KP2. Thumbnail diam secara default dan beranimasi saat kartu disorot kursor atau mendapat fokus keyboard. Di perangkat sentuh, hanya kartu yang terlihat ≥ 70% yang beranimasi.
- KP3. Grid responsif: 1 kolom di < 600 px, hingga 5 kolom di ≥ 1600 px, tanpa scroll horizontal halaman.
- KP4. Tombol simpan pada kartu langsung mengubah status tanpa reload; status tersinkron di semua tempat tombol yang sama muncul.

**US-2.** Sebagai pelajar, saya ingin memfilter berdasarkan kategori dan kesulitan.
- KP1. Chip kategori: Semua, Fondasi, Jaringan, Penyimpanan data, Caching, Messaging, Skalabilitas & keandalan, Studi kasus. Pilihan tunggal.
- KP2. Segmen kesulitan: Semua tingkat, Pemula, Menengah, Lanjutan.
- KP3. Filter dan pencarian bisa digabung; jumlah hasil ditampilkan ("8 dari 24 pelajaran") dan diumumkan ke screen reader.
- KP4. Hasil kosong menampilkan pesan yang menyebut kata kunci dan tombol "Hapus filter".
- KP5. (v1.1) Status filter tersimpan di URL agar bisa dibagikan.

**US-3.** Sebagai pelajar, saya ingin mencari pelajaran dengan kata kunci.
- KP1. Kolom pencarian selalu terlihat di bilah atas; tombol `/` memfokuskannya.
- KP2. Pencarian mencakup judul, deskripsi, nama kategori, poin kunci, dan (v1.1) teks langkah animasi.
- KP3. Hasil diperbarui saat mengetik, dengan waktu respons < 50 ms untuk 500 pelajaran.
- KP4. Mengetik dari halaman lain membawa pengguna ke beranda dengan hasil pencarian.

**US-4.** Sebagai pelajar, saya ingin melihat jalur belajar dan posisi saya di dalamnya.
- KP1. Peta belajar bergaya peta MRT: setiap kategori satu garis berwarna, setiap pelajaran satu stasiun, urut dari kiri ke kanan.
- KP2. Bentuk stasiun menandakan kesulitan (lingkaran = Pemula, lingkaran ganda = Menengah, belah ketupat = Lanjutan). Stasiun terisi warna berarti selesai.
- KP3. Setiap stasiun bisa diklik dan difokus dengan keyboard, dengan label aksesibel "judul, kesulitan, status".
- KP4. Di layar sempit, peta bisa digulir horizontal di dalam wadahnya sendiri.

### 7.2 Halaman pelajaran dan pemutar

**US-5.** Sebagai pelajar, saya ingin memutar animasi konsep langkah demi langkah.
- KP1. Pemutar menampilkan diagram, caption langkah (judul + 1–2 kalimat), tombol putar/jeda, langkah sebelumnya/berikutnya, timeline bersegmen per langkah, waktu, dan kecepatan (0,5×, 1×, 1,5×, 2×).
- KP2. Setiap langkah menyorot node yang relevan, menandai edge aktif, dan mengalirkan paket data. Paket merah menandai kegagalan (cache miss, request ditolak, timeout).
- KP3. Keyboard saat pemutar fokus: Spasi atau K untuk putar/jeda, ← → untuk pindah langkah.
- KP4. Animasi berhenti otomatis saat pemutar keluar layar atau tab disembunyikan, dan lanjut saat kembali.
- KP5. Autoplay saat halaman dibuka, kecuali pengguna mengaktifkan *reduce motion*.
- KP6. Progres tersimpan per langkah; menyelesaikan langkah terakhir menandai animasi tuntas.

**US-6.** Sebagai pelajar, saya ingin membaca penjelasan di bawah animasi.
- KP1. Tab Penjelasan berisi ringkasan, 3–5 poin kunci, dan daftar langkah animasi bertimestamp.
- KP2. Mengklik langkah di daftar memindahkan pemutar ke langkah itu.
- KP3. Daftar langkah sekaligus menjadi transkrip yang setara dengan animasi untuk pengguna screen reader.

**US-7.** Sebagai pelajar, saya ingin menguji pemahaman lewat kuis.
- KP1. Tab Kuis berisi soal pilihan ganda; jawaban tidak bisa dikirim kosong.
- KP2. Umpan balik langsung: benar atau salah, plus arahan ("Tonton ulang langkah 3").
- KP3. Hasil percobaan pertama dicatat untuk metrik pemahaman.

**US-8.** Sebagai pelajar, saya ingin menulis catatan pribadi di titik tertentu animasi.
- KP1. Catatan disimpan dengan timestamp posisi pemutar.
- KP2. Mengklik timestamp catatan memindahkan pemutar ke posisi itu.
- KP3. Catatan bisa dihapus. MVP menyimpan di perangkat; v1.1 tersinkron ke akun.

**US-9.** Sebagai pelajar, saya ingin tahu apa yang harus dipelajari berikutnya.
- KP1. Panel "Berikutnya di jalur" menampilkan 8 pelajaran berikutnya sesuai urutan peta.
- KP2. Tombol "Coba di playground" membuka playground dengan preset yang relevan (misalnya pelajaran cache membuka preset "Dengan cache").

### 7.3 Playground

**US-10.** Sebagai pelajar, saya ingin merakit arsitektur dan melihat perilakunya di bawah beban.
- KP1. Palet komponen: Client, Load balancer, Server, Cache, Database, Queue, CDN. Setiap komponen menampilkan kapasitas dan biaya default.
- KP2. Komponen bisa ditambah, digeser, dipilih, dihapus, dan disambungkan (mode sambung: klik asal lalu tujuan). Sambungan yang membentuk siklus ditolak.
- KP3. Seluruh operasi juga bisa dilakukan dengan keyboard lewat panel inspektur (pilih komponen, atur kapasitas, sambungkan, putuskan, hapus).
- KP4. Slider trafik 100–30.000 rps. Hasil diperbarui < 16 ms setelah perubahan.
- KP5. Panel hasil: rps berhasil, % ditolak, latensi rata-rata, biaya per bulan.
- KP6. Setiap komponen menampilkan beban/kapasitas dan bar utilisasi (hijau < 80%, kuning 80–100%, merah > 100%). Request yang ditolak terlihat sebagai percikan merah.
- KP7. Saran otomatis menunjuk bottleneck terbesar dalam bahasa sederhana ("Database 1 menerima 3.000 rps, padahal kapasitasnya 2.500. Pasang cache di depannya.").
- KP8. Preset: Satu server, Load balancer, Dengan cache, Queue dan worker, CDN di depan.

**US-11.** Sebagai pelajar, saya ingin tantangan dengan target yang jelas.
- KP1. Setiap tantangan punya cerita singkat dan target terukur (trafik, % ditolak, latensi, biaya).
- KP2. Setiap target menampilkan status lolos/gagal secara langsung.
- KP3. Tantangan yang selesai ditandai dan tersimpan.
- KP4. Tantangan MVP: (1) 3.000 rps, ditolak ≤ 1%, latensi ≤ 150 ms; (2) 10.000 rps, ≤ 1%, ≤ 100 ms, ≤ $800/bln, sehingga butuh CDN; (3) 25.000 rps, ≤ 0,1%, ≤ 60 ms, sehingga butuh queue.

**Model simulasi MVP.** Model aliran *steady-state*: trafik dari client dibagi rata ke setiap sambungan keluar; tiap komponen melayani `min(masuk, kapasitas)` dan sisanya ditolak; cache/CDN meneruskan `(1 − hit rate)`; queue hanya meneruskan sebanyak kapasitas worker dan sisanya menjadi backlog (bukan ditolak). Latensi komponen = `waktu layanan / (1 − utilisasi)` (pendekatan M/M/1, utilisasi dibatasi 95%). Model ini sengaja sederhana dan diberi label "model untuk intuisi, bukan benchmark". v2.0 menggantinya dengan simulasi per-request agar bisa mengajarkan p99 dan tail latency.

**US-12 (v1.1–v2.0).** Sebagai pelajar, saya ingin mencoba teknologi nyata di browser.
- Redis lab: perintah `GET/SET/EXPIRE/INCR` di emulator berbasis WebAssembly, divisualisasikan sebagai isi memori dan TTL.
- SQL lab: PGlite atau sql.js di browser; latihan indeks dengan `EXPLAIN` yang divisualisasikan.
- Status prototype: Redis lab (emulator JS: string, list, TTL, 5 latihan) dan SQL lab (sql.js 1.10.3, 100.000 user dan 300.000 pesanan, rencana eksekusi dan grafik waktu, 4 latihan) sudah ada di `#/lab`. sql.js dimuat lazy dari jsDelivr dengan SRI. Progres latihan lab belum disimpan.
- Kafka lab: topic, partition, consumer group, dan offset yang disimulasikan, dengan animasi rebalancing.
- Lab konsep: cincin consistent hashing, partisi CAP, rate limiter token bucket dengan slider.
- KP umum: tidak ada server per pengguna, semua berjalan di tab browser; lab dimuat hanya saat dibuka (lazy load).

### 7.4 Akun dan progres (v1.1)
Status prototype: login Google/GitHub/magic link dan sinkron progres sudah berjalan lewat Supabase (tabel `user_state`, satu dokumen per user, dijaga RLS). Tambah dan hapus simpanan atau catatan dicatat dengan waktu (`edits`), dan perubahan terakhir yang menang saat digabung. Waktunya memakai jam perangkat, jadi jam yang sangat meleset bisa membuat urutan salah.
- Login dengan magic link email atau Google. Progres lokal digabung ke akun saat login pertama (ambil nilai progres tertinggi per pelajaran).
- Data yang disimpan: progres, simpanan, catatan, hasil kuis, tantangan. Tidak ada data sensitif selain email.

## 8. Kurikulum awal (24 pelajaran)

| Garis | Pelajaran | Kesulitan | Menit |
|---|---|---|---|
| Fondasi | Apa itu system design? · Latensi vs throughput · Scaling vertikal vs horizontal · Estimasi kapasitas | P, P, P, M | 6, 8, 9, 12 |
| Jaringan | Bagaimana DNS bekerja · Load balancer L4 vs L7 · CDN dan edge caching | P, M, M | 8, 11, 10 |
| Penyimpanan data | SQL vs NoSQL · Replikasi primary-replica · Sharding dan partisi · Consistent hashing | P, M, L, L | 10, 12, 14, 13 |
| Caching | Pola cache-aside · Write-through vs write-back · Invalidasi dan eviction | P, M, M | 9, 11, 10 |
| Messaging | Message queue · Pub/Sub · Jaminan pengiriman pesan | P, M, L | 9, 10, 13 |
| Skalabilitas & keandalan | Rate limiting · API gateway · Circuit breaker · Teorema CAP | M, M, L, L | 10, 9, 11, 12 |
| Studi kasus | URL shortener · Sistem chat · News feed | M, L, L | 16, 18, 20 |

P = Pemula, M = Menengah, L = Lanjutan. Target katalog: 24 pelajaran saat MVP, 60 di v1.1, 120 di v2.0. Setiap pelajaran baru wajib punya diagram sendiri (prototype masih memakai ulang 12 diagram untuk 24 pelajaran).

## 9. Format konten: Scene JSON

Satu file per pelajaran, divalidasi JSON Schema di CI. Engine yang sama dipakai untuk thumbnail, pemutar, dan preset playground.

```json
{
  "id": "c1",
  "category": "cache",
  "title": "Pola cache-aside",
  "level": 0,
  "minutes": 9,
  "summary": "Aplikasi memeriksa cache lebih dulu…",
  "points": ["…", "…", "…"],
  "diagram": {
    "nodes": [["c","client",40,90,"Client"], ["a","server",140,90,"App"], ["k","cache",262,40,"Cache"], ["d","db",262,140,"Database"]],
    "edges": ["c-a", "a-k", "a-d"]
  },
  "steps": [
    {"title": "Cek cache dulu", "text": "App selalu bertanya ke cache sebelum ke database.", "flows": ["c>a","a>k"], "highlight": ["k"]},
    {"title": "Cache miss", "text": "…", "flows": ["!k>a","a>d","d>a"], "highlight": ["d"], "down": [], "cut": []}
  ],
  "quiz": [{"q": "…", "options": ["…","…","…"], "answer": 1, "explain": "…"}],
  "playgroundPreset": "cache"
}
```

Aturan: node memakai koordinat viewBox 320×180; `flows` berformat `asal>tujuan`, awalan `!` berarti gagal; setiap langkah 6 detik pada kecepatan 1×; caption maksimal 160 karakter; teks wajib bahasa Indonesia baku yang ramah pemula, istilah teknis tetap dalam bahasa Inggris.

## 10. Kebutuhan non-fungsional

### 10.1 Anggaran performa (diukur di CI dengan Lighthouse CI dan di produksi dengan web-vitals)

Profil uji: Moto G Power (atau setara), throttling 4G lambat, Chrome terbaru.

| Metrik | Beranda | Pelajaran | Playground |
|---|---|---|---|
| LCP (p75) | ≤ 2,0 s | ≤ 2,2 s | ≤ 2,5 s |
| INP (p75) | ≤ 150 ms | ≤ 150 ms | ≤ 200 ms |
| CLS | ≤ 0,05 | ≤ 0,05 | ≤ 0,05 |
| JS awal (gzip) | ≤ 90 KB | ≤ 110 KB | ≤ 160 KB |
| Frame rate animasi | 60 fps saat 1 kartu disorot | ≥ 55 fps (p5) | ≥ 50 fps dengan 20 komponen dan 500 paket |
| Animasi berjalan bersamaan | ≤ 1 thumbnail + 7 kereta peta | 1 pemutar | 1 kanvas |
| Memori heap | ≤ 60 MB dengan 500 kartu | ≤ 40 MB | ≤ 80 MB |

### 10.2 Strategi performa animasi
1. **Data, bukan video.** Diagram dirender sebagai SVG inline dari JSON (sekitar 2 KB per pelajaran). Tidak ada file media yang diunduh untuk thumbnail.
2. **Diam sampai diminta.** Animasi thumbnail ditulis dalam CSS dengan `animation-play-state: paused`. Frame diam diatur dengan `animation-delay` negatif agar thumbnail tetap informatif. Animasi berjalan hanya untuk kartu yang disorot, difokus, atau (di layar sentuh) terlihat penuh lewat IntersectionObserver.
3. **Hanya properti komposit.** Hanya `transform` dan `opacity` yang dianimasikan. Tidak ada animasi `width`, `top`, `filter`, atau `box-shadow`. Tidak ada `backdrop-filter`.
4. **Satu loop per halaman.** Pemutar dan playground masing-masing memakai satu `requestAnimationFrame` yang berhenti saat dijeda, saat tab tersembunyi, dan saat elemen keluar layar. Delta waktu dibatasi 50 ms agar tidak melompat setelah tab kembali aktif.
5. **Pool objek.** Paket data memakai pool elemen yang dipakai ulang (40 di pemutar). Tidak ada alokasi DOM per frame.
6. **Canvas untuk volume tinggi.** Playground menggambar ke `<canvas>` dengan batas visual 500 paket dan 160 percikan, berapa pun rps yang disimulasikan. DPR dibatasi 2.
7. **Render seperlunya.** `content-visibility: auto` pada kartu; virtualisasi grid saat katalog > 200 item; peta SMIL dijeda (`pauseAnimations`) saat keluar layar.
8. **Kode dipecah per rute.** Engine playground dan lab teknologi dimuat lazy. Font di-subset (Latin) dengan `font-display: swap`.
9. **Simulasi dihitung saat ada perubahan,** bukan per frame. Loop frame hanya menggerakkan titik visual.

### 10.3 Aksesibilitas (WCAG 2.2 AA)
- Kontras teks ≥ 4,5:1 di mode terang dan gelap. Kesulitan dibedakan oleh bentuk, bukan hanya warna.
- Seluruh fitur bisa dipakai dengan keyboard, termasuk playground lewat panel inspektur. Fokus selalu terlihat.
- Caption langkah diumumkan lewat `aria-live`. Daftar langkah menjadi alternatif teks animasi.
- `prefers-reduced-motion`: kereta peta disembunyikan, thumbnail diam, pemutar tidak autoplay.
- Target sentuh minimal 34×34 px (target 44 px di v1.1).

### 10.4 Lainnya
- Browser: dua versi terakhir Chrome, Edge, Firefox, Safari (desktop dan iOS).
- Privasi: tanpa akun, semua data di `localStorage` perangkat. Analitik tanpa cookie (Plausible atau PostHog dengan IP dianonimkan).
- Ketersediaan: situs statis di CDN, target uptime 99,9%.
- Bahasa: Indonesia saat MVP; struktur teks siap i18n (Inggris di v2.0).

## 11. Arsitektur teknis (rekomendasi)

| Lapisan | Pilihan | Alasan |
|---|---|---|
| Framework | **Astro** + island **Preact** (atau Svelte) | Katalog dan halaman pelajaran sebagian besar statis; hanya pemutar, pencarian, dan playground yang interaktif. JS awal tetap kecil. |
| Konten | Content Collections Astro + JSON Schema (Zod) | Validasi Scene JSON saat build; pelajaran rusak tidak bisa terbit. |
| Pencarian | MiniSearch di klien, indeks dibuat saat build | Cukup hingga ribuan pelajaran, tanpa server, typo-tolerant. |
| Engine animasi | Modul TypeScript sendiri (sekitar 300 baris, sudah dibuktikan di prototype) | Tidak perlu GSAP atau Lottie; formatnya spesifik untuk diagram. |
| Playground | Canvas 2D + modul simulasi murni (bisa diuji unit) | Performa stabil; logika simulasi terpisah dari render. |
| Lab teknologi | PGlite (Postgres WASM), emulator Redis di JS, simulator Kafka sendiri | Berjalan di browser, tanpa biaya server per pengguna. |
| Akun dan sinkron (v1.1) | Supabase (Auth + Postgres) | Magic link, Google login, row-level security. |
| Hosting | Cloudflare Pages atau Vercel | Situs statis di edge, preview per PR. |
| Kualitas | Vitest (simulasi, parser konten), Playwright (alur utama), Lighthouse CI (anggaran §10.1), axe-core | Anggaran performa dan aksesibilitas dicek di setiap PR. |
| Analitik | PostHog atau Plausible | Event tracking di §12, tanpa cookie. |

Struktur data lokal (MVP): `{ progress: {id: 0..1}, saved: [id], notes: {id: [{t, text}]}, quiz: {id: bool}, chal: {i: bool}, theme }`, satu kunci `localStorage`, semua akses dibungkus try/catch karena storage bisa diblokir.

## 12. Event analitik

| Event | Properti | Dipakai untuk |
|---|---|---|
| `lesson_open` | lesson_id, source (grid, map, search, next, direct) | Funnel, sumber penemuan |
| `lesson_step` | lesson_id, step, speed | Titik di mana pengguna berhenti |
| `lesson_complete` | lesson_id, duration_ms | North Star |
| `quiz_answer` | lesson_id, correct, attempt | Metrik pemahaman |
| `search` | query_length, results, clicked_rank | Kualitas pencarian (tidak menyimpan teks query mentah di MVP) |
| `filter_change` | category, level | Minat per topik |
| `save_toggle` | lesson_id, saved | Niat belajar ulang |
| `note_add` | lesson_id | Keterlibatan mendalam |
| `pg_open` | preset, source | Adopsi playground |
| `pg_change` | action (add, link, unlink, delete, capacity) | Pola eksperimen |
| `pg_challenge_complete` | challenge_id, time_ms, cost | Tingkat penyelesaian tantangan |
| `perf_vitals` | lcp, inp, cls, route | Pemantauan anggaran performa |

## 13. Desain dan sistem desain

Ringkasan (detail lengkap dan contoh hidup di halaman **Desain** pada prototype, rute `#/design`):

- **Konsep visual:** peta transit. Topik = garis berwarna, pelajaran = stasiun, kesulitan = bentuk stasiun. Konsep ini dipilih karena system design memang soal rute dan aliran, dan peta metro sudah dikenal sebagai cara membaca jalur yang rumit.
- **Warna dasar:** Paper `#EBEEF2`, Surface `#FFFFFF`, Sunk `#DFE4EA`, Ink `#17202B`, Ink 2 `#566274`. Mode gelap punya pasangan masing-masing.
- **Garis topik:** Fondasi `#2B6CE0`, Jaringan `#8350E8`, Penyimpanan `#0C9682`, Caching `#D48C06`, Messaging `#DB4157`, Skalabilitas `#3A963A`, Studi kasus `#5B6472`. Warna yang sama juga menandai tipe komponen di diagram.
- **Tipografi:** Overpass (turunan Highway Gothic, huruf rambu jalan) untuk semua teks; Overpass Mono untuk kode.
- **Radius:** 6 px (input), 10 px (thumbnail), 16 px (panel, player), pill (tombol, chip).
- **Gerak:** 120 ms (hover), 220 ms (pergantian state), 1.100 ms linear per hop paket, 6 detik per langkah.

## 14. Rencana rilis

Asumsi tim: 1 frontend engineer, 1 desainer/penulis konten paruh waktu, 1 reviewer materi.

| Minggu | Milestone | Kriteria selesai |
|---|---|---|
| 1–2 | Fondasi teknis | Repo Astro, design token, Scene JSON Schema, engine diagram porting dari prototype dengan unit test, CI dengan Lighthouse dan axe |
| 3–4 | Katalog dan pelajaran | Beranda, peta, filter, pencarian, halaman pelajaran, pemutar, kuis, catatan; 8 pelajaran Fondasi + Jaringan |
| 5–6 | Playground | Kanvas, inspektur keyboard, simulasi dengan unit test, 5 preset, 3 tantangan |
| 7 | Konten | 24 pelajaran lengkap dengan diagram unik dan review teknis |
| 8 | Beta tertutup | 30–50 penguji (mahasiswa + engineer), 5 sesi uji kegunaan, perbaikan |
| 9 | Rilis MVP publik | Semua KP §7 lolos, anggaran §10.1 lolos, analitik aktif |
| 10–14 | v1.1 | Akun + sinkron, Redis lab, SQL lab, 60 pelajaran, PWA |
| 15–22 | v2.0 | Kafka lab, simulasi per-request (p99), jalur kustom, bahasa Inggris |

## 15. Risiko dan mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Produksi konten lambat (setiap pelajaran butuh diagram + langkah + kuis) | Katalog tipis, retensi rendah | Format JSON yang sederhana, template per pola diagram, editor visual di v1.1, target 3 pelajaran per minggu |
| Simulasi playground dianggap "tidak akurat" oleh engineer senior | Kredibilitas turun | Label jelas "model untuk intuisi", dokumentasikan rumus, simulasi per-request di v2.0 |
| Animasi terlalu banyak membuat HP lambat | Pengguna utama (HP, 4G) pergi | Anggaran performa sebagai gerbang CI, uji di perangkat kelas menengah setiap sprint |
| Kesalahan teknis di materi | Pengguna belajar konsep yang salah | Review oleh engineer berpengalaman, tombol "Laporkan kesalahan" per langkah (v1.1) |
| Pengguna menonton tanpa memahami (pasif) | Metrik pemahaman rendah | Kuis wajib untuk status tuntas, tombol playground di setiap pelajaran, tantangan |
| `localStorage` dihapus atau diblokir | Progres hilang | Aplikasi tetap jalan tanpa storage; dorong login di v1.1 setelah 3 pelajaran tuntas |

## 16. Pertanyaan terbuka

1. Model bisnis: gratis sepenuhnya, freemium (lab teknologi berbayar), atau sponsor perusahaan untuk studi kasus?
2. Apakah narasi audio (TTS bahasa Indonesia) cukup penting untuk dimajukan ke MVP?
3. Apakah konten akan dibuka untuk kontribusi komunitas, dan bagaimana proses review-nya?
4. Domain dan merek: apakah nama "Alur" dipakai, dan apakah domainnya tersedia?
5. Perlu sertifikat penyelesaian jalur untuk keperluan CV?

## Lampiran A: Isi prototype

`prototype/index.html` adalah satu file HTML tanpa dependensi build (hanya Google Fonts) yang membuktikan keputusan desain dan performa di dokumen ini:

- **Beranda** (`#/`): peta belajar dengan kereta beranimasi, chip kategori, segmen kesulitan, pencarian, grid 24 kartu dengan thumbnail yang beranimasi saat disorot.
- **Pelajaran** (`#/l/c1`): pemutar langkah, timeline bersegmen, kecepatan, keyboard, tab Penjelasan/Kuis/Catatanku, panel "Berikutnya di jalur".
- **Playground** (`#/playground`): kanvas, palet, preset, slider trafik, metrik, saran bottleneck, 3 tantangan, inspektur keyboard.
- **Disimpan** (`#/saved`) dan **Desain** (`#/design`): daftar simpanan dan dokumentasi sistem desain.
- Mode terang/gelap, `prefers-reduced-motion`, dan self-test simulasi via `console.assert` saat halaman dimuat.
