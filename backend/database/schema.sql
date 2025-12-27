-- MySQL 8.0.44 Database Schema for Shoes Store App
-- Generated from SQLite schema
-- Date: 2025-12-17

-- Drop existing tables if they exist (in reverse dependency order)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS LoginHistory;
DROP TABLE IF EXISTS PurchaseItem;
DROP TABLE IF EXISTS Purchase;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS ProductImage;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS ProductBase;
DROP TABLE IF EXISTS Manufacturer;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- Manufacturer (제조사)
-- ============================================
CREATE TABLE Manufacturer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mName VARCHAR(255) NOT NULL,
    UNIQUE INDEX idx_manufacturer_name (mName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ProductBase (제품 기본 정보)
-- ============================================
-- Note: 같은 모델의 다른 색상은 허용 (pModelNumber + pColor 복합 UNIQUE)
CREATE TABLE ProductBase (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(255) NOT NULL,
    pDescription TEXT,
    pColor VARCHAR(100),
    pGender VARCHAR(50),
    pStatus VARCHAR(100),
    pFeatureType VARCHAR(100),
    pCategory VARCHAR(100),
    pModelNumber VARCHAR(100),
    UNIQUE INDEX idx_productbase_model_color (pModelNumber, pColor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ProductImage (제품 이미지)
-- ============================================
CREATE TABLE ProductImage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pbid INT NOT NULL,
    imagePath VARCHAR(500) NOT NULL,
    FOREIGN KEY (pbid) REFERENCES ProductBase(id) ON DELETE CASCADE,
    INDEX idx_product_image_pbid (pbid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Product (제품)
-- ============================================
CREATE TABLE Product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pbid INT NOT NULL,
    mfid INT NOT NULL,
    size INT NOT NULL,
    basePrice INT NOT NULL,
    pQuantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (pbid) REFERENCES ProductBase(id) ON DELETE CASCADE,
    FOREIGN KEY (mfid) REFERENCES Manufacturer(id) ON DELETE CASCADE,
    INDEX idx_product_pbid (pbid),
    INDEX idx_product_mfid (mfid),
    UNIQUE INDEX idx_product_pbid_size (pbid, size)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Customer (고객)
-- ============================================
CREATE TABLE Customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cEmail VARCHAR(255) NOT NULL,
    cPhoneNumber VARCHAR(50) NOT NULL,
    cName VARCHAR(255) NOT NULL,
    cPassword VARCHAR(255) NOT NULL,
    cProfileImage MEDIUMBLOB NULL,
    UNIQUE INDEX idx_customer_email (cEmail),
    UNIQUE INDEX idx_customer_phone (cPhoneNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Employee (직원/관리자)
-- ============================================
CREATE TABLE Employee (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eEmail VARCHAR(255) NOT NULL,
    ePhoneNumber VARCHAR(50) NOT NULL,
    eName VARCHAR(255) NOT NULL,
    ePassword VARCHAR(255) NOT NULL,
    eRole VARCHAR(100),
    eProfileImage MEDIUMBLOB NULL,
    UNIQUE INDEX idx_employee_email (eEmail),
    UNIQUE INDEX idx_employee_phone (ePhoneNumber),
    INDEX idx_employee_role (eRole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Purchase (주문)
-- ============================================
CREATE TABLE Purchase (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cid INT NOT NULL,
    pickupDate VARCHAR(50),
    orderCode VARCHAR(100) NOT NULL,
    timeStamp VARCHAR(50),
    FOREIGN KEY (cid) REFERENCES Customer(id) ON DELETE CASCADE,
    INDEX idx_purchase_cid (cid),
    UNIQUE INDEX idx_purchase_order_code (orderCode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PurchaseItem (주문 항목)
-- ============================================
CREATE TABLE PurchaseItem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pid INT NOT NULL,
    pcid INT NOT NULL,
    pcQuantity INT NOT NULL,
    pcStatus VARCHAR(100) NOT NULL,
    FOREIGN KEY (pid) REFERENCES Product(id) ON DELETE CASCADE,
    FOREIGN KEY (pcid) REFERENCES Purchase(id) ON DELETE CASCADE,
    INDEX idx_purchase_item_pcid (pcid),
    INDEX idx_purchase_item_pid (pid),
    INDEX idx_purchase_item_status (pcStatus)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- LoginHistory (로그인 이력)
-- ============================================
CREATE TABLE LoginHistory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cid INT NOT NULL,
    loginTime VARCHAR(50),
    lStatus VARCHAR(50),
    lVersion DECIMAL(5,2),
    lAddress VARCHAR(255),
    lPaymentMethod VARCHAR(100),
    FOREIGN KEY (cid) REFERENCES Customer(id) ON DELETE CASCADE,
    INDEX idx_login_history_cid (cid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

