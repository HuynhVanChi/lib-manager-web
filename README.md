# Website Quản Lý Thư Viện — LibraryOS

## 1. Thông tin nhóm thực hiện
-   **Thành viên 1:** Huỳnh Văn Chí — MSSV: `2305CT2275`
-   **Thành viên 2:** Lê Lương Minh Quân — MSSV: `2305CT2353`
-   **Thành viên 3:** Nguyễn Hữu Thắng — MSSV: `2305CT2350`
-   **Thành viên 4:** Võ Minh Mẫn — MSSV: `2305CT5913`
-   **Thành viên 5:** Nguyễn Vương Tường Vinh — MSSV: `2305CT8248`

## 2. Mô tả đề tài
**LibraryOS** là website quản lý thư viện trường học/cộng đồng, phục vụ cho hai đối tượng chính là **Quản trị viên (Admin)** và **Thủ thư (Staff)**. Hệ thống giải quyết trọn vẹn bài toán vận hành thư viện hàng ngày từ quản lý kho sách, theo dõi tình trạng mượn trả của độc giả, tính toán phí phạt, đến việc lưu vết các hành động quản trị hệ thống để bảo mật dữ liệu.


## 3. Công nghệ sử dụng
-   **Backend:** Java JDK 18, Java Servlet Specification 4.0.1, JDBC API.
-   **Frontend:** JSP (JavaServer Pages 2.3.3), JSTL 1.2, HTML5, CSS3, JavaScript (ES6+ thuần), Bootstrap 5.3.0, FontAwesome 6.4.0.
-   **Cơ sở dữ liệu:** MySQL (hỗ trợ Driver `mysql-connector-java` 8.0.28).
-   **Thư viện hỗ trợ:** Google Gson 2.9.0 (phục vụ tuần tự hóa JSON trong nhật ký hệ thống).
-   **Quản lý dự án & Build:** Maven.
-   **Máy chủ ứng dụng (Web Server):** **Apache Tomcat 9.0.x** (Khuyên dùng phiên bản 9 để tương thích hoàn toàn với namespace `javax.servlet` cũ. *Lưu ý: Tránh dùng Tomcat 10.x trở lên vì chúng đã chuyển sang namespace `jakarta`*).


## 4. Các chức năng chính
Hệ thống được chia nhỏ thành các phân hệ nghiệp vụ rõ ràng, bao gồm:
1.  **Bảng điều khiển Thống kê (Dashboard & Analytics):**
    -   Hiển thị các chỉ số đo lường hiệu suất chính (KPIs) của thư viện (tổng số sách, độc giả, phiếu mượn đang hoạt động, sách quá hạn).
    -   Biểu đồ trực quan hóa lượng sách được mượn theo thời gian (ngày, tuần, tháng) tích hợp Chart.js.
    -   Xếp hạng Top 10 sách được mượn nhiều nhất, tác giả được yêu thích nhất và danh mục sách được quan tâm nhất.
2.  **Quản lý Độc giả (Readers Module) & Cơ chế Thùng rác (Soft Delete):** 
    -   Xem danh sách độc giả với bộ lọc nâng cao, thanh tìm kiếm thông minh thời gian thực.
    -   Hồ sơ chi tiết độc giả hiển thị thông tin thẻ thành viên và các thẻ thống kê nhanh (Quick Stats) được thiết kế bo góc, đổ bóng nổi khối hiện đại.
    -   Thêm mới, chỉnh sửa thông tin độc giả (Hỗ trợ xác thực biểu mẫu đầy đủ ở cả Backend và hiển thị lỗi trực quan ở Frontend).
    -   Cơ chế Xóa mềm & Thùng rác (Soft Delete & Restore): Độc giả bị xóa sẽ chuyển vào trạng thái "Ẩn/Xóa mềm" trong Thùng rác, cho phép Thủ thư kiểm tra danh sách đã xóa, khôi phục lại trạng thái hoạt động hoặc xóa vĩnh viễn để bảo toàn tính toàn vẹn dữ liệu.
3.  **Quản lý Đề xuất Sách (Book Recommendations Module):**
    -   Cho phép gửi yêu cầu đề xuất mua mới hoặc bổ sung các đầu sách phục vụ độc giả.
    -   Quy trình xét duyệt đề xuất rõ ràng (Chờ duyệt, Đã duyệt, Từ chối).
    -   Tích hợp thùng rác đề xuất cho phép phục hồi hoặc xóa vĩnh viễn các bản ghi đề xuất.
4.  **Quản lý Sách & Danh mục (Books & Categories):** Quản lý danh mục sách, đầu sách và các bản sao sách vật lý trên từng vị trí kệ cụ thể.
5.  **Quản lý Mượn/Trả sách (Borrow & Return):** Ghi nhận thông tin phiếu mượn, hạn trả, tự động phát hiện sách quá hạn và tính toán phí phạt tương ứng cho từng phiếu mượn.
6.  **Nhật ký Hệ thống (Audit Logs Module - Chỉ dành cho Admin):**
    -   Lưu lại toàn bộ lịch sử thao tác dữ liệu (các hành động `Thêm`, `Sửa`, `Xóa`, `Khôi phục`).
    -   Lưu vết chi tiết: Ai làm (User ID), tác động lên bảng nào (Table Name), kiểu hành động (Action Type), thời gian thực hiện, và dữ liệu chi tiết trước/sau khi thay đổi dưới dạng JSON.
    -   Hỗ trợ bộ lọc hành động nhanh và tìm kiếm nhật ký.


## 5. Hướng dẫn cài đặt và khởi chạy

### Bước 1: Chuẩn bị Cơ sở dữ liệu (MySQL)
1.  Mở hệ quản trị cơ sở dữ liệu MySQL.
2.  Import file 2 trong thư mục [_database](/_database/) vào chương trình MySQL Workbench 8.0 (hoặc chương trình cho phép xem và tương tác hệ quản trị cơ sở dữ liệu MySQL)
2.  Tiến hành chạy toàn bộ nội dung file tạo cấu trúc bảng: 
    👉 [create_tables.sql](/_database/create_tables.sql)
3.  Tiếp tục chạy file chèn dữ liệu mẫu để có sẵn dữ liệu test hoàn chỉnh: 
    👉 [insert_sample_data.sql](/_database/insert_sample_data.sql)
    *(Sau hai bước trên, cơ sở dữ liệu `quanlythuvien` sẽ được khởi tạo với đầy đủ các bảng dữ liệu liên kết).*

### Bước 2: Cấu hình kết nối Database trong Project
1.  Mở file cấu hình kết nối tại đường dẫn:
    👉 [database.properties](/src/main/resources/database.properties)
2.  Chỉnh sửa lại thông tin tài khoản MySQL trên máy:
    ```properties
    db.url=jdbc:mysql://localhost:3306/quanlythuvien?useUnicode=true&characterEncoding=UTF-8
    db.user=root       # Thay bằng username trên máy
    db.password=123123 # Thay bằng mật khẩu MySQL trên máy
    ```

### Bước 3: Compile và Chạy ứng dụng
1.  Nhập lệnh compile dự án Maven: `mvn clean package` để tạo file `.war` trong thư mục `target`.
2.  Cấu hình máy chủ **Apache Tomcat 9.0.x** trong IDE trên máy (IntelliJ IDEA, Eclipse, VSCode hoặc NetBeans).
3.  Thêm (Deploy) artifact `lib-manager-web:war` vào máy chủ Tomcat và khởi chạy.
4.  Truy cập hệ thống qua trình duyệt theo địa chỉ mặc định: `http://localhost:8080/lib-manager-web/` (hoặc cổng cấu hình tương ứng ).


## 6. Tài khoản Demo có sẵn trong dữ liệu mẫu

Hệ thống phân quyền rõ ràng dựa theo hai tài khoản chính sau:

| Tên tài khoản (Username) | Mật khẩu (Password) | Vai trò (Role) | Phạm vi quyền hạn |
| :--- | :--- | :--- | :--- |
| **`admin`** | `12345` | **Admin (Quản trị viên)** | Toàn quyền hệ thống, **có quyền xem Nhật ký hệ thống (Audit Logs)**. |
| **`thuthu01`** | `67890` | **Staff (Thủ thư)** | Thực hiện các công việc nghiệp vụ: quản lý độc giả, sách, mượn trả. Không xem được Audit Logs. |


## 7. Video thuyết trình và Demo
-   **Link video thuyết trình:** *(Vui lòng đính kèm link Drive/YouTube của nhóm tại đây)*
-   **Link video chạy thử chức năng (Demo):** *(Vui lòng đính kèm link chạy thử tại đây)*
