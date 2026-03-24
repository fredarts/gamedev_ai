# Custom System Prompt (Instruksi Sistem Kustom)

Terkadang proyek studio memiliki aturan yang ketat, dan kita tidak ingin AI membuat keputusan umum untuk semua kode yang dihasilkan. Bagaimana Anda bisa membentuk perilaku "mental" default dari Gamedev AI?

## Panel "Custom Instructions"

Panel ini terletak di tab tersembunyi **Settings**, di bawah kolom provider "API Key".
Di sana terdapat bidang teks besar untuk input bebas bernama **Custom Instructions (appended to system prompt)**.

![Panel pengaturan yang menunjukkan area instruksi kustom](../../images/settings_ui.png)

Saat AI "berpikir", instruksi yang disimpan di sana dibaca sebagai aturan global nomor 1 sebelum menjawab Anda.

### Contoh isi dari bidang ini:
* *"Tolong jangan berikan penjelasan panjang atau salam, cukup tampilkan jendela Diff yang terfokus."*
* *"Semua proyek Godot di studio ini mengikuti konvensi Clean Code. Metode harus dimulai dengan huruf kecil bahasa Inggris dan node scene harus dalam PascalCase. Gunakan pengetikan statis (Static Typing) secara ketat di semua fungsi yang dibuat (: String, : int, -> void)."*
* *"Saya melarang penggunaan _process(). Saya ingin Anda fokus pada arsitektur yang berat pada sinyal (Signals) demi performa."*

Berkat ini, Gamedev AI menjadi pengembang yang dilatih khusus oleh direktur teknis (Anda) dan membuat kode dalam gaya yang disetujui tim Anda, alih-alih mengikuti sintaks umum dari LLM.
