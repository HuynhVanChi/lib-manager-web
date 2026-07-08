-- CẬP NHẬT CƠ SỞ DỮ LIỆU - DỰ ÁN LIBRARYOS
-- MODULE: ĐỀ XUẤT MUA SÁCH MỚI (LƯU HÀNH NỘI BỘ - HỖ TRỢ THÙNG RÁC)
USE quanlythuvien;

-- Hủy các bảng cũ liên quan
DROP TABLE IF EXISTS recommendation_forms;
DROP TABLE IF EXISTS book_recommendations;
DROP TABLE IF EXISTS book_recommends;

-- 1. Bảng lưu Đề xuất sách mới (Do Thủ thư ghi nhận từ yêu cầu của độc giả, hỗ trợ xóa mềm)
CREATE TABLE book_recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_name VARCHAR(255) NOT NULL,
    reader_phone VARCHAR(50),
    reader_code VARCHAR(100),
    book_title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    category VARCHAR(150),
    publisher VARCHAR(150),
    publish_year INT,
    reason TEXT,
    note TEXT,
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    created_by INT NOT NULL,              -- Cán bộ ghi nhận yêu cầu
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL, -- Hỗ trợ xóa mềm (thùng rác)
    deleted_by INT NULL,                  -- Người thực hiện xóa

    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (deleted_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2. Nạp dữ liệu mẫu
-- Thủ thư Lê Thị Đào (user_id = 2) ghi nhận đề xuất từ độc giả
INSERT INTO book_recommendations (recommendation_id, reader_name, reader_phone, reader_code, book_title, author, category, publisher, publish_year, reason, note, status, created_by) VALUES
(1, 'Phạm Minh Hoàng', '0912345678', 'DG001', 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Công nghệ thông tin', 'Prentice Hall', 2008, 'Học sinh mượn để nghiên cứu làm đồ án tốt nghiệp.', 'Cần mua gấp trước kỳ thi', 'Pending', 2),
(2, 'Đỗ Thu Hà', '0987654321', 'DG002', 'Bắt đầu với Python', 'Eric Matthes', 'Công nghệ thông tin', 'NXB Trẻ', 2021, 'Đọc giả cần tài liệu tự học Python căn bản.', 'Sách phổ thông dễ tiếp cận', 'Pending', 2);
