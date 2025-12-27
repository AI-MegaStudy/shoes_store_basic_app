-- MySQL 8.0.44 Dummy Data for Shoes Store App
-- Generated from DevelopmentDataSet
-- Date: 2025-12-17
-- 
-- Usage:
--   1. Run schema.sql first to create tables
--   2. Run this file to insert dummy data
--   3. Make sure FOREIGN_KEY_CHECKS is enabled

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- Manufacturer (제조사)
-- ============================================
INSERT INTO Manufacturer (mName) VALUES
('Nike'),
('NewBalance');

-- ============================================
-- ProductBase (제품 기본 정보)
-- ============================================
INSERT INTO ProductBase (pName, pDescription, pColor, pGender, pStatus, pCategory, pModelNumber) VALUES
('U740WN2', '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'Black', 'Unisex', '', 'Running', 'NEW009T1'),
('U740WN2', '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'Gray', 'Unisex', '', 'Running', 'NEW009T1'),
('U740WN2', '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'White', 'Unisex', '', 'Running', 'NEW009T1'),
('나이키 샥스 TL', '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'Black', 'Female', '', 'Running', 'NIK321E3'),
('나이키 샥스 TL', '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'Gray', 'Female', '', 'Running', 'NIK321E3'),
('나이키 샥스 TL', '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'White', 'Female', '', 'Running', 'NIK321E3'),
('나이키 에어포스 1', '나이키 에어포스 1은 클래식한 디자인과 현대적인 기술이 결합된 아이콘입니다. 에어 쿠셔닝 기술이 적용되어 편안한 착화감을 제공하며, 다양한 스타일과 어울리는 범용적인 디자인입니다.', 'Black', 'Unisex', '', 'Sneakers', 'AF1-001'),
('나이키 에어포스 1', '나이키 에어포스 1은 클래식한 디자인과 현대적인 기술이 결합된 아이콘입니다. 에어 쿠셔닝 기술이 적용되어 편안한 착화감을 제공하며, 다양한 스타일과 어울리는 범용적인 디자인입니다.', 'Gray', 'Unisex', '', 'Sneakers', 'AF1-001'),
('나이키 에어포스 1', '나이키 에어포스 1은 클래식한 디자인과 현대적인 기술이 결합된 아이콘입니다. 에어 쿠셔닝 기술이 적용되어 편안한 착화감을 제공하며, 다양한 스타일과 어울리는 범용적인 디자인입니다.', 'White', 'Unisex', '', 'Sneakers', 'AF1-001'),
('나이키 페가수스 플러스', '나이키 페가수스 플러스는 러닝을 위한 최적화된 신발입니다. 반응성이 뛰어난 쿠셔닝과 안정적인 지지력으로 장거리 러닝에도 편안함을 제공합니다.', 'Black', 'Unisex', '', 'Running', 'PEG-001'),
('나이키 페가수스 플러스', '나이키 페가수스 플러스는 러닝을 위한 최적화된 신발입니다. 반응성이 뛰어난 쿠셔닝과 안정적인 지지력으로 장거리 러닝에도 편안함을 제공합니다.', 'Gray', 'Unisex', '', 'Running', 'PEG-001'),
('나이키 페가수스 플러스', '나이키 페가수스 플러스는 러닝을 위한 최적화된 신발입니다. 반응성이 뛰어난 쿠셔닝과 안정적인 지지력으로 장거리 러닝에도 편안함을 제공합니다.', 'White', 'Unisex', '', 'Running', 'PEG-001');

-- ============================================
-- ProductImage (제품 이미지)
-- ============================================
-- Note: Only _01 images are used in customer-facing screens
INSERT INTO ProductImage (pbid, imagePath) VALUES
(1, 'images/Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png'),
(2, 'images/Newbalance_U740WN2/Newbalnce_U740WN2_Gray_01.png'),
(3, 'images/Newbalance_U740WN2/Newbalnce_U740WN2_White_01.png'),
(4, 'images/Nike_Shox_TL/Nike_Shox_TL_Black_01.avif'),
(5, 'images/Nike_Shox_TL/Nike_Shox_TL_Gray_01.avif'),
(6, 'images/Nike_Shox_TL/Nike_Shox_TL_White_01.avif'),
(7, 'images/Nike_Air_1/Nike_Air_1_Black_01.avif'),
(8, 'images/Nike_Air_1/Nike_Air_1_Gray_01.avif'),
(9, 'images/Nike_Air_1/Nike_Air_1_White_01.avif'),
(10, 'images/Nike_Pegasus/Nike_Pegasus_Black_01.avif'),
(11, 'images/Nike_Pegasus/Nike_Pegasus_Gray_01.avif'),
(12, 'images/Nike_Pegasus/Nike_Pegasus_White_01.avif');

-- ============================================
-- Product (제품)
-- ============================================
-- U740WN2 - Black (NewBalance, pbid=1, mfid=2)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(1, 2, 220, 100000, 30),
(1, 2, 230, 110000, 30),
(1, 2, 240, 120000, 30),
(1, 2, 250, 130000, 30),
(1, 2, 260, 140000, 30),
(1, 2, 270, 150000, 30),
(1, 2, 280, 160000, 30);

-- U740WN2 - Gray (NewBalance, pbid=2, mfid=2)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(2, 2, 220, 100500, 30),
(2, 2, 230, 101500, 30),
(2, 2, 240, 102500, 30),
(2, 2, 250, 103500, 30),
(2, 2, 260, 104500, 30),
(2, 2, 270, 105500, 30),
(2, 2, 280, 106500, 30);

-- U740WN2 - White (NewBalance, pbid=3, mfid=2)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(3, 2, 220, 102000, 30),
(3, 2, 230, 102100, 30),
(3, 2, 240, 102200, 30),
(3, 2, 250, 102300, 30),
(3, 2, 260, 102400, 30),
(3, 2, 270, 102500, 30),
(3, 2, 280, 102600, 30);

-- 나이키 샥스 TL - Black (Nike, pbid=4, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(4, 1, 220, 180000, 30),
(4, 1, 230, 181000, 30),
(4, 1, 240, 182000, 30),
(4, 1, 250, 183000, 30),
(4, 1, 260, 184000, 30),
(4, 1, 270, 185000, 30),
(4, 1, 280, 186000, 30);

-- 나이키 샥스 TL - Gray (Nike, pbid=5, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(5, 1, 220, 118000, 30),
(5, 1, 230, 123000, 30),
(5, 1, 240, 128000, 30),
(5, 1, 250, 133000, 30),
(5, 1, 260, 138000, 30),
(5, 1, 270, 143000, 30),
(5, 1, 280, 148000, 30);

-- 나이키 샥스 TL - White (Nike, pbid=6, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(6, 1, 220, 98000, 30),
(6, 1, 230, 99500, 30),
(6, 1, 240, 101000, 30),
(6, 1, 250, 102500, 30),
(6, 1, 260, 104000, 30),
(6, 1, 270, 105500, 30),
(6, 1, 280, 107000, 30);

-- 나이키 에어포스 1 - Black (Nike, pbid=7, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(7, 1, 220, 102000, 30),
(7, 1, 230, 103000, 30),
(7, 1, 240, 104000, 30),
(7, 1, 250, 105000, 30),
(7, 1, 260, 106000, 30),
(7, 1, 270, 107000, 30),
(7, 1, 280, 108000, 30);

-- 나이키 에어포스 1 - Gray (Nike, pbid=8, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(8, 1, 220, 175000, 30),
(8, 1, 230, 178000, 30),
(8, 1, 240, 181000, 30),
(8, 1, 250, 184000, 30),
(8, 1, 260, 187000, 30),
(8, 1, 270, 190000, 30),
(8, 1, 280, 193000, 30);

-- 나이키 에어포스 1 - White (Nike, pbid=9, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(9, 1, 220, 135000, 30),
(9, 1, 230, 140000, 30),
(9, 1, 240, 145000, 30),
(9, 1, 250, 150000, 30),
(9, 1, 260, 155000, 30),
(9, 1, 270, 160000, 30),
(9, 1, 280, 165000, 30);

-- 나이키 페가수스 플러스 - Black (Nike, pbid=10, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(10, 1, 220, 112000, 30),
(10, 1, 230, 115000, 30),
(10, 1, 240, 118000, 30),
(10, 1, 250, 121000, 30),
(10, 1, 260, 124000, 30),
(10, 1, 270, 127000, 30),
(10, 1, 280, 130000, 30);

-- 나이키 페가수스 플러스 - Gray (Nike, pbid=11, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(11, 1, 220, 92000, 30),
(11, 1, 230, 94000, 30),
(11, 1, 240, 96000, 30),
(11, 1, 250, 98000, 30),
(11, 1, 260, 100000, 30),
(11, 1, 270, 102000, 30),
(11, 1, 280, 104000, 30);

-- 나이키 페가수스 플러스 - White (Nike, pbid=12, mfid=1)
INSERT INTO Product (pbid, mfid, size, basePrice, pQuantity) VALUES
(12, 1, 220, 198000, 30),
(12, 1, 230, 202000, 30),
(12, 1, 240, 206000, 30),
(12, 1, 250, 210000, 30),
(12, 1, 260, 214000, 30),
(12, 1, 270, 218000, 30),
(12, 1, 280, 222000, 30);

-- ============================================
-- Customer (고객)
-- ============================================
-- cProfileImage: 1x1 픽셀 PNG 플레이스홀더 (테스트용)
INSERT INTO Customer (cEmail, cPhoneNumber, cName, cPassword, cProfileImage) VALUES
('jojo@han.com', '222-9898-1212', '조조', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('handbook@han.com', '999-7676-1987', '손책', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('bigear@han.com', '000-1234-5678', '유비', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('jangryo@han.com', '222-3452-7665', '장료', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('sixhand@han.com', '999-1010-2929', '육손', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('purpledraong@han.com', '000-0987-6543', '조자룡', 'qwer1234', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082);

-- ============================================
-- Employee (직원/관리자)
-- ============================================
-- eProfileImage: 1x1 픽셀 PNG 플레이스홀더 (테스트용)
INSERT INTO Employee (eEmail, ePhoneNumber, eName, ePassword, eRole, eProfileImage) VALUES
('ma@han.com', '222-6789-5432', '사마의', 'qwer1234', '1', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('oiling@han.com', '999-3211-0987', '주유', 'qwer1234', '2', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082),
('gongmyeong@han.com', '000-0987-6543', '제갈공명', 'qwer1234', '3', 0x89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000A49444154789C6300010000050001E2D9A4B50000000049454E44AE426082);

-- ============================================
-- Purchase (주문)
-- ============================================
INSERT INTO Purchase (cid, pickupDate, orderCode, timeStamp) VALUES
(1, '2025-12-13 07:20', 'ORDER-001', '2025-12-12 07:20'),
(1, '2025-12-13 07:20', 'ORDER-002', '2025-12-12 07:20'),
(1, '2025-12-13 07:20', 'ORDER-003', '2025-12-12 07:20'),
(1, '2025-12-13 07:20', 'ORDER-004', '2025-12-12 07:20'),
(1, '2023-12-13 07:20', 'ORDER-005', '2023-12-12 07:20');

-- ============================================
-- PurchaseItem (주문 항목)
-- ============================================
-- Note: pid values are based on Product insertion order
-- Product ID 매핑:
--   ProductBase 1 (U740WN2 Black):     Product ID 1-7   (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 2 (U740WN2 Gray):      Product ID 8-14  (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 3 (U740WN2 White):    Product ID 15-21 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 4 (나이키 샥스 TL Black): Product ID 22-28 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 5 (나이키 샥스 TL Gray): Product ID 29-35 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 6 (나이키 샥스 TL White): Product ID 36-42 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 7 (나이키 에어포스 1 Black): Product ID 43-49 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 8 (나이키 에어포스 1 Gray): Product ID 50-56 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 9 (나이키 에어포스 1 White): Product ID 57-63 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 10 (나이키 페가수스 플러스 Black): Product ID 64-70 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 11 (나이키 페가수스 플러스 Gray): Product ID 71-77 (사이즈 220, 230, 240, 250, 260, 270, 280)
--   ProductBase 12 (나이키 페가수스 플러스 White): Product ID 78-84 (사이즈 220, 230, 240, 250, 260, 270, 280)
--
-- 주문 항목 매핑 (DummyPurchaseItems.development 기준):
--   ORDER-001: pid=1  (ProductBase 0의 첫 번째 사이즈 220 = U740WN2 Black, size 220)
--   ORDER-002: pid=2  (ProductBase 0의 두 번째 사이즈 230 = U740WN2 Black, size 230)
--   ORDER-002: pid=3  (ProductBase 0의 세 번째 사이즈 240 = U740WN2 Black, size 240)
--   ORDER-003: pid=8  (ProductBase 1의 첫 번째 사이즈 220 = U740WN2 Gray, size 220)
--   ORDER-004: pid=9  (ProductBase 1의 두 번째 사이즈 230 = U740WN2 Gray, size 230)
--   ORDER-005: pid=10 (ProductBase 1의 세 번째 사이즈 240 = U740WN2 Gray, size 240)

INSERT INTO PurchaseItem (pid, pcid, pcQuantity, pcStatus) VALUES
(1, 1, 10, '제품 준비 완료'),
(2, 2, 3, '제품 준비 완료'),
(3, 2, 6, '제품 준비 완료'),
(8, 3, 1, '제품 준비 완료'),
(9, 4, 9, '제품 준비 완료'),
(10, 5, 11, '제품 준비 완료');

-- ============================================
-- LoginHistory (로그인 이력)
-- ============================================
INSERT INTO LoginHistory (cid, loginTime, lStatus, lVersion, lAddress, lPaymentMethod) VALUES
(1, '2025-12-12 17:05', '0', 1.0, '강남구', 'KaKaoPay'),
(2, '2025-12-12 19:05', '0', 1.0, '강남구', 'KaKaoPay'),
(3, '2025-12-12 19:20', '0', 1.0, '강남구', 'KaKaoPay'),
(4, '2023-12-12 19:20', '0', 1.0, '강남구', 'KaKaoPay'),
(5, '2025-12-12 07:20', '2', 1.0, '강남구', 'KaKaoPay'),
(6, '2023-12-12 07:20', '1', 1.0, '강남구', 'KaKaoPay');

