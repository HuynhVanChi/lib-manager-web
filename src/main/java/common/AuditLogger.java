package common;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.google.gson.Gson;

/**
 * Lớp trung tâm chịu trách nhiệm ghi nhận nhật ký hệ thống (Audit Logs) vào database.
 * Được tối ưu hóa cho dự án LibraryOS.
 */
public class AuditLogger {
    private static final Logger logger = Logger.getLogger(AuditLogger.class.getName());
    private static final Gson gson = new Gson();

    /**
     * Enum định nghĩa các hành động hệ thống được phép lưu trong audit_logs
     */
    public enum ActionType {
        INSERT,
        UPDATE,
        DELETE,
        RESTORE
    }

    /**
     * Ghi nhận audit log sử dụng một connection có sẵn.
     * Sử dụng phương thức này khi log hoạt động trong cùng một Giao dịch (Transaction) của nghiệp vụ chính.
     * Nếu nghiệp vụ chính bị lỗi rollback, log cũng sẽ được rollback tương ứng.
     *
     * @param conn       kết nối DB đang hoạt động (không được đóng kết nối này trong hàm)
     * @param userId     ID của người dùng/thủ thư thực hiện hành động
     * @param action     Loại hành động (INSERT, UPDATE, DELETE, RESTORE)
     * @param tableName  Tên bảng dữ liệu bị tác động
     * @param recordId   ID của bản ghi bị tác động
     * @param oldValues  Dữ liệu cũ trước khi thay đổi (sẽ được tự động serialize sang JSON)
     * @param newValues  Dữ liệu mới sau khi thay đổi (sẽ được tự động serialize sang JSON)
     * @throws SQLException khi có lỗi truy vấn cơ sở dữ liệu
     */
    public static void log(Connection conn, int userId, ActionType action, String tableName, int recordId, Object oldValues, Object newValues) throws SQLException {
        if (conn == null) {
            throw new IllegalArgumentException("Connection không được phép null khi sử dụng hàm log kết hợp transaction.");
        }

        String sql = "INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values, new_values) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, action.name());
            pstmt.setString(3, tableName);
            pstmt.setInt(4, recordId);
            
            // Serialize dữ liệu sang định dạng JSON
            pstmt.setString(5, oldValues != null ? gson.toJson(oldValues) : null);
            pstmt.setString(6, newValues != null ? gson.toJson(newValues) : null);
            
            pstmt.executeUpdate();
        }
    }

    /**
     * Ghi nhận audit log bằng một kết nối độc lập.
     * Sử dụng phương thức này khi hành động ghi log diễn ra độc lập, không cần ràng buộc transaction với luồng nghiệp vụ.
     * Phương thức này KHÔNG sử dụng try-with-resources để tránh đóng Connection tĩnh dùng chung của ứng dụng.
     *
     * @param userId     ID của người dùng/thủ thư thực hiện hành động
     * @param action     Loại hành động (INSERT, UPDATE, DELETE, RESTORE)
     * @param tableName  Tên bảng dữ liệu bị tác động
     * @param recordId   ID của bản ghi bị tác động
     * @param oldValues  Dữ liệu cũ trước khi thay đổi (sẽ được tự động serialize sang JSON)
     * @param newValues  Dữ liệu mới sau khi thay đổi (sẽ được tự động serialize sang JSON)
     */
    public static void log(int userId, ActionType action, String tableName, int recordId, Object oldValues, Object newValues) {
        try (Connection conn = DBConnection.getConnection()) {
            log(conn, userId, action, tableName, recordId, oldValues, newValues);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi cơ sở dữ liệu khi ghi nhận audit log độc lập", e);
        }
    }
}
