<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SchoolClass;
use Illuminate\Support\Str;

class ClassController extends Controller
{
    public function index(Request $request)
    {
        $classes = SchoolClass::select(['id_class','code_class','name','description','semester','created_by','created_at','updated_at'])->get();
        return response()->json(['data' => $classes], 200);
    }

    public function store(Request $request)
    {
        $data = $request->only(['name','description','semester','created_by']);
        $request->validate([
            'name' => 'required|string|max:255',
            'semester' => 'nullable|string|max:10',
        ]);

        // generate a code_class
        $code = 'CLS' . str_pad((string) (SchoolClass::max('id_class') + 1), 3, '0', STR_PAD_LEFT);

        $cls = SchoolClass::create([
            'code_class' => $code,
            'name' => $data['name'],
            'description' => $data['description'] ?? '',
            'semester' => $data['semester'] ?? '1',
            'created_by' => $data['created_by'] ?? 1,
        ]);

        return response()->json(['data' => $cls], 201);
    }
}
