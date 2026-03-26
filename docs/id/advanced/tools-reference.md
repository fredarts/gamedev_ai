# Semua Alat AI (Tool Reference)

Gamedev AI memiliki **34 alat bawaan** yang dapat dipanggil oleh AI secara mandiri selama percakapan. Alat-alat ini adalah "lengan mekanis" yang memungkinkan AI berinteraksi langsung dengan Godot Engine, dan masing-masing dijelaskan di bawah ini berdasarkan kategori.

## 🔧 Skrip (Pembuatan dan Pengeditan Kode)

### `create_script`
Membuat file GDScript baru (`.gd`) di jalur yang ditentukan dengan isi yang diberikan. AI menggunakan alat ini untuk menghasilkan skrip dari awal.
- **Parameter:** `path` (res://...), `content` (kode GDScript lengkap)

### `edit_script`
Mengganti seluruh isi skrip yang ada dengan versi baru. AI membaca file terlebih dahulu untuk memastikan ia memiliki versi terbaru.
- **Parameter:** `path`, `content`
- ⚠️ *Sekarang lebih jarang digunakan demi `patch_script` untuk perbaikan lokal yang kecil.*

### `patch_script`
Pengeditan bedah (Surgical Edit): mencari blok kode tertentu di dalam skrip dan hanya mengganti bagian tersebut dengan konten baru, tanpa menulis ulang seluruh file. Ideal untuk perbaikan kecil.
- **Parameter:** `path`, `search_content` (blok tepat untuk dicari), `replace_content` (blok baru)

### `replace_selection`
Mengganti teks yang saat ini dipilih di editor skrip Godot. Bekerja bersama dengan tombol tindakan cepat (Refactor, Fix, Explain).
- **Parameter:** `text` (kode baru untuk mengganti pilihan)

### `view_file_outline`
Mengembalikan struktur skrip tanpa kode lengkap: `class_name`, `extends`, fungsi, signal, ekspor, enum, inner classes, dan konstanta beserta nomor barisnya.
- **Parameter:** `path`

---

## 🌳 Node (Berkerja dengan Scene Tree)

### `add_node`
Menambahkan node baru ke scene yang saat ini terbuka di editor. Bisa membuat tipe node Godot apa pun (Node2D, CharacterBody3D, Label, Button, dll.).
- **Parameter:** `parent_path` (gunakan `.` untuk akar/root), `type` (kelas node), `name`, `script_path` (opsional)

### `remove_node`
Menghapus node dari scene tree saat ini. Memerlukan konfirmasi pengguna karena ini adalah tindakan destruktif.
- **Parameter:** `node_path`

### `set_property`
Menetapkan properti (Property) dari node scene (Position, Size, Text, Color, dll.). Menerima angka, vektor, warna, dan teks.
- **Parameter:** `node_path`, `property`, `value`

### `set_theme_override`
Menetapkan penimpaan tema (Theme Override) pada node kontrol Control (ukuran font, warna font, gaya).
- **Parameter:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Menghubungkan signal dari node sumber ke metode dari node tujuan di scene saat ini.
- **Parameter:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (opsional), `flags` (opsional)

### `disconnect_signal`
Memutuskan hubungan signal yang sebelumnya ditetapkan antara dua node.
- **Parameter:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Melampirkan file GDScript yang sudah ada ke sebuah node di scene.
- **Parameter:** `node_path`, `script_path`

### `analyze_node_children`
Memberikan dump mendetail dari hierarki anak dari node tertentu di scene yang sedang diedit. Berguna untuk mempelajari struktur yang dalam.
- **Parameter:** `node_path`, `max_depth` (default: 5)

---

## 📂 File dan Proyek

### `read_file`
Membaca konten lengkap dari file proyek apa pun.
- **Parameter:** `path`

### `list_dir`
Menampilkan isi dari direktori proyek.
- **Parameter:** `path`

### `find_file`
Mencari file proyek berdasarkan nama (bisa pencocokan parsial).
- **Parameter:** `pattern`

### `remove_file`
Menghapus file atau direktori dari proyek. Memerlukan konfirmasi.
- **Parameter:** `path`

### `move_files_batch`
Memindahkan beberapa file/direktori atau mengubah namanya dalam satu operasi batch. Secara otomatis memperbarui semua referensi internal Godot (`.tscn`, `.tres`).
- **Parameter:** `moves` (kamus yang menghubungkan jalur lama ke jalur baru)

### `create_scene`
Membuat file scene baru (`.tscn`) dan membukanya di editor.
- **Parameter:** `path`, `root_type`, `root_name`

### `instance_scene`
Meng-instance scene `.tscn` yang sudah ada sebagai anak dari node lain di scene saat ini.
- **Parameter:** `parent_path`, `scene_path`, `name`

### `create_resource`
Membuat file sumber daya baru (`.tres`). Berguna untuk aset seperti item, statistik, atau konfigurasi pengguna.
- **Parameter:** `path`, `type`, `properties` (opsional)

---

## 🔍 Pencarian dan Analisis

### `grep_search`
Mencari teks di dalam file proyek. Mengembalikan baris yang ditemukan beserta jalur dan nomor barisnya.
- **Parameter:** `query`, `include` (filter ekstensi, opsional), `max_results` (default: 20)

### `search_in_files`
Mencari variabel, fungsi, atau logika tertentu melalui Regex di semua file `.gd` di proyek.
- **Parameter:** `pattern` (ekspresi reguler)

### `get_class_info`
Memberikan informasi mendetail tentang kelas Godot (mesin atau kustom): kelas dasar, properti, metode, dan signal.
- **Parameter:** `class_name`

### `capture_editor_screenshot`
Mengambil tangkapan layar dari seluruh jendela editor Godot dan secara otomatis melampirkannya ke permintaan berikutnya untuk analisis visual.

---

## 🧠 Memori dan Pengetahuan

### `save_memory`
Menyimpan fakta permanen di memori proyek yang akan tersedia di semua sesi obrolan mendatang.
- **Parameter:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Menampilkan daftar semua fakta permanen yang disimpan untuk proyek ini.

### `delete_memory`
Menghapus fakta memori tertentu berdasarkan ID-nya.
- **Parameter:** `id`

### `read_skill`
Membaca file dokumentasi keahlian dari perpustakaan internal AI untuk mempelajari praktik terbaik sebelum memprogram.
- **Parameter:** `skill_name`

---

## 🗄️ Basis Data Vektor (RAG)

### `index_codebase`
Mengindeks seluruh proyek (`.gd`) ke dalam basis data vektor lokal untuk pencarian semantik. Harus dilakukan sebelum menggunakan `semantic_search`.

### `semantic_search`
Melakukan pencarian vektor semantik pada basis data yang telah diindeks, mencari potongan kode yang relevan berdasarkan makna dan bukan hanya pencocokan teks yang tepat.
- **Parameter:** `query`

---

## 🧪 Pengujian (Tests)

### `run_tests`
Menjalankan skrip atau perintah pengujian. Berguna untuk memeriksa perubahan dengan GUT, GdUnit4, atau skrip pengujian khusus.
- **Parameter:** `test_script_path` (opsional)

---

## 🛡️ Audit (Auditing)

### `audit_scene`
Melakukan audit arsitektural pada scene yang sedang dibuka, mencari node yatim (orphan), skrip yang hilang, atau peringatan performa.

### `audit_script`
Melakukan audit analisis statis pada file GDScript tertentu untuk menangkap praktik buruk, bug potensial, atau peringatan sintaksis.
- **Parameter:** `path`
