
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