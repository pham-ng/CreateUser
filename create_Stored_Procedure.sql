
--j) Tạo và phân quyền trên Stored Procedure:

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


--SPCau6
create procedure SPCau6 @Vong int,@Nam int
as
		SELECT CLB.TENCLB,T.TENTINH
		FROM CAULACBO CLB 
			 INNER JOIN TINH T ON CLB.MATINH=T.MATINH 
			 INNER JOIN BANGXH BXH ON BXH.MACLB=CLB.MACLB
		WHERE BXH.NAM=@Nam AND BXH.VONG=@Vong AND BXH.HANG=1
go


exec SPCau6 @vong = 3,@Nam=2009



--SPCau7
create procedure SPCau7 
as
		SELECT HLV.TENHLV
		FROM  HLV_CLB hlvclb
		      INNER JOIN HUANLUYENVIEN HLV ON hlvclb.MAHLV=HLV.MAHLV
			  INNER JOIN CAULACBO CLB ON CLB.MACLB=hlvclb.MACLB
		WHERE HLV.DIENTHOAI IS NULL AND hlvclb.VAITRO IS NOT NULL
go

exec spcau7

--SPCau8
create procedure SPCau8 @TenQG nvarchar(60) 
as
SELECT HLV.*
		FROM HUANLUYENVIEN HLV
			 INNER JOIN QUOCGIA QG ON QG.MAQG=HLV.MAQG
		WHERE NOT EXISTS (
						  SELECT *
						  FROM HLV_CLB
						  WHERE HLV_CLB.MAHLV = HLV.MAHLV)
        AND QG.TENQG LIKE @TenQG
go

exec spcau8  @tenqg = N'Việt Nam'
go

--SPCau9

create  procedure SPCau9 @Vong int, @Nam int
as
select NGAYTD, TENSAN,clb1.TENCLB as TENCLB1,clb2.TENCLB as TENCLB2,KETQUA, TRANDAU.VONG
from TRANDAU join CAULACBO as clb1 on TRANDAU.MACLB1=clb1.MACLB
				join CAULACBO as clb2 on TRANDAU.MACLB2=clb2.MACLB
					join BANGXH on clb1.MACLB=BANGXH.MACLB or clb2.MACLB=BANGXH.MACLB
						join SANVD on SANVD.MASAN=TRANDAU.MASAN
where TRANDAU.VONG<=3 and (clb1.MACLB=(select MACLB from BANGXH where HANG=1 and VONG=@Vong and NAM = @Nam) 
		or clb2.MACLB=(select MACLB from BANGXH where HANG=1 and VONG=@Vong and NAM = @Nam))
group by NGAYTD, TENSAN,clb1.TENCLB,clb2.TENCLB ,KETQUA, TRANDAU.VONG
go

exec spCau9 @vong = '3' ,@Nam=2009


--SPcau10 
create  procedure SPCau10 @Vong int, @Nam int
as
select NGAYTD, TENSAN,clb1.TENCLB as TENCLB1,clb2.TENCLB as TENCLB2,KETQUA, TRANDAU.VONG
from TRANDAU join CAULACBO as clb1 on TRANDAU.MACLB1=clb1.MACLB
				join CAULACBO as clb2 on TRANDAU.MACLB2=clb2.MACLB
					join BANGXH on clb1.MACLB=BANGXH.MACLB or clb2.MACLB=BANGXH.MACLB
						join SANVD on SANVD.MASAN=TRANDAU.MASAN
where TRANDAU.VONG<3 and (clb1.MACLB=(select MACLB from BANGXH where VONG=@vong and HANG=5 and NAM = @Nam) 
		or clb2.MACLB=(select MACLB from BANGXH where VONG=@vong and HANG=5 and NAM = @Nam))
group by NGAYTD, TENSAN,clb1.TENCLB,clb2.TENCLB ,KETQUA, TRANDAU.VONG

go


exec spCau10 @vong = '3',@Nam=2009
go


--PHAN QUYEN
use QLBongDa
--BDRead--
grant execute to BDRead


--PHAN QUYEN
use QLBongDa
--BDRead--
grant execute to BDRead

--BDU01

grant execute on SPCau5 to BDU01
grant execute on SPCau6 to BDU01
grant execute on SPCau7 to BDU01
grant execute on SPCau8 to BDU01
grant execute on SPCau9 to BDU01
grant execute on SPCau10 to BDU01

--BDU03
grant execute on SPCau1 to BDU03
grant execute on SPCau2 to BDU03
grant execute on SPCau3 to BDU03
grant execute on SPCau4 to BDU03

--BDU04
grant execute on SPCau1 to BDU04
grant execute on SPCau2 to BDU04
grant execute on SPCau3 to BDU04
grant execute on SPCau4 to BDU04
