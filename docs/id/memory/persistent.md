# Memori Persisten (AI sebagai Arsitek)

Jika indexing (Codebase) mengajarkan AI **"di mana"** setiap file sumber yang diproses oleh Godot berada, maka memori persisten mengajarkannya **"mengapa"** hal-hal tersebut diprogram dengan cara tertentu.

Pengembang indie dan studio kecil sering kali menderita saat membuka kembali proyek setelah berminggu-minggu. *Mengapa kelas penyimpanan game diimplementasikan dalam format biner dan bukan JSON? Mengapa saya menggunakan CharacterBody2D sebelum kemudian berubah pikiran?*

## Tombol "Summarize to Memory"

Di bagian atas tab tengah panel chat `(di sebelah tombol History)` terdapat tombol ajaib **💾 Summarize to Memory**.

Setiap kali Anda memiliki sesi yang panjang, melelahkan, dan kompleks dengan AI (contoh: refaktorisasi penuh pada fisika mobil), lakukan hal berikut:
1. Di akhir hari, klik **Summarize to Memory**.
2. AI akan membaca dengan cermat semua yang telah dibaca dan didiskusikan.
3. Ia akan membuat file permanen dalam format *Memory Log* di folder tidak terlihat `.gamedev_ai` pada proyek Anda.
4. Saat Anda membuka proyek 3 minggu kemudian untuk memperbaiki bug pada fisika mobil, AI akan dengan cerdik mengeluarkan alasan mengapa Anda tidak menggunakan "Friction" standar Godot, tanpa Anda harus membuka 40 jendela chat lama untuk mengingatnya.

*Dengan ini, plugin Godot menjadi dokumenter studio dan kepala insinyur perangkat lunak Anda.*
