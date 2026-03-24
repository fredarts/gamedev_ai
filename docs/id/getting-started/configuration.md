# Konfigurasi (Mendapatkan Kunci API)

Gamedev AI tidak menggunakan backend milik sendiri untuk mencuri data Anda. Ia langsung memanggil server LLM yang ingin Anda gunakan. Demi keamanan, semua pengetahuan yang diindeks disimpan secara lokal di mesin Anda!

Agar plugin dapat "berbicara" dengan kode Anda dan memberikan jawaban, kita perlu menyediakan **API Key**.

## Menggunakan Google Tools (Gemini) - Gratis
Saat ini, cara paling populer, sangat cerdas, dan **Gratis** untuk menggunakan plugin ini adalah melalui Gemini 2.5 Pro atau Gemini 2.5 Flash melalui Google AI Studio. Gemini 3.0 dan 3.1 Pro berbayar.

1. Buka [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Login dengan akun Google Anda (tidak perlu kartu kredit untuk paket gratis).
3. Klik **"Get API key"** atau **"Create API key"**.
4. Salin kunci panjang yang dihasilkan `(contoh: AIzaSyD......)`.

## Menghubungkan Kunci di Editor

1. Di dalam panel Gamedev AI di Godot, klik pada tab tersembunyi di atas **"Settings"**.
2. Pastikan provider terpilih sebagai **"Gemini"** di menu dropdown.
3. Tempelkan kunci lengkap Anda di bidang teks **API Key**, pastikan tidak ada spasi tambahan.
4. Di bidang *Model Name*, tulis model pilihan Anda (default biasanya `gemini-2.5-pro` atau `gemini-2.5-flash`).

<br>

> **💡 Tips Mantap!** 
>
> ![Tab pengaturan yang menunjukkan kolom Preset, Provider, dan API Key](../../images/settings_ui.png)

## Menggunakan OpenRouter atau OpenAI

Dukungan untuk GPT-5.4, Claude Opus 4.6, Qwen3 Coder mungkin menarik.
Gamedev AI mendukung ekosistem OpenAI / OpenRouter tanpa mengubah satu baris kode pun:
1. Kembali ke tab **Settings**.
2. Ubah provider dari `Gemini` menjadi `OpenAI / OpenRouter` di dropdown.
3. Masukkan kunci OpenAI atau OpenRouter Anda.
4. Bidang tambahan bernama **Base URL** akan muncul, tulis:
   * Untuk OpenAI: `https://api.openai.com/v1`
   * Untuk OpenRouter: `https://openrouter.ai/api/v1`
5. Ubah Nama Model (contoh `gpt-5.4` atau `anthropic/claude-opus-4.6`).

Kita siap untuk mengobrol!

[**Langkah Selanjutnya: Katakan "Halo" pada AI** ➔](./quick-start.md)
