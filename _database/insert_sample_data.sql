-- Chỉ chỉ định sử dụng đúng database đã tạo
USE quanlythuvien;

-- Đảm bảo làm sạch dữ liệu cũ trong bảng trước khi chèn mới (Dùng khóa ngoại kiểm tra tạm tắt)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE fines;
TRUNCATE TABLE borrow_details;
TRUNCATE TABLE borrow_records;
TRUNCATE TABLE book_recommendations;
TRUNCATE TABLE readers;
TRUNCATE TABLE users;
TRUNCATE TABLE book_copies;
TRUNCATE TABLE books;
TRUNCATE TABLE categories;
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- 1. DANH MỤC SÁCH (Đầy đủ tông màu và trạng thái hoạt động/xóa mềm)
-- =========================================================================
INSERT INTO categories (category_id, name, description, color_theme, deleted_at, deleted_by) VALUES
(1, 'Công nghệ thông tin', 'Sách về lập trình, mạng máy tính, AI, cơ sở dữ liệu...', 'indigo', NULL, NULL),
(2, 'Văn học & Nghệ thuật', 'Tiểu thuyết, truyện ngắn, thơ ca, danh tác cổ điển...', 'rose', NULL, NULL),
(3, 'Kinh tế & Kinh doanh', 'Sách về quản trị, tài chính, khởi nghiệp, marketing...', 'amber', NULL, NULL),
(4, 'Kỹ năng sống', 'Sách kỹ năng mềm, phát triển bản thân, tư duy...', 'emerald', NULL, NULL),
(5, 'Khoa học viễn tưởng', 'Tiểu thuyết giả tưởng, vũ trụ, công nghệ tương lai...', 'teal', NULL, NULL),
(6, 'Lịch sử & Triết học', 'Nghiên cứu lịch sử thế giới, triết học phương Đông & phương Tây', 'orange', NULL, NULL),
-- Danh mục bị xóa mềm (Nằm trong thùng rác)
(7, 'Danh mục thử nghiệm', 'Mô tả danh mục đã xóa để kiểm thử tính năng khôi phục', 'indigo', DATE_SUB(NOW(), INTERVAL 2 DAY), 1);

-- =========================================================================
-- 2. ĐẦU SÁCH (books)
-- =========================================================================
INSERT INTO books (book_id, category_id, title, author, publisher, publish_year, price, image_path, deleted_at, deleted_by) VALUES
-- Sách công nghệ thông tin
(1, 1, 'Lập trình Java Web căn bản', 'Nguyễn Văn B', 'NXB Giáo Dục', 2024, 79000, 'assets/images/books/book_jwd.png', NULL, NULL),
(2, 1, 'Cấu trúc dữ liệu và Giải thuật', 'Trần Minh C', 'NXB Khoa Học', 2023, 95000, 'assets/images/books/book_dsa.png', NULL, NULL),
(3, 1, 'Life 3.0: Loài người trong kỷ nguyên Trí tuệ Nhân tạo', 'Max Tegmark', 'NXB Thế Giới', 2020, 189000, 'assets/images/books/life30.jpg', NULL, NULL),
-- Sách văn học
(4, 2, 'Số đỏ', 'Vũ Trọng Phụng', 'NXB Văn Học', 2020, 55000, 'assets/images/books/book_sdo.png', NULL, NULL),
(5, 2, 'Tắt đèn', 'Ngô Tất Tố', 'NXB Văn Học', 2019, 48000, 'assets/images/books/TatDen.jpg', NULL, NULL),
-- Sách kinh tế
(6, 3, 'Nghĩ giàu và Làm giàu', 'Napoleon Hill', 'NXB Trẻ', 2021, 110000, 'assets/images/books/book_think_rich.png', NULL, NULL),
-- Sách kỹ năng sống
(7, 4, 'Đắc Nhân Tâm', 'Dale Carnegie', 'NXB Tổng Hợp', 2022, 86000, 'assets/images/books/Ebook-Dac-nhan-tam.jpg', NULL, NULL),
-- Sách khoa học (Chưa có bản sao nào - Để test trường hợp đặc biệt)
(8, 5, 'Lược sử thời gian', 'Stephen Hawking', 'NXB Trẻ', 2018, 135000, 'assets/images/books/luocsuthoigian.webp', NULL, NULL),
-- Sách bị xóa mềm (Nằm trong thùng rác)
(9, 1, 'Lập trình Turbo Pascal', 'Quách Tuấn Ngọc', 'NXB Giáo Dục', 2002, 35000, 'assets/images/books/pascal.jpg', DATE_SUB(NOW(), INTERVAL 1 DAY), 1);

-- =========================================================================
-- 3. BẢN SAO SÁCH VẬT LÝ (book_copies - Đa dạng trạng thái)
-- =========================================================================
INSERT INTO book_copies (copy_id, book_id, barcode, status, location_shelf, price, deleted_at, deleted_by) VALUES
-- Sách 1 (Lập trình Java Web căn bản): Có 3 bản sao
(1, 1, 'JWD-001', 'Available', 'Kệ A1-01', 79000, NULL, NULL),
(2, 1, 'JWD-002', 'Borrowed', 'Kệ A1-01', 79000, NULL, NULL), -- Đang được mượn
(3, 1, 'JWD-003', 'Available', 'Kệ A1-02', 79000, NULL, NULL),

-- Sách 2 (Cấu trúc dữ liệu): Có 2 bản sao (Tất cả đều bị mượn -> Sách này hiển thị "Hết sách")
(4, 2, 'DSA-001', 'Borrowed', 'Kệ A2-01', 95000, NULL, NULL), -- Đang mượn trong hạn
(5, 2, 'DSA-002', 'Borrowed', 'Kệ A2-01', 95000, NULL, NULL), -- Đang mượn quá hạn

-- Sách 4 (Số đỏ): Có 2 bản sao
(6, 4, 'SDO-001', 'Damaged', 'Kệ B1-01', 55000, NULL, NULL),  -- Bị hỏng
(7, 4, 'SDO-002', 'Available', 'Kệ B1-02', 55000, NULL, NULL),

-- Sách 6 (Nghĩ giàu làm giàu): Có 2 bản sao
(8, 6, 'NGL-001', 'Lost', 'Kệ C1-01', 110000, NULL, NULL),     -- Báo mất
(9, 6, 'NGL-002', 'Available', 'Kệ C1-01', 110000, NULL, NULL),

-- Sách 7 (Đắc Nhân Tâm): Có 1 bản sao
(10, 7, 'DNT-001', 'Decommissioned', 'Kho Lưu Trữ', 86000, NULL, NULL), -- Đã thanh lý

-- Bản sao bị xóa mềm (Nằm trong thùng rác)
(11, 4, 'SDO-003', 'Available', 'Kệ B1-02', 55000, DATE_SUB(NOW(), INTERVAL 3 DAY), 1);

-- =========================================================================
-- 4. TÀI KHOẢN THỦ THƯ / QUẢN TRỊ (users)
-- =========================================================================
INSERT INTO users (user_id, username, password, full_name, role, deleted_at, deleted_by) VALUES
(1, 'admin', '12345', 'Nguyễn Quản Trị', 'Admin', NULL, NULL),
(2, 'thuthu01', '67890', 'Lê Thủ Thư', 'Staff', NULL, NULL),
-- Thủ thư bị xóa mềm (Kiểm thử thùng rác tài khoản)
(3, 'thuthu_old', 'abcde', 'Trần Cựu Nhân Viên', 'Staff', DATE_SUB(NOW(), INTERVAL 5 DAY), 1);

-- =========================================================================
-- 5. ĐỘC GIẢ (readers - Đủ các loại hạn thẻ và trạng thái khóa)
-- =========================================================================
INSERT INTO readers (reader_id, full_name, phone, email, membership_expired_at, status, deleted_at, deleted_by) VALUES
-- Độc giả hoạt động bình thường
(1, 'Phạm Minh Hoàng', '0912345678', 'hoangpm@gmail.com', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 'Active', NULL, NULL),
(2, 'Đỗ Thu Hà', '0987654321', 'hadt@gmail.com', DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 'Active', NULL, NULL),
-- Độc giả hết hạn thẻ thành viên
(3, 'Nguyễn Văn Nam', '0901234567', 'namnv@gmail.com', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Expired', NULL, NULL),
-- Độc giả đang bị khóa/tạm đình chỉ thẻ (Do vi phạm hoặc nợ phạt)
(4, 'Trần Thị Mai', '0934567890', 'maitt@gmail.com', DATE_ADD(CURDATE(), INTERVAL 3 MONTH), 'Suspended', NULL, NULL),
-- Độc giả bị xóa mềm
(5, 'Lê Hoàng Long', '0977889900', 'longlh@gmail.com', DATE_ADD(CURDATE(), INTERVAL 1 MONTH), 'Active', DATE_SUB(NOW(), INTERVAL 12 HOUR), 1);

-- =========================================================================
-- 6. LƯỢT MƯỢN SÁCH TỔNG QUÁT (borrow_records)
-- =========================================================================
INSERT INTO borrow_records (borrow_record_id, reader_id, user_id, created_at) VALUES
(1, 1, 2, DATE_SUB(NOW(), INTERVAL 3 DAY)), -- Phiếu 1 của Hoàng (3 ngày trước)
(2, 2, 2, DATE_SUB(NOW(), INTERVAL 15 DAY)), -- Phiếu 2 của Hà (15 ngày trước)
(3, 3, 2, DATE_SUB(NOW(), INTERVAL 20 DAY)), -- Phiếu 3 của Nam (20 ngày trước)
(4, 4, 2, DATE_SUB(NOW(), INTERVAL 10 DAY)), -- Phiếu 4 của Mai (10 ngày trước)
(5, 1, 2, NOW());                            -- Phiếu 5 của Hoàng (mượn hôm nay để test chart giờ)

-- =========================================================================
-- 7. CHI TIẾT LƯỢT MƯỢN (borrow_details - Phủ tất cả trạng thái nghiệp vụ)
-- =========================================================================
INSERT INTO borrow_details (borrow_detail_id, borrow_record_id, copy_id, borrow_date, due_date, return_date, status, created_at) VALUES
-- Lượt 1: Hoàng đang mượn cuốn Java Web (trong hạn)
(1, 1, 2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), NULL, 'Borrowing', DATE_SUB(NOW(), INTERVAL 3 DAY)),

-- Lượt 2: Hà đã trả trễ hạn cuốn Số đỏ (trễ 3 ngày, phát sinh phạt)
(2, 2, 6, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Returned', DATE_SUB(NOW(), INTERVAL 15 DAY)),

-- Lượt 3: Hà đã mượn và trả đúng hạn cuốn Sách khác
(3, 2, 7, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Returned', DATE_SUB(NOW(), INTERVAL 5 DAY)),

-- Lượt 4: Nam mượn quá hạn chưa trả (quá hạn 10 ngày)
(4, 3, 5, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), NULL, 'Overdue', DATE_SUB(NOW(), INTERVAL 20 DAY)),

-- Lượt 5: Mai mượn và báo mất sách
(5, 4, 8, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY), NULL, 'Lost', DATE_SUB(NOW(), INTERVAL 10 DAY)),

-- Lượt 6: Hoàng mượn thêm sách hôm nay (Mượn lúc 9h sáng và 15h chiều để vẽ biểu đồ theo giờ trên Dashboard)
(6, 5, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL, 'Borrowing', DATE_ADD(CURDATE(), INTERVAL 9 HOUR)),
(7, 5, 3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL, 'Borrowing', DATE_ADD(CURDATE(), INTERVAL 15 HOUR));

-- =========================================================================
-- 8. PHÍ PHẠT (fines - Đa dạng lý do và trạng thái thanh toán)
-- =========================================================================
INSERT INTO fines (fine_id, borrow_detail_id, amount, reason, status, paid_at, received_by) VALUES
-- Phạt trễ hạn đã đóng (Hà đóng trễ hạn 3 ngày x 5000đ/ngày = 15000đ)
(1, 2, 15000.00, 'Overdue', 'Paid', DATE_SUB(NOW(), INTERVAL 5 DAY), 2),

-- Phạt trễ hạn chưa đóng (Nam trễ hạn 10 ngày x 5000đ/ngày = 50000đ)
(2, 4, 50000.00, 'Overdue', 'Unpaid', NULL, NULL),

-- Phạt mất sách chưa đóng (Mai làm mất cuốn sách giá trị 110000đ)
(3, 5, 110000.00, 'Lost Book', 'Unpaid', NULL, NULL),

-- Phạt làm hỏng sách nhưng được thủ thư miễn giảm (Waived) do lý do bất khả kháng
(4, 2, 30000.00, 'Damaged Book', 'Waived', NULL, NULL);

-- =========================================================================
-- 9. ĐỀ XUẤT SÁCH MỚI (book_recommendations - Đủ trạng thái duyệt & xóa mềm)
-- =========================================================================
INSERT INTO book_recommendations (recommendation_id, reader_name, reader_phone, reader_code, book_title, author, reason, status, created_by, deleted_at, deleted_by) VALUES
-- Đề xuất đang chờ duyệt
(1, 'Phạm Minh Hoàng', '0912345678', 'DG001', 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Sách gối đầu giường của lập trình viên, rất cần thiết cho học sinh làm đồ án.', 'Pending', 2, NULL, NULL),
-- Đề xuất đã được duyệt mua
(2, 'Đỗ Thu Hà', '0987654321', 'DG002', 'Bắt đầu với Python', 'Eric Matthes', 'Cần tài liệu nhập môn Python cơ bản để tự học lập trình.', 'Approved', 1, NULL, NULL),
-- Đề xuất bị từ chối duyệt
(3, 'Nguyễn Văn Nam', '0901234567', 'DG003', 'Kỷ nguyên AI 2030', 'Tác Giả Ẩn Danh', 'Sách không rõ nguồn gốc xuất bản, nội dung chưa được kiểm định.', 'Rejected', 1, NULL, NULL),
-- Đề xuất bị xóa mềm (Nằm trong thùng rác)
(4, 'Người Dùng Ẩn Danh', '0999999999', 'DG999', 'Sách rác không phù hợp', 'Không rõ', 'Đề xuất thử nghiệm để test tính năng xóa', 'Pending', 2, DATE_SUB(NOW(), INTERVAL 1 DAY), 2);

-- =========================================================================
-- 10. NHẬT KÝ ĐỐI SOÁT HỆ THỐNG (audit_logs - Minh họa sinh động các nghiệp vụ)
-- =========================================================================
INSERT INTO audit_logs (log_id, user_id, action, table_name, record_id, old_values, new_values, created_at) VALUES
(1, 1, 'INSERT', 'books', 1, NULL, '{"title": "Lập trình Java Web căn bản", "author": "Nguyễn Văn B", "price": 79000}', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(2, 1, 'UPDATE', 'books', 1, '{"price": 75000}', '{"price": 79000}', DATE_SUB(NOW(), INTERVAL 9 DAY)),
(3, 2, 'INSERT', 'readers', 1, NULL, '{"full_name": "Phạm Minh Hoàng", "email": "hoangpm@gmail.com"}', DATE_SUB(NOW(), INTERVAL 8 DAY)),
(4, 1, 'DELETE', 'categories', 7, '{"name": "Danh mục thử nghiệm", "color_theme": "indigo"}', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 2, 'INSERT', 'book_recommendations', 1, NULL, '{"book_title": "Clean Code", "reader_name": "Phạm Minh Hoàng"}', DATE_SUB(NOW(), INTERVAL 1 DAY));