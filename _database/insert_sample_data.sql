-- Chỉ chỉ định sử dụng đúng database đã tạo
USE quanlythuvien;

-- Đảm bảo làm sạch dữ liệu cũ trong bảng trước khi chèn mới (Dùng khóa ngoại kiểm tra tạm tắt)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE fines;
TRUNCATE TABLE borrow_details;
TRUNCATE TABLE borrow_records;
TRUNCATE TABLE book_recommendations;
TRUNCATE TABLE book_recommends;
TRUNCATE TABLE readers;
TRUNCATE TABLE users;
TRUNCATE TABLE book_copies;
TRUNCATE TABLE books;
TRUNCATE TABLE categories;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- CHÈN DỮ LIỆU MẪU HỢP NHẤT VỚI KIẾN TRÚC MỚI
-- ==========================================

-- 1. Dữ liệu Danh mục sách
INSERT INTO categories (category_id, name, description) VALUES
(1, 'Công nghệ thông tin', 'Sách về lập trình, mạng máy tính, AI, cơ sở dữ liệu...'),
(2, 'Văn học & Nghệ thuật', 'Tiểu thuyết, truyện ngắn, thơ ca, danh tác cổ điển...'),
(3, 'Kinh tế & Kinh doanh', 'Sách về quản trị, tài chính, khởi nghiệp, marketing...');

-- 2. Dữ liệu Đầu sách (Không còn cột quantity vì đã chuyển xuống bản sao)
INSERT INTO books (book_id, category_id, title, author, publisher, publish_year) VALUES
(1, 1, 'Lập trình JWDa Web căn bản', 'Nguyễn Văn B', 'NXB Giáo Dục', 2024),
(2, 1, 'Cấu trúc dữ liệu và Giải thuật', 'Trần Minh C', 'NXB Khoa Học', 2023),
(3, 2, 'Số đỏ', 'Vũ Trọng Phụng', 'NXB Văn Học', 2020),
(4, 3, 'Nghĩ giàu và Làm giàu', 'Napoleon Hill', 'NXB Trẻ', 2021);

-- 3. Dữ liệu Bản sao sách cụ thể (Mỗi đầu sách có nhiều bản sao vật lý trên kệ)
INSERT INTO book_copies (copy_id, book_id, barcode, status, location_shelf) VALUES
(1, 1, 'JWD-001', 'Available', 'Kệ A1-01'),
(2, 1, 'JWD-002', 'Borrowed', 'Kệ A1-01'), -- Đang được mượn bởi Hoàng (Record 1)
(3, 1, 'JWD-003', 'Available', 'Kệ A1-02'),
(4, 2, 'DSA-001', 'Available', 'Kệ A2-01'),
(5, 2, 'DSA-002', 'Available', 'Kệ A2-01'),
(6, 3, 'SDO-001', 'Available', 'Kệ B1-01'), -- Đã trả bởi Hà (Record 2)
(7, 4, 'NGL-001', 'Available', 'Kệ C1-01');

-- 4. Dữ liệu Tài khoản Quản trị / Nhân sự
INSERT INTO users (user_id, username, password, full_name, role) VALUES
(1, 'admin', '12345', 'Nguyễn Văn A', 'Admin'),
(2, 'thuthu01', '67890', 'Lê Thị Đào', 'Staff');

-- 5. Dữ liệu Độc giả (Bổ sung hạn thẻ và trạng thái hoạt động)
INSERT INTO readers (reader_id, full_name, phone, email, membership_expired_at, status) VALUES
(1, 'Phạm Minh Hoàng', '0912345678', 'hoangpm@gmail.com', '2027-12-31 23:59:59', 'Active'),
(2, 'Đỗ Thu Hà', '0987654321', 'hadt@gmail.com', '2027-06-30 23:59:59', 'Active');

-- 6. Dữ liệu Lượt mượn sách tổng quát (Bỏ ngày mượn/hạn trả vì đã chuyển xuống chi tiết)
INSERT INTO borrow_records (borrow_record_id, reader_id, user_id) VALUES
(1, 1, 2), -- Phiếu 1: Hoàng mượn
(2, 2, 2); -- Phiếu 2: Hà mượn

-- 7. Dữ liệu Chi tiết các cuốn sách được mượn (Lấy khóa ngoại copy_id và lưu ngày riêng biệt)
INSERT INTO borrow_details (borrow_detail_id, borrow_record_id, copy_id, borrow_date, due_date, return_date, status) VALUES
(1, 1, 2, '2026-06-20', '2026-06-27', NULL, 'Borrowing'),        -- Lượt 1: Hoàng mượn cuốn JWDa (copy_id=2), chưa trả
(2, 2, 6, '2026-06-10', '2026-06-17', '2026-06-20', 'Returned');    -- Lượt 2: Hà mượn cuốn Số đỏ (copy_id=6), trễ hạn 3 ngày

-- 8. Dữ liệu Phí phạt (Phát sinh từ lượt mượn trễ hạn của Hà)
INSERT INTO fines (fine_id, borrow_detail_id, amount, reason, status, paid_at, received_by) VALUES
(1, 2, 15000.00, 'Overdue', 'Paid', '2026-06-20 10:30:00', 2); -- Hà trả trễ hạn 3 ngày bị phạt 15.000đ, đã thanh toán cho thủ thư Đào

-- 9. Dữ liệu Đề xuất sách mới (Do Thủ thư ghi nhận từ yêu cầu của độc giả, hỗ trợ xóa mềm)
INSERT INTO book_recommendations (recommendation_id, reader_name, reader_phone, reader_code, book_title, author, reason, status, created_by) VALUES
(1, 'Phạm Minh Hoàng', '0912345678', 'DG001', 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Học sinh mượn để nghiên cứu làm đồ án tốt nghiệp.', 'Pending', 2),
(2, 'Đỗ Thu Hà', '0987654321', 'DG002', 'Bắt đầu với Python', 'Eric Matthes', 'Đọc giả cần tài liệu tự học Python căn bản.', 'Pending', 2);

-- 10. Dữ liệu Nhật ký đối soát mẫu
INSERT INTO audit_logs (log_id, user_id, action, table_name, record_id, old_values, new_values) VALUES
(1, 1, 'INSERT', 'books', 1, NULL, '{"title": "Lập trình JWDa Web căn bản", "author": "Nguyễn Văn B"}');