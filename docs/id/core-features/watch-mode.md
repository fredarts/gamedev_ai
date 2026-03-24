# Watch Mode (Keajaiban Auto-Fixing)

Sebagai Game Developer (Gamedev), Anda menghabiskan **30% waktu Anda untuk membuat logika game yang hebat** dan **70% waktu yang menyiksa di tab `Debugger / Output` khusus Godot** untuk memecahkan kode kesalahan sintaksis merah dan pengecualian referensi null.

Fitur **Watch Mode** di Gamedev AI menghapus langkah debugging manual yang membosankan ini. Ia mengubah robot menjadi insinyur QA tak terlihat yang bekerja di ruangan sebelah untuk Anda.

## Mengapa dan Bagaimana Mengaktifkannya?
Di bagian bawah panel chat, aktifkan switch bernama **[x] Watch Mode**.

Apa yang terjadi di latar belakang:
1. Anda menekan `F5` di Godot (Run Scene / Debug Project).
2. Pemain Anda bertabrakan dengan `Area2D` yang lupa Anda inisialisasi `NodeGroup`-nya. Mesin crash dan memberikan teks merah fatal di output ("Attempt to call function 'die' in base 'null instance'").
3. Tanpa harus mengeklik apa pun atau menyalin teks, Gamedev AI akan *terbangun*, membaca 50 blok terakhir log kesalahan sintaksis konsol, mengumpulkan file yang diindeks yang mencurigakan, membuat dugaan tentang kegagalan referensi, dan segera mengirimkan **solusi dalam bentuk penulisan ulang Diff** atau penjelasan langkah demi langkah tentang di mana node yang bermasalah berada.

## Ambang Batas (Threshold) dan Periode Pendinginan (Cooldown)

Asisten yang terlalu aktif dapat membakar akun model berbayar dengan mengirimkan duplikat "Orphan Warnings" dari Godot Engine (peringatan kuning sepele yang sebenarnya tidak merusak apa pun).

Untuk mengelola dompet dan alur kerja Anda, Gamedev AI membatasi pemantauan melalui **periode pendinginan dinamis**:
* Ia akan aktif saat log melaporkan **tiga** output kritis pertama dalam segmen 30 detik, atau terkadang menunggu dalam mode `Stand-by` lebih lama.

*Menjaga mesin dengan membaca saran otonom menjadi semudah permainan anak-anak.*
