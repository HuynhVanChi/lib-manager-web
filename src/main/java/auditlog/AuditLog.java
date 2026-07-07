package auditlog;

import java.sql.Timestamp;

/**
 * Model đại diện cho một bản ghi nhật ký hệ thống (Audit Log).
 * Bao gồm các thông tin gốc từ bảng 'audit_logs' và trường 'userFullName' 
 * lấy từ bảng 'users' thông qua câu lệnh SQL JOIN.
 */
public class AuditLog {

    // =============================================
    // FIELDS — Ánh xạ bảng audit_logs & thông tin JOIN
    // =============================================

    private int logId;
    private Integer userId;
    private String userFullName; // Tên đầy đủ của thủ thư thực hiện hành động
    private String action;       // 'INSERT', 'UPDATE', 'DELETE', 'RESTORE'
    private String tableName;    // Tên bảng dữ liệu bị tác động
    private int recordId;        // ID của dòng dữ liệu bị tác động
    private String oldValues;    // Dữ liệu cũ (định dạng JSON string)
    private String newValues;    // Dữ liệu mới (định dạng JSON string)
    private Timestamp createdAt;


    // =============================================
    // CONSTRUCTORS
    // =============================================

    /**
     * Constructor mặc định không tham số — bắt buộc có để DAO nạp dữ liệu.
     */
    public AuditLog() {
    }

    /**
     * Constructor đầy đủ tham số dùng để khởi tạo nhanh đối tượng.
     */
    public AuditLog(int logId, Integer userId, String userFullName, String action, 
                    String tableName, int recordId, String oldValues, String newValues, 
                    Timestamp createdAt) {
        this.logId = logId;
        this.userId = userId;
        this.userFullName = userFullName;
        this.action = action;
        this.tableName = tableName;
        this.recordId = recordId;
        this.oldValues = oldValues;
        this.newValues = newValues;
        this.createdAt = createdAt;
    }


    // =============================================
    // GETTERS & SETTERS
    // =============================================

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public int getRecordId() {
        return recordId;
    }

    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }

    public String getOldValues() {
        return oldValues;
    }

    public void setOldValues(String oldValues) {
        this.oldValues = oldValues;
    }

    public String getNewValues() {
        return newValues;
    }

    public void setNewValues(String newValues) {
        this.newValues = newValues;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "AuditLog{" +
                "logId=" + logId +
                ", userFullName='" + userFullName + '\'' +
                ", action='" + action + '\'' +
                ", tableName='" + tableName + '\'' +
                ", recordId=" + recordId +
                ", createdAt=" + createdAt +
                '}';
    }
}
