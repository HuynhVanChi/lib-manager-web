package borrowtereturn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import common.DBConnection;

public class BorrowReturnDAO {

    public void initDb() {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try {
                stmt.executeUpdate("ALTER TABLE borrow_details ADD COLUMN book_condition VARCHAR(100) DEFAULT 'Bình thường'");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE borrow_details ADD COLUMN notes TEXT DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE fines ADD COLUMN notes TEXT DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE books ADD COLUMN price DECIMAL(10,2) DEFAULT 100000.00");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE fines ADD COLUMN original_amount DECIMAL(10,2) DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Map<String, Object>> getBorrowList() throws SQLException {
        List<Map<String, Object>> borrowList = new ArrayList<>();
        String borrowSql = "SELECT bd.borrow_detail_id, bd.borrow_record_id, bd.copy_id, bd.borrow_date, bd.due_date, " +
                         "bd.return_date, bd.status AS detail_status, r.full_name AS reader_name, r.email AS reader_email, " +
                         "b.title AS book_title, c.barcode " +
                         "FROM borrow_details bd " +
                         "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                         "JOIN readers r ON br.reader_id = r.reader_id " +
                         "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                         "JOIN books b ON c.book_id = b.book_id " +
                         "ORDER BY bd.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(borrowSql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                map.put("borrow_record_id", rs.getInt("borrow_record_id"));
                map.put("copy_id", rs.getInt("copy_id"));
                map.put("borrow_date", rs.getDate("borrow_date"));
                map.put("due_date", rs.getDate("due_date"));
                map.put("return_date", rs.getDate("return_date"));
                map.put("status", rs.getString("detail_status"));
                map.put("reader_name", rs.getString("reader_name"));
                map.put("reader_email", rs.getString("reader_email"));
                map.put("book_title", rs.getString("book_title"));
                map.put("barcode", rs.getString("barcode"));
                borrowList.add(map);
            }
        }
        return borrowList;
    }

    public List<Map<String, Object>> getFineList() throws SQLException {
        List<Map<String, Object>> fineList = new ArrayList<>();
        String fineSql = "SELECT f.fine_id, f.borrow_detail_id, f.amount, f.original_amount, f.reason, f.status AS fine_status, " +
                       "f.paid_at, u.full_name AS receiver_name, r.full_name AS reader_name, r.email AS reader_email, b.title AS book_title, c.barcode " +
                       "FROM fines f " +
                       "JOIN borrow_details bd ON f.borrow_detail_id = bd.borrow_detail_id " +
                       "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                       "JOIN readers r ON br.reader_id = r.reader_id " +
                       "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                       "JOIN books b ON c.book_id = b.book_id " +
                       "LEFT JOIN users u ON f.received_by = u.user_id " +
                       "ORDER BY f.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(fineSql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("fine_id", rs.getInt("fine_id"));
                map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                map.put("amount", rs.getBigDecimal("amount"));
                map.put("original_amount", rs.getBigDecimal("original_amount"));
                map.put("reason", rs.getString("reason"));
                map.put("status", rs.getString("fine_status"));
                map.put("paid_at", rs.getTimestamp("paid_at"));
                map.put("receiver_name", rs.getString("receiver_name"));
                map.put("reader_name", rs.getString("reader_name"));
                map.put("reader_email", rs.getString("reader_email"));
                map.put("book_title", rs.getString("book_title"));
                map.put("barcode", rs.getString("barcode"));
                fineList.add(map);
            }
        }
        return fineList;
    }

    public List<Map<String, Object>> getActiveReaders() throws SQLException {
        List<Map<String, Object>> readerList = new ArrayList<>();
        String readerSql = "SELECT reader_id, full_name, email, phone FROM readers WHERE deleted_at IS NULL AND status = 'Active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(readerSql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("reader_id", rs.getInt("reader_id"));
                map.put("full_name", rs.getString("full_name"));
                map.put("email", rs.getString("email"));
                map.put("phone", rs.getString("phone"));
                readerList.add(map);
            }
        }
        return readerList;
    }

    public List<Map<String, Object>> getAvailableCopies() throws SQLException {
        List<Map<String, Object>> availableCopies = new ArrayList<>();
        String copiesSql = "SELECT c.copy_id, c.barcode, b.title FROM book_copies c " +
                           "JOIN books b ON c.book_id = b.book_id " +
                           "WHERE c.status = 'Available' AND c.deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(copiesSql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("copy_id", rs.getInt("copy_id"));
                map.put("barcode", rs.getString("barcode"));
                map.put("title", rs.getString("title"));
                availableCopies.add(map);
            }
        }
        return availableCopies;
    }

    public String checkCopyStatusForUpdate(Connection conn, int copyId) throws SQLException {
        String checkCopySql = "SELECT status FROM book_copies WHERE copy_id = ? FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(checkCopySql)) {
            stmt.setInt(1, copyId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }
        return null;
    }

    public int insertBorrowRecord(Connection conn, int readerId, int userId) throws SQLException {
        String insertRecordSql = "INSERT INTO borrow_records (reader_id, user_id) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(insertRecordSql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, readerId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Không tạo được borrow_records");
    }

    public int insertBorrowDetail(Connection conn, int borrowRecordId, int copyId, Date borrowDate, Date dueDate) throws SQLException {
        String insertDetailSql = "INSERT INTO borrow_details (borrow_record_id, copy_id, borrow_date, due_date, status) VALUES (?, ?, ?, ?, 'Borrowing')";
        try (PreparedStatement stmt = conn.prepareStatement(insertDetailSql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, borrowRecordId);
            stmt.setInt(2, copyId);
            stmt.setDate(3, borrowDate);
            stmt.setDate(4, dueDate);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("Không tạo được borrow_details");
    }

    public void updateCopyStatus(Connection conn, int copyId, String status) throws SQLException {
        String updateCopySql = "UPDATE book_copies SET status = ? WHERE copy_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
            stmt.setString(1, status);
            stmt.setInt(2, copyId);
            stmt.executeUpdate();
        }
    }

    public Map<String, Object> findBorrowDetailById(int id) throws SQLException {
        Map<String, Object> map = null;
        String sql = "SELECT bd.borrow_detail_id, bd.borrow_record_id, bd.copy_id, bd.borrow_date, bd.due_date, " +
                     "bd.return_date, bd.status AS detail_status, bd.book_condition, bd.notes, r.full_name AS reader_name, r.email AS reader_email, " +
                     "r.phone AS reader_phone, b.title AS book_title, c.barcode " +
                     "FROM borrow_details bd " +
                     "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                     "JOIN readers r ON br.reader_id = r.reader_id " +
                     "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                     "JOIN books b ON c.book_id = b.book_id " +
                     "WHERE bd.borrow_detail_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    map = new HashMap<>();
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("borrow_record_id", rs.getInt("borrow_record_id"));
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("borrow_date", rs.getDate("borrow_date"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("return_date", rs.getDate("return_date"));
                    map.put("status", rs.getString("detail_status"));
                    map.put("book_condition", rs.getString("book_condition"));
                    map.put("notes", rs.getString("notes"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("reader_phone", rs.getString("reader_phone"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                }
            }
        }
        return map;
    }

    public List<Map<String, Object>> findFinesByBorrowDetailId(int borrowDetailId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT f.fine_id, f.amount, f.reason, f.status AS fine_status, f.paid_at " +
                     "FROM fines f " +
                     "WHERE f.borrow_detail_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public double getBookPrice(Connection conn, int borrowDetailId) throws SQLException {
        double bookPrice = 100000.00;
        String priceSql = "SELECT b.price FROM borrow_details bd " +
                          "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                          "JOIN books b ON c.book_id = b.book_id " +
                          "WHERE bd.borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(priceSql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    bookPrice = rs.getDouble("price");
                }
            }
        }
        return bookPrice;
    }

    public Map<String, Object> getBorrowDetailForUpdate(Connection conn, int borrowDetailId) throws SQLException {
        String fetchSql = "SELECT copy_id, due_date, status FROM borrow_details WHERE borrow_detail_id = ? FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("status", rs.getString("status"));
                    return map;
                }
            }
        }
        return null;
    }

    public void updateBorrowDetailReturn(Connection conn, int borrowDetailId, Date returnDate, String status, String bookCondition, String notes) throws SQLException {
        String updateDetailSql = "UPDATE borrow_details SET return_date = ?, status = ?, book_condition = ?, notes = ? WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateDetailSql)) {
            if (returnDate == null) {
                stmt.setNull(1, java.sql.Types.DATE);
            } else {
                stmt.setDate(1, returnDate);
            }
            stmt.setString(2, status);
            stmt.setString(3, bookCondition);
            stmt.setString(4, notes);
            stmt.setInt(5, borrowDetailId);
            stmt.executeUpdate();
        }
    }

    public int checkFineExists(Connection conn, int borrowDetailId) throws SQLException {
        String checkFineSql = "SELECT fine_id FROM fines WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(checkFineSql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("fine_id");
                }
            }
        }
        return 0;
    }

    public void updateFineAmountAndReason(Connection conn, int fineId, double amount, String reason) throws SQLException {
        String updateFineSql = "UPDATE fines SET amount = ?, reason = ?, status = 'Unpaid' WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, reason);
            stmt.setInt(3, fineId);
            stmt.executeUpdate();
        }
    }

    public void insertFine(Connection conn, int borrowDetailId, double amount, String reason, String status) throws SQLException {
        String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
            stmt.setInt(1, borrowDetailId);
            stmt.setDouble(2, amount);
            stmt.setString(3, reason);
            stmt.setString(4, status);
            stmt.executeUpdate();
        }
    }

    public Map<String, Object> getFineForUpdate(Connection conn, int fineId) throws SQLException {
        String selectSql = "SELECT amount, status FROM fines WHERE fine_id = ? FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
            stmt.setInt(1, fineId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("amount", rs.getDouble("amount"));
                    map.put("status", rs.getString("status"));
                    return map;
                }
            }
        }
        return null;
    }

    public void payFine(Connection conn, int fineId, double finalAmount, double originalAmount, String newStatus, int userId, String discountNote) throws SQLException {
        String updateFineSql = "UPDATE fines SET amount = ?, original_amount = ?, status = ?, paid_at = CURRENT_TIMESTAMP, received_by = ?, notes = CONCAT(IFNULL(notes, ''), ?) WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
            stmt.setDouble(1, finalAmount);
            stmt.setDouble(2, originalAmount);
            stmt.setString(3, newStatus);
            stmt.setInt(4, userId);
            stmt.setString(5, discountNote);
            stmt.setInt(6, fineId);
            stmt.executeUpdate();
        }
    }

    public void waiveFine(Connection conn, int fineId, int userId) throws SQLException {
        String updateFineSql = "UPDATE fines SET status = 'Waived', paid_at = CURRENT_TIMESTAMP, received_by = ? WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, fineId);
            stmt.executeUpdate();
        }
    }

    public Map<String, Object> getFineDetailsForUndo(Connection conn, int fineId) throws SQLException {
        String selectSql = "SELECT amount, original_amount, status FROM fines WHERE fine_id = ? FOR UPDATE";
        try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
            stmt.setInt(1, fineId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("amount", rs.getDouble("amount"));
                    double orig = rs.getDouble("original_amount");
                    if (rs.wasNull()) {
                        map.put("original_amount", null);
                    } else {
                        map.put("original_amount", orig);
                    }
                    map.put("status", rs.getString("status"));
                    return map;
                }
            }
        }
        return null;
    }

    public void undoFine(Connection conn, int fineId, double restoredAmount, String undoNote) throws SQLException {
        String updateSql = "UPDATE fines SET status = 'Unpaid', amount = ?, original_amount = NULL, paid_at = NULL, received_by = NULL, notes = CONCAT(IFNULL(notes, ''), ?) WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
            stmt.setDouble(1, restoredAmount);
            stmt.setString(2, undoNote);
            stmt.setInt(3, fineId);
            stmt.executeUpdate();
        }
    }

    public void deleteFinesByBorrowDetailId(Connection conn, int borrowDetailId) throws SQLException {
        String deleteFinesSql = "DELETE FROM fines WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteFinesSql)) {
            stmt.setInt(1, borrowDetailId);
            stmt.executeUpdate();
        }
    }

    public int getCopyIdFromBorrowDetail(Connection conn, int borrowDetailId) throws SQLException {
        String getCopySql = "SELECT copy_id FROM borrow_details WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(getCopySql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("copy_id");
                }
            }
        }
        return 0;
    }

    public void deleteBorrowDetail(Connection conn, int borrowDetailId) throws SQLException {
        String deleteDetailSql = "DELETE FROM borrow_details WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteDetailSql)) {
            stmt.setInt(1, borrowDetailId);
            stmt.executeUpdate();
        }
    }

    public void deleteFine(Connection conn, int fineId) throws SQLException {
        String deleteFineSql = "DELETE FROM fines WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteFineSql)) {
            stmt.setInt(1, fineId);
            stmt.executeUpdate();
        }
    }

    public Map<String, Object> findFineById(int fineId) throws SQLException {
        Map<String, Object> map = null;
        String sql = "SELECT f.fine_id, f.borrow_detail_id, f.amount, f.reason, f.status AS fine_status, " +
                     "f.paid_at, f.notes, r.full_name AS reader_name, r.email AS reader_email, b.title AS book_title, c.barcode, " +
                     "bd.borrow_date, bd.due_date, bd.return_date " +
                     "FROM fines f " +
                     "JOIN borrow_details bd ON f.borrow_detail_id = bd.borrow_detail_id " +
                     "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                     "JOIN readers r ON br.reader_id = r.reader_id " +
                     "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                     "JOIN books b ON c.book_id = b.book_id " +
                     "WHERE f.fine_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, fineId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    map.put("notes", rs.getString("notes"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                    map.put("borrow_date", rs.getDate("borrow_date"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("return_date", rs.getDate("return_date"));
                }
            }
        }
        return map;
    }

    public void updateBorrowDetailAll(Connection conn, int id, Date borrowDate, Date dueDate, Date returnDate, String status, String bookCondition, String notes) throws SQLException {
        String sql = "UPDATE borrow_details SET borrow_date = ?, due_date = ?, return_date = ?, status = ?, book_condition = ?, notes = ? WHERE borrow_detail_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, borrowDate);
            stmt.setDate(2, dueDate);
            if (returnDate == null) {
                stmt.setNull(3, java.sql.Types.DATE);
            } else {
                stmt.setDate(3, returnDate);
            }
            stmt.setString(4, status);
            stmt.setString(5, bookCondition);
            stmt.setString(6, notes);
            stmt.setInt(7, id);
            stmt.executeUpdate();
        }
    }

    public void updateFineAll(Connection conn, int id, double amount, String reason, String status, Timestamp paidAt, Integer receivedBy) throws SQLException {
        String sql = "UPDATE fines SET amount = ?, reason = ?, status = ?, paid_at = ?, received_by = ? WHERE fine_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, reason);
            stmt.setString(3, status);
            if (paidAt == null) {
                stmt.setNull(4, java.sql.Types.TIMESTAMP);
            } else {
                stmt.setTimestamp(4, paidAt);
            }
            if (receivedBy == null) {
                stmt.setNull(5, java.sql.Types.INTEGER);
            } else {
                stmt.setInt(5, receivedBy);
            }
            stmt.setInt(6, id);
            stmt.executeUpdate();
        }
    }
}
