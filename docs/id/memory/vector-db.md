# Mengindeks Kode Anda (Analytical Mind)

Salah satu hal paling berharga tentang Gamedev AI, yang membuatnya sama sekali berbeda dari solusi ChatGPT biasa atau asisten pemrograman lainnya, adalah pemahamannya yang mendalam tentang struktur pengembangan game Anda.

Jika "konteks terbuka" adalah mata AI saat ini, maka **Index Codebase** adalah jaringan saraf yang tersembunyi dari robot tersebut.

## Apa itu Indeks Vektor (Vector DB)?

Karena bekerja dengan mesin sebesar Godot, banyak kelas kustom (seperti `PlayerStats`, `InventoryManager`, `WeaponBuilder`) bukanlah bagian dari referensi GDScript klasik yang dipelajari AI bertahun-tahun lalu di OpenAI. Kelas-kelas ini dibuat oleh **Anda**.

Menyalin skrip `PlayerStats` ke dalam chat setiap kali Anda mengajukan pertanyaan tentang inventaris (Inventory) menghabiskan ribuan token tambahan dan waktu yang berharga. Melalui indexing DB (pencarian vektor), hal ini sudah menjadi masa lalu.

### Menggunakan Pengindeksan (Tombol Pengaturan)
1. Buka panel Gamedev AI dan klik pada tab pengaturan konteks tersembunyi di bagian atas dengan ikon roda gigi ("⚙️ Settings" di sudut bawah).
2. Gulir ke bawah panel pengaturan untuk membuka jendela **Vector Database**.
3. Klik pada **🔍 Scan Changes**. Plugin akan memeriksa semua nama file di hard drive Anda untuk mencari penghapusan atau perubahan yang tidak terdaftar.
4. *File List* yang terlihat akan terisi dengan warna yang mencerminkan penambahan penting dan file lama yang tidak berubah. Jika ada perbedaan dari pengindeksan final terakhir:
5. Terakhir, klik pada **⚡ Index Database**.

Ini akan memicu mode indexing yang tidak terlihat melalui Gemini Text-Embedding API. Di akhir proses, jaringan semantik RAG JSON akan disimpan secara lokal di hard drive Anda di dalam file `.gamedev_ai/vector_db.json` dalam format terenkripsi.

Sekarang coba di chat:
* *"Bagaimana cara memperbaiki bug di inventaris?"*

AI akan menjawab: *"Oh, saya perhatikan berdasarkan skrip di `res://src/player_inventory.gd` dan panggilan di `Network.gd` bahwa kelas-kelas tersebut tidak selalu terhubung. Saya akan memperbaikinya."*

[**Langkah Selanjutnya: Pahami 25 file "Skills" yang membantu sistem RAG** ➔](./skills.md)
