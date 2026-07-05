# BÁO CÁO PHÂN TÍCH THIẾT KẾ CƠ SỞ DỮ LIỆU - LIBRARYOS

Tài liệu này cung cấp cái nhìn toàn diện về cấu trúc cơ sở dữ liệu (Database Schema) của dự án Quản lý Thư viện, giải thích lý do đằng sau các quyết định thiết kế và hướng dẫn nhóm lập trình Backend/Frontend phối hợp vận hành an toàn.

---

## I. TỔNG QUAN HỆ THỐNG CƠ SỞ DỮ LIỆU

Cơ sở dữ liệu của chúng ta gồm **10 bảng chính** được thiết kế chuẩn hóa để lưu trữ thông tin sách, độc giả, tài khoản thủ thư, giao dịch mượn trả, quản lý phí phạt và nhật ký hệ thống.

### Sơ đồ liên kết chính (Entity Relationship Overview)
* `categories` (1) <--- (N) `books`
* `books` (1) <--- (N) `book_copies` (Quản lý cuốn sách vật lý)
* `readers` (1) <--- (N) `borrow_records` (Phiếu mượn - Thông tin chung)
* `users` (1) <--- (N) `borrow_records` (Thủ thư duyệt phiếu)
* `borrow_records` (1) <--- (N) `borrow_details` (Chi tiết cuốn sách mượn)
* `book_copies` (1) <--- (N) `borrow_details` (Liên kết bản sao cụ thể)
* `borrow_details` (1) <--- (1) `fines` (Phí phạt phát sinh)
* `readers` (1) <--- (N) `book_recommends` (Độc giả gửi đề xuất sách)
* `users` (1) <--- (N) `book_recommends` (Thủ thư duyệt đề xuất sách)

---

## II. GIẢI THÍCH CHI TIẾT CÁC QUYẾT ĐỊNH THIẾT KẾ (TẠI SAO CẦN NỘI DUNG NÀY?)

Nhóm phát triển cần nắm rõ các giải pháp kiến trúc dưới đây để tránh viết code sai luồng nghiệp vụ:

### 1. Tại sao phải tách thành bảng `books` và `book_copies`?
* **Thực tế:** Thư viện không cho mượn "Đầu sách" chung chung (như tiêu đề cuốn sách), mà cho mượn **"Bản sao vật lý cụ thể"** có dán mã vạch (Barcode) riêng.
* **Quyết định thiết kế:** 
  * Bảng `books` chỉ lưu thông tin thư tịch (Tên sách, tác giả, NXB).
  * Bảng `book_copies` lưu từng cuốn sách cụ thể kèm theo mã vạch (`barcode`) và trạng thái vật lý (`status`: Mới, Hỏng, Mất).
* **Lợi ích:** Cho phép thủ thư theo dõi chính xác vị trí kệ của từng cuốn, đánh dấu hỏng/mất của một cuốn cụ thể mà không làm ảnh hưởng đến các cuốn khác cùng tựa đề.

### 2. Tại sao di chuyển hạn trả (`due_date`) xuống bảng `borrow_details`?
* **Thực tế:** Trong một lần mượn, độc giả có thể mượn nhiều cuốn sách khác loại (ví dụ: giáo trình được mượn 30 ngày, tiểu thuyết chỉ được mượn 14 ngày). Độc giả cũng có thể muốn gia hạn thêm ngày cho cuốn sách A nhưng trả đúng hạn cuốn sách B.
* **Quyết định thiết kế:** Hạn trả (`due_date`) và ngày mượn (`borrow_date`) được lưu ở bảng chi tiết `borrow_details` thay vì bảng cha `borrow_records`.
* **Lợi ích:** Hỗ trợ mượn nhiều sách với thời hạn khác nhau trong cùng một phiếu mượn và cho phép gia hạn độc lập từng cuốn.

### 3. Giải pháp Xóa mềm (Soft Delete) & Khóa Unique Cột ảo (Virtual UNIQUE)
* **Thực tế:** Khi xóa một độc giả hoặc nhân viên, ta không dùng lệnh `DELETE` vật lý (vì sẽ làm mất sạch lịch sử mượn sách/đối soát tài chính). Ta dùng xóa mềm bằng cách set `deleted_at = TIMESTAMP`.
* **Bẫy lỗi UNIQUE của MySQL:** Nếu dùng index UNIQUE thông thường trên cột `username`, khi tài khoản `thuthu01` bị xóa mềm, hệ thống sẽ **không cho phép** tạo tài khoản mới tên `thuthu01` vì bị trùng khóa UNIQUE.
* **Quyết định thiết kế:** Sử dụng cột ảo tính toán tự động:
  ```sql
  active_username VARCHAR(100) GENERATED ALWAYS AS (IF(deleted_at IS NULL, username, NULL)) VIRTUAL
  ```
  Và đánh khóa `UNIQUE` trên cột ảo `active_username` này.
* **Lợi ích:** 
  * Cho phép tạo tài khoản mới trùng tên với tài khoản đã bị xóa mềm (vì tài khoản cũ có `active_username = NULL` - MySQL cho phép nhiều giá trị NULL trùng nhau trên khóa UNIQUE).
  * Đảm bảo **chỉ có tối đa 1 tài khoản hoạt động** chiếm giữ username đó.
  * Tự động chặn đứng hành vi khôi phục (Restore) tài khoản cũ nếu nó trùng tên với tài khoản mới đang hoạt động.

### 4. Tại sao bắt buộc dùng `ENGINE=InnoDB` và Giao dịch (Transaction)?
* **Thực tế:** Khi độc giả trả sách, hệ thống phải thực hiện 2 lệnh: đổi trạng thái phiếu mượn sang `'Returned'` và đổi trạng thái cuốn sách sang `'Available'`. Nếu một trong hai lệnh bị lỗi (do mất mạng, mất điện), dữ liệu sẽ bị lệch.
* **Quyết định thiết kế:** Khai báo cấu trúc bảng sử dụng `ENGINE=InnoDB` (hỗ trợ tính năng Transaction).
* **Lợi ích:** Giúp lập trình viên Backend có thể sử dụng cơ chế Transaction (Giao dịch). Nếu một lệnh lỗi, toàn bộ giao dịch sẽ tự động Rollback (hủy bỏ hoàn toàn), đảm bảo không bao giờ bị lệch kho.

### 5. Tại sao cần bảng Phí phạt (`fines`) và Nhật ký (`audit_logs`)?
* Bảng `fines` ghi nhận rõ ràng số tiền phạt trễ hạn hoặc làm hỏng sách, theo dõi độc giả đã nộp tiền chưa và thủ thư nào đã thu tiền. Đảm bảo tính minh bạch tài chính.
* Bảng `audit_logs` lưu lại vết thay đổi dữ liệu nhạy cảm dưới định dạng `JSON` (ai đã sửa số lượng sách, ai xóa phạt...). Đây là tiêu chuẩn bắt buộc để đối soát dữ liệu.

### 6. Tại sao bảng Đề xuất sách (`book_recommends`) cần kết nối với Độc giả và Thủ thư?
* **Thực tế:** Đề xuất sách là một nghiệp vụ nội bộ của thư viện dành cho độc giả đã đăng ký thành viên. Khi một đề xuất được duyệt hoặc từ chối, ta cần biết rõ: Độc giả nào đã đề xuất? Thủ thư nào đã duyệt hoặc từ chối? Và phản hồi lý do cụ thể là gì?
* **Quyết định thiết kế:** Bổ sung khóa ngoại `reader_id` (Độc giả đề xuất) và `reviewed_by` (Thủ thư duyệt) cùng trường phản hồi `feedback` vào bảng `book_recommends`.
* **Lợi ích:** Độc giả có thể tra cứu lịch sử các đề xuất của riêng mình trên giao diện cá nhân. Đồng thời đảm bảo tính chịu trách nhiệm của thủ thư khi phê duyệt mua sách mới.

---

## III. KHUNG DATABASE DDL SQL HOÀN CHỈNH

Nhóm phát triển chạy file script SQL này trong MySQL Client để khởi tạo database:

```sql
CREATE DATABASE IF NOT EXISTS quanlythuvien CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quanlythuvien;

-- Hủy bảng cũ theo thứ tự ngược để tránh lỗi khóa ngoại
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS fines;
DROP TABLE IF EXISTS borrow_details;
DROP TABLE IF EXISTS borrow_records;
DROP TABLE IF EXISTS book_recommends;
DROP TABLE IF EXISTS readers;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;


-- 1. BẢNG DANH MỤC SÁCH
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_name VARCHAR(255) GENERATED ALWAYS AS (IF(deleted_at IS NULL, name, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_category (active_name)
) ENGINE=InnoDB;


-- 2. BẢNG ĐẦU SÁCH
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL, -- Bắt buộc phải chọn danh mục khi tạo sách
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    publisher VARCHAR(255),
    publish_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 3. BẢNG BẢN SAO SÁCH VẬT LÝ
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'Available', -- 'Available', 'Borrowed', 'Damaged', 'Lost', 'Decommissioned'
    location_shelf VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by INT NULL,
    
    active_barcode VARCHAR(100) GENERATED ALWAYS AS (IF(deleted_at IS NULL, barcode, NULL)) VIRTUAL,
    UNIQUE KEY uq_active_barcode (active_barcode),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 4. BẢNG NHÂN VIÊN / THỦ THƯ
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


-- 5. BẢNG ĐỘC GIẢ
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


-- 6. BẢNG PHIẾU MƯỢN (Thông tin chung)
CREATE TABLE borrow_records (
    borrow_record_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 7. BẢNG CHI TIẾT PHIẾU MƯỢN
CREATE TABLE borrow_details (
    borrow_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_record_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'Borrowing', -- 'Borrowing', 'Returned', 'Overdue', 'Lost'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (borrow_record_id) REFERENCES borrow_records(borrow_record_id) ON DELETE RESTRICT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 8. BẢNG QUẢN LÝ PHÍ PHẠT
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_detail_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(100) NOT NULL, -- 'Overdue', 'Lost Book', 'Damaged Book'
    status VARCHAR(50) DEFAULT 'Unpaid', -- 'Unpaid', 'Paid', 'Waived'
    paid_at TIMESTAMP NULL DEFAULT NULL,
    received_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (borrow_detail_id) REFERENCES borrow_details(borrow_detail_id) ON DELETE RESTRICT,
    FOREIGN KEY (received_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 9. BẢNG ĐỀ XUẤT SÁCH MỚI
CREATE TABLE book_recommends (
    book_recommend_id INT AUTO_INCREMENT PRIMARY KEY,
    reader_id INT NOT NULL, -- Độc giả gửi đề xuất
    book_title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    reason TEXT,
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending' (Chờ duyệt), 'Approved' (Đã duyệt), 'Rejected' (Từ chối)
    feedback TEXT, -- Phản hồi từ thủ thư
    reviewed_by INT NULL, -- Nhân viên duyệt đề xuất
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;


-- 10. BẢNG NHẬT KÝ ĐỐI SOÁT HỆ THỐNG
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


-- 11. CÁC CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG TÌM KIẾM (INDEXES)
CREATE INDEX idx_books_title ON books(title);          -- Tối ưu tìm sách theo tiêu đề
CREATE INDEX idx_books_author ON books(author);        -- Tối ưu tìm sách theo tác giả
CREATE INDEX idx_copies_barcode ON book_copies(barcode); -- Tối ưu tìm kiếm bản sao bằng máy quét mã vạch
```

---

## IV. HƯỚNG DẪN DÀNH CHO LẬP TRÌNH VIÊN BACKEND (JAVA SERVLET)

Nhóm lập trình Backend cần tuân thủ nghiêm ngặt các quy tắc sau khi kết nối với Database này:

### 1. Yêu cầu môi trường chạy MySQL
* Bắt buộc cài đặt **MySQL Server phiên bản 5.7.6 trở lên** hoặc **MariaDB 10.2 trở lên** (khuyên dùng MySQL 8.0) để chạy được cú pháp cột ảo `GENERATED ALWAYS AS ... VIRTUAL`.

### 2. Sử dụng Transaction cho Giao dịch mượn/trả sách
* Không chạy các câu lệnh SQL riêng lẻ độc lập cho thao tác mượn/trả.
* Bắt buộc phải tắt Auto-Commit trước khi chạy các lệnh cập nhật:
  ```java
  connection.setAutoCommit(false);
  try {
      // 1. Cập nhật bảng borrow_details (luôn chạy trước)
      // 2. Cập nhật trạng thái sách trong bảng book_copies (chạy sau)
      connection.commit(); // Thành công cả hai thì lưu
  } catch (Exception e) {
      connection.rollback(); // Lỗi bất kỳ thì tự động hủy toàn bộ
  } finally {
      connection.setAutoCommit(true);
      connection.close();
  }
  ```
* **Lưu ý:** Không đặt bất kỳ hàm gửi email, gọi API ngoài hoặc xử lý logic Java nặng bên trong khối `try` của Transaction để tránh giữ khóa hàng (Row Lock) quá lâu gây nghẽn máy chủ.

### 3. Ngăn chặn Deadlock (Khóa chết)
* Thống nhất thứ tự cập nhật bảng trong toàn bộ code: Luôn thao tác cập nhật trên bảng `borrow_details` trước, sau đó mới cập nhật trạng thái trong bảng `book_copies`. Việc đồng bộ thứ tự này triệt tiêu nguy cơ Deadlock về 0%.

### 4. Phòng chống SQL Injection và XSS
* Tuyệt đối không dùng ghép chuỗi String để tạo câu lệnh SQL (ví dụ: `WHERE name = '` + input + `'`). Luôn dùng **`PreparedStatement`** và các tham số dấu chấm hỏi `?`.
* Khi render dữ liệu từ database lên trang JSP, luôn sử dụng thẻ JSTL `<c:out value="${...}" />` để mã hóa HTML, ngăn chặn mã độc Javascript được chèn vào dữ liệu (XSS).