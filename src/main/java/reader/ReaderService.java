package reader;

import java.util.ArrayList;
import java.util.List;
import java.sql.*;
import common.DBConnection;

/**
 * Service chứa toàn bộ logic nghiệp vụ liên quan đến độc giả.
 * Là lớp trung gian giữa Servlet (Controller) và DAO (Database).
 * Không chứa bất kỳ câu SQL nào — chỉ điều phối validate và kiểm tra điều kiện.
 */
public class ReaderService {

    private final ReaderDAO dao = new ReaderDAO();

    // =============================================
    // INNER CLASS — Kết quả Validation
    // =============================================

    /**
     * Lớp đại diện cho kết quả kiểm tra hợp lệ của form.
     * Servlet sẽ kiểm tra isValid() và lấy danh sách lỗi để trả về JSP.
     */
    public static class ValidationResult {
        private final List<String> errors = new ArrayList<>();

        /** Thêm một lỗi vào danh sách */
        public void addError(String field, String message) {
            errors.add(field + "|" + message);
        }

        /** Kiểm tra form có hợp lệ không (không có lỗi nào) */
        public boolean isValid() {
            return errors.isEmpty();
        }

        /** Trả về toàn bộ danh sách lỗi dạng "field|message" */
        public List<String> getErrors() {
            return errors;
        }

        /**
         * Chuyển danh sách lỗi thành Map field → message để JSP dễ tra cứu.
         * Dùng trong Servlet: request.setAttribute("fieldErrors", result.toMap())
         */
        public java.util.Map<String, String> toMap() {
            java.util.Map<String, String> map = new java.util.LinkedHashMap<>();
            for (String entry : errors) {
                String[] parts = entry.split("\\|", 2);
                if (parts.length == 2) {
                    map.put(parts[0], parts[1]);
                }
            }
            return map;
        }
    }


    // =============================================
    // 3.2 — validateForInsert: Validate khi thêm mới
    // =============================================

    /**
     * Kiểm tra toàn bộ dữ liệu trước khi thêm mới một độc giả.
     * Bao gồm: kiểm tra trường bắt buộc, định dạng, trùng lặp DB.
     *
     * @param reader Đối tượng Reader chứa dữ liệu từ form
     * @return ValidationResult — gọi isValid() để biết có lỗi không
     */
    public ValidationResult validateForInsert(Reader reader) {
        ValidationResult result = new ValidationResult();

        // --- Kiểm tra Họ tên ---
        if (reader.getFullName() == null || reader.getFullName().trim().isEmpty()) {
            result.addError("fullName", "Họ và tên không được để trống.");
        } else if (reader.getFullName().trim().length() > 150) {
            result.addError("fullName", "Họ và tên không được vượt quá 150 ký tự.");
        }

        // --- Kiểm tra Email ---
        if (reader.getEmail() == null || reader.getEmail().trim().isEmpty()) {
            result.addError("email", "Email không được để trống.");
        } else if (!isValidEmail(reader.getEmail().trim())) {
            result.addError("email", "Email không đúng định dạng.");
        } else if (dao.isEmailTaken(reader.getEmail().trim(), null)) {
            result.addError("email", "Email này đã được sử dụng bởi một độc giả khác.");
        }

        // --- Kiểm tra Số điện thoại (không bắt buộc, nhưng nếu nhập thì phải hợp lệ) ---
        if (reader.getPhone() != null && !reader.getPhone().trim().isEmpty()) {
            if (!isValidPhone(reader.getPhone().trim())) {
                result.addError("phone", "Số điện thoại chỉ được chứa chữ số, dấu '+', '-', '(' và ')', tối thiểu 9 ký tự.");
            } else if (dao.isPhoneTaken(reader.getPhone().trim(), null)) {
                result.addError("phone", "Số điện thoại này đã được sử dụng bởi một độc giả khác.");
            }
        }

        // --- Kiểm tra Trạng thái ---
        if (!isValidStatus(reader.getStatus())) {
            result.addError("status", "Trạng thái không hợp lệ. Chỉ chấp nhận: Active, Suspended, Expired.");
        }

        return result;
    }


    // =============================================
    // 3.3 — validateForUpdate: Validate khi chỉnh sửa
    // =============================================

    /**
     * Kiểm tra toàn bộ dữ liệu trước khi cập nhật một độc giả đã tồn tại.
     * Tương tự validateForInsert nhưng loại trừ chính bản ghi đang sửa khi kiểm tra trùng.
     *
     * @param reader Đối tượng Reader chứa dữ liệu mới từ form (readerId phải > 0)
     * @return ValidationResult — gọi isValid() để biết có lỗi không
     */
    public ValidationResult validateForUpdate(Reader reader) {
        ValidationResult result = new ValidationResult();

        // --- Kiểm tra Họ tên ---
        if (reader.getFullName() == null || reader.getFullName().trim().isEmpty()) {
            result.addError("fullName", "Họ và tên không được để trống.");
        } else if (reader.getFullName().trim().length() > 150) {
            result.addError("fullName", "Họ và tên không được vượt quá 150 ký tự.");
        }

        // --- Kiểm tra Email (loại trừ chính reader đang sửa) ---
        if (reader.getEmail() == null || reader.getEmail().trim().isEmpty()) {
            result.addError("email", "Email không được để trống.");
        } else if (!isValidEmail(reader.getEmail().trim())) {
            result.addError("email", "Email không đúng định dạng.");
        } else if (dao.isEmailTaken(reader.getEmail().trim(), reader.getReaderId())) {
            result.addError("email", "Email này đã được sử dụng bởi một độc giả khác.");
        }

        // --- Kiểm tra Số điện thoại (loại trừ chính reader đang sửa) ---
        if (reader.getPhone() != null && !reader.getPhone().trim().isEmpty()) {
            if (!isValidPhone(reader.getPhone().trim())) {
                result.addError("phone", "Số điện thoại chỉ được chứa chữ số, dấu '+', '-', '(' và ')', tối thiểu 9 ký tự.");
            } else if (dao.isPhoneTaken(reader.getPhone().trim(), reader.getReaderId())) {
                result.addError("phone", "Số điện thoại này đã được sử dụng bởi một độc giả khác.");
            }
        }

        // --- Kiểm tra Trạng thái ---
        if (!isValidStatus(reader.getStatus())) {
            result.addError("status", "Trạng thái không hợp lệ. Chỉ chấp nhận: Active, Suspended, Expired.");
        }

        return result;
    }


    // =============================================
    // 3.4 — canDelete: Kiểm tra điều kiện xóa mềm
    // =============================================

    /**
     * Kiểm tra xem một độc giả có thể bị xóa mềm không.
     * Điều kiện từ chối: Độc giả còn ít nhất 1 cuốn sách đang trong trạng thái 'Borrowing'.
     *
     * @param readerId ID của độc giả cần kiểm tra
     * @return true nếu được phép xóa, false nếu bị từ chối
     */
    public boolean canDelete(int readerId) {
        String sql =
            "SELECT 1 FROM borrow_records br " +
            "JOIN borrow_details bd ON br.borrow_record_id = bd.borrow_record_id " +
            "WHERE br.reader_id = ? AND bd.status = 'Borrowing' " +
            "LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, readerId);
            ResultSet rs = pstmt.executeQuery();

            // Nếu tìm thấy ít nhất 1 dòng → còn đang mượn sách → không được xóa
            return !rs.next();

        } catch (SQLException e) {
            System.err.println("[ReaderService] Lỗi canDelete id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        // Lỗi DB → từ chối xóa để an toàn
        return false;
    }


    // =============================================
    // 3.5 — canRestore: Kiểm tra điều kiện khôi phục
    // =============================================

    /**
     * Kiểm tra xem một độc giả đã xóa mềm có thể được khôi phục không.
     * Điều kiện từ chối: Email hoặc SĐT của độc giả này đang bị chiếm bởi một active reader khác.
     * (Xảy ra khi có người mới đăng ký cùng email/SĐT sau khi reader cũ bị xóa)
     *
     * @param readerId ID của độc giả cần khôi phục
     * @return true nếu được phép khôi phục, false nếu bị xung đột
     */
    public boolean canRestore(int readerId) {
        Reader deletedReader = dao.findById(readerId);

        // Không tìm thấy hoặc chưa bị xóa → không hợp lệ
        if (deletedReader == null || !deletedReader.isDeleted()) {
            return false;
        }

        // Kiểm tra email xung đột với active reader khác
        if (dao.isEmailTaken(deletedReader.getEmail(), readerId)) {
            return false;
        }

        // Kiểm tra phone xung đột (chỉ khi reader có phone)
        if (deletedReader.getPhone() != null && !deletedReader.getPhone().trim().isEmpty()) {
            if (dao.isPhoneTaken(deletedReader.getPhone(), readerId)) {
                return false;
            }
        }

        return true;
    }


    // =============================================
    // PRIVATE HELPERS — Tiện ích validate định dạng
    // =============================================

    /**
     * Kiểm tra định dạng email cơ bản.
     * Regex đơn giản: có ký tự @ và dấu chấm sau @.
     */
    private boolean isValidEmail(String email) {
        return email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    /**
     * Kiểm tra định dạng số điện thoại.
     * Cho phép: chữ số, dấu +, -, (, ), khoảng trắng. Tối thiểu 9 ký tự số.
     */
    private boolean isValidPhone(String phone) {
        // Loại bỏ ký tự định dạng để đếm chữ số thuần
        String digitsOnly = phone.replaceAll("[^0-9]", "");
        return digitsOnly.length() >= 9 && phone.matches("^[0-9+\\-().\\s]+$");
    }

    /**
     * Kiểm tra trạng thái có nằm trong danh sách cho phép không.
     */
    private boolean isValidStatus(String status) {
        return status != null &&
               (status.equals("Active") || status.equals("Suspended") || status.equals("Expired"));
    }
}
