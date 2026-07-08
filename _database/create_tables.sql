-- KHỞI TẠO DATABASE QUANLYTHUVIEN
CREATE DATABASE IF NOT EXISTS quanlythuvien CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quanlythuvien;

-- Xóa các bảng cũ theo thứ tự ngược của khóa ngoại để tránh lỗi xung đột liên kết
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS borrow_details;
DROP TABLE IF EXISTS borrow_records;
DROP TABLE IF EXISTS book_recommendations;
DROP TABLE IF EXISTS book_recommends;
DROP TABLE IF EXISTS readers;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;

-- 1. BẢNG DANH MỤC SÁCH (Hỗ trợ Xóa mềm)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color_theme VARCHAR(50) NOT NULL DEFAULT 'indigo', -- Hỗ trợ 10 tông màu: blue, indigo, purple, pink, rose, red, orange, amber, emerald, teal (mặc định fallback: slate)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_name VARCHAR(255) GENERATED ALWAYS AS (IF(deleted_at IS NULL, name, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_category (active_name)
) ENGINE=InnoDB;

-- 2. BẢNG ĐẦU SÁCH (Lưu thông tin thư tịch chung - Hỗ trợ Xóa mềm)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL, -- Bắt buộc phải chọn danh mục khi tạo sách
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    publisher VARCHAR(255),
    publish_year INT,
    image_path VARCHAR(255) DEFAULT NULL,
    price DECIMAL(12, 0) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. BẢNG BẢN SAO SÁCH VẬT LÝ (Quản lý cuốn sách cụ thể - Hỗ trợ Xóa mềm)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'Available', -- 'Available' (Sẵn sàng), 'Borrowed' (Đang mượn), 'Damaged' (Hỏng), 'Lost' (Mất), 'Decommissioned' (Thanh lý)
    location_shelf VARCHAR(100),
    price DECIMAL(12, 0) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_barcode VARCHAR(100) GENERATED ALWAYS AS (IF(deleted_at IS NULL, barcode, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_barcode (active_barcode),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. BẢNG NHÂN VIÊN / THỦ THƯ (Hỗ trợ Xóa mềm)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL, -- Bắt buộc họ tên hiển thị trên header chào mừng
    role VARCHAR(50) DEFAULT 'Staff', -- 'Admin', 'Staff'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_username VARCHAR(100) GENERATED ALWAYS AS (IF(deleted_at IS NULL, username, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_username (active_username)
) ENGINE=InnoDB;

-- 5. BẢNG ĐỘC GIẢ (Hỗ trợ Xóa mềm & Thẻ thành viên)
CREATE TABLE readers (
    reader_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) NOT NULL, -- Bắt buộc email làm định danh tài khoản độc giả
    membership_expired_at TIMESTAMP NULL,
    status VARCHAR(50) DEFAULT 'Active', -- 'Active', 'Suspended', 'Expired'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_email VARCHAR(100) GENERATED ALWAYS AS (IF(deleted_at IS NULL, email, NULL)) VIRTUAL,
    active_phone VARCHAR(20) GENERATED ALWAYS AS (IF(deleted_at IS NULL, phone, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_email (active_email),
    UNIQUE KEY uq_active_phone (active_phone)
) ENGINE=InnoDB;

-- 6. BẢNG PHIẾU MƯỢN (Thông tin chung - Không xóa mềm)
CREATE TABLE borrow_records (
    borrow_record_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 7. BẢNG CHI TIẾT PHIẾU MƯỢN (Có gia hạn và hạn trả riêng - Không xóa mềm)
CREATE TABLE borrow_details (
    borrow_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_record_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'Borrowing', -- 'Borrowing' (Đang mượn), 'Returned' (Đã trả), 'Overdue' (Quá hạn), 'Lost' (Báo mất)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (borrow_record_id) REFERENCES borrow_records(borrow_record_id) ON DELETE RESTRICT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. BẢNG QUẢN LÝ PHÍ PHẠT (Không xóa mềm)
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_detail_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(100) NOT NULL, -- 'Overdue' (Trễ hạn), 'Lost Book' (Mất sách), 'Damaged Book' (Hỏng sách)
    status VARCHAR(50) DEFAULT 'Unpaid', -- 'Unpaid' (Chưa đóng), 'Paid' (Đã đóng), 'Waived' (Miễn giảm)
    paid_at TIMESTAMP NULL DEFAULT NULL,
    received_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (borrow_detail_id) REFERENCES borrow_details(borrow_detail_id) ON DELETE RESTRICT,
    FOREIGN KEY (received_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 9. BẢNG ĐỀ XUẤT SÁCH MỚI (LƯU HÀNH NỘI BỘ - HỖ TRỢ THÙNG RÁC)
CREATE TABLE book_recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_name VARCHAR(255) NOT NULL,
    reader_phone VARCHAR(50),
    reader_code VARCHAR(100),
    book_title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    created_by INT NOT NULL,              -- Cán bộ ghi nhận yêu cầu
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL, -- Hỗ trợ xóa mềm (thùng rác)
    deleted_by INT NULL,                  -- Người thực hiện xóa
    
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (deleted_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 10. BẢNG NHẬT KÝ ĐỐI SOÁT HỆ THỐNG (Lưu Audit Logs dạng JSON)
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action VARCHAR(50) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE', 'RESTORE'
    table_name VARCHAR(100) NOT NULL,
    record_id INT NOT NULL,
    old_values JSON DEFAULT NULL,
    new_values JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;


-- 11. THIẾT LẬP CHỈ MỤC TÌM KIẾM (INDEXES) TỐI ƯU HÓA HIỆU NĂNG TÌM KIẾM
CREATE INDEX idx_books_title ON books(title);          -- Tối ưu tìm kiếm sách theo tiêu đề
CREATE INDEX idx_books_author ON books(author);        -- Tối ưu tìm kiếm sách theo tác giả
CREATE INDEX idx_copies_barcode ON book_copies(barcode); -- Tối ưu quét mã vạch bản sao sách