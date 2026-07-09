package borrowtereturn;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import common.DBConnection;
import common.AuditLogger;

public class BorrowReturnService {
    private final BorrowReturnDAO dao = new BorrowReturnDAO();

    public void borrowBook(int readerId, int copyId, int durationDays, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra bản sao sách có sẵn không
            String status = dao.checkCopyStatusForUpdate(conn, copyId);
            if (status == null) {
                throw new SQLException("Không tìm thấy bản sao sách.");
            }
            if (!"Available".equals(status)) {
                throw new SQLException("Sách không có sẵn để mượn (Trạng thái hiện tại: " + status + ")");
            }

            // 2. Tạo borrow_record mới
            int borrowRecordId = dao.insertBorrowRecord(conn, readerId, userId);

            // 3. Tạo borrow_detail mới
            LocalDate borrowDate = LocalDate.now();
            LocalDate dueDate = borrowDate.plusDays(durationDays);
            int borrowDetailId = dao.insertBorrowDetail(conn, borrowRecordId, copyId, Date.valueOf(borrowDate), Date.valueOf(dueDate));

            // 4. Cập nhật trạng thái book_copies thành 'Borrowed'
            dao.updateCopyStatus(conn, copyId, "Borrowed");

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
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void returnBook(int borrowDetailId, String bookCondition, String notes, int userId) throws SQLException {
        if (bookCondition == null || bookCondition.trim().isEmpty()) {
            bookCondition = "Bình thường";
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin lượt mượn hiện tại
            Map<String, Object> detail = dao.getBorrowDetailForUpdate(conn, borrowDetailId);
            if (detail == null) {
                throw new SQLException("Không tìm thấy thông tin lượt mượn.");
            }

            int copyId = (Integer) detail.get("copy_id");
            Date dueDate = (Date) detail.get("due_date");
            String status = (String) detail.get("status");

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả từ trước.");
            }

            // Lấy giá sách từ bảng books
            double bookPrice = dao.getBookPrice(conn, borrowDetailId);

            LocalDate returnDate = LocalDate.now();
            String newStatus = "Returned";
            if ("Mất sách".equals(bookCondition)) {
                newStatus = "Lost";
            }

            // 2. Cập nhật chi tiết mượn sang 'Returned' hoặc 'Lost'
            dao.updateBorrowDetailReturn(conn, borrowDetailId, "Lost".equals(newStatus) ? null : Date.valueOf(returnDate), newStatus, bookCondition, notes);

            // 3. Cập nhật trạng thái sách thành 'Available', 'Damaged', hoặc 'Lost'
            String copyStatus = "Available";
            if ("Mất sách".equals(bookCondition) || "Lost".equals(newStatus)) {
                copyStatus = "Lost";
            } else if ("Rách nặng".equals(bookCondition)) {
                copyStatus = "Damaged";
            }
            dao.updateCopyStatus(conn, copyId, copyStatus);

            // 4. Tính toán phí phạt theo quy tắc
            double fineAmount = 0;
            List<String> reasonsList = new ArrayList<>();

            if ("Mất sách".equals(bookCondition) || "Lost".equals(newStatus)) {
                fineAmount = bookPrice + 20000.0;
                reasonsList.add("Lost Book");
            } else {
                // Kiểm tra trễ hạn
                LocalDate localDueDate = dueDate.toLocalDate();
                long daysOverdue = ChronoUnit.DAYS.between(localDueDate, returnDate);
                double overdueFine = 0;
                if (daysOverdue > 0) {
                    overdueFine = daysOverdue * 5000.0;
                    if (overdueFine > bookPrice) {
                        overdueFine = bookPrice;
                    }
                    reasonsList.add("Overdue");
                }

                // Kiểm tra hư hỏng
                double damageFine = 0;
                if ("Rách nhẹ".equals(bookCondition)) {
                    damageFine = bookPrice * 0.20;
                    if (damageFine < 15000.0) {
                        damageFine = 15000.0;
                    }
                    reasonsList.add("Damaged Book");
                } else if ("Rách nặng".equals(bookCondition)) {
                    damageFine = bookPrice * 0.80;
                    reasonsList.add("Damaged Book");
                }

                fineAmount = overdueFine + damageFine;
                double maxFine = bookPrice + 20000.0;
                if (fineAmount > maxFine) {
                    fineAmount = maxFine;
                }
            }

            if (fineAmount > 0) {
                String combinedReason = String.join(", ", reasonsList);
                
                // Kiểm tra xem đã có bản ghi phạt nào chưa
                int existingFineId = dao.checkFineExists(conn, borrowDetailId);
                if (existingFineId > 0) {
                    dao.updateFineAmountAndReason(conn, existingFineId, fineAmount, combinedReason);
                } else {
                    dao.insertFine(conn, borrowDetailId, fineAmount, combinedReason, "Unpaid");
                }
            }

            // Ghi Audit Log
            Map<String, Object> oldLogData = new HashMap<>();
            oldLogData.put("status", status);
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("status", newStatus);
            newLogData.put("return_date", returnDate.toString());
            newLogData.put("book_condition", bookCondition);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "borrow_details", borrowDetailId, oldLogData, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void reportLostBook(int borrowDetailId, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin lượt mượn
            Map<String, Object> detail = dao.getBorrowDetailForUpdate(conn, borrowDetailId);
            if (detail == null) {
                throw new SQLException("Không tìm thấy thông tin lượt mượn.");
            }

            int copyId = (Integer) detail.get("copy_id");
            String status = (String) detail.get("status");

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả.");
            }

            // Lấy giá sách từ bảng books
            double bookPrice = dao.getBookPrice(conn, borrowDetailId);

            // 2. Cập nhật chi tiết mượn sang 'Lost'
            dao.updateBorrowDetailReturn(conn, borrowDetailId, null, "Lost", "Mất sách", "Độc giả báo mất");

            // 3. Cập nhật trạng thái sách thành 'Lost'
            dao.updateCopyStatus(conn, copyId, "Lost");

            // 4. Tạo khoản phạt mất sách
            double fineAmount = bookPrice + 20000.0;
            int existingFineId = dao.checkFineExists(conn, borrowDetailId);
            if (existingFineId > 0) {
                dao.updateFineAmountAndReason(conn, existingFineId, fineAmount, "Lost Book");
            } else {
                dao.insertFine(conn, borrowDetailId, fineAmount, "Lost Book", "Unpaid");
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
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void payFine(int fineId, int discountRate, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin số tiền phạt và trạng thái hiện tại
            Map<String, Object> fine = dao.getFineForUpdate(conn, fineId);
            if (fine == null) {
                throw new SQLException("Không tìm thấy thông tin khoản phạt.");
            }

            double amount = (Double) fine.get("amount");
            String status = (String) fine.get("status");

            if ("Paid".equals(status) || "Waived".equals(status)) {
                throw new SQLException("Khoản phạt này đã được thanh toán hoặc miễn giảm từ trước.");
            }

            double finalAmount = amount * (1.0 - discountRate / 100.0);
            String newStatus = (discountRate == 100) ? "Waived" : "Paid";

            // 2. Cập nhật fines
            String discountNote = "\n[Thu tiền] Áp dụng miễn giảm " + discountRate + "%. Số tiền gốc: " + amount + "đ.";
            dao.payFine(conn, fineId, finalAmount, amount, newStatus, userId, discountNote);

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", status);
            oldLog.put("amount", amount);
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", newStatus);
            newLog.put("amount", finalAmount);
            newLog.put("discount_rate", discountRate);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void waiveFine(int fineId, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            dao.waiveFine(conn, fineId, userId);

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", "Unpaid");
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Waived");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void undoFine(int fineId, String undoReason, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin
            Map<String, Object> fineDetails = dao.getFineDetailsForUndo(conn, fineId);
            if (fineDetails == null) {
                throw new SQLException("Không tìm thấy thông tin khoản phạt.");
            }

            double currentAmount = (Double) fineDetails.get("amount");
            Double originalAmount = (Double) fineDetails.get("original_amount");
            String status = (String) fineDetails.get("status");

            if (!"Paid".equals(status) && !"Waived".equals(status)) {
                throw new SQLException("Chỉ có thể hoàn tác khoản phạt đã đóng hoặc đã miễn giảm.");
            }

            double restoredAmount = (originalAmount != null) ? originalAmount : currentAmount;

            // 2. Khôi phục trạng thái phạt về Unpaid
            String undoNote = "\n[Hoàn tác] Lý do: " + undoReason + " (Người thực hiện: User #" + userId + ")";
            dao.undoFine(conn, fineId, restoredAmount, undoNote);

            // Ghi Audit Log với hành động RESTORE
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", status);
            oldLog.put("amount", currentAmount);
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Unpaid");
            newLog.put("amount", restoredAmount);
            newLog.put("undo_reason", undoReason);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.RESTORE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void deleteBorrow(int id, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Delete associated fines first
            dao.deleteFinesByBorrowDetailId(conn, id);

            // 2. We should also update book copy status back to 'Available' if it was 'Borrowed' or 'Lost'
            int copyId = dao.getCopyIdFromBorrowDetail(conn, id);
            if (copyId > 0) {
                dao.updateCopyStatus(conn, copyId, "Available");
            }

            // 3. Delete borrow detail
            dao.deleteBorrowDetail(conn, id);

            // Ghi Audit Log
            AuditLogger.log(conn, userId, AuditLogger.ActionType.DELETE, "borrow_details", id, null, null);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void deleteFine(int id, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            dao.deleteFine(conn, id);

            // Ghi Audit Log
            AuditLogger.log(conn, userId, AuditLogger.ActionType.DELETE, "fines", id, null, null);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void updateBorrowDetail(int id, String borrowDateStr, String dueDateStr, String returnDateStr, String status, String bookCondition, String notes, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy giá sách từ bảng books
            double bookPrice = dao.getBookPrice(conn, id);

            Date borrowDate = Date.valueOf(borrowDateStr);
            Date dueDate = Date.valueOf(dueDateStr);
            Date returnDate = (returnDateStr != null && !returnDateStr.trim().isEmpty()) ? Date.valueOf(returnDateStr) : null;

            // 2. Cập nhật chi tiết mượn
            dao.updateBorrowDetailAll(conn, id, borrowDate, dueDate, returnDate, status, bookCondition, notes);

            // 3. Cập nhật trạng thái sách trong bản sao
            int copyId = dao.getCopyIdFromBorrowDetail(conn, id);
            if (copyId > 0) {
                String copyStatus = "Available";
                if ("Lost".equals(status) || "Mất sách".equals(bookCondition)) {
                    copyStatus = "Lost";
                } else if ("Borrowing".equals(status) || "Overdue".equals(status)) {
                    copyStatus = "Borrowed";
                } else if ("Rách nặng".equals(bookCondition)) {
                    copyStatus = "Damaged";
                }
                dao.updateCopyStatus(conn, copyId, copyStatus);
            }

            // 4. Tính toán phí phạt theo quy tắc mới
            double fineAmount = 0;
            List<String> reasonsList = new ArrayList<>();

            if ("Lost".equals(status) || "Mất sách".equals(bookCondition)) {
                fineAmount = bookPrice + 20000.0;
                reasonsList.add("Lost Book");
            } else {
                // Kiểm tra quá hạn
                if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
                    try {
                        LocalDate due = LocalDate.parse(dueDateStr);
                        LocalDate ret = LocalDate.parse(returnDateStr);
                        long daysOverdue = ChronoUnit.DAYS.between(due, ret);
                        if (daysOverdue > 0) {
                            double overdueFine = daysOverdue * 5000.0;
                            if (overdueFine > bookPrice) {
                                overdueFine = bookPrice;
                            }
                            reasonsList.add("Overdue");
                            fineAmount += overdueFine;
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                // Kiểm tra hư hỏng
                double damageFine = 0;
                if ("Rách nhẹ".equals(bookCondition)) {
                    damageFine = bookPrice * 0.20;
                    if (damageFine < 15000.0) {
                        damageFine = 15000.0;
                    }
                    reasonsList.add("Damaged Book");
                    fineAmount += damageFine;
                } else if ("Rách nặng".equals(bookCondition)) {
                    damageFine = bookPrice * 0.80;
                    reasonsList.add("Damaged Book");
                    fineAmount += damageFine;
                }

                double maxFine = bookPrice + 20000.0;
                if (fineAmount > maxFine) {
                    fineAmount = maxFine;
                }
            }

            if (fineAmount > 0) {
                String combinedReason = String.join(", ", reasonsList);

                int existingFineId = dao.checkFineExists(conn, id);
                if (existingFineId > 0) {
                    dao.updateFineAmountAndReason(conn, existingFineId, fineAmount, combinedReason);
                } else {
                    dao.insertFine(conn, id, fineAmount, combinedReason, "Unpaid");
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public void updateFineDetails(int id, double amount, String[] reasons, String status, String paidAtStr, int userId) throws SQLException {
        String reason = (reasons != null) ? String.join(", ", reasons) : "";
        Timestamp paidAt = null;
        Integer receivedBy = null;

        if ("Paid".equals(status)) {
            paidAt = new Timestamp(System.currentTimeMillis());
            receivedBy = userId;
        } else if (paidAtStr != null && !paidAtStr.trim().isEmpty()) {
            try {
                paidAt = Timestamp.valueOf(paidAtStr.replace("T", " ") + ":00");
            } catch (Exception e) {
                paidAt = new Timestamp(System.currentTimeMillis());
            }
            receivedBy = userId;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            dao.updateFineAll(conn, id, amount, reason, status, paidAt, receivedBy);
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
}
