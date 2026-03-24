# Layar Diff - Lampu Hijau untuk Pengembang

Gamedev AI menulis kode secara asinkron. Ini berarti bahwa saat Anda sedang membaca log di mesin, ia sedang menulis ulang file Anda dan mengedit lusinan instance.
Tapi tunggu dulu, mengizinkan robot menulis secara otomatis ke hard drive Anda — bukankah itu merusak fondasi kreatif pengembang?

Tidak! *Layar diff hadir justru untuk melindungi pekerjaan dan proyek Anda dari kerusakan yang tidak disengaja.*

Plugin Gamedev AI mengimplementasikan jendela "pratinjau perubahan yang aman", yang mirip dengan tampilan kontrol versi yang terkenal di VSCode atau GitHub/GitLens.

## Bagaimana Diff Dihasilkan
1. Saat meminta untuk membuat atau memperbaiki `EnemyAttack.gd`, log akan menunjukkan progres penulisan ulang data kelas...
2. Akan ada suara "ting" visual dan segera sebuah **tab diff gelap** akan muncul mengisi layar chat, dengan [Original Code] di sisi [New Code Changes].
3. **[color=red]Garis Merah -[/color]** Mewakili baris yang dihapus secara cerdas dari sumbernya.
4. **[color=green]Garis Hijau +[/color]** Mewakili penambahan baru yang dilakukan oleh AI.

## Menerapkan atau Melewatkan (Kekuatan Penolakan)

Di akhir diff (gulir ke bawah atau analisis dengan tenang), tombol perlindungan penting muncul:
* **"Apply Changes":** Gamedev AI akan menggunakan agen riwayat Undo/Redo resmi dari Godot Engine dan memodifikasi skrip target yang sebenarnya. Jika Anda menekan `Ctrl + Z` di skrip, Anda akan kembali ke status sebelum campur tangan AI.
* **"Skip":** Tidak suka dengan ide AI setelah meninjau diff? Tekan "Skip". Tidak ada baris yang akan diubah (bahkan di cache), tidak ada kerugian teknis, hanya beberapa *token* yang terpakai.

> _(Bayangkan cara kerja diff dalam praktik:)_

![Jendela diff yang menunjukkan kode yang dihapus dalam warna merah dan kode yang ditambahkan dalam warna hijau dengan tombol Apply dan Skip](../../images/diff_preview.png)
