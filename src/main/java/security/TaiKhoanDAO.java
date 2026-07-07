package security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import common.AuditLogger;
import common.DBConnection;

/**
 * Lớp DAO quản lý các thao tác cơ sở dữ liệu trên bảng `users` cho module Tài khoản.
 */
public class TaiKhoanDAO {

    /**
     * Trả về kết nối Database
     */
    private Connection getConnection() throws SQLException {
        try {
            return DBConnection.getConnection();
        } catch (SQLException e) {
            // Lọc lỗi Access denied hoặc SQLState xác thực không thành công
            if (e.getMessage() != null && (e.getMessage().contains("Access denied") || "28000".equals(e.getSQLState()))) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    return DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/quanlythuvien?useUnicode=true&characterEncoding=UTF-8",
                        "root",
                        "123456"
                    );
                } catch (Exception ex) {
                    throw e; // Ném lỗi gốc nếu fallback cũng thất bại
                }
            }
            throw e;
        }
    }

    /**
     * Hàm băm mật khẩu sử dụng thuật toán SHA-256.
     * 
     * @param password mật khẩu gốc dạng văn bản thuần túy
     * @return chuỗi thập lục phân dài 64 ký tự đã được băm
     */
    public String hashPassword(String password) {
        if (password == null) return null;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception ex) {
            throw new RuntimeException("Lỗi mã hóa mật khẩu", ex);
        }
    }

    /**
     * Kiểm tra thông tin đăng nhập của người dùng.
     * Hỗ trợ so sánh plaintext (dành cho dữ liệu mẫu có sẵn) và SHA-256 (dành cho các tài khoản mới).
     * 
     * @param username tên tài khoản
     * @param password mật khẩu người dùng nhập
     * @return đối tượng TaiKhoan nếu đăng nhập thành công, ngược lại trả về null
     */
    public TaiKhoan checkLogin(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND deleted_at IS NULL";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
                    
                    // So sánh plaintext (tương thích dữ liệu mẫu) hoặc băm SHA-256
                    if (password.equals(storedPassword) || hashPassword(password).equals(storedPassword)) {
                        return mapResultSetToTaiKhoan(rs);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy toàn bộ danh sách tài khoản hoạt động có hỗ trợ tìm kiếm và lọc.
     * 
     * @param search từ khóa tìm kiếm (theo tên đăng nhập hoặc họ tên)
     * @param roleFilter vai trò lọc ('Admin', 'Staff')
     * @return danh sách các tài khoản phù hợp điều kiện
     */
    public List<TaiKhoan> getAll(String search, String roleFilter) {
        List<TaiKhoan> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE deleted_at IS NULL");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (username LIKE ? OR full_name LIKE ?)");
            String keyword = "%" + search.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !roleFilter.equalsIgnoreCase("All")) {
            sql.append(" AND role = ?");
            params.add(roleFilter.trim());
        }

        sql.append(" ORDER BY user_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToTaiKhoan(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết của một tài khoản theo ID.
     */
    public TaiKhoan getById(int userId) {
        try (Connection conn = getConnection()) {
            return getByIdInternal(conn, userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Lấy thông tin chi tiết của một tài khoản theo ID bằng connection có sẵn (hỗ trợ transaction).
     */
    private TaiKhoan getByIdInternal(Connection conn, int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ? AND deleted_at IS NULL";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTaiKhoan(rs);
                }
            }
        }
        return null;
    }

    /**
     * Kiểm tra tên tài khoản đã tồn tại chưa (tránh trùng tên đăng nhập cho tài khoản đang hoạt động).
     */
    public boolean isUsernameExists(String username, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE username = ? AND deleted_at IS NULL");
        if (excludeId != null) {
            sql.append(" AND user_id != ?");
        }
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            pstmt.setString(1, username);
            if (excludeId != null) {
                pstmt.setInt(2, excludeId);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm mới tài khoản và ghi nhận audit log.
     * 
     * @param tk đối tượng tài khoản chứa thông tin cần lưu (mật khẩu dạng plaintext sẽ tự động được băm)
     * @param actorId ID của người thực hiện hành động (Admin đang đăng nhập)
     * @return true nếu thành công, ngược lại false
     */
    public boolean insert(TaiKhoan tk, int actorId) {
        String sql = "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Băm mật khẩu mới thêm
                String hashedPassword = hashPassword(tk.getPassword());
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    pstmt.setString(1, tk.getUsername());
                    pstmt.setString(2, hashedPassword);
                    pstmt.setString(3, tk.getFullName());
                    pstmt.setString(4, tk.getRole());
                    
                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows == 0) {
                        throw new SQLException("Thêm tài khoản thất bại, không có hàng nào bị ảnh hưởng.");
                    }
                    
                    try (ResultSet rs = pstmt.getGeneratedKeys()) {
                        if (rs.next()) {
                            tk.setUserId(rs.getInt(1));
                        } else {
                            throw new SQLException("Thêm tài khoản thất bại, không lấy được ID tự sinh.");
                        }
                    }
                }
                
                // Đồng bộ hash vào object phục vụ Audit Log
                tk.setPassword(hashedPassword);
                
                // Ghi nhận Audit Log
                AuditLogger.log(conn, actorId, AuditLogger.ActionType.INSERT, "users", tk.getUserId(), null, tk);
                
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật thông tin tài khoản và ghi nhận audit log.
     * 
     * @param tk đối tượng tài khoản chứa thông tin cần cập nhật (nếu mật khẩu trống hoặc giống cũ sẽ giữ nguyên)
     * @param actorId ID của người thực hiện hành động
     * @return true nếu thành công, ngược lại false
     */
    public boolean update(TaiKhoan tk, int actorId) {
        String sql = "UPDATE users SET username = ?, password = ?, full_name = ?, role = ? WHERE user_id = ? AND deleted_at IS NULL";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Lấy thông tin trạng thái cũ của user
                TaiKhoan oldTk = getByIdInternal(conn, tk.getUserId());
                if (oldTk == null) {
                    throw new SQLException("Không tìm thấy tài khoản cần cập nhật hoặc đã bị xóa.");
                }
                
                // Xác định mật khẩu mới cập nhật
                String newPasswordHash = oldTk.getPassword();
                if (tk.getPassword() != null && !tk.getPassword().trim().isEmpty()) {
                    // Nếu nhập mật khẩu mới khác mật khẩu đã lưu
                    if (!tk.getPassword().equals(oldTk.getPassword())) {
                        // Kiểm tra nếu là hash SHA-256 sẵn thì không băm lại, nếu không thì băm
                        if (tk.getPassword().length() == 64 && tk.getPassword().matches("^[0-9a-fA-F]+$")) {
                            newPasswordHash = tk.getPassword();
                        } else {
                            newPasswordHash = hashPassword(tk.getPassword());
                        }
                    }
                }
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, tk.getUsername());
                    pstmt.setString(2, newPasswordHash);
                    pstmt.setString(3, tk.getFullName());
                    pstmt.setString(4, tk.getRole());
                    pstmt.setInt(5, tk.getUserId());
                    
                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows == 0) {
                        throw new SQLException("Cập nhật tài khoản thất bại, không tìm thấy bản ghi.");
                    }
                }
                
                // Đồng bộ dữ liệu mới để ghi log
                tk.setPassword(newPasswordHash);
                
                // Ghi nhận Audit Log
                AuditLogger.log(conn, actorId, AuditLogger.ActionType.UPDATE, "users", tk.getUserId(), oldTk, tk);
                
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa mềm tài khoản và ghi nhận audit log.
     * 
     * @param userId ID của tài khoản cần xóa
     * @param actorId ID của người thực hiện hành động xóa
     * @return true nếu thành công, ngược lại false
     */
    public boolean delete(int userId, int actorId) {
        String sql = "UPDATE users SET deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE user_id = ? AND deleted_at IS NULL";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Lấy thông tin trạng thái cũ trước khi xóa
                TaiKhoan oldTk = getByIdInternal(conn, userId);
                if (oldTk == null) {
                    throw new SQLException("Không tìm thấy tài khoản cần xóa hoặc đã bị xóa trước đó.");
                }
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, actorId);
                    pstmt.setInt(2, userId);
                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows == 0) {
                        throw new SQLException("Xóa tài khoản thất bại.");
                    }
                }
                
                // Ghi nhận Audit Log hành động xóa
                AuditLogger.log(conn, actorId, AuditLogger.ActionType.DELETE, "users", userId, oldTk, null);
                
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách tài khoản đã bị xóa mềm (deleted_at IS NOT NULL).
     *
     * @return danh sách các tài khoản đã bị xóa mềm
     */
    public List<TaiKhoan> getDeleted() {
        List<TaiKhoan> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE deleted_at IS NOT NULL ORDER BY deleted_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToTaiKhoan(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm một tài khoản theo user_id kể cả khi đã bị xóa mềm.
     *
     * @param userId ID cần tìm
     * @return TaiKhoan nếu tìm thấy, null nếu không có
     */
    public TaiKhoan getByIdAny(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTaiKhoan(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Khôi phục tài khoản đã bị xóa mềm: set deleted_at = NULL và deleted_by = NULL.
     *
     * @param userId ID của tài khoản cần khôi phục
     * @param actorId ID của người thực hiện hành động khôi phục
     * @return true nếu khôi phục thành công, ngược lại false
     */
    public boolean restore(int userId, int actorId) {
        String sql = "UPDATE users SET deleted_at = NULL, deleted_by = NULL WHERE user_id = ? AND deleted_at IS NOT NULL";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Lấy thông tin tài khoản trước khi khôi phục (để ghi audit log)
                TaiKhoan tk = getByIdAny(userId);
                if (tk == null) {
                    throw new SQLException("Không tìm thấy tài khoản cần khôi phục.");
                }

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, userId);
                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows == 0) {
                        throw new SQLException("Khôi phục tài khoản thất bại.");
                    }
                }

                // Ghi nhận Audit Log hành động khôi phục
                AuditLogger.log(conn, actorId, AuditLogger.ActionType.RESTORE, "users", userId, null, tk);

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Ánh xạ ResultSet thành đối tượng TaiKhoan.
     */
    private TaiKhoan mapResultSetToTaiKhoan(ResultSet rs) throws SQLException {
        TaiKhoan tk = new TaiKhoan();
        tk.setUserId(rs.getInt("user_id"));
        tk.setUsername(rs.getString("username"));
        tk.setPassword(rs.getString("password"));
        tk.setFullName(rs.getString("full_name"));
        tk.setRole(rs.getString("role"));
        tk.setCreatedAt(rs.getTimestamp("created_at"));
        tk.setUpdatedAt(rs.getTimestamp("updated_at"));
        tk.setDeletedAt(rs.getTimestamp("deleted_at"));
        
        int delBy = rs.getInt("deleted_by");
        if (rs.wasNull()) {
            tk.setDeletedBy(null);
        } else {
            tk.setDeletedBy(delBy);
        }
        return tk;
    }
}
