<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LoaiPhong extends Model
{
    use HasFactory;

    protected $table = 'loaiphong';
    protected $primaryKey = 'maLoaiPhong';
    public $timestamps = false;

    protected $fillable = [
        'tenLoaiPhong',
    ];

    public function phongTro()
    {
        return $this->hasMany(PhongTro::class, 'maLoaiPhong', 'maLoaiPhong');
    }
}
