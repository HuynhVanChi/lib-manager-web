package recommend;

import common.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý các tác vụ cơ sở dữ liệu trên bảng book_recommendations.
 * Hỗ trợ xóa mềm (soft delete) và khôi phục (restore) giống với Reader.
 */
public class BookRecommendationDAO {

    public boolean create(BookRecommendation rec) throws SQLException {
        String sql = "INSERT INTO book_recommendations (reader_name, reader_phone, reader_code, book_title, author, " +
                     "category, publisher, publish_year, reason, note, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', ?)";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, rec.getReaderName());
            ps.setString(2, rec.getReaderPhone());
            ps.setString(3, rec.getReaderCode());
            ps.setString(4, rec.getBookTitle());
            ps.setString(5, rec.getAuthor());
            ps.setString(6, rec.getCategory());
            ps.setString(7, rec.getPublisher());
            ps.setInt(8, rec.getPublishYear());
            ps.setString(9, rec.getReason());
            ps.setString(10, rec.getNote());
            ps.setInt(11, rec.getCreatedBy());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        rec.setRecommendationId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public boolean update(BookRecommendation rec) throws SQLException {
        String sql = "UPDATE book_recommendations " +
                     "SET reader_name = ?, reader_phone = ?, reader_code = ?, book_title = ?, author = ?, " +
                     "category = ?, publisher = ?, publish_year = ?, reason = ?, note = ? " +
                     "WHERE recommendation_id = ? AND status = 'Pending' AND deleted_at IS NULL";
                      
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rec.getReaderName());
            ps.setString(2, rec.getReaderPhone());
            ps.setString(3, rec.getReaderCode());
            ps.setString(4, rec.getBookTitle());
            ps.setString(5, rec.getAuthor());
            ps.setString(6, rec.getCategory());
            ps.setString(7, rec.getPublisher());
            ps.setInt(8, rec.getPublishYear());
            ps.setString(9, rec.getReason());
            ps.setString(10, rec.getNote());
            ps.setInt(11, rec.getRecommendationId());
            
            return ps.executeUpdate() > 0;
        }
    }

    // Thực hiện xóa mềm (Soft Delete)
    public boolean delete(int id, int deletedBy) throws SQLException {
        String sql = "UPDATE book_recommendations SET deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE recommendation_id = ? AND status = 'Pending' AND deleted_at IS NULL";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deletedBy);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    // Khôi phục từ thùng rác
    public boolean restore(int id) throws SQLException {
        String sql = "UPDATE book_recommendations SET deleted_at = NULL, deleted_by = NULL WHERE recommendation_id = ? AND deleted_at IS NOT NULL";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // Danh sách các đề xuất đã xóa (Thùng rác)
    public List<BookRecommendation> findDeleted() throws SQLException {
        List<BookRecommendation> list = new ArrayList<>();
        String sql = "SELECT br.*, u.full_name AS creator_name " +
                     "FROM book_recommendations br " +
                     "LEFT JOIN users u ON br.created_by = u.user_id " +
                     "WHERE br.deleted_at IS NOT NULL " +
                     "ORDER BY br.deleted_at DESC";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToRecommendation(rs));
            }
        }
        return list;
    }

    public BookRecommendation getById(int id) throws SQLException {
        String sql = "SELECT br.*, u.full_name AS creator_name " +
                     "FROM book_recommendations br " +
                     "LEFT JOIN users u ON br.created_by = u.user_id " +
                     "WHERE br.recommendation_id = ? AND br.deleted_at IS NULL";
                      
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToRecommendation(rs);
                }
            }
        }
        return null;
    }

    public List<BookRecommendation> listAll(String keyword, String statusFilter) throws SQLException {
        List<BookRecommendation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT br.*, u.full_name AS creator_name " +
            "FROM book_recommendations br " +
            "LEFT JOIN users u ON br.created_by = u.user_id " +
            "WHERE br.deleted_at IS NULL"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (br.book_title LIKE ? OR br.author LIKE ? OR br.reader_name LIKE ?)");
            String queryKey = "%" + keyword.trim() + "%";
            params.add(queryKey);
            params.add(queryKey);
            params.add(queryKey);
        }
        
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND br.status = ?");
            params.add(statusFilter.trim());
        }
        
        sql.append(" ORDER BY br.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToRecommendation(rs));
                }
            }
        }
        return list;
    }

    private BookRecommendation mapRowToRecommendation(ResultSet rs) throws SQLException {
        BookRecommendation rec = new BookRecommendation();
        rec.setRecommendationId(rs.getInt("recommendation_id"));
        rec.setReaderName(rs.getString("reader_name"));
        rec.setReaderPhone(rs.getString("reader_phone"));
        rec.setReaderCode(rs.getString("reader_code"));
        rec.setBookTitle(rs.getString("book_title"));
        rec.setAuthor(rs.getString("author"));
        rec.setCategory(rs.getString("category"));
        rec.setPublisher(rs.getString("publisher"));
        rec.setPublishYear(rs.getInt("publish_year"));
        rec.setReason(rs.getString("reason"));
        rec.setNote(rs.getString("note"));
        rec.setStatus(rs.getString("status"));
        rec.setCreatedBy(rs.getInt("created_by"));
        rec.setCreatorName(rs.getString("creator_name"));
        rec.setCreatedAt(rs.getTimestamp("created_at"));
        rec.setUpdatedAt(rs.getTimestamp("updated_at"));
        return rec;
    }

    public boolean updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE book_recommendations SET status = ? WHERE recommendation_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }
}
