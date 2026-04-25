# Konfigurasi (Mendapatkan Kunci API)

Gamedev AI tidak menggunakan backend milik sendiri untuk mencuri data Anda. Ia langsung memanggil server LLM yang ingin Anda gunakan. Demi keamanan, semua pengetahuan yang diindeks disimpan secara lokal di mesin Anda!

For the plugin to speak and respond to your code, we need to provide an **API Key**.

## Menggunakan Google Tools (Gemini)
Saat ini, cara paling populer dan sangat cerdas untuk menggunakan plugin ini adalah melalui Google AI Studio dengan Gemini 3.1 Pro atau Gemini 3.1 Flash. Gemini 4.0 saat ini dalam tahap beta.

1. Buka [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Login dengan akun Google Anda (tidak perlu kartu kredit untuk paket gratis).
3. Klik **"Get API key"** atau **"Create API key"**.
4. Salin kunci panjang yang dihasilkan `(contoh: AIzaSyD......)`.

## Menghubungkan Kunci di Editor

1. Di dalam panel Gamedev AI di Godot, klik pada tab tersembunyi di atas **"Settings"**.
2. Pastikan provider terpilih sebagai **"Gemini"** di menu dropdown.
3. Tempelkan kunci lengkap Anda di bidang teks **API Key**, pastikan tidak ada spasi tambahan.
4. Di bidang *Model Name*, tulis model pilihan Anda (default biasanya `gemini-3.1-pro` atau `gemini-3.1-flash`).

<br>

> **💡 Tips Mantap!** 

![Tab pengaturan yang menunjukkan kolom Preset, Provider, dan API Key](../../images/settings_ui.png)

## Menggunakan OpenRouter atau OpenAI

Jika Anda lebih suka mengakses model seperti Claude Opus 4.7, GPT-5.5, atau model terbuka mutakhir lainnya, Gamedev AI mendukung API yang kompatibel secara asli.

1. Daftar dan dapatkan API Key Anda di:
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Kembali ke tab **Settings** yang tersembunyi di dalam Godot.
3. Ubah provider dari `Gemini` menjadi `OpenAI / OpenRouter` di dropdown.
4. Tempelkan **API Key** Anda.
5. Di bidang tambahan bernama **Base URL**, masukkan alamat yang sesuai **dengan tepat**:
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. Ubah bidang **Model Name** ke pengidentifikasi model yang diinginkan (contoh: `anthropic/claude-opus-4.7` atau `gpt-5.5`).

## Menggunakan NVIDIA NIM (DeepSeek Gratis dan Lainnya)

Platform NVIDIA NIM menyediakan akses cepat dan seringkali gratis ke banyak model kelas atas, seperti seri **DeepSeek** dan **Llama**, melalui API yang kompatibel dengan standar OpenAI.

1. Buka [Katalog API NVIDIA](https://build.nvidia.com/) dan buat akun untuk mendapatkan API Key Anda.
2. Di tab **Settings** plugin, pilih provider **`OpenAI / OpenRouter`**.
3. Tempelkan **API Key** yang dihasilkan NVIDIA Anda.
4. Di bidang **Base URL**, Anda harus memasukkan URL NVIDIA NIM yang tepat:
   * `https://integrate.api.nvidia.com/v1`
5. Di bidang **Model Name**, masukkan nama model yang diinginkan.

> **⚠️ Peringatan: Nama Model di NVIDIA**
> Di NVIDIA NIM, Anda **wajib** menyertakan "prefiks organisasi" sebelum nama model.
> Contoh: Untuk DeepSeek, Anda tidak boleh hanya menggunakan `deepseek-v4-pro`, melainkan **`deepseek-ai/deepseek-v4-pro`** (atau `deepseek-ai/deepseek-r1`). Untuk Llama, itu akan menjadi `meta/llama-3.1-70b-instruct`. Jika prefiks organisasi tidak disertakan, API akan mengembalikan **error 404 - Not Found**.

## Menggunakan Model Lokal (Ollama / LM Studio)

Apakah Anda lebih suka menjalankan model AI langsung di mesin Anda sendiri, tanpa mengandalkan API eksternal dan sepenuhnya gratis?

1. Instal [Ollama](https://ollama.ai) dan unduh model di terminal Anda: `ollama pull llama3.1`
2. Pastikan Ollama berjalan (melalui `ollama serve` atau biarkan aplikasi terbuka).
3. Di tab **Settings**, ubah provider menjadi **`Local (Ollama / LM Studio)`**.
4. Bidang **Base URL** akan terisi secara otomatis dengan `http://localhost:11434/v1`.
5. Masukkan nama model yang diunduh di bidang **Model Name** (contoh: `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. Bidang API Key akan dinonaktifkan secara otomatis (model lokal tidak memerlukan kunci).

> **⚠️ Catatan:** Kecepatan dan kualitas respons murni bergantung pada perangkat keras mesin Anda (GPU) dan model yang dipilih.

Kita siap untuk mengobrol!

[**Langkah Selanjutnya: Katakan "Halo" pada AI** ➔](./quick-start.md)
