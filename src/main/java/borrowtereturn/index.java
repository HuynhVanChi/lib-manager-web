package borrowtereturn;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import common.DBConnection;
import common.AuditLogger;

@WebServlet("/borrow-return")
public class index extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> borrowList = new ArrayList<>();
        List<Map<String, Object>> fineList = new ArrayList<>();
        List<Map<String, Object>> readerList = new ArrayList<>();
        List<Map<String, Object>> availableCopies = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch borrow details
            String borrowSql = "SELECT bd.borrow_detail_id, bd.borrow_record_id, bd.copy_id, bd.borrow_date, bd.due_date, " +
                             "bd.return_date, bd.status AS detail_status, r.full_name AS reader_name, r.email AS reader_email, " +
                             "b.title AS book_title, c.barcode " +
                             "FROM borrow_details bd " +
                             "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                             "JOIN readers r ON br.reader_id = r.reader_id " +
                             "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                             "JOIN books b ON c.book_id = b.book_id " +
                             "ORDER BY bd.created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(borrowSql);
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

            // 2. Fetch fines
            String fineSql = "SELECT f.fine_id, f.borrow_detail_id, f.amount, f.reason, f.status AS fine_status, " +
                           "f.paid_at, u.full_name AS receiver_name, r.full_name AS reader_name, b.title AS book_title " +
                           "FROM fines f " +
                           "JOIN borrow_details bd ON f.borrow_detail_id = bd.borrow_detail_id " +
                           "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                           "JOIN readers r ON br.reader_id = r.reader_id " +
                           "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                           "JOIN books b ON c.book_id = b.book_id " +
                           "LEFT JOIN users u ON f.received_by = u.user_id " +
                           "ORDER BY f.created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(fineSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    map.put("receiver_name", rs.getString("receiver_name"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("book_title", rs.getString("book_title"));
                    fineList.add(map);
                }
            }

            // 3. Fetch active readers for dropdown list in borrow modal
            String readerSql = "SELECT reader_id, full_name, email FROM readers WHERE deleted_at IS NULL AND status = 'Active'";
            try (PreparedStatement stmt = conn.prepareStatement(readerSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("reader_id", rs.getInt("reader_id"));
                    map.put("full_name", rs.getString("full_name"));
                    map.put("email", rs.getString("email"));
                    readerList.add(map);
                }
            }

            // 4. Fetch available copies
            String copiesSql = "SELECT c.copy_id, c.barcode, b.title FROM book_copies c " +
                               "JOIN books b ON c.book_id = b.book_id " +
                               "WHERE c.status = 'Available' AND c.deleted_at IS NULL";
            try (PreparedStatement stmt = conn.prepareStatement(copiesSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("barcode", rs.getString("barcode"));
                    map.put("title", rs.getString("title"));
                    availableCopies.add(map);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("borrowList", borrowList);
        request.setAttribute("fineList", fineList);
        request.setAttribute("readerList", readerList);
        request.setAttribute("availableCopies", availableCopies);

        request.getRequestDispatcher("/views/borrowtereturn/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        // Giả sử user_id mặc định là 1 (Admin) nếu chưa tích hợp cơ chế đăng nhập.
        int currentUserId = 1;

        if ("borrow".equals(action)) {
            handleBorrow(request, response, currentUserId);
        } else if ("return".equals(action)) {
            handleReturn(request, response, currentUserId);
        } else if ("lost".equals(action)) {
            handleLost(request, response, currentUserId);
        } else if ("payFine".equals(action)) {
            handlePayFine(request, response, currentUserId);
        } else if ("waiveFine".equals(action)) {
            handleWaiveFine(request, response, currentUserId);
        } else {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleBorrow(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int readerId = Integer.parseInt(request.getParameter("readerId"));
        int copyId = Integer.parseInt(request.getParameter("copyId"));
        int durationDays = Integer.parseInt(request.getParameter("durationDays"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra bản sao sách có sẵn không
            String checkCopySql = "SELECT status FROM book_copies WHERE copy_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(checkCopySql)) {
                stmt.setInt(1, copyId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String status = rs.getString("status");
                        if (!"Available".equals(status)) {
                            throw new SQLException("Sách không có sẵn để mượn (Trạng thái hiện tại: " + status + ")");
                        }
                    } else {
                        throw new SQLException("Không tìm thấy bản sao sách.");
                    }
                }
            }

            // 2. Tạo borrow_record mới
            String insertRecordSql = "INSERT INTO borrow_records (reader_id, user_id) VALUES (?, ?)";
            int borrowRecordId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(insertRecordSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, readerId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        borrowRecordId = rs.getInt(1);
                    }
                }
            }

            // 3. Tạo borrow_detail mới
            LocalDate borrowDate = LocalDate.now();
            LocalDate dueDate = borrowDate.plusDays(durationDays);
            String insertDetailSql = "INSERT INTO borrow_details (borrow_record_id, copy_id, borrow_date, due_date, status) VALUES (?, ?, ?, ?, 'Borrowing')";
            int borrowDetailId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(insertDetailSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, borrowRecordId);
                stmt.setInt(2, copyId);
                stmt.setDate(3, Date.valueOf(borrowDate));
                stmt.setDate(4, Date.valueOf(dueDate));
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        borrowDetailId = rs.getInt(1);
                    }
                }
            }

            // 4. Cập nhật trạng thái book_copies thành 'Borrowed'
            String updateCopySql = "UPDATE book_copies SET status = 'Borrowed' WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setInt(1, copyId);
                stmt.executeUpdate();
            }

            // 5. Ghi Audit Log cho việc mượn sách
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("borrow_record_id", borrowRecordId);
            newLogData.put("reader_id", readerId);
            newLogData.put("copy_id", copyId);
            newLogData.put("borrow_date", borrowDate.toString());
            newLogData.put("due_date", dueDate.toString());
            newLogData.put("status", "Borrowing");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.INSERT, "borrow_details", borrowDetailId, null, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã mượn sách thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleReturn(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin lượt mượn hiện tại
            int copyId = 0;
            Date dueDate = null;
            String status = null;
            String fetchSql = "SELECT copy_id, due_date, status FROM borrow_details WHERE borrow_detail_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        copyId = rs.getInt("copy_id");
                        dueDate = rs.getDate("due_date");
                        status = rs.getString("status");
                    } else {
                        throw new SQLException("Không tìm thấy thông tin lượt mượn.");
                    }
                }
            }

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả từ trước.");
            }

            // 2. Cập nhật chi tiết mượn sang 'Returned'
            LocalDate returnDate = LocalDate.now();
            String updateDetailSql = "UPDATE borrow_details SET return_date = ?, status = 'Returned' WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateDetailSql)) {
                stmt.setDate(1, Date.valueOf(returnDate));
                stmt.setInt(2, borrowDetailId);
                stmt.executeUpdate();
            }

            // 3. Cập nhật trạng thái sách thành 'Available'
            String updateCopySql = "UPDATE book_copies SET status = 'Available' WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setInt(1, copyId);
                stmt.executeUpdate();
            }

            // 4. Tính toán phí phạt quá hạn (nếu có)
            LocalDate localDueDate = dueDate.toLocalDate();
            if (returnDate.isAfter(localDueDate)) {
                long daysOverdue = ChronoUnit.DAYS.between(localDueDate, returnDate);
                double fineAmount = daysOverdue * 5000.0; // Phạt 5.000đ mỗi ngày quá hạn

                String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, ?, 'Overdue', 'Unpaid')";
                try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
                    stmt.setInt(1, borrowDetailId);
                    stmt.setDouble(2, fineAmount);
                    stmt.executeUpdate();
                }
            }

            // Ghi Audit Log
            Map<String, Object> oldLogData = new HashMap<>();
            oldLogData.put("status", status);
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("status", "Returned");
            newLogData.put("return_date", returnDate.toString());

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "borrow_details", borrowDetailId, oldLogData, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã trả sách thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleLost(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int copyId = 0;
            String status = null;
            String fetchSql = "SELECT copy_id, status FROM borrow_details WHERE borrow_detail_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        copyId = rs.getInt("copy_id");
                        status = rs.getString("status");
                    } else {
                        throw new SQLException("Không tìm thấy thông tin lượt mượn.");
                    }
                }
            }

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả.");
            }

            // 1. Cập nhật chi tiết mượn sang 'Lost'
            String updateDetailSql = "UPDATE borrow_details SET status = 'Lost' WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateDetailSql)) {
                stmt.setInt(1, borrowDetailId);
                stmt.executeUpdate();
            }

            // 2. Cập nhật trạng thái sách thành 'Lost'
            String updateCopySql = "UPDATE book_copies SET status = 'Lost' WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setInt(1, copyId);
                stmt.executeUpdate();
            }

            // 3. Tạo khoản phạt mất sách (mặc định 100.000đ)
            String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, 100000.00, 'Lost Book', 'Unpaid')";
            try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
                stmt.setInt(1, borrowDetailId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            Map<String, Object> oldLogData = new HashMap<>();
            oldLogData.put("status", status);
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("status", "Lost");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "borrow_details", borrowDetailId, oldLogData, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã báo mất sách thành công! Đã tạo khoản phí phạt mất sách.");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handlePayFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String updateFineSql = "UPDATE fines SET status = 'Paid', paid_at = CURRENT_TIMESTAMP, received_by = ? WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, fineId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", "Unpaid");
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Paid");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Thanh toán phí phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleWaiveFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String updateFineSql = "UPDATE fines SET status = 'Waived', paid_at = CURRENT_TIMESTAMP, received_by = ? WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, fineId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", "Unpaid");
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Waived");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã miễn giảm phí phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }
}

