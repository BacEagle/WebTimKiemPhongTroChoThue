<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PhongTro extends Model
{
    use HasFactory;

    protected $table = 'phongtro';
    protected $primaryKey = 'maPhong';
    public const CREATED_AT = 'ngayDang';
    public const UPDATED_AT = null;

    protected $fillable = [
        'maNguoiDung',
        'tieuDe',
        'moTa',
        'diaChiTro',
        'dienTich',
        'giaThue',
        'trangThai',
        'maLoaiPhong',
    ];

    public function nguoiDung()
    {
        return $this->belongsTo(User::class, 'maNguoiDung', 'maNguoiDung');
    }

    public function hinhAnh()
    {
        return $this->hasMany(HinhAnh::class, 'maPhong', 'maPhong');
    }

    public function loaiPhong()
    {
        return $this->belongsTo(LoaiPhong::class, 'maLoaiPhong', 'maLoaiPhong');
    }

    public function tienIch()
    {
        return $this->belongsToMany(TienIch::class, 'phongtro_tienich', 'maPhong', 'maTienIch');
    }

    public function binhLuan()
    {
        return $this->hasMany(BinhLuan::class, 'maPhong', 'maPhong');
    }
}
