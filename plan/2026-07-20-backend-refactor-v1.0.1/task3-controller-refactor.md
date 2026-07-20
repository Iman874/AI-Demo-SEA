# Task 3 — Refactor GeminiController → 3 Controller

## Deskripsi
Memecah GeminiController (742 baris, 8+ tanggung jawab) menjadi 3 controller yang fokus. Ini adalah perubahan terbesar di refactoring ini.

## Tujuan Teknis
- Buat `AiProxyController` untuk AI general + generate
- Buat `ChatController` untuk chat + messages
- Buat `DiscussionUtilityController` untuk summary + understanding
- Hapus `GeminiController` lama
- Update routes di `api.php`

## Scope
**Backend:**
- BUAT: `app/Http/Controllers/AiProxyController.php`
- BUAT: `app/Http/Controllers/ChatController.php`
- BUAT: `app/Http/Controllers/DiscussionUtilityController.php`
- HAPUS: `app/Http/Controllers/GeminiController.php`
- EDIT: `routes/api.php` (update controller references)

**Flutter:** Tidak ada perubahan (endpoint sama, hanya controller berubah)

## Breakdown ke 3 Controller Baru

### AiProxyController (AI General + Generate)
| Method | Endpoint Lama | Endpoint Baru |
|---|---|---|
| `askGemini()` | `POST /api/ask` | `POST /api/ask` |
| `echoRequest()` | `GET/POST /api/echo` | `GET/POST /api/echo` |
| `generateQuestions()` | `POST /api/generate-questions` | `POST /api/generate-questions` |
| `generateGroups()` | `POST /api/generate-groups` | `POST /api/generate-groups` |

### ChatController (Chat + Messages)
| Method | Endpoint Lama | Endpoint Baru |
|---|---|---|
| `chatStudent()` | `POST /api/student/chat` | `POST /api/student/chat` |
| `getDiscussionMessages()` | `GET /api/discussion/messages` | `GET /api/discussion/messages` |
| `deleteAllDiscussionMessages()` | `POST /api/discussion/delete_all_messages` | `POST /api/discussion/delete_all_messages` |

### DiscussionUtilityController (Summary + Understanding)
| Method | Endpoint Lama | Endpoint Baru |
|---|---|---|
| `submitDiscussionSummary()` | `POST /api/discussion/submit_summary` | `POST /api/discussion/submit_summary` |
| `getDiscussionSummaries()` | `GET /api/discussion/summaries` | `GET /api/discussion/summaries` |
| `check_understanding()` | `POST /api/student/check_understanding` | `POST /api/student/check_understanding` |

## Contoh Implementasi AiProxyController

```php
<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\GeminiApiService;
use App\Services\AiPromptService;

class AiProxyController extends Controller
{
    public function __construct(
        private GeminiApiService $gemini,
        private AiPromptService $prompts
    ) {}

    public function askGemini(Request $request)
    {
        $prompt = $request->input('prompt');
        $answer = $this->gemini->generateContent($prompt);

        if ($answer) {
            return response()->json(['answer' => $answer]);
        }

        return response()->json(['error' => 'No response from Gemini API'], 500);
    }

    public function generateQuestions(Request $request)
    {
        $materials = $request->input('materials', []);
        $prompt = $this->prompts->generateQuestionsPrompt($materials);
        $result = $this->gemini->generateContent($prompt);

        if ($result) {
            return response()->json(['result' => $result]);
        }

        return response()->json(['error' => 'No response from Gemini API'], 500);
    }

    // ... dst
}
```

## Output yang Diharapkan
- 3 controller baru dengan fokus masing-masing
- `GeminiController` dihapus
- Semua endpoint berfungsi seperti sebelumnya
- Kode lebih bersih dan terorganisir

## Dependencies
- Task 2 (Service Layer) harus selesai duluan

## Acceptance Criteria
- [ ] `AiProxyController` dibuat dengan 4 methods
- [ ] `ChatController` dibuat dengan 3 methods
- [ ] `DiscussionUtilityController` dibuat dengan 3 methods
- [ ] `GeminiController` dihapus
- [ ] Semua endpoint berfungsi (regression test)
- [ ] Tidak ada logic AI di controllers (pindah ke services)
- [ ] `composer lint` bersih

## Estimasi: 3-4 jam
