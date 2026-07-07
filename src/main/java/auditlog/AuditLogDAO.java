package auditlog;

import common.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object (DAO) chịu trách nhiệm truy vấn bảng 'audit_logs'.
 * Chỉ bao gồm các thao tác đọc dữ liệu (Read-only) để phục vụ việc hiển thị.
 */
public class AuditLogDAO {

    /**
     * Truy vấn toàn bộ danh sách nhật ký hệ thống kèm theo thông tin tên thủ thư.
     * Hỗ trợ tìm kiếm từ khóa, lọc theo hành động, lọc theo bảng và giới hạn dòng tải.
     *
     * @param search       Từ khóa tìm kiếm theo tên thủ thư hoặc bảng (null nếu không dùng)
     * @param actionFilter Bộ lọc hành động: INSERT, UPDATE, DELETE, RESTORE (null nếu không dùng)
     * @param tableFilter  Bộ lọc tên bảng trong DB (null nếu không dùng)
     * @param limit        Giới hạn số bản ghi trả về (ví dụ: 150)
     * @return Danh sách AuditLog được sắp xếp mới nhất lên đầu
     */
    public List<AuditLog> findAll(String search, String actionFilter, String tableFilter, int limit) {
        List<AuditLog> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT al.*, u.full_name AS user_full_name " +
            "FROM audit_logs al " +
            "LEFT JOIN users u ON al.user_id = u.user_id " +
            "WHERE 1=1 "
        );

        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasAction = actionFilter != null && !actionFilter.trim().isEmpty();
        boolean hasTable = tableFilter != null && !tableFilter.trim().isEmpty();

        if (hasSearch) {
            sql.append(" AND (u.full_name LIKE ? OR al.table_name LIKE ?)");
        }
        if (hasAction) {
            sql.append(" AND al.action = ?");
        }
        if (hasTable) {
            sql.append(" AND al.table_name = ?");
        }

        sql.append(" ORDER BY al.created_at DESC LIMIT ").append(limit > 0 ? limit : 150);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (hasSearch) {
                String keyword = "%" + search.trim() + "%";
                pstmt.setString(paramIndex++, keyword); // u.full_name
                pstmt.setString(paramIndex++, keyword); // al.table_name
            }
            if (hasAction) {
                pstmt.setString(paramIndex++, actionFilter.trim());
            }
            if (hasTable) {
                pstmt.setString(paramIndex++, tableFilter.trim());
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setLogId(rs.getInt("log_id"));
                    
                    // user_id có thể null (Ví dụ khi user bị xóa cứng hoặc hành động hệ thống tự sinh)
                    int userId = rs.getInt("user_id");
                    log.setUserId(rs.wasNull() ? null : userId);
                    
                    // Lấy tên thủ thư từ kết quả JOIN, nếu null thì hiển thị "Hệ thống"
                    String fullName = rs.getString("user_full_name");
                    log.setUserFullName(rs.wasNull() || fullName == null ? "Hệ thống" : fullName);
                    
                    log.setAction(rs.getString("action"));
                    log.setTableName(rs.getString("table_name"));
                    log.setRecordId(rs.getInt("record_id"));
                    log.setOldValues(rs.getString("old_values"));
                    log.setNewValues(rs.getString("new_values"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));

                    list.add(log);
                }
            }

        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] Lỗi findAll: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Tìm chi tiết một bản ghi nhật ký hệ thống bằng ID
     *
     * @param logId ID của bản ghi nhật ký
     * @return Đối tượng AuditLog hoặc null nếu không tìm thấy
     */
    public AuditLog findById(int logId) {
        String sql = 
            "SELECT al.*, u.full_name AS user_full_name " +
            "FROM audit_logs al " +
            "LEFT JOIN users u ON al.user_id = u.user_id " +
            "WHERE al.log_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, logId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setLogId(rs.getInt("log_id"));
                    
                    int userId = rs.getInt("user_id");
                    log.setUserId(rs.wasNull() ? null : userId);
                    
                    String fullName = rs.getString("user_full_name");
                    log.setUserFullName(rs.wasNull() || fullName == null ? "Hệ thống" : fullName);
                    
                    log.setAction(rs.getString("action"));
                    log.setTableName(rs.getString("table_name"));
                    log.setRecordId(rs.getInt("record_id"));
                    log.setOldValues(rs.getString("old_values"));
                    log.setNewValues(rs.getString("new_values"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    return log;
                }
            }
        } catch (SQLException e) {
            System.err.println("[AuditLogDAO] Lỗi findById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
