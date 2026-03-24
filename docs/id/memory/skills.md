# 25 Keahlian Bawaan (Katalog Lengkap)

Gamedev AI bukan sekadar AI standar dengan memori hasil pelatihan dari internet. Ia memiliki **25 modul ahli** yang ditulis khusus untuk Godot 4.6. Modul-modul ini diakses secara otomatis selama percakapan untuk memastikan bahwa kode yang dihasilkan memenuhi standar industri terbaik.

Berikut adalah semua 25 keahlian beserta tujuannya dan contoh penggunaan AI.

---

## 📜 GDScript dan Bahasa

### 1. `gdscript_style_guide`
**Panduan Gaya GDScript.** Konvensi penamaan (snake_case, PascalCase), organisasi file, pengetikan statis (Static Typing), urutan deklarasi, dan praktik terbaik pemformatan sesuai dengan standar resmi Godot.

### 2. `gdscript_modern_features`
**Fitur Modern GDScript.** Lambda, pengetikan statis yang ditingkatkan, `await`, `super()`, enum yang diketik (Typed Enums), pola `match` tingkat lanjut, dan semua fungsi baru GDScript 2.0+ yang menggantikan sintaks lama.

### 3. `gdscript_deprecated`
**Fitur GDScript yang Usang.** Daftar lengkap fungsi, metode, dan pola yang telah dihapus atau diganti antara Godot 3 dan Godot 4. AI berkonsultasi dengan keahlian ini untuk tidak pernah menyarankan kode yang sudah ketinggalan zaman.

### 4. `gdscript_recipes_and_patterns`
**Resep dan Pola GDScript.** Solusi siap pakai untuk masalah umum: singleton, object pooling, dependency injection, observer, dan implementasi yang khas untuk GDScript.

### 5. `gdscript_signals_and_tweens`
**Signal dan Tween.** Panduan mendalam tentang sistem signal Godot 4, `SceneTreeTween`, pembuatan animasi prosedural, perangkaian tween, dan pemutusan hubungan melalui signal.

---

## 🏗️ Arsitektur dan Struktur

### 6. `common_architectures`
**Arsitektur Game Umum.** Pola seperti Entity-Component, MVC untuk game, Service Locator, Event Bus, dan cara menyusun proyek menengah dan besar di Godot.

### 7. `project_structure_guidelines`
**Rekomendasi Struktur Proyek.** Organisasi folder yang ideal (`src/`, `assets/`, `ui/`, `autoloads/`), konvensi penamaan file, Autoload vs Dependency Injection, dan kapan harus memilih masing-masing opsi.

### 8. `state_machine_implementation`
**Implementasi State Machine.** Pola state machine dengan node anak (Child Nodes), transisi yang bersih, status hierarkis, dan integrasi dengan AnimationTree untuk karakter yang kompleks.

---

## 🎮 Sistem Game

### 9. `inventory_and_item_systems`
**Sistem Inventaris dan Barang.** Arsitektur inventaris berbasis sumber daya (Resource), slot, penumpukan (Stacking), drag-and-drop barang, serialisasi untuk penyimpanan, dan antarmuka inventaris interaktif.

### 10. `quest_and_dialogue_systems`
**Sistem Quest dan Dialog.** Implementasi pohon dialog, sistem quest dengan status (aktif/selesai/gagal), NPC, kondisi progres, dan hubungan dengan antarmuka (UI).

### 11. `save_system_and_persistence`
**Sistem Penyimpanan dan Persistensi (Persistence).** Serialisasi lengkap status game ke JSON/Binary, penyimpanan otomatis, beberapa slot untuk penyimpanan, versi penyimpanan, dan migrasi saat pembaruan.

### 12. `data_management_and_crafting`
**Manajemen Data dan Kerajinan (Crafting).** Sistem kerajinan dengan resep berbasis sumber daya, basis data barang, tabel loot, dan penyeimbangan ekonomi game.

---

## 🕹️ Mekanika dan Fisika

### 13. `physics_and_collision_handling`
**Fisika dan Penanganan Tabrakan.** Pengaturan layer/mask (Layers/Masks), CharacterBody2D/3D, RigidBody, Raycasting, area deteksi, dan solusi untuk masalah fisika umum.

### 14. `input_handling_and_remapping`
**Penanganan Input dan Pemetaan Ulang.** InputMap, tindakan kustom, dukungan pengontrol/keyboard/layar sentuh, pemetaan ulang tombol saat dijalankan, buffering input (Input Buffering), dan deadzone.

### 15. `ai_and_pathfinding`
**AI dan Pencarian Jalur.** NavigationServer2D/3D, NavigationAgent, penghindaran rintangan, pohon perilaku yang disederhanakan, pengejaran, patroli, dan AI musuh berbasis status.

---

## 🎨 Visual dan Suara

### 16. `shaders_and_vfx`
**Shader dan VFX.** Bahasa shader Godot, efek melarutkan, garis tepi, distorsi, GPU partikel, dan efek visual untuk game 2D dan 3D.

### 17. `post_processing_and_environment`
**Pasca-pemrosesan dan Lingkungan.** WorldEnvironment, glow, kabut (Fog), SSAO, SSR, tone mapping, koreksi warna, dan pengaturan lingkungan sinematik.

### 18. `animation_and_cutscenes`
**Animasi dan Cutscene.** AnimationPlayer, AnimationTree, blend spaces, state machine animasi, transisi halus, dan cutscene melalui AnimationPlayer.

### 19. `audio_management_best_practices`
**Praktik Terbaik Manajemen Audio.** AudioBus, AudioStreamPlayer2D/3D, pooling efek suara, musik adaptif, crossfade, pencampuran, dan organisasi sistem audio.

---

## 🖥️ Antarmuka dan Platform

### 20. `ui_ux_patterns`
**Pola UI/UX.** Menu interaktif, HUD, tema global, navigasi dengan pengontrol, transisi antar layar, jendela pop-up, dan praktik antarmuka terbaik di Godot.

### 21. `mobile_and_resolution_scaling`
**Perangkat Seluler dan Penskalaan Resolusi.** Pengaturan mode peregangan, rasio aspek, input sentuh, joystick virtual, optimalisasi untuk perangkat seluler, dan pengujian berbagai resolusi.

### 22. `localization_and_i18n`
**Lokalisasi dan Internasionalisasi (i18n).** Sistem penerjemahan menggunakan `.csv`/`.po`, TranslationServer, penggantian bahasa saat dijalankan, pemformatan angka/tanggal, dan dukungan RTL.

---

## 🌐 Multipemain dan Performa

### 23. `multiplayer_and_networking_api`
**Multipemain dan Jaringan.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPC, otoritas (Authority), arsitektur klien-server, sistem lobi, dan sinkronisasi status.

### 24. `performance_optimization`
**Optimalisasi Performa.** Pemantauan performa (Profiling), object pooling, LOD, culling, batching penggambaran, optimalisasi GDScript, minimalisasi Draw Calls, dan teknik untuk game dengan 60 FPS.

### 25. `level_generation_and_pcg`
**Pembuatan Level dan PCG.** Pembuatan dungeon prosedural, Wave Function Collapse, lanskap berbasis noise, Auto-TileMaps, dan random seeds yang dapat direproduksi.

---

## 🛠️ Buat Keahlian Anda Sendiri

Sistem keahlian ini **dapat diperluas**! Anda dapat membuat file `.md` Anda sendiri di folder `addons/gamedev_ai/skills/` untuk mengajarkan aturan proyek Anda kepada AI.

**Contoh:** Buat file `my_art_style.md` dengan isi:
```markdown
# Aturan Artistik Studio Kami

- Semua aset harus berukuran 16x16 atau 32x32 piksel.
- Gunakan palet warna terbatas (maksimum 32 warna).
- Animasi karakter memerlukan minimal 4 bingkai (frame).
- Beri nama aset seperti ini: tipe_nama_tindakan_bingkai.png
```

AI akan mengikuti aturan ini saat membuat atau mengedit aset visual apa pun di proyek Anda.
