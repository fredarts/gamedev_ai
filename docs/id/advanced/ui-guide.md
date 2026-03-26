# Panduan UI Lengkap (Semua Tombol)

Halaman ini menjelaskan **setiap tombol, sakelar, dan kontrol** di dalam antarmuka Gamedev AI di dalam editor Godot.

![Ikhtisar antarmuka utama Gamedev AI di Godot](../../images/main_interface.png)

## 🗂️ Tab Utama (Main Tabs)

Plugin ini memiliki **3 tab** di bagian atas panel:
- **Chat** — panel utama interaksi dengan AI.
- **Settings** — manajemen kunci API, preset, prompt, dan indexing.
- **Git** — kontrol versi GitHub terintegrasi asli.

---

## 💬 Tab Chat (Chat Tab)

### Bar Atas (Top Bar)
| Tombol | Fungsi |
|-------|--------|
| **Preset Selector** | Menu dropdown untuk beralih cepat di antara berbagai pengaturan provider/model (contoh: "Gemini 3.1", "GPT-4o"). |
| **A-** / **A+** | Mengurangi atau menambah ukuran font di chat. |
| **+ New Chat** | Menghapus chat saat ini dan memulai sesi baru yang benar-benar bersih. |
| **⊙ History** | Daftar dropdown semua percakapan lama. Klik pada salah satu percakapan untuk mengembalikan konteks lengkap sesi tersebut. |
| **💾 Summarize to Memory** | Mengirimkan permintaan otomatis ke AI untuk merangkum keputusan arsitektural percakapan saat ini dan menyimpannya di memori persisten proyek. |

### Area Chat (OutputDisplay)
- Menampilkan pesan yang diformat dengan BBCode dengan **teks tebal**, *miring*, `kode dalam baris`, dan penyorotan sintaksis untuk blok kode.
- Tautan yang dapat diklik ke file proyek (terbuka di editor saat diklik).
- Tombol **Copy** melayang muncul saat mengarahkan kursor ke teks untuk penyalinan cepat.

### Pemutar TTS (Text-to-Speech)

![Pemutar TTS ringkas dengan kontrol pemutaran](../../images/tts_player.png)

| Kontrol | Fungsi |
|----------|--------|
| **▶ Read Aloud** | Mengonversi jawaban AI terakhir menjadi suara dan memutarnya. Sangat cocok untuk mendengarkan penjelasan sambil memprogram. |
| **⏹ Stop** | Menghentikan pemutaran audio. |
| **Bilah Progres** | Untuk memajukan atau memundurkan audio. |
| **Kecepatan (1.0x - 2.0x)** | Mengontrol tempo pemutaran. |

### Tombol Tindakan Cepat (Quick Action Buttons)
| Tombol | Apa yang Dilakukan |
|-------|-----------|
| **✧ Refactor** | Mengirimkan kode yang dipilih di editor dengan permintaan "Refactor this code". AI menganalisis dan menyarankan peningkatan struktural. |
| **◆ Fix** | Mengirimkan kode yang dipilih dengan permintaan "Fix errors in this code". AI mengidentifikasi kesalahan dan menghasilkan perbaikan. |
| **💡 Explain** | Mengirimkan kode yang dipilih dengan permintaan "Explain what this code does". AI menjelaskan setiap bagian dalam bahasa Indonesia. |
| **↺ Undo** | Membatalkan tindakan terakhir AI di proyek (menggunakan sistem Undo/Redo di Godot). |
| **🖥 Fix Console** | Membaca kesalahan merah terbaru dari konsol output Godot dan mengirimkannya langsung ke AI untuk saran perbaikan. |

### Area Input (Input Area)
| Elemen | Fungsi |
|----------|--------|
| **Bidang Teks** | Ketik pesan Anda. Tekan `Shift + Enter` untuk mengirim. |
| **📎 Attach** | Membuka jendela pemilihan file untuk melampirkan gambar, skrip, atau file apa pun ke permintaan. |
| **➤ Send** | Mengirimkan pesan ke AI untuk diproses. |
| **Drag & Drop** | Tarik node dari scene tree atau file dari filesystem langsung ke bidang teks atau area chat. AI akan menerima metadata lengkap. |

### Pengaturan Prompt (Dropdown)
Opsi-opsi ini dikelompokkan di bawah ikon ⚙️ di sebelah tombol kirim.

| Pengaturan | Fungsi |
|-----------|--------|
| **Sertakan Konteks (Include Context)** | Saat diaktifkan, plugin secara otomatis melampirkan seluruh isi skrip yang sedang terbuka di editor ke pesan yang dikirim. |
| **Kirim Screenshot (Send Screenshot)** | Saat diaktifkan, plugin secara otomatis mengambil tangkapan layar jendela Godot dan mengirimkannya bersama pesan untuk analisis visual AI. |
| **Rencanakan Terlebih Dahulu (Plan First)** | Saat diaktifkan, AI tidak akan langsung menulis kode. AI hanya akan membalas dengan rencana Markdown terperinci. Setelah diperiksa, klik tombol "Execute Plan" untuk mulai mengkode. |
| **Watch Mode (Mode Pantau)** | Saat diaktifkan, AI secara otomatis memantau konsol output Godot. Jika mendeteksi kesalahan kritis, AI akan mengusulkan perbaikan secara otomatis. |

---

## ⚙️ Tab Pengaturan (Settings Tab)

### Manajemen Preset (Presets)
| Elemen | Fungsi |
|----------|--------|
| **Preset Selector** | Menu dropdown untuk memilih preset yang tersimpan. |
| **Add** | Membuat preset baru yang kosong. |
| **Edit** | Membuka panel pengeditan (Nama, Provider, Kunci API, URL Dasar, Model). |
| **Delete** | Menghapus preset terpilih secara permanen. |
| **Done Editing** | Menutup panel pengeditan dan menyimpan perubahan. |

### Bidang Pengeditan Preset
| Bidang | Deskripsi |
|-------|-----------|
| **Preset Name** | Nama identitas (contoh: "Gemini 3.1 Free"). |
| **Provider** | Pilihan antara "Gemini" dan "OpenAI / OpenRouter". |
| **API Key** | Kunci API dari provider terpilih. |
| **Base URL** | URL dasar API (hanya untuk OpenAI/OpenRouter). |
| **Model Name** | Nama tepat model (contoh: `gemini-2.5-flash`, `gpt-4o`). |

### Bahasa (Language)
| Elemen | Fungsi |
|----------|--------|
| **Language Selector** | Menu dropdown untuk memilih bahasa antarmuka dan tanggapan AI (Indonesia, Português BR, English, dll.). |

### Custom System Prompt (Instruksi Kustom)
Bidang teks besar untuk aturan tetap yang ingin Anda agar AI selalu ikuti. Contoh: *"Gunakan pengetikan statis di semua fungsi. Beri komentar dalam bahasa Indonesia."*

| Tombol | Fungsi |
|-------|--------|
| **✨ Enhance Instructions with AI** | Mengirimkan instruksi saat ini ke AI untuk ditingkatkan secara otomatis (detail teknis, praktik terbaik). Pratinjau sebelum diterima. |

### Basis Data Vektor (Vector Database)
| Elemen | Fungsi |
|----------|--------|
| **File List** | Daftar visual semua file `.gd` di proyek beserta status pengindeksannya. |
| **🔍 Scan Changes** | Memindai proyek untuk file baru, yang diubah, atau dihapus sejak pengindeksan terakhir. |
| **⚡ Index Codebase** | Meluncurkan proses pengindeksan vektor dari semua skrip yang diubah melalui Embeddings API. |

---

## 🐙 Tab Git (Git Tab)

### Konfigurasi Awal
| Elemen | Fungsi |
|----------|--------|
| **Initialize Repository** | Menginisialisasi repositori Git di folder proyek (jika belum ada). |
| **Remote URL** | Bidang untuk menempelkan URL repositori GitHub (contoh: `https://github.com/user/repo.git`). |
| **Set Remote** | Menetapkan URL repositori jarak jauh. |

### Operasi Utama
| Tombol | Fungsi |
|-------|--------|
| **🔃 Refresh Status** | Memperbarui status Git (file yang diubah/tidak dilacak, branch saat ini). |
| **⬇️ Pull** | Mengunduh perubahan terbaru dari repositori jarak jauh. |
| **✨ Auto-Generate Commit Message** | AI menganalisis semua diff dan secara otomatis menghasilkan pesan commit profesional. |
| **Commit & Sync (Push)** | Membuat commit untuk semua perubahan dengan sebuah pesan dan mengirimkannya ke GitHub. |

### Branch (Cabang)
| Elemen | Fungsi |
|----------|--------|
| **Branch Label** | Menampilkan nama branch saat ini. |
| **Branch Name Input** | Bidang untuk menulis nama branch baru atau yang sudah ada. |
| **Checkout/Create Branch** | Membuat branch baru atau beralih ke yang sudah ada. |

### Tindakan Darurat
| Tombol | Fungsi |
|-------|--------|
| **⚠️ Undo Uncommitted Changes** | Membatalkan semua perubahan lokal yang belum di-commit (kembali ke commit terakhir). Memerlukan konfirmasi. |
| **⚠️ Force Pull Overwrite** | Membersihkan sepenuhnya dan menimpa folder lokal Anda dengan status tepat dari cloud. Memerlukan konfirmasi. |
| **⚠️ Force Push** | Menimpa riwayat repositori jarak jauh dengan versi lokal. Gunakan dengan sangat hati-hati! |

---

## 📋 Panel Diff (Peninjauan Kode)

Saat AI menghasilkan atau mengubah kode, panel perbandingan akan muncul di chat:

![Panel diff yang menunjukkan kode yang dihapus (merah) dan kode yang ditambahkan (hijau)](../../images/diff_preview.png)

| Elemen | Fungsi |
|----------|--------|
| **Diff View** | Tampilan baris yang dihapus (merah) dan ditambahkan (hijau) secara berdampingan. |
| **Apply Changes** | Menerima perubahan dan menerapkannya pada file nyata. Tindakan ini dicatat dalam Undo/Redo di Godot. |
| **Skip** | Menolak perubahan. Tidak ada file yang dimodifikasi. |
