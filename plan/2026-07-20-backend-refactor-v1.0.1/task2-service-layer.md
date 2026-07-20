# Task 2 — Service Layer: GeminiApiService & AiPromptService

## Deskripsi
Membuat service layer untuk memisahkan logika HTTP call ke Gemini API dan manajemen prompt dari controllers. Saat ini semua bercampur di GeminiController (742 baris).

## Tujuan Teknis
- Buat `GeminiApiService` untuk handle HTTP call ke Gemini API
- Buat `AiPromptService` untuk mengelola semua prompt (hanya 1 kali definisi)
- Ganti `env('GEMINI_API_KEY')` → `config('services.gemini.key')`
- Tambah config Gemini di `config/services.php`

## Scope
**Backend:**
- BUAT: `app/Services/GeminiApiService.php`
- BUAT: `app/Services/AiPromptService.php`
- EDIT: `config/services.php` (tambah gemini config)
- EDIT: `app/Http/Controllers/GeminiController.php` (refactor pakai service)

**Flutter:** Tidak ada perubahan

## Langkah Implementasi

### 1. Tambah Config Gemini di `config/services.php`
```php
'gemini' => [
    'key' => env('GEMINI_API_KEY'),
    'url' => env('GEMINI_API_URL', 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
],
```

### 2. Buat `app/Services/GeminiApiService.php`
```php
<?php
namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeminiApiService
{
    public function generateContent(string $prompt): ?string
    {
        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'X-goog-api-key' => config('services.gemini.key'),
            ])->post(config('services.gemini.url'), [
                'contents' => [
                    ['parts' => [['text' => $prompt]]]
                ]
            ]);

            if ($response->successful()) {
                return $response->json()['candidates'][0]['content']['parts'][0]['text'] ?? null;
            }

            Log::error('Gemini API error', ['status' => $response->status()]);
            return null;
        } catch (\Throwable $e) {
            Log::error('Gemini API exception: ' . $e->getMessage());
            return null;
        }
    }
}
```

### 3. Buat `app/Services/AiPromptService.php`
```php
<?php
namespace App\Services;

class AiPromptService
{
    public function evaluateUnderstanding(array $materials, string $summary): string
    {
        $referenceText = $this->buildReferenceText($materials);

        return "You are an evaluator for student understanding. ..."
            . "Materials:\n" . $referenceText
            . "Summary:\n" . $summary . "\n";
    }

    public function generateQuestionsPrompt(array $materials): string
    {
        $referenceText = $this->buildReferenceText($materials);

        return "Create exam-style questions from the provided reference materials. ..."
            . "Materials:\n" . $referenceText;
    }

    public function generateGroupsPrompt(array $students, int $groupCount, ?string $quizResults): string
    {
        // ... build prompt
    }

    public function chatPrompt(array $materials, array $history, ?string $lastUserMsg): string
    {
        // ... build prompt
    }

    private function buildReferenceText(array $materials): string
    {
        $text = '';
        foreach ($materials as $mat) {
            $text .= "[Material Title]: " . ($mat['title'] ?? '') . "\n";
            $text .= "[Material Content]: " . ($mat['content'] ?? '') . "\n\n";
        }
        return $text;
    }
}
```

### 4. Refactor GeminiController Pakai Service
Ganti semua `Http::withHeaders([...])->post(...)` dengan `$this->gemini->generateContent($prompt)`.
Ganti semua prompt building dengan `$this->prompts->evaluateUnderstanding(...)`.

## Output yang Diharapkan
- `GeminiApiService` handle semua HTTP call ke Gemini
- `AiPromptService` handle semua prompt building
- Tidak ada `env()` langsung di controllers
- Semua prompt ditulis hanya 1 kali

## Dependencies
Tidak ada (bisa paralel dengan Task 1)

## Acceptance Criteria
- [ ] `GeminiApiService` dibuat dan bisa generate content
- [ ] `AiPromptService` dibuat dengan semua prompt methods
- [ ] Config Gemini ada di `config/services.php`
- [ ] Tidak ada `env('GEMINI_API_KEY')` di controllers
- [ ] Semua AI call menggunakan `$this->gemini->generateContent()`
- [ ] Semua prompt menggunakan `$this->prompts->*()`
- [ ] `composer lint` bersih

## Estimasi: 2-3 jam
