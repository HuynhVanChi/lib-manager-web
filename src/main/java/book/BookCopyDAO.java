package book;

import common.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookCopyDAO {

    /**
     * Lấy danh sách các cuốn sách (bản sao) đang hoạt động của một đầu sách.
     */
    public List<BookCopy> findCopiesByBookId(int bookId) {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT * FROM book_copies WHERE book_id = ? AND deleted_at IS NULL ORDER BY copy_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BookCopy copy = new BookCopy();
                    copy.setCopyId(rs.getInt("copy_id"));
                    copy.setBookId(rs.getInt("book_id"));
                    copy.setBarcode(rs.getString("barcode"));
                    copy.setStatus(rs.getString("status"));
                    copy.setLocationShelf(rs.getString("location_shelf"));
                    copy.setCreatedAt(rs.getTimestamp("created_at"));
                    copy.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(copy);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm kiếm một cuốn sách cụ thể theo ID.
     */
    public BookCopy findById(int id) {
        String sql = "SELECT * FROM book_copies WHERE copy_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BookCopy copy = new BookCopy();
                    copy.setCopyId(rs.getInt("copy_id"));
                    copy.setBookId(rs.getInt("book_id"));
                    copy.setBarcode(rs.getString("barcode"));
                    copy.setStatus(rs.getString("status"));
                    copy.setLocationShelf(rs.getString("location_shelf"));
                    copy.setCreatedAt(rs.getTimestamp("created_at"));
                    copy.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return copy;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm mới một cuốn sách (bản sao) độc lập.
     */
    public boolean insert(BookCopy copy) throws SQLException {
        String sql = "INSERT INTO book_copies (book_id, barcode, status, location_shelf) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, copy.getBookId());
            pstmt.setString(2, copy.getBarcode());
            pstmt.setString(3, copy.getStatus() != null ? copy.getStatus() : "Available");
            pstmt.setString(4, copy.getLocationShelf());
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Thêm mới cuốn sách trong cùng một Connection dùng chung (phục vụ Transaction).
     */
    public boolean insert(Connection conn, BookCopy copy) throws SQLException {
        String sql = "INSERT INTO book_copies (book_id, barcode, status, location_shelf) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, copy.getBookId());
            pstmt.setString(2, copy.getBarcode());
            pstmt.setString(3, copy.getStatus() != null ? copy.getStatus() : "Available");
            pstmt.setString(4, copy.getLocationShelf());
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật thông tin cuốn sách (vị trí kệ, trạng thái).
     */
    public boolean update(BookCopy copy) throws SQLException {
        String sql = "UPDATE book_copies SET location_shelf = ?, status = ? WHERE copy_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, copy.getLocationShelf());
            pstmt.setString(2, copy.getStatus());
            pstmt.setInt(3, copy.getCopyId());
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật trạng thái cuốn sách sử dụng Connection chung (Transaction cho nhánh borrow-return).
     */
    public boolean updateStatus(Connection conn, int copyId, String status) throws SQLException {
        String sql = "UPDATE book_copies SET status = ? WHERE copy_id = ? AND deleted_at IS NULL";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, copyId);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật trạng thái cuốn sách (độc lập).
     */
    public boolean updateStatus(int copyId, String status) throws SQLException {
        String sql = "UPDATE book_copies SET status = ? WHERE copy_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, copyId);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Xóa mềm một cuốn sách (bản sao). Bị chặn nếu sách đang có trạng thái 'Borrowed' (Đang mượn).
     */
    public boolean softDelete(int id, int userId) throws SQLException {
        // 1. Kiểm tra trạng thái hiện tại
        BookCopy copy = findById(id);
        if (copy == null) {
            throw new SQLException("Cuốn sách không tồn tại hoặc đã bị xóa trước đó.");
        }
        if ("Borrowed".equalsIgnoreCase(copy.getStatus())) {
            throw new SQLException("Không thể xóa cuốn sách này vì sách đang được mượn bởi độc giả.");
        }

        // 2. Tiến hành xóa mềm
        String sql = "UPDATE book_copies SET deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE copy_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, id);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Kiểm tra trùng mã vạch trong hệ thống.
     */
    public boolean existsByBarcode(String barcode, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM book_copies WHERE barcode = ? AND deleted_at IS NULL");
        if (excludeId != null) {
            sql.append(" AND copy_id != ?");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            pstmt.setString(1, barcode);
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
     * Truy vấn động mã vạch lớn nhất hiện có trong DB dựa trên mã viết tắt của sách để sinh mã kế tiếp.
     * Ví dụ: mã viết tắt 'JWD' -> tìm các mã bắt đầu bằng 'JWD-' -> tìm thấy 'JWD-003' -> sinh 'JWD-004'.
     *
     * @param bookId      ID đầu sách
     * @param bookPrefix  Mã 3 ký tự viết tắt của đầu sách (ví dụ: JWD, DSA)
     * @return mã vạch kế tiếp (ví dụ: JWD-004)
     * @throws SQLException lỗi SQL
     */
    public String getNextBarcodeForBook(int bookId, String bookPrefix) throws SQLException {
        if (bookPrefix == null || bookPrefix.trim().isEmpty()) {
            bookPrefix = "BK"; // Fallback mặc định nếu không lấy được mã viết tắt
        }
        bookPrefix = bookPrefix.trim().toUpperCase();

        String sql = "SELECT barcode FROM book_copies WHERE barcode LIKE ? AND deleted_at IS NULL ORDER BY barcode DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, bookPrefix + "-%");
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String lastBarcode = rs.getString("barcode");
                    // Tách phần số thứ tự từ mã vạch (ví dụ: JWD-003 -> tách lấy 003)
                    String[] parts = lastBarcode.split("-");
                    if (parts.length >= 2) {
                        try {
                            int seq = Integer.parseInt(parts[parts.length - 1]);
                            int nextSeq = seq + 1;
                            return String.format("%s-%03d", bookPrefix, nextSeq);
                        } catch (NumberFormatException e) {
                            // Nếu phần đuôi không phải là số, tự động tạo chuỗi kế tiếp ngẫu nhiên/an toàn
                        }
                    }
                }
            }
        }

        // Nếu chưa có cuốn sách nào trong DB bắt đầu bằng prefix đó, bắt đầu từ 001
        return String.format("%s-001", bookPrefix);
    }
}
