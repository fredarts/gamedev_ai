# Instalasi (Installation)

Selamat datang di dokumentasi resmi **Gamedev AI**! Halaman ini memandu Anda untuk menambahkan asisten dengan cepat ke dalam proyek Godot 4.6 Anda saat ini.

## Persyaratan (Prerequisites)
* **Godot Engine:** Versi 4.6 atau lebih tinggi (tidak memerlukan dukungan `.gdextension` asli, plugin ini bekerja dalam bahasa GDScript murni).
* Akun Google atau OpenRouter untuk kunci API.

## Tutorial: Instalasi Manual (GitHub)

1. Buat atau buka proyek di Godot 4.6.
2. Buka folder root proyek Anda (di mana file `project.godot` berada).
3. Buat folder bernama `addons` (jika belum ada).
4. Download atau clone repositori plugin di dalam `addons/`:
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(Atau download file `.zip` dari tab Releases di GitHub dan ekstrak ke `res://addons/gamedev_ai`).*

## Aktivasi di Editor (Activation)

Setelah file berada di tempatnya:
1. Buka editor proyek Godot Anda.
2. Buka menu `Project` di bagian atas dan pilih `Project Settings`.
3. Buka tab `Plugins` di bagian atas.
4. Cari **Gamedev AI** dalam daftar plugin yang terinstal.
5. Centang kotak di sebelah `Enabled`.

Selesai! Saat mengaktifkan untuk pertama kalinya, Anda akan melihat panel chat Gamedev AI muncul di *Dock* samping editor Anda.

[**Langkah Selanjutnya: Konfigurasi Kunci API Anda** ➔](./configuration.md)
