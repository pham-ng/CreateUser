
--TẠO VÀ PHÂN QUYỀN TÀI KHOẢN--

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


--e Tạo stored procedure với yêu cầu cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí
--của các cầu thủ thuộc đội bóng “SHB Đà Nẵng” và tên quốc tịch = “Brazil”, trong
--đó tên đội bóng/câu lạc bộ và tên quốc tịch/quốc gia là 2 tham số của stored procedure.
--i) Tên stored procedure: SP_SEL_NO_ENCRYPT

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


--Khởi tạo một biến để chứa tên của từng stored procedure trong CSDL:
DECLARE @name VARCHAR(128)

--Khởi tạo một con trỏ để lấy tên của từng stored procedure:
DECLARE cur CURSOR FOR SELECT name FROM sys.objects WHERE type = 'P'

--Mở con trỏ, lấy tên của stored procedure đầu tiên:
OPEN cur

FETCH NEXT FROM cur INTO @name
--Sử dụng vòng lặp while để lặp qua từng stored procedure trong CSDL và encrypt:
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = N'ALTER PROCEDURE ' + QUOTENAME(@name) + N' WITH ENCRYPTION'
    EXEC sp_executesql @sql

    FETCH NEXT FROM cur INTO @name
END
--Đóng và giải phóng con trỏ:
CLOSE cur
DEALLOCATE cur
