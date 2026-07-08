package reader;

import common.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object cho bảng 'readers'.
 * Tất cả câu lệnh SQL đều dùng PreparedStatement để chống SQL Injection.
 * Soft Delete: Mọi thao tác "xóa" chỉ set deleted_at, không DELETE vật lý.
 */
public class ReaderDAO {

    // =============================================
    // PRIVATE HELPER — Ánh xạ ResultSet → Reader
    // =============================================

    /**
     * Ánh xạ một hàng ResultSet sang đối tượng Reader.
     * Tập trung mapping một chỗ, tránh lặp code ở nhiều phương thức.
     */
    private Reader mapRow(ResultSet rs) throws SQLException {
        Reader reader = new Reader();
        reader.setReaderId(rs.getInt("reader_id"));
        reader.setFullName(rs.getString("full_name"));
        reader.setPhone(rs.getString("phone"));
        reader.setEmail(rs.getString("email"));
        reader.setMembershipExpiredAt(rs.getTimestamp("membership_expired_at"));
        reader.setStatus(rs.getString("status"));
        reader.setCreatedAt(rs.getTimestamp("created_at"));
        reader.setUpdatedAt(rs.getTimestamp("updated_at"));
        reader.setDeletedAt(rs.getTimestamp("deleted_at"));

        // deleted_by có thể NULL trong DB → dùng getObject để tránh lỗi NPE
        int deletedBy = rs.getInt("deleted_by");
        reader.setDeletedBy(rs.wasNull() ? null : deletedBy);

        return reader;
    }


    // =============================================
    // 2.2 — findAll: Danh sách độc giả đang hoạt động
    // =============================================

    /**
     * Lấy danh sách tất cả độc giả chưa bị xóa mềm.
     * Hỗ trợ tìm kiếm theo tên/email/SĐT và lọc theo trạng thái.
     *
     * @param search       Từ khóa tìm kiếm (null hoặc rỗng = không lọc)
     * @param statusFilter Trạng thái cần lọc: 'Active', 'Suspended', 'Expired' (null = tất cả)
     * @return Danh sách Reader chưa xóa, sắp xếp theo tên A-Z
     */
    public List<Reader> findAll(String search, String statusFilter) {
        List<Reader> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT * FROM readers WHERE deleted_at IS NULL"
        );

        // Ghép điều kiện tìm kiếm full-text (tên, email, SĐT)
        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasStatus = statusFilter != null && !statusFilter.trim().isEmpty();

        if (hasSearch) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ? OR phone LIKE ?)");
        }
        if (hasStatus) {
            sql.append(" AND status = ?");
        }

        sql.append(" ORDER BY reader_id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (hasSearch) {
                String keyword = "%" + search.trim() + "%";
                pstmt.setString(paramIndex++, keyword); // full_name
                pstmt.setString(paramIndex++, keyword); // email
                pstmt.setString(paramIndex++, keyword); // phone
            }
            if (hasStatus) {
                pstmt.setString(paramIndex, statusFilter.trim());
            }

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi findAll: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }


    // =============================================
    // 2.3 — findDeleted: Danh sách độc giả đã xóa mềm
    // =============================================

    /**
     * Lấy danh sách độc giả đã bị xóa mềm (deleted_at IS NOT NULL).
     * Dùng cho tính năng "Thùng rác" hoặc khôi phục.
     *
     * @return Danh sách Reader đã xóa, sắp xếp theo thời gian xóa mới nhất
     */
    public List<Reader> findDeleted() {
        List<Reader> list = new ArrayList<>();
        String sql = "SELECT * FROM readers WHERE deleted_at IS NOT NULL ORDER BY deleted_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi findDeleted: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }


    // =============================================
    // 2.4 — findById: Tìm một độc giả theo ID
    // =============================================

    /**
     * Tìm một độc giả theo reader_id.
     * Trả về cả độc giả đã xóa mềm (để phục vụ trang detail hoặc restore).
     *
     * @param readerId ID cần tìm
     * @return Reader nếu tìm thấy, null nếu không có
     */
    public Reader findById(int readerId) {
        String sql = "SELECT * FROM readers WHERE reader_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, readerId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi findById id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }


    // =============================================
    // 2.5 — isEmailTaken: Kiểm tra email đã tồn tại chưa
    // =============================================

    /**
     * Kiểm tra email đã được sử dụng bởi một độc giả đang hoạt động chưa.
     * Sử dụng cột virtual 'active_email' (UNIQUE, chỉ non-null khi deleted_at IS NULL).
     *
     * @param email     Email cần kiểm tra
     * @param excludeId reader_id cần loại trừ khi kiểm tra (dùng khi edit, truyền null khi insert)
     * @return true nếu email đã bị chiếm bởi reader khác
     */
    public boolean isEmailTaken(String email, Integer excludeId) {
        String sql = "SELECT 1 FROM readers WHERE active_email = ?"
                   + (excludeId != null ? " AND reader_id != ?" : "")
                   + " LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            if (excludeId != null) {
                pstmt.setInt(2, excludeId);
            }

            ResultSet rs = pstmt.executeQuery();
            return rs.next(); // true = tìm thấy → email đã bị dùng

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi isEmailTaken: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }


    // =============================================
    // 2.6 — isPhoneTaken: Kiểm tra SĐT đã tồn tại chưa
    // =============================================

    /**
     * Kiểm tra số điện thoại đã được sử dụng bởi một độc giả đang hoạt động chưa.
     * Sử dụng cột virtual 'active_phone' (UNIQUE, chỉ non-null khi deleted_at IS NULL).
     * Bỏ qua kiểm tra nếu phone là null hoặc rỗng.
     *
     * @param phone     SĐT cần kiểm tra
     * @param excludeId reader_id cần loại trừ khi kiểm tra (dùng khi edit, truyền null khi insert)
     * @return true nếu SĐT đã bị chiếm bởi reader khác
     */
    public boolean isPhoneTaken(String phone, Integer excludeId) {
        // SĐT không bắt buộc — không kiểm tra nếu rỗng
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM readers WHERE active_phone = ?"
                   + (excludeId != null ? " AND reader_id != ?" : "")
                   + " LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, phone);
            if (excludeId != null) {
                pstmt.setInt(2, excludeId);
            }

            ResultSet rs = pstmt.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi isPhoneTaken: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }


    // =============================================
    // 2.7 — insert: Thêm độc giả mới
    // =============================================

    /**
     * Thêm một độc giả mới vào cơ sở dữ liệu.
     * Các trường created_at, updated_at do MySQL tự sinh (DEFAULT CURRENT_TIMESTAMP).
     *
     * @param reader Đối tượng Reader chứa dữ liệu cần insert
     * @return reader_id vừa được sinh ra, -1 nếu thất bại
     */
    public int insert(Reader reader) {
        String sql = "INSERT INTO readers (full_name, phone, email, membership_expired_at, status) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, reader.getFullName());
            pstmt.setString(2, reader.getPhone());
            pstmt.setString(3, reader.getEmail());
            pstmt.setTimestamp(4, reader.getMembershipExpiredAt());
            pstmt.setString(5, reader.getStatus() != null ? reader.getStatus() : "Active");

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows > 0) {
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1); // Trả về reader_id mới
                }
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi insert: " + e.getMessage());
            e.printStackTrace();
        }

        return -1; // Thất bại
    }


    // =============================================
    // 2.8 — update: Cập nhật thông tin độc giả
    // =============================================

    /**
     * Cập nhật thông tin của một độc giả đã tồn tại.
     * updated_at sẽ tự động cập nhật bởi MySQL (ON UPDATE CURRENT_TIMESTAMP).
     *
     * @param reader Đối tượng Reader chứa dữ liệu mới (readerId phải > 0)
     * @return true nếu cập nhật thành công
     */
    public boolean update(Reader reader) {
        String sql = "UPDATE readers SET full_name = ?, phone = ?, email = ?, "
                   + "membership_expired_at = ?, status = ? "
                   + "WHERE reader_id = ? AND deleted_at IS NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, reader.getFullName());
            pstmt.setString(2, reader.getPhone());
            pstmt.setString(3, reader.getEmail());
            pstmt.setTimestamp(4, reader.getMembershipExpiredAt());
            pstmt.setString(5, reader.getStatus());
            pstmt.setInt(6, reader.getReaderId());

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi update id=" + reader.getReaderId() + ": " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }


    // =============================================
    // 2.9 — softDelete: Xóa mềm độc giả
    // =============================================

    /**
     * Thực hiện xóa mềm: set deleted_at = NOW() và deleted_by = userId.
     * Không DELETE vật lý để bảo toàn lịch sử mượn sách.
     *
     * @param readerId  ID của độc giả cần xóa
     * @param deletedBy user_id của thủ thư đang thực hiện xóa
     * @return true nếu xóa mềm thành công
     */
    public boolean softDelete(int readerId, int deletedBy) {
        String sql = "UPDATE readers SET deleted_at = NOW(), deleted_by = ? "
                   + "WHERE reader_id = ? AND deleted_at IS NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, deletedBy);
            pstmt.setInt(2, readerId);

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi softDelete id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }


    // =============================================
    // 2.10 — restore: Khôi phục độc giả đã xóa mềm
    // =============================================

    /**
     * Khôi phục độc giả đã bị xóa mềm: set deleted_at = NULL và deleted_by = NULL.
     * Lưu ý: Phải gọi ReaderService.canRestore() trước để kiểm tra xung đột email/phone.
     *
     * @param readerId ID của độc giả cần khôi phục
     * @return true nếu khôi phục thành công
     */
    public boolean restore(int readerId) {
        String sql = "UPDATE readers SET deleted_at = NULL, deleted_by = NULL "
                   + "WHERE reader_id = ? AND deleted_at IS NOT NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, readerId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi restore id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }


    // =============================================
    // 2.11 — getReaderStats: Thống kê nhanh cho trang Detail
    // =============================================

    /**
     * Lấy thống kê tổng hợp của một độc giả để hiển thị trên trang chi tiết.
     * Bao gồm: tổng lượt mượn, đang mượn, quá hạn, tổng phí phạt chưa trả.
     *
     * @param readerId ID độc giả cần thống kê
     * @return Map chứa: totalBorrows, activeBorrows, overdueBorrows, unpaidFines
     */
    public Map<String, Object> getReaderStats(int readerId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBorrows", 0);
        stats.put("activeBorrows", 0);
        stats.put("overdueBorrows", 0);
        stats.put("unpaidFines", 0.0);

        String sql =
            "SELECT " +
            "  COUNT(bd.borrow_detail_id)                                      AS totalBorrows, " +
            "  SUM(bd.status = 'Borrowing')                                    AS activeBorrows, " +
            "  SUM(bd.status = 'Overdue')                                      AS overdueBorrows, " +
            "  COALESCE(SUM(CASE WHEN f.status = 'Unpaid' THEN f.amount END), 0) AS unpaidFines " +
            "FROM borrow_records br " +
            "JOIN borrow_details bd ON br.borrow_record_id = bd.borrow_record_id " +
            "LEFT JOIN fines f      ON bd.borrow_detail_id = f.borrow_detail_id " +
            "WHERE br.reader_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, readerId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                stats.put("totalBorrows",    rs.getInt("totalBorrows"));
                stats.put("activeBorrows",   rs.getInt("activeBorrows"));
                stats.put("overdueBorrows",  rs.getInt("overdueBorrows"));
                stats.put("unpaidFines",     rs.getDouble("unpaidFines"));
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi getReaderStats id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        return stats;
    }


    // =============================================
    // 2.12 — getBorrowHistory: Lịch sử mượn sách cho trang Detail
    // =============================================

    /**
     * Lấy toàn bộ lịch sử mượn sách của một độc giả.
     * JOIN qua 4 bảng để lấy tên sách và barcode.
     *
     * @param readerId ID độc giả cần xem lịch sử
     * @return Danh sách Map, mỗi phần tử là một lượt mượn chi tiết
     */
    public List<Map<String, Object>> getBorrowHistory(int readerId) {
        List<Map<String, Object>> history = new ArrayList<>();

        String sql =
            "SELECT " +
            "  bd.borrow_detail_id, " +
            "  b.title          AS bookTitle, " +
            "  bc.barcode, " +
            "  bd.borrow_date, " +
            "  bd.due_date, " +
            "  bd.return_date, " +
            "  bd.status        AS borrowStatus " +
            "FROM borrow_records br " +
            "JOIN borrow_details bd  ON br.borrow_record_id = bd.borrow_record_id " +
            "JOIN book_copies bc     ON bd.copy_id = bc.copy_id " +
            "JOIN books b            ON bc.book_id = b.book_id " +
            "WHERE br.reader_id = ? " +
            "ORDER BY bd.borrow_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, readerId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("borrowDetailId", rs.getInt("borrow_detail_id"));
                row.put("bookTitle",      rs.getString("bookTitle"));
                row.put("barcode",        rs.getString("barcode"));
                row.put("borrowDate",     rs.getDate("borrow_date"));
                row.put("dueDate",        rs.getDate("due_date"));
                row.put("returnDate",     rs.getDate("return_date")); // có thể null
                row.put("borrowStatus",   rs.getString("borrowStatus"));
                history.add(row);
            }

        } catch (SQLException e) {
            System.err.println("[ReaderDAO] Lỗi getBorrowHistory id=" + readerId + ": " + e.getMessage());
            e.printStackTrace();
        }

        return history;
    }
}
