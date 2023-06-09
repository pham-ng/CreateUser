﻿
--i) Tạo và phân quyền trên Views:


--1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ 
--thuộc đội bóng “SHB Đà Nẵng” có quốc tịch “Brazil”.


USE QLBongDa
GO
  
CREATE VIEW vCau1
AS
	SELECT CT.MACT, CT.HOTEN, CT.NGAYSINH, CT.DIACHI, CT.VITRI
	FROM CAUTHU CT JOIN CAULACBO CLB ON CT.MACLB = CLB.MACLB 
					JOIN QUOCGIA QG ON CT.MAQG = QG.MAQG
	WHERE CLB.TENCLB = N'SHB ĐÀ NẴNG' AND QG.TENQG = N'BRAZIL';
GO
SELECT * FROM vCau1

--2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2,
--KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009.
USE QLBongDa
GO

CREATE VIEW vCau2
AS  
	SELECT TD.MATRAN, TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB 'TENCLB1', CLB2.TENCLB 'TENCLB2', TD.KETQUA 
	FROM TRANDAU TD JOIN SANVD SVD ON TD.MASAN=SVD.MASAN 
					JOIN CAULACBO CLB1 ON TD.MACLB1 = CLB1.MACLB
					JOIN CAULACBO CLB2 ON TD.MACLB2 = CLB2.MACLB
	WHERE TD.VONG = 3 AND TD.NAM = 2009;
GO
SELECT * FROM vCau2


--3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, 
--vai trò và tên CLB đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”.
USE QLBongDa
GO
CREATE VIEW vCau3
AS  
	SELECT HLV.MAHLV, HLV.TENHLV, HLV.NGAYSINH, HLV.DIACHI, HLV_CLB.VAITRO, CLB.TENCLB
	FROM HUANLUYENVIEN HLV JOIN QUOCGIA QG ON HLV.MAQG = QG.MAQG
							JOIN HLV_CLB ON HLV.MAHLV = HLV_CLB.MAHLV
							JOIN CAULACBO CLB ON HLV_CLB.MACLB = CLB.MACLB
	WHERE QG.TENQG = N'Việt Nam';
GO
SELECT * FROM vCau3

--4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ
--và số lượng cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng
--của các câu lạc bộ có nhiều hơn 2 cầu thủ nước ngoài.


USE QLBongDa
GO
CREATE VIEW vCau4
AS
		SELECT CLB.MACLB, CLB.TENCLB, SVD.TENSAN, SVD.DIACHI, COUNT(CT.MACT) 'SO_LUONG_CAU_THU_NUOC_NGOAI'
		FROM CAULACBO CLB JOIN SANVD SVD ON CLB.MASAN = SVD.MASAN
						  JOIN CAUTHU CT ON CLB.MACLB = CT.MACLB
						  JOIN QUOCGIA QG ON CT.MAQG = QG.MAQG
		WHERE QG.TENQG <> N'Việt Nam'
		GROUP BY CLB.MACLB, CLB.TENCLB, SVD.TENSAN, SVD.DIACHI
		HAVING COUNT(CT.MACT) > 2;
GO
SELECT * FROM vCau4


--5. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo
--trong các câu lạc bộ thuộc địa bàn tỉnh đó quản lý.
USE QLBongDa
GO

CREATE VIEW vCau5
AS
		SELECT T.TENTINH, COUNT(A.MACT) AS SO_LUONG_TIEN_DAO 
		FROM TINH T LEFT JOIN CAULACBO CLB ON CLB.MATINH = T.MATINH 
					LEFT JOIN (SELECT * FROM CAUTHU CT WHERE CT.VITRI = N'Tiền đạo') A ON CLB.MACLB = A.MACLB
		GROUP BY T.MATINH, T.TENTINH;
GO
SELECT * FROM vCau5

--6. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất 
-- của bảng xếp hạng của vòng 3, năm 2009.

CREATE VIEW vCau6 
AS
		SELECT CLB.TENCLB, T.TENTINH
		FROM CAULACBO CLB 
			INNER JOIN TINH T ON CLB.MATINH=T.MATINH 
			INNER JOIN (SELECT MACLB, VONG, NAM, HANG 
						FROM BANGXH 
						WHERE VONG = 3 AND NAM = 2009 AND HANG = 1) BXH ON BXH.MACLB = CLB.MACLB;
GO

SELECT * FROM vCau6

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
SELECT * FROM vCau7

--8 Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn
--luyện tại bất kỳ một câu lạc bộ nào.

CREATE VIEW vCau8
AS
		SELECT HLV.*
		FROM HUANLUYENVIEN HLV
			INNER JOIN QUOCGIA QG ON QG.MAQG = HLV.MAQG
		WHERE QG.TENQG LIKE N'Việt Nam'
		AND NOT EXISTS (SELECT * FROM HLV_CLB hlvclb WHERE hlvclb.MAHLV = HLV.MAHLV)
GO	

SELECT * FROM vCau8

--9 Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2,
--KETQUA) của câu lạc bộ CLB đang xếp hạng cao nhất tính đến hết vòng 3 năm
--2009.

CREATE VIEW vCau9 
AS
		SELECT NGAYTD, TENSAN,CLB1.TENCLB AS TENCLB1,CLB2.TENCLB AS TENCLB2,KETQUA, TRANDAU.VONG
		FROM TRANDAU JOIN CAULACBO AS CLB1 ON TRANDAU.MACLB1=CLB1.MACLB
				     JOIN CAULACBO AS CLB2 ON TRANDAU.MACLB2=CLB2.MACLB
					 JOIN BANGXH ON CLB1.MACLB=BANGXH.MACLB OR CLB2.MACLB=BANGXH.MACLB
					 JOIN SANVD ON SANVD.MASAN=TRANDAU.MASAN

		WHERE TRANDAU.VONG<=3 AND (CLB1.MACLB=(SELECT MACLB FROM BANGXH WHERE HANG='1' AND VONG='3' AND NAM = 2009) 
							  OR CLB2.MACLB=(SELECT MACLB FROM BANGXH WHERE HANG='1' AND VONG='3' AND NAM = 2009))
		GROUP BY NGAYTD, TENSAN,CLB1.TENCLB,CLB2.TENCLB ,KETQUA, TRANDAU.VONG		

GO

SELECT * FROM vCau9
--10.Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, 
--KETQUA) của câu lạc bộ CLB có thứ hạng thấp nhất trong bảng xếp hạng vòng 
--3 năm 2009

CREATE VIEW vCau10 
AS
		SELECT NGAYTD, TENSAN,CLB1.TENCLB AS TENCLB1,CLB2.TENCLB AS TENCLB2,KETQUA, TRANDAU.VONG
		FROM TRANDAU JOIN CAULACBO AS CLB1 ON TRANDAU.MACLB1=CLB1.MACLB
				     JOIN CAULACBO AS CLB2 ON TRANDAU.MACLB2=CLB2.MACLB
					 JOIN BANGXH ON CLB1.MACLB=BANGXH.MACLB OR CLB2.MACLB=BANGXH.MACLB
					 JOIN SANVD ON SANVD.MASAN=TRANDAU.MASAN

		WHERE TRANDAU.VONG<3 AND (CLB1.MACLB=(SELECT MACLB FROM BANGXH WHERE VONG='3' AND HANG='5'AND NAM = 2009) 
							OR CLB2.MACLB=(SELECT MACLB FROM BANGXH WHERE VONG='3' AND HANG='5' AND NAM = 2009))
		GROUP BY NGAYTD, TENSAN,CLB1.TENCLB,CLB2.TENCLB ,KETQUA, TRANDAU.VONG


GO
SELECT * FROM vCau10
--Phân quyền
USE [QLBongda]
GO

--BDRead
--Có quyền đọc trên mọi đối tượng
--BDU01
GRANT SELECT ON vCau5 TO BDU01
GRANT SELECT ON vCau6 TO BDU01
GRANT SELECT ON vCau7 TO BDU01
GRANT SELECT ON vCau9 TO BDU01
GRANT SELECT ON vCau10 TO BDU01

--BDU03

GRANT SELECT ON vCau1 TO BDU03
GRANT SELECT ON vCau2 TO BDU03
GRANT SELECT ON vCau3 TO BDU03
GRANT SELECT ON vCau4 TO BDU03

--BDU04

GRANT SELECT ON vCau1 TO BDU04
GRANT SELECT ON vCau2 TO BDU04
GRANT SELECT ON vCau3 TO BDU04
GRANT SELECT ON vCau4 TO BDU04


