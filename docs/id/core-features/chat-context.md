# Chat, Lampiran, dan Konteks (Context)

Chat bukan sekadar ChatGPT bawaan di jendela kanan editor. Ia adalah "alat pernapasan" nyata antara **file proyek Anda** dan **otak AI**.

## Pentingnya "Konteks" (Membaca Kode Anda Saat Ini)

AI tidak dapat melihat layar Anda dan tidak tahu apa yang sedang Anda program saat ini — *kecuali Anda memintanya untuk melihat!*

Di bawah bar *"Send"*, Anda akan melihat kotak centang penting bernama **Context**.
1. **Terpilih (Default):** Gamedev AI secara diam-diam akan menyalin setiap baris, setiap karakter dari skrip skrip (`.gd`) di mana mouse Anda berada. Informasi ini akan dikirim bersama pertanyaan Anda!
2. **Tidak Terpilih:** Menghemat token konteks pada model berbayar (OpenAI). Ajukan pertanyaan cepat tanpa ia harus membaca kode, persis seperti ChatGPT biasa. Gunakan ini untuk pertanyaan terisolasi yang tidak memerlukan konteks mesin.

## 📸 Tangkapan Layar (Auto-Screenshot)

Tepat di sebelah switch konteks, terdapat switch **Screenshot**. Fungsi ini memungkinkan AI untuk secara harfiah "melihat" apa yang terjadi di layar Godot.

### Cara Kerjanya
1. Aktifkan switch **"Screenshot"** di bar bawah chat.
2. Pesan berikutnya yang Anda kirim akan disertai dengan **tangkapan layar otomatis** dari seluruh jendela editor Godot.
3. AI akan menerima gambar lengkap dan dapat melakukan analisis visual: scene 2D/3D yang terbuka, Scene Tree, Inspector, Output, dan panel lain yang terlihat.

### Kapan Menggunakannya
- **UI yang Rusak:** Antarmuka game Anda tidak sejajar dan Anda tidak tahu Label atau Container mana yang bermasalah? Aktifkan tangkapan layar dan kirim "apa masalah pada tata letak ini?", dan AI akan menganalisis node secara visual.
- **Scene Tree yang Kompleks:** Anda ingin AI memahami bagaimana hierarki node Anda disusun tanpa harus menulis deskripsinya secara manual.

::: tip Tips
AI juga memiliki alat `capture_editor_screenshot` yang dapat ia panggil sendiri kapan saja selama obrolan jika ia merasa perlu "melihat" editor.
:::

## Tombol "Plan First"

Kesalahan yang sangat umum adalah meminta AI untuk membuat seluruh logika RPG besar sekaligus. Plugin ini memungkinkan Anda mengontrol antusiasme berlebih robot tersebut dengan mengaktifkan **Plan First**.

![Switch Plan First diaktifkan dan tombol Execute Plan terlihat](../../images/plan_first.png)

* **Aktif:** Plugin akan mengirimkan instruksi yang ketat. *AI tidak akan menghasilkan kode*. Ia akan menjawab dengan daftar bernomor Markdown berisi elemen-elemen (kelas, nama, fungsi utama) yang akan diubah.
* Setelah meninjau dan mengonfirmasi rencana tersebut, klik **"Execute Plan"** yang akan muncul secara otomatis. Baru setelah itu AI akan mulai bekerja sesuai rencana.

## Lampiran dan Node yang Ditarik (Drag)

Perlu menganalisis bagaimana Sprite2D dibuat atau mengapa scene `Player.tscn` tidak bertabrakan dengan `Ground` RigidBody3D?

Gamedev AI mendukung Drag & Drop. Tidak perlu membuang waktu membuka setiap tab di inspektor yang menimbulkan rasa ingin tahu atau bug visual...

![File yang dilampirkan ke bidang chat melalui drag and drop](../../images/drag_and_drop.png)

1. **Scene Tree:** Klik pada sebuah node di scene Anda dan tarik ke panel logika. AI akan menggunakan pintasan untuk menganalisis semua metadata node (mode tersembunyi, instance, collision layers...) dan memahami mengapa friction vector sepertinya tidak berfungsi.
2. **📎 Tombol Attach:** Gunakan ini untuk memasukkan gambar (`.png` untuk UI yang ada bug), arsip file mentah (`.json`), dan snapshot lengkap dari skrip panjang (meskipun indexing vektor adalah metode yang paling profesional).

---

## 🎙️ Text-to-Speech (TTS)

Gamedev AI memiliki **pemutar voice-over** bawaan yang dapat mengubah jawaban AI menjadi suara. Ini memungkinkan Anda untuk terus memprogram sambil mendengarkan jawaban, tanpa harus menghentikan pekerjaan untuk membaca teks yang panjang.

![Pemutar TTS ringkas dengan kontrol pemutaran dan kecepatan](../../images/tts_player.png)

### Cara Menggunakan
1. Setelah jawaban AI di chat, klik tombol **"▶ Read Aloud"** (terletak tepat di bawah area chat).
2. Plugin akan mengirimkan permintaan sintesis suara dari teks jawaban terakhir.
3. Pemutar audio ringkas akan muncul dengan semua kontrol:

| Kontrol | Fungsi |
|----------|--------|
| **▶ Read Aloud** | Memulai voice-over. |
| **⏹ (Stop)** | Segera menghentikan pemutaran. |
| **Bilah Progres** | Memungkinkan Anda menarik slider untuk maju atau mundur dalam voice-over. |
| **Kecepatan (1.0x hingga 2.0x)** | Mengontrol kecepatan voice-over. Gunakan 1.5x atau 2.0x untuk mendengarkan lebih cepat. |

### Kapan Ini Berguna
- **Jawaban Panjang:** Apakah AI menjelaskan 3 paragraf tentang cara kerja `NavigationAgent3D`? Dengarkan instruksinya sambil Anda mengatur node di Scene Tree.
- **Aksesibilitas:** Bagi pengembang yang lebih suka belajar dengan mendengarkan atau yang memiliki kesulitan membaca teks panjang di layar.
- **Peninjauan Pasif:** Minta AI membacakan rencana refaktorisasi saat Anda pergi mengambil kopi!

::: info Catatan
Fitur TTS menggunakan API dari provider yang Anda konfigurasi untuk menghasilkan suara. Audio disimpan dalam cache, sehingga menjeda dan melanjutkan tidak akan memakan token tambahan.
:::

---

## ⚡ Tindakan Cepat (Quick Actions)

Tepat di bawah area chat (dan di atas bidang teks), terdapat **5 tombol tindakan cepat** yang berfungsi sebagai pintasan cerdas. Tombol-tombol ini secara otomatis mengirimkan prompt yang telah dikonfigurasi sebelumnya bersama dengan kode yang Anda pilih di editor skrip Godot.

### Cara Kerjanya
1. Buka **skrip apa pun** (`.gd`) di editor kode Godot.
2. Gunakan mouse atau keyboard untuk **memilih bagian kode** (seperti fungsi lengkap, blok `if`, atau beberapa baris).
3. Klik salah satu **tombol** berikut:

### 5 Tombol

| Tombol | Prompt yang Dikirim | Apa yang Dilakukan AI |
|-------|---------------|----------------|
| **✧ Refactor** | "Refactor this code" | Menganalisis bagian yang dipilih dan menyarankan versi yang lebih bersih dan efisien mengikuti praktik terbaik GDScript. |
| **◆ Fix** | "Fix errors in this code" | Mencari bug, kesalahan sintaksis, tipe yang salah, atau masalah logis di bagian tersebut dan menghasilkan perbaikan melalui Diff. |
| **💡 Explain** | "Explain what this code does" | Menjelaskan baris demi baris fungsi kode dalam bahasa Indonesia — cocok untuk belajar atau dokumentasi. |
| **↺ Undo** | *(Tindakan Langsung)* | Membatalkan tindakan terakhir AI di proyek (menggunakan sistem Undo/Redo asli Godot). Tidak memerlukan prompt. |
| **🖥 Fix Console** | *(Membaca Output)* | Membaca kesalahan merah terbaru dari konsol output Godot dan mengirimkannya langsung ke AI untuk diagnosis dan perbaikan. |

### Contoh Penggunaan "Fix Console"
1. Anda menjalankan game melalui Godot (`F5`).
2. Game crash dengan kesalahan merah: `Attempt to call function 'die' in base 'null instance'`.
3. Tidak perlu menyalin apa pun, cukup klik **🖥 Fix Console**.
4. AI akan membaca log output sendiri, menemukan skrip yang bermasalah, dan menyarankan perbaikan dalam Diff yang aman.

::: tip Tips
Tombol **"Fix Console"** berbeda dengan **"Watch Mode"**. Konsol memerlukan klik manual, sementara "Watch Mode" jika diaktifkan akan bekerja secara otomatis di latar belakang.
:::
