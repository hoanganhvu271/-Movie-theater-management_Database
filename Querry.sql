

-- Truy vấn tên khách hàng có thẻ thành viên nhưng đã hết hạn
SELECT Ten_KH
	FROM KhachHang
	INNER JOIN KhachHangCoThe ON KhachHang.ID_khach_hang = KhachHangCoThe.ID_khach_hang
	INNER JOIN The ON The.C_ID_khach_hang = KhachHangCoThe.C_ID_khach_hang
	WHERE GETDATE() > The.Ngay_het_han


-- In ra nhung bo phim co doanh thu lon nhat
SELECT TOP 1 Ten_phim, SUM(Gia) AS DoanhThu
	FROM SuatChieu 
	INNER JOIN Phim ON SuatChieu.ID_phim = Phim.ID_phim
	INNER JOIN Ve ON SuatChieu.ID_suat_chieu = Ve.ID_suat_chieu
	--ORDER BY SUM(Gia)
GROUP BY Ten_phim
ORDER BY DoanhThu DESC

-- Cách 2:

SELECT Ten_Phim, SUM(gia) AS DoanhThu
FROM Phim
INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
INNER Join Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
GROUP BY Ten_phim
HAVING SUM(gia) = (
	SELECT MAX(dt)
	FROM(
		SELECT SUM(gia) as dt
		FROM Phim
		INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
		INNER Join Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
		GROUP BY Ten_phim
	)AS res
)

-- Liệt kê các khách hàng có chứa ký tự a trong tên, có thẻ VIP từ năm 2020

SELECT Ten_KH
FROM KhachHang
INNER JOIN KhachHangCoThe ON KhachHang.ID_khach_hang = KhachHangCoThe.ID_khach_hang
INNER JOIN The ON The.C_ID_khach_hang = KhachHangCoThe.C_ID_khach_hang
WHERE Ten_KH LIKE '%a%'AND Ngay_het_han > GETDATE()

-- Liệt kê nhân viên quản lí

SELECT Ten_nhan_vien
FROM NhanVien
WHERE ID_nhan_vien IN (SELECT ID_quan_ly FROM NhanVien)

-- Tên khách hàng là thành viên lâu nhất và thẻ vẫn còn hạn sử dụng

SELECT TOP 1 Ten_KH, DATEDIFF(month, Ngay_tao , Ngay_het_han) AS So_thang
FROM KhachHang 
INNER JOIN KhachHangCoThe ON KhachHang.ID_khach_hang = KhachHangCoThe.ID_khach_hang
INNER JOIN The ON KhachHangCoThe.C_ID_khach_hang = The.C_ID_khach_hang
ORDER BY So_thang DESC


-- lưu ý muốn dùng các hàm toán học phải sử dụng group by--
-----------------------------------------------------------------------------------------------------------------------


-- Tính doanh thu số vé được bán online trong khoảng thời gian từ 3/2023 đến 12/2023 ở chi nhánh 'Ha Dong, Ha Noi'.
SELECT SUM(Gia) AS Doanh_thu
FROM VE 
INNER JOIN SuatChieu ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
INNER JOIN ChiNhanh ON SuatChieu.ID_chi_nhanh = ChiNhanh.ID_chi_nhanh
INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_dat = Ve.ID_dat
WHERE ChiNhanh.Dia_chi = 'Ha Dong, Ha Noi' AND Hinh_thuc_dat = 'Online' AND SuatChieu.Thoi_gian_chieu BETWEEN '2023-01-01' AND '2023-12-31'

-- Tên của các khách hàng đã xem 1 bộ phim >2 lần ở nhiều chi nhánh khác nhau


-- Liệt kê tên các phim có số lượng vé bán ra năm 2023 nhiều nhất.


SELECT Ten_phim, COUNT(ID_ve) AS SL_Ve
FROM Phim
INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
INNER JOIN Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
GROUP BY Ten_phim
HAVING COUNT(ID_ve) = (

	SELECT MAX(ve_count)
	FROM(
		SELECT COUNT(ID_ve) AS ve_count
        FROM Phim
        INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
        INNER JOIN Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
        GROUP BY Ten_phim
	) AS Ve_c
)

-- Liệt kê tên các nhân viên do NV001 quản lý và > 22 tuổi 
SELECT * FROM NhanVien
WHERE ID_quan_ly = 'NV016' AND YEAR(Ngay_sinh) < YEAR(GETDATE()) - 22


-- Liệt kê tên, tổng doanh thu các phim có doanh thu lớn hơn 100.000 dong trong thang 10, sap xep theo doanh thu giam đan

SELECT Ten_phim, SUM(Ve.Gia) AS Doanh_thu
FROM Phim
INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
INNER JOIN Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
WHERE Thoi_gian_chieu BETWEEN '2023-10-01' AND '2023-10-31' 
GROUP BY Ten_phim
HAVING SUM(Ve.Gia) > 100000
ORDER BY Doanh_thu DESC

-- Tra cứu lịch sử đặt vé của khách hàng KH000000001

SELECT *
FROM ThongTinDatVe
WHERE ThongTinDatVe.ID_khach_hang = 'KH000000001'

-- Danh sach ghe trong tai phong R002 vao 20h ngay 30-10-2023

SELECT ID_Ghe
FROM Ghe
WHERE ID_Phong = 'R002' AND ID_Ghe NOT IN (
	SELECT ID_Ghe
	FROM Ve
	INNER JOIN SuatChieu ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
	INNER JOIN Phim ON Phim.ID_phim = SuatChieu.ID_phim
	WHERE CONVERT(DATETIME, '2023-10-30 20:00:00' , 120) BETWEEN Thoi_gian_chieu AND DATEADD(MINUTE, Phim.Thoi_luong, Thoi_gian_chieu)
) 

-- Lấy ds các bộ phim đang được chiếu tại rạp vào 31/10/2023

SELECT *
FROM Phim
INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
WHERE CONVERT(DATE, Thoi_gian_chieu, 120) = CONVERT(DATE, '2023-10-31', 120)


-- Danh sách suất chiếu của phim 'Glass'

SELECT *
FROM SuatChieu
WHERE ID_phim = (
	SELECT ID_phim
	FROM Phim
	WHERE Ten_phim = 'Glass'

)

-- Các phòng chiếu phim 'Glass' trong khoảng từ 12h đến 22h ngày 31/10/2023

SELECT DISTINCT Phong.ID_Phong
FROM SuatChieu
INNER JOIN Ve ON SuatChieu.ID_suat_chieu = Ve.ID_suat_chieu
INNER JOIN Ghe ON Ve.ID_ghe = Ghe.ID_ghe
INNER JOIN Phong ON Ghe.ID_Phong = Phong.ID_Phong
INNER JOIN Phim ON Phim.ID_phim = SuatChieu.ID_phim
WHERE Ten_phim = 'Glass' AND (Thoi_gian_chieu BETWEEN '2023-10-31 12:00:00' AND '2023-10-31 22:00:00')


-- Các khách hàng có thẻ thành viên đi xem phim >= 2 lần trong tháng 10 năm 2023.
SELECT KhachHang.ID_khach_hang, Ten_KH, COUNT(ID_ve) AS So_lan_xem
FROM KhachHang
INNER JOIN KhachHangCoThe ON KhachHangCoThe.ID_khach_hang = KhachHang.ID_khach_hang	
INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
INNER JOIN Ve ON Ve.ID_dat = ThongTinDatVe.ID_dat
INNER JOIN SuatChieu ON SuatChieu.ID_suat_chieu = Ve.ID_suat_chieu
WHERE Thoi_gian_chieu BETWEEN '2023-10-01' AND '2023-10-31'
GROUP BY KhachHang.ID_khach_hang, Ten_KH
HAVING COUNT(ID_ve) >= 2

-- Liet ke ten cac phim, So luong ve ban nhieu nhat vao ngay 31-10-2023

SELECT Ten_phim, COUNT(ID_ve) AS So_Luong_Ve
FROM Phim
INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
INNER JOIN Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
GROUP BY Ten_phim
HAVING COUNT(ID_ve) = (

	SELECT MAX(sl_ve)
	FROM(
		SELECT COUNT(ID_ve) AS sl_ve
		FROM Phim
		INNER JOIN SuatChieu ON SuatChieu.ID_phim = Phim.ID_phim
		INNER JOIN Ve ON Ve.ID_suat_chieu = SuatChieu.ID_suat_chieu
		GROUP BY Ten_phim
	) AS ket_qua

)

-- Phim chi chieu trong ngay X


WITH BangTest1 AS
(
  SELECT P.ID_phim AS id, P.Ten_phim AS ten
  FROM Phim P
  INNER JOIN SuatChieu SC ON P.ID_phim = SC.ID_phim
  WHERE CONVERT(CHAR(20), SC.Thoi_gian_chieu, 23) = '2023-10-30'
)
SELECT b1.id, b1.ten  
From BangTest1 b1
WHERE b1.id NOT IN (SELECT P.ID_phim AS id
  FROM Phim P
  INNER JOIN SuatChieu SC ON P.ID_phim = SC.ID_phim
  WHERE CONVERT(CHAR(20), SC.Thoi_gian_chieu, 23) <> '2023-10-30' )
  GROUP BY b1.id, b1.ten


-- Tìm khách hàng có tổng chi tiêu lớn nhất (cả đặt vé và dịch vụ)

SELECT Ten_KH, SUM(ThongTinDatVe.Thanh_tien) + SUM(HoaDon.Thanh_tien) AS Chi_tieu_max
FROM KhachHang
INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
INNER JOIN HoaDon ON HoaDon.ID_khach_hang = KhachHang.ID_khach_hang
GROUP BY Ten_KH
HAVING SUM(ThongTinDatVe.Thanh_tien) + SUM(HoaDon.Thanh_tien) = (
	SELECT MAX(Chi_tieu_max) 
	FROM(
		SELECT SUM(ThongTinDatVe.Thanh_tien) + SUM(HoaDon.Thanh_tien) AS Chi_tieu_max
		FROM KhachHang
		INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
		INNER JOIN HoaDon ON HoaDon.ID_khach_hang = KhachHang.ID_khach_hang
		GROUP BY Ten_KH
	)AS KetQua
)

-- Cach 2:

WITH BangTamThoi AS (
	SELECT TOP 1 Ten_KH, SUM(ThongTinDatVe.Thanh_tien) + SUM(HoaDon.Thanh_tien) AS Chi_tieu_max
		FROM KhachHang
		INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
		INNER JOIN HoaDon ON HoaDon.ID_khach_hang = KhachHang.ID_khach_hang
		GROUP BY Ten_KH
		ORDER BY Chi_tieu_max DESC
)

SELECT Ten_KH, BangTamThoi.Chi_tieu_max
FROM BangTamThoi
WHERE Chi_tieu_max = (SELECT TOP 1 BangTamThoi.Chi_tieu_max FROM BangTamThoi)

-- Khách hàng xem phim 'Glass' nhưng không xem phim 'Frozen'

WITH TamThoi AS(
	SELECT Ten_KH
	FROM KhachHang
	INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
	INNER JOIN Ve ON Ve.ID_dat = ThongTinDatVe.ID_dat
	INNER JOIN SuatChieu ON SuatChieu.ID_suat_chieu = Ve.ID_suat_chieu
	INNER JOIn Phim ON SuatChieu.ID_phim = Phim.ID_phim
	WHERE Ten_Phim = 'Kungfu Panda 3'
)

SELECT DISTINCT KhachHang.ID_khach_hang, Ten_KH
FROM KhachHang
	INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
	INNER JOIN Ve ON Ve.ID_dat = ThongTinDatVe.ID_dat
	INNER JOIN SuatChieu ON SuatChieu.ID_suat_chieu = Ve.ID_suat_chieu
	INNER JOIn Phim ON SuatChieu.ID_phim = Phim.ID_phim
	WHERE Ten_Phim = 'Glass' AND Ten_KH NOT IN(
		SELECT Ten_KH FROM TamThoi
	)

 -- Khách hàng chỉ mua vé trong 1 ngày 
 SELECT KhachHang.ID_khach_hang, Ten_KH, COUNT(DISTINCT CONVERT(DATE, Thoi_gian_dat)) AS So_ngay_khac_nhau
 FROM KhachHang
 INNER JOIN ThongTinDatVe ON ThongTinDatVe.ID_khach_hang = KhachHang.ID_khach_hang
 GROUP BY KhachHang.ID_khach_hang, Ten_KH
 HAVING COUNT(DISTINCT CONVERT(DATE, Thoi_gian_dat)) = 1 AND MAX(CONVERT(DATE, Thoi_gian_dat)) = '2023-10-29'

SELECT GETDATE() AS Thoi_gian_hien_tai 
