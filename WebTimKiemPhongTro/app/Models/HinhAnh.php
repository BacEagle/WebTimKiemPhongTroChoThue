<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HinhAnh extends Model
{
    use HasFactory;

    protected $table = 'hinhanh';
    protected $primaryKey = 'maHinhAnh';
    public $timestamps = false;

    protected $fillable = [
        'maPhong',
        'duongDan',
    ];

    public function phongTro()
    {
        return $this->belongsTo(PhongTro::class, 'maPhong', 'maPhong');
    }
}
