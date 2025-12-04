<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BinhLuan extends Model
{
    use HasFactory;

    protected $table = 'binhluan';
    protected $primaryKey = 'maBinhLuan';
    public const CREATED_AT = 'ngayBinhLuan';
    public const UPDATED_AT = null;

    protected $fillable = [
        'maPhong',
        'maNguoiDung',
        'noiDung',
    ];

    public function phongTro()
    {
        return $this->belongsTo(PhongTro::class, 'maPhong', 'maPhong');
    }

    public function nguoiDung()
    {
        return $this->belongsTo(User::class, 'maNguoiDung', 'maNguoiDung');
    }
}
