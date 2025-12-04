<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TienIch extends Model
{
    use HasFactory;

    protected $table = 'tienich';
    protected $primaryKey = 'maTienIch';
    public $timestamps = false;

    protected $fillable = [
        'tenTienIch',
    ];

    public function phongTro()
    {
        return $this->belongsToMany(PhongTro::class, 'phongtro_tienich', 'maTienIch', 'maPhong');
    }
}
