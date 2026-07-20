# Task 1 — Auth Middleware & Route Protection

## Deskripsi
Membuat middleware autentikasi token dan menerapkannya ke semua route yang membutuhkan proteksi. Saat ini semua 35+ endpoint terbuka tanpa auth middleware.

## Tujuan Teknis
- Buat `EnsureApiToken` middleware yang verifikasi Bearer token
- Register middleware di `bootstrap/app.php`
- Pisahkan route ke `routes/api.php` dengan group auth
- Hapus duplikasi auth logic dari controllers

## Scope
**Backend:**
- BUAT: `app/Http/Middleware/EnsureApiToken.php`
- BUAT: `routes/api.php`
- EDIT: `bootstrap/app.php` (register middleware)
- EDIT: `routes/web.php` (kosongkan, hanya welcome view)
- EDIT: `app/Http/Controllers/UserClassController.php` (hapus manual auth)
- EDIT: `app/Http/Controllers/AuthController.php` (hapus manual auth di method `user`)

**Flutter:** Tidak ada perubahan

## Langkah Implementasi

### 1. Buat `app/Http/Middleware/EnsureApiToken.php`
```php
<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\ApiToken;
use App\Models\User;

class EnsureApiToken
{
    public function handle(Request $request, Closure $next)
    {
        $header = $request->header('Authorization');
        if (!$header || !str_starts_with($header, 'Bearer ')) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $token = substr($header, 7);
        $record = ApiToken::where('token', $token)->first();
        if (!$record) {
            return response()->json(['message' => 'Invalid token'], 401);
        }

        $user = User::where('id_user', $record->user_id)->first();
        if (!$user) {
            return response()->json(['message' => 'User not found'], 401);
        }

        $request->setUserResolver(fn() => $user);

        return $next($request);
    }
}
```

### 2. Register Middleware di `bootstrap/app.php`
```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'auth.token' => \App\Http\Middleware\EnsureApiToken::class,
    ]);
})
```

### 3. Buat `routes/api.php`
Pindahkan semua route dari `web.php` ke `api.php` dengan group auth:
```php
<?php
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/echo', [AiProxyController::class, 'echo']);
Route::post('/echo', [AiProxyController::class, 'echo']);

// Protected routes
Route::middleware('auth.token')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);

    // Classes
    Route::get('/classes', [ClassController::class, 'index']);
    Route::post('/classes', [ClassController::class, 'store']);

    // ... semua endpoint lainnya
});
```

### 4. Kosongkan `routes/web.php`
```php
<?php
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
```

### 5. Hapus Manual Auth dari Controllers
- `AuthController::user()` — gunakan `$request->user()` langsung
- `UserClassController::join()` — gunakan `$request->user()` langsung
- `UserClassController::myClasses()` — gunakan `$request->user()` langsung
- `UserClassController::userClassIds()` — gunakan `$request->user()` langsung

## Output yang Diharapkan
- Middleware `EnsureApiToken` berfungsi
- Semua protected endpoint return 401 tanpa token
- Route terorganisir di `api.php`
- Auth logic tidak duplikasi di controllers

## Dependencies
Tidak ada (task pertama)

## Acceptance Criteria
- [ ] `EnsureApiToken` middleware dibuat dan diregister
- [ ] `/api/register` dan `/api/login` bisa diakses tanpa token
- [ ] `/api/user` return 401 tanpa token
- [ ] `/api/user` return data user dengan token valid
- [ ] `/api/classes` return 401 tanpa token
- [ ] Semua manual auth code dihapus dari controllers
- [ ] `routes/web.php` hanya berisi welcome view
- [ ] `composer lint` bersih

## Estimasi: 2-3 jam
