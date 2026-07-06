# AI Context: Hướng Dẫn Sử Dụng AuditLogger (LibraryOS Project)

Tài liệu này đóng vai trò là đặc tả kỹ thuật và tài liệu tham khảo nhanh cho các lập trình viên và các Trợ lý AI khi tích hợp cơ chế ghi nhật ký hệ thống (`audit_logs`) trên Backend (Java Servlet + MySQL).

---

## 1. Thông Tin Hệ Thống & Signature Lớp Cấu Trúc

- **Đường dẫn Class:** `src/main/java/common/AuditLogger.java`
- **Thư viện phụ thuộc:** Google Gson (`com.google.gson.Gson`)
- **Bảng Database tác động:** `audit_logs` (Các trường `old_values` và `new_values` có định dạng JSON)
- **Các hành động được định nghĩa (Enum `ActionType`):** `INSERT`, `UPDATE`, `DELETE`, `RESTORE`

### Cấu trúc phương thức (Method Signatures)

```java
// Cách 1: Ghi log dùng chung Connection (Gắn liền với Transaction nghiệp vụ)
public static void log(
    Connection conn, 
    int userId, 
    ActionType action, 
    String tableName, 
    int recordId, 
    Object oldValues, 
    Object newValues
) throws SQLException;

// Cách 2: Ghi log tự lấy Connection mới (Độc lập, tự động giải phóng kết nối)
public static void log(
    int userId, 
    ActionType action, 
    String tableName, 
    int recordId, 
    Object oldValues, 
    Object newValues
);
```

---

## 2. Quy Tắc Sử Dụng Cho AI & Lập Trình Viên

Khi sinh code hoặc viết controller cập nhật dữ liệu, cần tuân thủ quy tắc sau:

1. **Ghi log trong Transaction (Thao tác mượn/trả sách, phí phạt trễ hạn...):**
   - Sử dụng **Cách 1** (truyền tham số `Connection conn`).
   - Log sẽ tham gia chung vào giao dịch. Nếu nghiệp vụ chính rollback, log cũng tự động biến mất để tránh dữ liệu rác.
   
2. **Ghi log độc lập (Thao tác thay đổi danh mục, cấu hình hệ thống đơn giản...):**
   - Sử dụng **Cách 2** (không truyền `Connection`).
   - Lớp sẽ tự động lấy một kết nối mới từ `DBConnection`, thực hiện ghi log và tự động giải phóng kết nối bằng Try-with-resources (đảm bảo không bị rò rỉ kết nối và an toàn đa luồng).

---

## 3. Mã Nguồn Mẫu Cho AI Copy-Paste Nhanh

### Ví dụ 1: Ghi log UPDATE độc lập trong Servlet (Không Transaction)

```java
// 1. Lấy dữ liệu hiện tại trước khi sửa đổi
Map<String, Object> oldData = categoryDAO.findById(categoryId);

// 2. Thực thi cập nhật dữ liệu nghiệp vụ
categoryDAO.update(categoryId, newName, newDesc);

// 3. Chuẩn bị dữ liệu mới vừa thay đổi
Map<String, Object> newData = new HashMap<>();
newData.put("name", newName);
newData.put("description", newDesc);

// 4. Gọi AuditLogger độc lập
AuditLogger.log(
    currentUserId, 
    AuditLogger.ActionType.UPDATE, 
    "categories", 
    categoryId, 
    oldData, 
    newData
);
```

### Ví dụ 2: Ghi log INSERT kèm Transaction (Bắt buộc dùng chung Connection)

```java
Connection conn = null;
try {
    conn = DBConnection.getConnection();
    conn.setAutoCommit(false); // Bắt đầu Transaction

    // 1. Tạo phiếu mượn mới
    int newBorrowRecordId = borrowDAO.insertBorrowRecord(conn, readerId, currentUserId);

    // 2. Chuẩn bị dữ liệu để lưu log
    Map<String, Object> newRecordData = new HashMap<>();
    newRecordData.put("reader_id", readerId);
    newRecordData.put("user_id", currentUserId);

    // 3. Ghi log sử dụng chung connection 'conn'
    AuditLogger.log(
        conn,
        currentUserId,
        AuditLogger.ActionType.INSERT,
        "borrow_records",
        newBorrowRecordId,
        null, // INSERT nên không có dữ liệu cũ
        newRecordData
    );

    conn.commit(); // Hoàn thành Transaction thành công
} catch (Exception e) {
    if (conn != null) {
        try {
            conn.rollback(); // Rollback toàn bộ bao gồm cả Audit Log nếu lỗi
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
} finally {
    if (conn != null) {
        try {
            conn.setAutoCommit(true);
            conn.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
```

---

## 4. Các Lưu Ý Tối Ưu Hóa Cho Trợ Lý AI

- **Tham số `oldValues` và `newValues`:** Nhận vào bất kỳ Object Java nào (Map, POJO, List). Đối với lệnh `INSERT`, đặt `oldValues` là `null`. Đối với lệnh `DELETE`, đặt `newValues` là `null`.
- **Giới hạn kích thước Object:** Tránh đưa các Object quá lớn, có quan hệ vòng tròn (circular references) vào log. Nên convert sang `Map<String, Object>` phẳng chứa các thuộc tính thay đổi quan trọng trước khi truyền vào hàm log.
- **Ngoại lệ:** Đối với phương thức ghi log trong Transaction, luôn đẩy ngoại lệ `SQLException` lên để code nghiệp vụ bắt được và thực hiện rollback.
