# Kế hoạch thiết kế & hiện thực hóa menu "Sách" và "Danh mục"

Tài liệu này trình bày ý tưởng thiết kế giao diện, kiến trúc mã nguồn và lộ trình triển khai tính năng quản lý **Sách (Books & Book Copies)** và **Danh mục (Categories)** cho dự án **LibraryOS**.

> [!NOTE]
> Để tránh xung đột mã nguồn khi làm việc nhóm, toàn bộ các file Java và JSP mới sẽ được đặt gọn trong các gói `book` và `categories`. Không chỉnh sửa cấu trúc khung xương dùng chung.

---

## Phân tích Tư duy Thiết kế (Design Thinking) & Tư duy Phản biện (Critical Thinking)

### 1. Góc nhìn Tư duy Thiết kế (Thấu cảm người dùng - Thủ thư)
* **Thao tác hàng loạt (Bulk Operations):** Thủ thư thường xuyên phải nhập số lượng lớn sách cùng tựa đề. Việc bắt họ thêm từng cuốn sách cụ thể (`book_copies`) và nhập tay từng mã vạch (`barcode`) là một trải nghiệm tệ. 
  * *Giải pháp:* Tích hợp chức năng **Thêm nhanh cuốn sách** ngay trong giao diện Modal của sách. Thủ thư chỉ cần chọn vị trí kệ (`location_shelf`) và số lượng cần thêm (ví dụ: `5`), hệ thống tự động sinh mã vạch dạng `[Mã_viết_tắt_đầu_sách]-[STT]` (Ví dụ: `JWD-004` hoặc `DSA-003`) tương thích 100% với dữ liệu mẫu hiện tại và lưu vào cơ sở dữ liệu.
* **Tìm kiếm đa mục tiêu (Multi-target Search):** Thủ thư cần tìm sách rất nhanh khi độc giả hỏi hoặc khi cầm trên tay một cuốn sách có dán mã vạch.
  * *Giải pháp:* Thanh tìm kiếm ở trang quản lý Sách không chỉ tìm theo tiêu đề/tác giả, mà hỗ trợ **quét/nhập mã vạch (Barcode)**. Nếu nhập mã vạch hợp lệ, hệ thống sẽ tìm ra đầu sách tương ứng và tự động kích hoạt Modal Quản lý cuốn sách đó, giúp thủ thư định vị ngay cuốn sách nằm trên kệ nào.
* **Cảnh báo trực quan (Visual Alerts):**
  * *Giải pháp:* Thiết lập các cảnh báo trạng thái số lượng cuốn sách. Nếu số lượng sách sẵn có để cho mượn là `0`, hệ thống hiển thị badge màu đỏ `"Hết sách"` thay vì chỉ hiển thị số lượng đơn thuần, giúp thủ thư nắm bắt nhanh kho sách.

### 2. Góc nhìn Tư duy Phản biện (Logic nghiệp vụ & An toàn tích hợp)
* **Xử lý Ràng buộc Xóa & Bắc cầu Xóa mềm (Deletion Integrity & Cascading Soft Delete):**
  * **Xóa danh mục:** DDL quy định `ON DELETE RESTRICT`. Hệ thống **phải chặn hoàn toàn việc xóa mềm danh mục** nếu danh mục đó đang chứa các đầu sách hoạt động.
  * **Xóa đầu sách (Cascading Soft Delete):** Khi xóa mềm một đầu sách (`books`), toàn bộ các cuốn sách (`book_copies`) của đầu sách đó cũng phải tự động bị xóa mềm theo.
    * *Ràng buộc:* Nếu có bất kỳ cuốn sách nào của đầu sách đó đang ở trạng thái `'Borrowed'` (Đang mượn), hệ thống **phải từ chối xóa** đầu sách này.
    * *Giải pháp kỹ thuật:* Việc xóa mềm đầu sách và xóa các cuốn sách con phải thực hiện trong một **Transaction (Giao dịch)** thông qua `Connection conn` trong `BookDAO` để đảm bảo tính nhất quán (nếu xóa một cuốn con lỗi, toàn bộ tác vụ xóa đầu sách sẽ rollback).
* **Khóa trạng thái "Đang mượn" (Borrowed) trên giao diện thủ công:**
  * Trạng thái `'Borrowed'` của cuốn sách chỉ được sinh ra và giải phóng thông qua quy trình Mượn - Trả sách chuyên biệt (thuộc nhánh `borrow-return`).
  * *Giải pháp:* Trong giao diện sửa thông tin cuốn sách, hệ thống **không cho phép thủ thư chuyển trạng thái thủ công** từ bất kỳ trạng thái nào sang `'Borrowed'`, và ngược lại (nếu cuốn sách đang bị khóa `'Borrowed'`, thủ thư không được phép sửa trạng thái sang `'Available'` thủ công vì sẽ làm hỏng dữ liệu đối soát của phiếu mượn). Trạng thái `'Borrowed'` sẽ ở dạng Read-only (chỉ đọc) trên màn hình này.
* **Xử lý trùng lặp khi Khôi phục (Restore Duplicate Name Conflict):**
  * Database dùng cột ảo UNIQUE để cho phép tạo danh mục mới trùng tên với danh mục đã xóa mềm. Nhưng khi thực hiện **Khôi phục (Restore)** một danh mục cũ, nếu tên danh mục đó trùng với một danh mục khác đang hoạt động, MySQL sẽ báo lỗi UNIQUE.
  * *Giải pháp:* Trước khi khôi phục, DAO/Servlet phải kiểm tra xem có danh mục nào đang hoạt động trùng tên hay không. Nếu có, chặn khôi phục và báo lỗi trực quan cho thủ thư.
* **Đồng bộ hóa & Tự động sinh Mã vạch theo dữ liệu mẫu (Barcode Format Consistency):**
  * *Đồng bộ dữ liệu mẫu:* Trong bảng dữ liệu mẫu `insert_sample_data.sql`, mã vạch các cuốn sách được định nghĩa theo dạng viết tắt 3 chữ số hoa từ tiêu đề đầu sách kết hợp với số thứ tự tự tăng (Ví dụ: Đầu sách *Lập trình JWDa Web căn bản* dùng `JWD-001`, `JWD-002`, `JWD-003`; *Cấu trúc dữ liệu và Giải thuật* dùng `DSA-001`, `DSA-002`).
  * *Giải pháp thiết kế:* Để tránh sự không nhất quán giữa dữ liệu cũ và mới, hệ thống sẽ tự động sinh mã vạch chuẩn theo định dạng này:
    1. **Tự động tạo chữ viết tắt đầu sách (3 chữ cái):** Khi tạo đầu sách, hệ thống sử dụng thuật toán rút gọn từ tiêu đề (Ví dụ: Lấy các chữ cái đầu tiên viết hoa không dấu của các từ chính: "Số đỏ" -> "SDO", "Nghĩ giàu và Làm giàu" -> "NGL").
    2. **Tự động sinh số thứ tự (Suffix):** Khi thêm cuốn sách mới, hệ thống kiểm tra các cuốn sách hiện tại của đầu sách đó để lấy số thứ tự lớn nhất rồi tự động tăng tiến (Ví dụ: Thêm cuốn mới cho đầu sách `JWD` thì tự động tạo mã `JWD-004`).
    3. **Tối giản hóa quy trình:** Lược bỏ chế độ nhập mã thủ công, hệ thống kiểm soát hoàn toàn việc sinh mã vạch tự động để đảm bảo 100% không xảy ra lỗi trùng lặp do thủ thư gõ sai.
* **Hỗ trợ Transaction dùng chung cho các nhóm khác (Cross-branch Integration):**
  * Nhánh `borrow-return` sẽ thực hiện thay đổi trạng thái của cuốn sách (`book_copies.status` từ `'Available'` sang `'Borrowed'` và ngược lại) bên trong một Transaction chung với bảng phiếu mượn.
  * *Giải pháp:* Tất cả các phương thức cập nhật trạng thái cuốn sách trong `BookCopyDAO` của chúng ta phải hỗ trợ nạp chồng (overload) nhận tham số `Connection conn` (ví dụ: `updateStatus(Connection conn, int copyId, String status)`) để tham gia chung vào giao dịch của nhóm khác, đảm bảo an toàn dữ liệu và tránh lỗi `Deadlock`.
* **Xử lý Lỗi trùng lặp dữ liệu (Unique Constraint Violations):**
  * Database có khóa UNIQUE ảo để tránh trùng tên danh mục và trùng mã vạch cuốn sách. Nếu xảy ra lỗi trùng lặp khi người dùng tạo mới hoặc chỉnh sửa, hệ thống Servlet phải bắt được ngoại lệ `SQLIntegrityConstraintViolationException` và trả về thông báo lỗi thân thiện thay vì hiển thị màn hình crash lỗi hệ thống.

---

## 2. Ý tưởng thiết kế Giao diện (UI/UX)

Giao diện sẽ tuân thủ nghiêm ngặt bảng màu quy định trong [Colors.md](file:///c:/Users/LAPTOP/lib-manager-web/.design_notes/Colors.md):
- **Màu chủ đạo:** Tím than / Chàm (`#312E81`) làm màu thương hiệu, màu nút nhấn chính, tiêu đề card.
- **Màu phụ (Accent):** Tím pastel (`#A78BFA`) làm các chi tiết tương tác (hover, link), trạng thái chọn.
- **Màu nền:** Trắng (`#FFFFFF`) kết hợp xám nhạt (`#F9FAFB`) tạo độ tương phản tốt, làm nổi bật các thẻ dữ liệu (Cards).
- **Phông chữ:** Inter (Sans-serif) tăng độ hiện đại, dễ đọc.
- **Thư viện giao diện:** Sử dụng thuần **Bootstrap 5** (đã tích hợp sẵn trong project) để thiết kế giao diện thông qua các class tiện ích (Utility classes) và component của Bootstrap (như cards, modals, tables, badges, flex, grid), hạn chế tối đa việc viết thêm custom CSS ngoài để tránh ảnh hưởng đến các trang khác.

Dưới đây là hình ảnh mockup giao diện trang Quản lý cuốn sách đề xuất (được tạo tự động theo phong cách premium):

![Mockup Giao diện Quản lý Cuốn sách](C:/Users/LAPTOP/.gemini/antigravity/brain/d8a1ba96-4466-4f19-831d-c93a87150ced/manage_copies_page_mockup_1783393318118.png)

### Chi tiết các khối giao diện:
1. **Thẻ thống kê nhanh (Summary Cards):**
   - Đặt ở đầu trang Quản lý Sách.
   - Gồm 4 thẻ: *Tổng số đầu sách*, *Tổng số cuốn sách*, *Sách sẵn có (trong kho)*, *Sách đang hỏng/Mất*.
   - Mỗi thẻ có biểu tượng (icon) trực quan và màu nền dịu nhẹ (soft bg).
2. **Bộ lọc & Tìm kiếm thông minh:**
   - Ô tìm kiếm nhanh theo tiêu đề hoặc tác giả (với biểu tượng kính lúp).
   - Dropdown lọc theo **Danh mục** (lấy động từ DB).
   - Nút **"Thêm đầu sách"** màu chàm (`#312E81`) nằm góc phải (Chuyển hướng sang trang thêm mới).
3. **Bảng hiển thị đầu sách (Books Table):**
   - Hiển thị thông tin: Ảnh bìa (giả lập hoặc icon), Tiêu đề & Tác giả (dòng đôi), Danh mục (dưới dạng badge màu tím pastel), Nhà xuất bản & Năm, Số lượng cuốn sách (dạng tỉ lệ `Còn lại / Tổng số`, ví dụ: `Còn 4/5 cuốn`).
   - Cột **Hành động**: Nút *Sửa* (bút chì - chuyển hướng sang trang sửa), *Xóa* (thùng rác - mở modal xác nhận xóa), và nút *Quản lý cuốn sách* (biểu tượng danh sách/mã vạch - chuyển hướng sang trang quản lý bản sao).
4. **Trang Quản lý danh sách Cuốn sách (Book Copies Page):**
   - Một trang độc lập hiển thị danh sách tất cả các cuốn sách (bản sao cụ thể) (`book_copies`) của đầu sách được chọn.
   - Tiêu đề trang hiển thị tên đầu sách làm ngữ cảnh.
   - Hiển thị danh sách: Mã vạch (`barcode`), Vị trí kệ (`location_shelf`), Trạng thái (`Available`, `Borrowed`, `Damaged`, `Lost`) dưới dạng các badge màu sắc trực quan.
   - Một Card ở góc hoặc khu vực riêng chứa Form nhanh để **Thêm nhanh cuốn sách mới** (hệ thống tự động sinh mã vạch, thủ thư chỉ cần chọn vị trí kệ và số lượng cần thêm).
   - Nút sửa vị trí/trạng thái hoặc xóa bản sao vật lý được tích hợp trực tiếp trên bảng dữ liệu.

---

## 3. Thiết kế Cơ sở dữ liệu & Tích hợp Audit Log

Chúng ta sẽ dựa trên khung DDL của [Bao_Cao_Database.md](file:///c:/Users/LAPTOP/lib-manager-web/.design_notes/Bao_Cao_Database.md):
- Bảng `categories`: Lưu trữ tên danh mục và mô tả.
- Bảng `books`: Lưu trữ thông tin chung của sách (liên kết khóa ngoại đến `categories`).
- Bảng `book_copies`: Lưu trữ thông tin bản sao vật lý cụ thể (liên kết khóa ngoại đến `books`).

### Tích hợp Audit Log theo [Huong_Dan_Audit_Log.md](file:///c:/Users/LAPTOP/lib-manager-web/.design_notes/Huong_Dan_Audit_Log.md):
Khi thực hiện các hành động CRUD trên Servlet, chúng ta sẽ gọi `AuditLogger.log()` độc lập (không cần transaction vì là tác vụ CRUD cơ bản):
- **Thêm mới (INSERT):** Lưu `oldValues = null`, `newValues = Map` chứa các thuộc tính quan trọng của đối tượng vừa tạo.
- **Cập nhật (UPDATE):** Lấy dữ liệu cũ từ DAO trước khi ghi đè, thực hiện sửa đổi, chuẩn bị `newValues` chứa dữ liệu mới, sau đó ghi log với `oldValues` và `newValues`.
- **Xóa mềm (DELETE):** Đọc dữ liệu hiện tại, cập nhật cột `deleted_at = NOW()` and `deleted_by = user_id`, ghi log với `newValues = null` và `oldValues` chứa dữ liệu trước khi xóa.

---

## 4. Các thay đổi đề xuất (Proposed Changes)

Để tránh xung đột tối đa với các thành viên khác trong nhóm, chúng ta sẽ **chỉ tạo mới hoặc chỉnh sửa mã nguồn** bên trong các thư mục sau:
- `/src/main/java/categories/`
- `/src/main/java/book/`
- `/src/main/webapp/views/categories/`
- `/src/main/webapp/views/book/`
- `/src/main/webapp/assets/categories/`
- `/src/main/webapp/assets/book/`

> [!IMPORTANT]
> **Làm rõ về cấu trúc Layout (Sidebar & Header):**
> 1. **Sidebar (`sidebar.jsp`):** Giữ nguyên hoàn toàn không thay đổi.
> 2. **Header (`header.jsp`):** Giữ nguyên hoàn toàn không thay đổi. Do cấu trúc `header.jsp` đã được viết động để tự động hiển thị tiêu đề (ví dụ: "Quản lý Sách" khi ở URL `/books` hoặc "Quản lý Danh mục" khi ở URL `/categories`), chúng ta chỉ cần gọi `<jsp:include>` vào đầu trang mà không cần sửa đổi bất kỳ code nào của file header này.
> 3. **File giao diện JSP cần viết:** Hiện đã đổi tên hai file trống từ `index.jsp` thành `books.jsp` (ở `/views/book/`) và `categories.jsp` (ở `/views/categories/`). Chúng ta sẽ hiện thực hóa nội dung vào các file này. File root template ngoài trang chủ `src/main/webapp/index.jsp` sẽ **giữ nguyên không sửa đổi**.

### 3.1. Thành phần Danh mục (Categories Component)

#### [NEW] [Category.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/categories/Category.java)
- Lớp Model chứa các trường: `categoryId`, `name`, `description`, `createdAt`, `updatedAt`, `deletedAt`, `deletedBy`.

#### [NEW] [CategoryDAO.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/categories/CategoryDAO.java)
- Lớp tương tác DB chứa các phương thức chính:
  - `List<Category> findAllActive()`: Lấy danh sách các danh mục chưa bị xóa mềm.
  - `Category findById(int id)`: Tìm danh mục theo ID.
  - `boolean insert(Category category)`: Thêm mới danh mục.
  - `boolean update(Category category)`: Cập nhật thông tin danh mục.
  - `boolean softDelete(int id, int userId)`: Đánh dấu xóa mềm danh mục.
  - `boolean existsByName(String name, Integer excludeId)`: Kiểm tra trùng tên danh mục đang hoạt động.

#### [NEW] [CategoryServlet.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/categories/CategoryServlet.java)
- Mapped vào đường dẫn `/categories`.
- Hàm `doGet`: Forward đến trang `/views/categories/categories.jsp` kèm danh sách danh mục hoạt động.
- Hàm `doPost`: Xử lý thêm mới, chỉnh sửa, xóa danh mục (gọi `AuditLogger.log` tương ứng).

#### [NEW] [categories.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/categories/categories.jsp)
- Thiết kế giao diện quản lý danh mục dạng bảng.
- Tích hợp modal thêm/sửa danh mục.
- Sử dụng màu sắc thương hiệu tím/chàm.
- Nhúng file JS ngoài `categories-jsp.js`.

#### [NEW] [categories-jsp.js](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/assets/categories/categories-jsp.js)
- Chứa toàn bộ mã JavaScript tương tác các modal thêm, sửa, xóa, khôi phục của màn hình Danh mục.

---

### 3.2. Thành phần Sách & Bản sao (Books & Book Copies Component)

#### [NEW] [Book.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/book/Book.java)
- Lớp Model chứa: `bookId`, `categoryId`, `categoryName`, `title`, `author`, `publisher`, `publishYear`, `createdAt`, `updatedAt`.

#### [NEW] [BookCopy.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/book/BookCopy.java)
- Lớp Model chứa: `copyId`, `bookId`, `barcode`, `status`, `locationShelf`, `createdAt`, `updatedAt`.

#### [NEW] [BookDAO.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/book/BookDAO.java)
- Lớp tương tác DB cho Đầu sách (`books`):
  - `List<Book> findAllActive(String query, Integer categoryId)`: Lấy các đầu sách kèm thông tin tên danh mục, lọc theo từ khóa và danh mục.
  - `Book findById(int id)`: Tìm đầu sách cụ thể.
  - `int insert(Book book)`: Thêm mới đầu sách và trả về ID tự sinh.
  - `boolean update(Book book)`: Cập nhật thông tin đầu sách.
  - `boolean softDelete(int id, int userId)`: Xóa mềm đầu sách.
  - Thống kê: `countTotalActiveBooks()`, `countTotalBookCopies()`, `countAvailableCopies()`, `countDamagedOrLostCopies()`.

#### [NEW] [BookCopyDAO.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/book/BookCopyDAO.java)
- Lớp tương tác DB cho Cuốn sách (`book_copies`):
  - `List<BookCopy> findCopiesByBookId(int bookId)`: Tìm các cuốn sách chưa bị xóa của một đầu sách.
  - `boolean insert(BookCopy copy)`: Thêm một cuốn sách mới.
  - `boolean update(BookCopy copy)`: Sửa đổi thông tin cuốn sách (vị trí kệ, trạng thái).
  - `boolean softDelete(int id, int userId)`: Xóa mềm cuốn sách.
  - `boolean existsByBarcode(String barcode)`: Kiểm tra trùng mã vạch.

#### [NEW] [BookServlet.java](file:///c:/Users/LAPTOP/lib-manager-web/src/main/java/book/BookServlet.java)
- Mapped vào đường dẫn `/books`.
- Hàm `doGet`: Điều phối chuyển hướng (Forward) dựa trên tham số `action`:
  - `action = null`: Hiển thị danh sách đầu sách ([books.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/books.jsp)).
  - `action = "add"`: Hiển thị trang thêm đầu sách ([add.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/add.jsp)).
  - `action = "edit"`: Tải thông tin sách theo ID và hiển thị trang sửa đầu sách ([edit.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/edit.jsp)).
  - `action = "detail"`: Tải thông tin chi tiết đầu sách, danh mục, thống kê bản sao và nhật ký hoạt động/mượn trả để hiển thị trang chi tiết ([detail.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/detail.jsp)).
  - `action = "copies"`: Tải thông tin đầu sách và danh sách cuốn sách con để hiển thị trang quản lý bản sao ([copies.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/copies.jsp)).
- Hàm `doPost`: Xử lý các nghiệp vụ thêm mới/sửa/xóa đầu sách, và thêm/sửa/xóa cuốn sách con, sau đó thực hiện chuyển hướng về trang tương ứng bằng `sendRedirect` để tránh lặp dữ liệu khi reload trang (gọi `AuditLogger.log` tương ứng).

#### [NEW] [books.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/books.jsp)
- Trang chính danh sách Sách (chỉ giữ lại Modal xác nhận Xóa).
- Các nút "Thêm đầu sách", "Sửa", "Xem chi tiết", "Quản lý cuốn" sẽ chuyển hướng URL sang các trang tương ứng thay vì mở Modal.
- Tiêu đề sách trong bảng danh sách cũng là đường dẫn click nhanh để mở trang Chi tiết đầu sách.

#### [NEW] [add.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/add.jsp)
- Trang giao diện thêm mới đầu sách, biểu mẫu lớn, trực quan, có nút "Quay lại danh sách".

#### [NEW] [edit.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/edit.jsp)
- Trang giao diện chỉnh sửa thông tin đầu sách, tự điền dữ liệu cũ.

#### [NEW] [detail.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/detail.jsp)
- Trang hồ sơ chi tiết đầu sách (Book Profile Hub) được chia bố cục:
  - Cột bên trái: Hiển thị thông tin tổng quan, ảnh bìa, tóm tắt/mô tả và các nút thao tác nhanh (Sửa đầu sách, Quản lý cuốn).
  - Cột bên phải: Sử dụng tab điều hướng Bootstrap gồm:
    - **Tab 1: Danh sách bản sao:** Xem nhanh trạng thái, mã vạch và kệ của từng bản sao vật lý.
    - **Tab 2: Lịch sử mượn trả:** Dữ liệu đối soát lịch sử các lần độc giả mượn cuốn sách này (được tích hợp chéo).
    - **Tab 3: Nhật ký hệ thống (Audit Log):** Xem nhật ký lịch sử chỉnh sửa đầu sách từ hệ thống.

#### [NEW] [copies.jsp](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/views/book/copies.jsp)
- Trang giao diện quản lý cuốn sách chuyên biệt:
  - Khối thông tin và thống kê của đầu sách hiện tại.
  - Bảng danh sách các cuốn sách vật lý.
  - Form thêm nhanh cuốn sách mới (tự sinh mã vạch tiếp theo).
  - Tích hợp Modal chỉnh sửa vị trí/trạng thái cuốn sách, Modal xóa cuốn sách.

#### [NEW] [books-jsp.js](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/assets/book/books-jsp.js)
- Chứa mã Javascript xử lý trên trang danh sách Sách (chủ yếu là gán ID đầu sách cho Modal xác nhận Xóa).

#### [NEW] [copies-jsp.js](file:///c:/Users/LAPTOP/lib-manager-web/src/main/webapp/assets/book/copies-jsp.js)
- Chứa toàn bộ mã Javascript xử lý trên trang quản lý cuốn sách (điều khiển Modal sửa/xóa cuốn sách, quản lý trạng thái mượn và logic thêm nhanh bản sao).

---

## 5. Kế hoạch Xác minh (Verification Plan)

### Kiểm tra Tự động (Automated/Semi-automated Checks):
- Chạy lệnh biên dịch dự án Maven để đảm bảo không lỗi cú pháp:
  ```powershell
  mvn clean compile
  ```
- Kiểm tra các lớp Servlet được nạp đúng cấu trúc và không gây lỗi khi triển khai.

### Xác minh Thủ công (Manual Verification):
1. **Kiểm tra Giao diện (UI/UX Review):**
   - Đảm bảo bảng màu đúng Indigo (`#312E81`), các badge hiển thị đúng trạng thái bản sao vật lý.
   - Kiểm tra xem giao diện hiển thị đúng trên các kích thước màn hình.
2. **Kiểm tra Nghiệp vụ (Business Logic Review):**
   - Thử thêm mới, chỉnh sửa, xóa danh mục và đầu sách.
   - Thêm bản sao vật lý, thay đổi trạng thái của bản sao (Available -> Damaged) và xác minh tính đúng đắn của dữ liệu.
3. **Kiểm tra Audit Log:**
   - Sau khi thao tác, kiểm tra trực tiếp trong bảng `audit_logs` của MySQL xem có các bản ghi chứa JSON mô tả dữ liệu trước/sau chính xác hay không.

---
*Vui lòng phản hồi bằng cách nhấn **Proceed** hoặc phê duyệt kế hoạch để tôi bắt đầu viết mã nguồn.*
