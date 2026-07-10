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


## 4. Phân tích các chức năng hệ thống
### 4.1. Chức năng Nghiệp vụ Cốt lõi
1. **Bảng điều khiển Thống kê (Dashboard & Analytics):**
   - Theo dõi trực quan hiệu suất hoạt động của thư viện thông qua các chỉ số đo lường chính (KPIs) thời gian thực (tổng sách, độc giả, phiếu mượn đang hoạt động, sách quá hạn).
   - Trực quan hóa lượng sách được mượn theo chu kỳ (ngày, tuần, tháng) tích hợp Chart.js.
   - Báo cáo xếp hạng tự động Top 10 sách mượn nhiều nhất, tác giả được yêu thích và danh mục được quan tâm nhiều nhất.
2. **Quản lý Sách & Danh mục (Book Catalog & Inventory):**
   - Quản lý thông tin đầu sách (tác giả, nhà xuất bản, năm xuất bản, giá trị) và phân loại theo các danh mục nghiệp vụ.
   - Quản lý chi tiết từng bản sao sách vật lý cụ thể (mã vạch/barcode, vị trí kệ sách, trạng thái như Sẵn sàng, Đang mượn, Hỏng, Mất).
3. **Quản lý Độc giả (Reader & Membership):**
   - Quản lý thông tin hồ sơ chi tiết và thông tin liên hệ của từng độc giả.
   - Theo dõi và kiểm soát chặt chẽ trạng thái hoạt động (Active, Suspended, Expired) cũng như thời hạn của thẻ thành viên.
4. **Nghiệp vụ Mượn, Trả & Phí phạt (Circulation & Fines):**
   - Ghi nhận và kiểm soát toàn bộ chu trình mượn, trả và gia hạn hạn trả sách của độc giả.
   - Tự động phát hiện các trường hợp trả sách quá hạn và tính toán phí phạt chi tiết cho từng phiếu mượn.
5. **Quản lý Đề xuất Sách (Book Recommendations):**
   - Tiếp nhận các yêu cầu đề xuất mua mới hoặc bổ sung các đầu sách phục vụ độc giả.
   - Quy trình xét duyệt đề xuất 3 trạng thái rõ ràng (Chờ duyệt, Đã duyệt, Từ chối).
6. **Quản lý Nhân sự & Phân quyền (Staff Management & Security):**
   - Quản trị thông tin nhân viên, cấp tài khoản và mật khẩu truy cập hệ thống.
   - Phân quyền thao tác hệ thống dựa trên hai vai trò chính: Quản trị viên (Admin - toàn quyền) và Thủ thư (Staff - thực hiện nghiệp vụ).

### 4.2. Cơ chế Kỹ thuật & Bảo mật
- **Cơ chế Xóa mềm & Thùng rác (Soft Delete & Restore):** Tích hợp trên toàn bộ các bảng dữ liệu gốc (Danh mục, Đầu sách, Bản sao sách, Độc giả, Đề xuất, Nhân sự). Bản ghi khi bị xóa sẽ chuyển vào trạng thái "Ẩn/Xóa mềm" trong Thùng rác, cho phép Thủ thư kiểm tra, khôi phục hoặc xóa vĩnh viễn để bảo toàn tính toàn vẹn và an toàn dữ liệu.
- **Nhật ký thay đổi (Audit Logs - Chỉ dành cho Admin):** Tự động ghi lại toàn bộ lịch sử thao tác dữ liệu (`Thêm`, `Sửa`, `Хóa`, `Khôi phục`). Lưu vết chi tiết người thực hiện, thời gian, loại hành động và thông tin trước/sau khi thay đổi dưới dạng dữ liệu JSON để phục vụ đối soát bảo mật.
- **Xác thực dữ liệu 2 lớp (Double-layer Data Validation):** Kiểm soát nghiêm ngặt dữ liệu nhập vào thông qua hai tầng bảo vệ độc lập: Lớp 1 tại trình duyệt (Client-side - kiểm tra định dạng, bắt buộc nhập để tối ưu trải nghiệm) và Lớp 2 tại máy chủ (Server-side Servlet - xác thực lại logic nghiệp vụ và ràng buộc cơ sở dữ liệu để phòng tránh các hành vi vượt rào).


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
