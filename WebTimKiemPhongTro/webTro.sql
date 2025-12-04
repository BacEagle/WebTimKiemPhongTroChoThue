c:\Users\yencr\Downloads\webTro.sql-- Xóa cơ sở dữ liệu nếu đã tồn tại để tránh lỗi
DROP DATABASE IF EXISTS web_tro;

-- Tạo cơ sở dữ liệu mới với bộ ký tự utf8mb4 để hỗ trợ tiếng Việt tốt nhất
CREATE DATABASE web_tro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Sử dụng cơ sở dữ liệu vừa tạo
USE web_tro;

-- Bảng `nguoidung`: Lưu trữ thông tin tất cả người dùng (bao gồm cả admin)
CREATE TABLE IF NOT EXISTS nguoidung (
    maNguoiDung INT AUTO_INCREMENT NOT NULL,
    tenNguoiDung VARCHAR(100) NOT NULL,
    soDienThoai VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    matKhau VARCHAR(255) NOT NULL, -- Dùng để lưu mật khẩu đã được mã hóa
    soBaiViet INT NOT NULL DEFAULT 0, -- Số lượng bài viết hiện có, sẽ được cập nhật bằng code
    loaiTaiKhoan VARCHAR(20) NOT NULL DEFAULT 'user', -- 'user' hoặc 'admin'
    soLanViPham INT NOT NULL DEFAULT 0, -- Tăng lên mỗi khi bị admin xử lý
    anhDaiDien VARCHAR(255) DEFAULT 'default_avatar.jpg',
    ngayTao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_nguoidung PRIMARY KEY(maNguoiDung)
);

-- Bảng `phongtro`: Đổi tên từ `baidang`. Lưu thông tin các bài đăng phòng trọ.
CREATE TABLE IF NOT EXISTS phongtro (
    maPhong INT AUTO_INCREMENT NOT NULL,
    maNguoiDung INT NOT NULL,
    tieuDe VARCHAR(255) NOT NULL,
    moTa TEXT,
    diaChiTro VARCHAR(255) NOT NULL,
    dienTich INT NOT NULL, -- Đơn vị: m2
    giaThue INT NOT NULL, -- Đơn vị: VND
    trangThai VARCHAR(50) NOT NULL DEFAULT 'Chờ duyệt', -- 'Chờ duyệt', 'Đã duyệt', 'Bị ẩn'
    ngayDang TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_phongtro PRIMARY KEY(maPhong),
    CONSTRAINT fk_phongtro_nguoidung FOREIGN KEY (maNguoiDung) REFERENCES nguoidung(maNguoiDung) ON DELETE CASCADE
);

-- Bảng `admin`: Lưu thông tin mở rộng cho tài khoản quản trị, liên kết với bảng `nguoidung`
CREATE TABLE IF NOT EXISTS admin (
    maAdmin INT AUTO_INCREMENT NOT NULL,
    maNguoiDung INT NOT NULL UNIQUE, -- Liên kết 1-1 với bảng nguoidung
    quyenHan VARCHAR(50) NOT NULL DEFAULT 'moderator', -- Ví dụ: 'superadmin', 'moderator'
    ngayBoNhiem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_admin PRIMARY KEY(maAdmin),
    CONSTRAINT fk_admin_nguoidung FOREIGN KEY (maNguoiDung) REFERENCES nguoidung(maNguoiDung) ON DELETE CASCADE
);

-- Bảng `baocao`: Lưu các báo cáo của người dùng về bài đăng hoặc người dùng khác
CREATE TABLE IF NOT EXISTS baocao (
    maBaoCao INT AUTO_INCREMENT NOT NULL,
    maNguoiBaoCao INT, -- Người gửi báo cáo. SET NULL nếu họ xóa tài khoản
    maPhongBiBaoCao INT, -- Bài đăng bị báo cáo. SET NULL nếu bài đăng bị xóa
    maNguoiBiBaoCao INT, -- Người dùng bị báo cáo (chủ bài đăng).
    loaiBaoCao VARCHAR(100) NOT NULL, -- Ví dụ: 'Nội dung không phù hợp', 'Lừa đảo'
    chiTietBaoCao TEXT, -- Mô tả chi tiết từ người báo cáo
    ngayBaoCao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trangThaiXuLy VARCHAR(50) NOT NULL DEFAULT 'Chờ xử lý', -- 'Chờ xử lý', 'Đã xử lý (Xóa bài)', 'Đã xử lý (Bỏ qua)'
    CONSTRAINT pk_baocao PRIMARY KEY (maBaoCao),
    CONSTRAINT fk_baocao_nguoibaocao FOREIGN KEY (maNguoiBaoCao) REFERENCES nguoidung(maNguoiDung) ON DELETE SET NULL,
    CONSTRAINT fk_baocao_phongtro FOREIGN KEY (maPhongBiBaoCao) REFERENCES phongtro(maPhong) ON DELETE SET NULL,
    CONSTRAINT fk_baocao_nguoibibaocao FOREIGN KEY (maNguoiBiBaoCao) REFERENCES nguoidung(maNguoiDung) ON DELETE SET NULL
);

-- Bảng `danhsachden`: Lưu các số điện thoại bị cấm đăng ký tài khoản
CREATE TABLE IF NOT EXISTS danhsachden (
    maDanhSachDen INT AUTO_INCREMENT NOT NULL,
    soDienThoai VARCHAR(15) NOT NULL UNIQUE,
    lyDo TEXT,
    ngayThem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_danhsachden PRIMARY KEY (maDanhSachDen)
);

-- Bảng `hinhanh`: Lưu trữ các hình ảnh cho mỗi phòng trọ
CREATE TABLE IF NOT EXISTS hinhanh (
    maHinhAnh INT AUTO_INCREMENT NOT NULL,
    maPhong INT NOT NULL,
    duongDan VARCHAR(255) NOT NULL,
    CONSTRAINT pk_hinhanh PRIMARY KEY (maHinhAnh),
    CONSTRAINT fk_hinhanh_phongtro FOREIGN KEY (maPhong) REFERENCES phongtro(maPhong) ON DELETE CASCADE
);

-- Ghi chú tổng quan:
-- 1. `nguoidung` là bảng trung tâm, lưu tất cả tài khoản.
-- 2. `admin` là bảng mở rộng, chỉ định ai là admin và có quyền gì.
-- 3. `phongtro` (bài đăng) được tạo bởi `nguoidung`.
-- 4. `hinhanh` chứa các ảnh của `phongtro`.
-- 5. `baocao` là nơi người dùng báo cáo các `phongtro` hoặc `nguoidung` không phù hợp.
-- 6. `danhsachden` chứa các số điện thoại bị cấm.
-- Quy trình xử lý vi phạm: Khi admin xử lý một `baocao` và quyết định xóa bài, `trangThai` của `phongtro` sẽ được cập nhật, đồng thời `soLanViPham` của `nguoidung` tương ứng sẽ tăng lên.
-- Nếu `soLanViPham` vượt ngưỡng, admin có thể xóa tài khoản `nguoidung` và thêm `soDienThoai` của họ vào `danhsachden`.

CREATE TABLE IF NOT EXISTS binhluan (
    maBinhLuan INT AUTO_INCREMENT PRIMARY KEY,
    maPhong INT NOT NULL,
    maNguoiDung INT NOT NULL,
    noiDung TEXT NOT NULL,
    ngayBinhLuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bl_phong FOREIGN KEY (maPhong) REFERENCES phongtro(maPhong) ON DELETE CASCADE,
    CONSTRAINT fk_bl_user FOREIGN KEY (maNguoiDung) REFERENCES nguoidung(maNguoiDung) ON DELETE CASCADE
);

INSERT INTO loaiphong (tenLoaiPhong) VALUES
('Phòng trọ'),
('Căn hộ mini'),
('Nhà nguyên căn'),
('Chung cư'),
('Ký túc xá');



ALTER TABLE phongtro
ADD maLoaiPhong INT NULL,
ADD CONSTRAINT fk_phongtro_loaiphong 
    FOREIGN KEY (maLoaiPhong) REFERENCES loaiphong(maLoaiPhong) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS tienich (
    maTienIch INT AUTO_INCREMENT PRIMARY KEY,
    tenTienIch VARCHAR(100) NOT NULL UNIQUE
);



INSERT INTO tienich (tenTienIch) VALUES
('Wifi'),
('Máy lạnh'),
('WC riêng'),
('Chỗ để xe'),
('Giờ giấc tự do'),
('Có gác lửng'),
('Nội thất đầy đủ');



CREATE TABLE IF NOT EXISTS phongtro_tienich (
    maPhong INT NOT NULL,
    maTienIch INT NOT NULL,
    PRIMARY KEY (maPhong, maTienIch),
    CONSTRAINT fk_pt_ti_phong FOREIGN KEY (maPhong) REFERENCES phongtro(maPhong) ON DELETE CASCADE,
    CONSTRAINT fk_pt_ti_tienich FOREIGN KEY (maTienIch) REFERENCES tienich(maTienIch) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS yeuthich (
    maYeuThich INT AUTO_INCREMENT PRIMARY KEY,
    maNguoiDung INT NOT NULL,
    maPhong INT NOT NULL,
    ngayThem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_yt_user FOREIGN KEY (maNguoiDung) REFERENCES nguoidung(maNguoiDung) ON DELETE CASCADE,
    CONSTRAINT fk_yt_phong FOREIGN KEY (maPhong) REFERENCES phongtro(maPhong) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS binhluan (
    maBinhLuan INT AUTO_INCREMENT PRIMARY KEY,
    maPhong INT NOT NULL,
    maNguoiDung INT NOT NULL,
    noiDung TEXT NOT NULL,
    ngayBinhLuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bl_phong FOREIGN KEY (maPhong) REFERENCES phongtro(maPhong) ON DELETE CASCADE,
    CONSTRAINT fk_bl_user FOREIGN KEY (maNguoiDung) REFERENCES nguoidung(maNguoiDung) ON DELETE CASCADE
);
--
-- Cấu trúc bảng cho bảng `daNang`
--
CREATE TABLE `daNang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenQuanHuyen` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `loai` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đổ dữ liệu cho bảng `daNang`
--
INSERT INTO `daNang` (`tenQuanHuyen`, `loai`) VALUES
('Quận Hải Châu', 'Quận'),
('Quận Cẩm Lệ', 'Quận'),
('Quận Thanh Khê', 'Quận'),
('Quận Liên Chiểu', 'Quận'),
('Quận Ngũ Hành Sơn', 'Quận'),
('Quận Sơn Trà', 'Quận'),
('Huyện Hòa Vang', 'Huyện'),
('Huyện Hoàng Sa', 'Huyện');

