

----------------------------------------------------BMCSDL -LAB 02 - NHOM 10---------------------------------------


-- 1. USER BDAdmin Được toàn quyền trên CSDL QLBongDa:
--TAO USER ADMIN

USE [master]
GO
CREATE LOGIN [BDAdmin] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [QLBongDa]
GO
CREATE USER [BDAdmin] FOR LOGIN [BDAdmin]
GO

--cap quyen owner cho user BDAmin
USE [QLBongDa]
GO
ALTER ROLE [db_owner] ADD MEMBER [BDAdmin]
GO


--2.  BDBK Được phép backup CSDL QLBongDa:
USE [master]
GO
CREATE LOGIN [BDBK] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [QLBongDa]
GO
CREATE USER [BDBK] FOR LOGIN [BDBK]
GO
USE [QLBongDa]
GO
--cap quyen owner cho user BDBK
ALTER ROLE [db_backupoperator] ADD MEMBER [BDBK]
GO



--3.   BDRead Chỉ được phép xem dữ liệu trong CSDL QLBongDa:
USE [master]
GO
CREATE LOGIN [BDRead] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [QLBongDa]
GO


CREATE USER [BDRead] FOR LOGIN [BDRead]
GO
USE [QLBongDa]
GO
--cap quyen chi duoc xem du lieu cho BDRead
ALTER ROLE [db_datareader] ADD MEMBER [BDRead]
GO


--4.   BDU01 Được phép thêm mới table:

--Tao user 
USE [master]
GO
CREATE LOGIN [BDU01] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

--them quyen thêm mới bảng
USE [QLBongDa]
GO
CREATE USER [BDU01] FOR LOGIN [BDU01]
go
USE [QLBongDa]
GO
GRANT CONNECT TO [BDU01]
GO

USE [QLBongDa]
GO
GRANT CREATE TABLE TO [BDU01]
GO
USE [QLBongDa]
GO
GRANT ALTER ON SCHEMA::dbo TO [BDU01]
GO


--5.  BDU02  Được phép cập nhật các table, không được phép thêm mới hoặc xóa table:
-- Tạo login cho user 
USE [master]
GO
CREATE LOGIN [BDU02] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
use [master];
GO
USE [QLBongDa]
GO
CREATE USER [BDU02] FOR LOGIN [BDU02]
GO
USE [QLBongDa]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BDU02]
GO
USE [QLBongDa]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [BDU02]
GO

-- Tạo user và cấp quyền cập nhật trên tất cả các bảng
USE [QLBongDa]
GO
CREATE USER [BDU02] FOR LOGIN [BDU02];
GO
USE [QLBongDa]
GO
GRANT UPDATE ON SCHEMA::dbo TO [BDU02];
GO
-- Từ chối quyền tạo mới bảng và xóa bảng
use [QLBongDa]
go
DENY CREATE TABLE TO [BDU02];
GO
use [QLBongDa]
GO
DENY DELETE ON SCHEMA::[dbo] TO [BDU02]
GO


--6   BDU03 Chỉ được phép thao tác table CauLacBo (select, insert, delete,
--update), không được phép thao tác các table khác.
USE [master]
GO
CREATE LOGIN [BDU03] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
use [master];
GO
USE [QLBongDa]
GO
CREATE USER [BDU03] FOR LOGIN [BDU03]
GO
--Cấp quyền cho user BDU03 thao tác bảng CAULACBO 
use [QLBongDa]
GO
GRANT SELECT,DELETE,INSERT, UPDATE  ON [dbo].[CAULACBO] TO [BDU03]
GO


--7 BDU04  Chỉ được phép thao tác table CAUTHU, trong đó- Không được phép xem cột ngày sinh (NGAYSINH)
-- Không được phép chỉnh sửa giá trị trong cột Vị trí (VITRI) Không được phép thao tác các table khác

USE [master]
GO
CREATE LOGIN [BDU04] WITH PASSWORD=N'1234567kid', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
use [master];
GO
USE [QLBongDa]
GO
CREATE USER [BDU04] FOR LOGIN [BDU04]
GO

--câp quyền theo yêu cầu
USE [QLBongDa]
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[CAUTHU] TO BDU04
DENY SELECT ON [dbo].[CAUTHU]([NGAYSINH]) TO BDU04
DENY UPDATE ON [dbo].[CAUTHU]([VITRI]) TO BDU04
GO



--8 BDProfile Được phép thao tác SQL Profile
--tao user login
USE [master]
GO
CREATE LOGIN [BDProfile] WITH PASSWORD=N'', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [QLBongDa]
GO
CREATE USER [BDProfile] FOR LOGIN [BDProfile]
GO


--cap quyen thao tác SQL Profile
use [master]
GRANT ALTER TRACE TO BDProfile;
GO



--e) Tạo stored procedure với yêu cầu cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí 
--của các cầu thủ thuộc đội bóng “SHB Đà Nẵng” và tên quốc tịch = “Brazil”, trong đó 
tên đội bóng/câu lạc bộ và tên quốc tịch/quốc gia là 2 tham số của stored procedure.


USE QLBongDa
GO
CREATE PROCEDURE SP_SEL_NO_ENCRYPT @TENCLB NVARCHAR(100), @TENQG NVARCHAR(60)

AS 
BEGIN 
	SELECT CT.MACT,CT.HOTEN,CT.NGAYSINH,CT.DIACHI,CT.VITRI
	FROM CAUTHU CT INNER JOIN CAULACBO CLB ON CT.MACLB=CLB.MACLB
	               INNER JOIN QUOCGIA QG ON CT.MAQG=QG.MAQG
	WHERE CLB.TENCLB=@TENCLB AND QG.TENQG=@TENQG
END


--f) Tạo stored procedure với yêu cầu như câu e, với nội dung stored được mã hóa.
USE QLBongDa
GO
CREATE PROCEDURE SP_SEL_ENCRYPT @TENCLB NVARCHAR(100), @TENQG NVARCHAR(60) 
WITH ENCRYPTION

AS 
BEGIN 
	SELECT CT.MACT,CT.HOTEN,CT.NGAYSINH,CT.DIACHI,CT.VITRI
	FROM CAUTHU CT INNER JOIN CAULACBO CLB ON CT.MACLB=CLB.MACLB
	               INNER JOIN QUOCGIA QG ON CT.MAQG=QG.MAQG
	WHERE CLB.TENCLB=@TENCLB AND QG.TENQG=@TENQG
END


--g)  Thực thi 2 stored procedure trên với tham số truyền vào 
--@TenCLB = “SHB Đà Nẵng” ,@TenQG = “Brazil”,
GO
EXEC SP_SEL_NO_ENCRYPT @TENCLB=N'SHB Đà Nẵng', @TenQG = N'Brazil';
EXEC SP_SEL_ENCRYPT @TENCLB=N'SHB Đà Nẵng', @TenQG = N'Brazil';
--
GO
EXEC sp_helptext 'SP_SEL_NO_ENCRYPT'
GO
EXEC sp_helptext 'SP_SEL_ENCRYPT'
GO


--h) Giả sử trong CSDL có 100 stored procedure, có cách nào để Encrypt toàn bộ 100 stored
--procedure trước khi cài đặt cho khách hàng không? Nếu có, hãy mô tả các bước thực hiện.





--i) Tạo và phân quyền trên Views:


--1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ 
--thuộc đội bóng “SHB Đà Nẵng” có quốc tịch “Brazil”.


USE QLBongDa
GO
CREATE VIEW vCau1 
AS  
	SELECT CT.MACT,CT.HOTEN,CT.NGAYSINH,CT.DIACHI,CT.VITRI
	FROM CAUTHU CT INNER JOIN CAULACBO CLB ON CT.MACLB=CLB.MACLB
	               INNER JOIN QUOCGIA QG ON CT.MAQG=QG.MAQG
	WHERE CLB.TENCLB LIKE 'SHB Đà Nẵng' AND QG.TENQG= N'Brazil'
GO


--2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2,
--KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009.
USE QLBongDa
GO
CREATE VIEW vCau2
AS  
	SELECT TD.MATRAN,TD.NGAYTD,SVD.TENSAN,CLB1.TENCLB,CLB2.TENCLB, TD.KETQUA 
	FROM TRANDAU TD INNER JOIN SANVD SVD ON TD.MASAN=SVD.MASAN
	                INNER JOIN CAULACBO CLB1 ON TD.MACLB1= CLB1.MACLB
					INNER JOIN CAULACBO CLB2 ON TD.MACLB2= CLB2.MACLB
	WHERE TD.VONG=3 AND TD.NAM=2009
GO



--3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, 
--vai trò và tên CLB đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”.
USE QLBongDa
GO
CREATE VIEW vCau3
AS  
	SELECT HLV.MAHLV, HLV.TENHLV, HLV.NGAYSINH, HLV.DIACHI, HLV_CLB.VAITRO, CAULACBO.TENCLB 
        FROM HUANLUYENVIEN HLV 
                          JOIN HLV_CLB hlvclb ON HLV.MAHLV = hlvclb.MAHLV 
                          JOIN CAULACBO CLB ON hlvclb.MACLB = CLB.MACLB 
                          JOIN QUOCGIA QG ON HLV.MAQG = QG.MAQG 
	WHERE QG.TENQG LIKE N'Việt Nam'
GO


--4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ
--và số lượng cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng
--của các câu lạc bộ có nhiều hơn 2 cầu thủ nước ngoài.


USE QLBongDa
GO
CREATE VIEW vCau4
AS
		SELECT CLB.MACLB, CLB.TENCLB, SVD.TENSAN, SVD.DIACHI, COUNT(*) AS SO_LUONG_CAU_THU_NUOC_NGOAI
		FROM CAULACBO CLB
				INNER JOIN SANVD SVD ON CLB.MASAN = SVD.MASAN
				INNER JOIN CAUTHU CT ON CLB.MACLB = CT.MACLB
				INNER JOIN QUOCGIA QG ON CT.MAQG = QG.MAQG
		WHERE QG.TENQG <> N'Việt Nam'
		GROUP BY CLB.MACLB, CLB.TENCLB, SVD.TENSAN, SVD.DIACHI
		HAVING COUNT(*) > 2;
GO


--5. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo
--trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý.

USE QLBongDa
GO
CREATE VIEW vCau5
AS
		SELECT T.TENTINH, COUNT(CT.MACT) AS SO_LUONG_TIEN_DAO
		FROM TINH T
		     INNER JOIN CAULACBO CLB ON CLB.MATINH=T.MATINH
			 INNER JOIN CAUTHU CT ON CLB.MACLB=CT.MACLB
	    WHERE CT.VITRI LIKE N'Tiền đạo'
		GROUP BY T.TENTINH,CLB.MACLB
GO


--6. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất 
-- của bảng xếp hạng của vòng 3, năm 2009.

USE QLBongDa
GO
CREATE VIEW vCau6
AS
		SELECT CLB.TENCLB,T.TENTINH
		FROM CAULACBO CLB 
			 INNER JOIN TINH T ON CLB.MATINH=T.MATINH 
			 INNER JOIN BANGXH BXH ON BXH.MACLB=CLB.MACLB
		WHERE BXH.NAM=2009 AND BXH.VONG=3 AND BXH.HANG=1
GO
  

--7. Cho biết tên huấn luyện viên đang nắm giữ một vị trí
--trong một câu lạc bộ mà chưa có số điện thoại.
USE QLBongDa
GO
CREATE VIEW vCau7
AS 
		SELECT HLV.TENHLV
		FROM  HLV_CLB hlvclb
		      INNER JOIN HUANLUYENVIEN HLV ON hlvclb.MAHLV=HLV.MAHLV
			  INNER JOIN CAULACBO CLB ON CLB.MACLB=hlvclb.MACLB
		WHERE HLV.DIENTHOAI IS NULL AND hlvclb.VAITRO IS NOT NULL
		
GO


--8 Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn
--luyện tại bất kỳ một câu lạc bộ nào.

USE QLBongDa
GO
CREATE VIEW vCau8
AS
		SELECT HLV.*
		FROM HUANLUYENVIEN HLV
			 INNER JOIN QUOCGIA QG ON QG.MAQG=HLV.MAQG
		WHERE NOT EXISTS (
						  SELECT *
						  FROM HLV_CLB
						  WHERE HLV_CLB.MAHLV = HLV.MAHLV)
        AND QG.TENQG LIKE 'Việt Nam'

		
GO


--9 Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2,
--KETQUA) của câu lạc bộ CLB đang xếp hạng cao nhất tính đến hết vòng 3 năm
--2009.

create view vCAU9 as
select NGAYTD, TENSAN,clb1.TENCLB as TENCLB1,clb2.TENCLB as TENCLB2,KETQUA, TRANDAU.VONG
from TRANDAU join CAULACBO as clb1 on TRANDAU.MACLB1=clb1.MACLB
				join CAULACBO as clb2 on TRANDAU.MACLB2=clb2.MACLB
					join BANGXH on clb1.MACLB=BANGXH.MACLB or clb2.MACLB=BANGXH.MACLB
						join SANVD on SANVD.MASAN=TRANDAU.MASAN
where TRANDAU.VONG<=3 and (clb1.MACLB=(select MACLB from BANGXH where HANG='1' and VONG='3' and NAM = 2009) 
		or clb2.MACLB=(select MACLB from BANGXH where HANG='1' and VONG='3' and NAM = 2009))
group by NGAYTD, TENSAN,clb1.TENCLB,clb2.TENCLB ,KETQUA, TRANDAU.VONG



--i) Tạo và phân quyền trên Produre:


--1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ 
--thuộc đội bóng “SHB Đà Nẵng” có quốc tịch “Brazil”.


USE QLBongDa
GO
CREATE PROCEDURE SPCau1
	@tenclb NVARCHAR(100),
	@tenqg NVARCHAR(60)
AS
BEGIN 
	SELECT CT.MACT, CT.HOTEN, CT.NGAYSINH, CT.DIACHI, CT.VITRI
	FROM CAUTHU CT,CAULACBO CLB, QUOCGIA QG
	WHERE CT.MACLB=CLB.MACLB AND CT.MAQG=QG.MAQG AND CLB.TenCLB = @tenclb AND QG.TenQG = @tenqg
END
GO


--2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2,
--KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009.
USE QLBongDa
GO
CREATE PROCEDURE SPCau2 
	@vong INT,
	@nam INT
AS
BEGIN
	SELECT TD.MATRAN, TD.NGAYTD,SVD.TENSAN, CLB1.TENCLB AS TENCLB1, CLB2.TENCLB AS TENCLB2, TD.KETQUA
	FROM TRANDAU TD, SANVD SVD, CAULACBO CLB1,CAULACBO CLB2
	WHERE TD.MASAN=SVD.MASAN AND TD.MACLB1=CLB1.MACLB AND TD.MACLB2=CLB2.MACLB AND TD.VONG = @vong AND TD.NAM = @nam
END
GO



--3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, 
--vai trò và tên CLB đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”.
USE QLBongDa
GO
CREATE PROCEDURE SPCau3 
	@tenqg NVARCHAR(100)
AS
BEGIN
	SELECT HLV.MAHLV,HLV.TENHLV,HLV.NGAYSINH,HLV.DIACHI,HC.VAITRO,CLB.TENCLB
	FROM CAULACBO CLB,HUANLUYENVIEN HLV, HLV_CLB HC, QUOCGIA QG
	WHERE CLB.MACLB=HC.MACLB AND HLV.MAHLV=HC.MAHLV AND HLV.MAQG=QG.MAQG AND QG.TENQG= @tenqg
END
GO


--4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ
--và số lượng cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng
--của các câu lạc bộ có nhiều hơn 2 cầu thủ nước ngoài.


USE QLBongDa
GO
CREATE PROCEDURE SPCau4 
	@tenqg NVARCHAR(100)
AS
BEGIN
	SELECT CLB.MaCLB, CLB.TenCLB, SVD.TENSAN, SVD.DIACHI, COUNT(CT.MACT) as SoLuongCauThuNuocNgoai
	FROM CAULACBO CLB,SANVD SVD,CAUTHU CT, QUOCGIA QG
	WHERE CLB.MASAN = SVD.MASAN AND CLB.MACLB = CT.MACLB AND CT.MAQG=QG.MAQG AND QG.TENQG <> @tenqg
	GROUP BY CLB.MACLB, CLB.TENCLB, SVD.TENSAN, SVD.DIACHI
	HAVING COUNT(CT.MACT) > 2;
END
GO


--5. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo
--trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý.

USE QLBongDa
GO
CREATE PROCEDURE SPCau5
	@vitri NVARCHAR(20)
AS
BEGIN
	SELECT T.TENTINH,COUNT(CT.MACT) AS SOLUONGCAUTHU
	FROM CAUTHU CT,TINH T,CAULACBO CLB
	WHERE CLB.MATINH=T.MATINH AND CT.MACLB=CLB.MACLB AND CT.VITRI=@vitri
	GROUP BY T.TENTINH
END
GO


