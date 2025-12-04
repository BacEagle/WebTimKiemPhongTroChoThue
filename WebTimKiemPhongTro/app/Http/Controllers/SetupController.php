<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SetupController extends Controller
{
    public function setupDatabase()
    {
        $sql = file_get_contents(database_path('../webTro.sql'));
        DB::unprepared($sql);
        return 'Database setup complete.';
    }
}
