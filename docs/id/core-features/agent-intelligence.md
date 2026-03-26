# 🧠 Agen & Inteligensi

Gamedev AI bukan sekadar chat yang menulis kode. Ia didukung oleh arsitektur agen mutakhir, berdasarkan praktik terbaik pengembangan otonom, yang memungkinkan asisten bertindak secara metodis, proaktif, dan sadar konteks.

---

## 🎭 Persona Spesialis (Dynamic Routing)

AI secara otomatis mengidentifikasi tujuan Anda berdasarkan percakapan Anda dan mengasumsikan "Persona" tertentu. Hal ini memastikan bahwa prompt hanya terfokus pada hal yang penting, menghemat token, dan meningkatkan akurasi.

- **Godot Expert**: Asisten umum untuk logika dan struktur game.
- **UI/UX Designer**: Berfokus pada node `Control`, anchor, dan layout responsif.
- **Technical Artist**: Spesialis dalam Shader, partikel, dan efek visual.
- **Multiplayer Engineer**: Berfokus pada jaringan, RPC, dan sinkronisasi.

> [!TIP]
> Anda dapat memaksa sebuah persona dengan menyebutkan kata kunci seperti "saya butuh menu (UI)" atau "saya sedang membuat shader".

---

## ⛩️ Gerbang Sokrates (Stop & Ask)

Untuk menghindari pembuatan kode masif dan generik yang mungkin tidak berguna bagi proyek Anda, AI menerapkan **Gerbang Sokrates**.

Setiap kali Anda meminta sesuatu yang kompleks (misal: "Buat sistem inventaris"), AI akan:
1. **Menghentichen** pembuatan kode.
2. **Mengajukan** setidaknya 2 pertanyaan tentang *trade-off* atau kasus tepi (misal: "Apakah akan berbasis slot atau berat?", "Apakah butuh persistensi basis data?").
3. **Mengeksekusi** tugas hanya setelah klarifikasi dari Anda.

---

## ⌨️ Alur Kerja melalui Slash Command

Anda dapat menggunakan perintah langsung untuk mengubah perilaku AI secara instan:

- `/brainstorm`: AI masuk ke mode penemuan. Ia tidak akan menulis kode, hanya membantu merencanakan arsitektur, GDD, dan logika.
- `/plan`: Berfokus pada penataan folder dan scene sebelum melakukan pengodean.
- `/debug`: Mode investigasi mendalam. Berfokus hanya pada log kesalahan dan akar masalah.

---

## 🔍 Auto-Audit (Penyempurnaan Otonom)

Setelah melakukan perubahan kompleks, AI memiliki otonomi untuk menjalankan alat audit (`audit_script`, `audit_scene`) untuk memverifikasi kesalahan sintaksis atau referensi yatim (orphan references) sebelum menganggap tugas selesai. Hal ini menjamin siklus umpan balik yang jauh lebih singkat dan kode yang lebih stabil.
