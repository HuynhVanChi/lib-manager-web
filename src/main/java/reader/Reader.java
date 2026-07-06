package reader;

import java.sql.Timestamp;

public class Reader {

    // =============================================
    // FIELDS — Ánh xạ đầy đủ các cột bảng readers
    // =============================================

    private int readerId;
    private String fullName;
    private String phone;
    private String email;
    private Timestamp membershipExpiredAt;
    private String status; // 'Active', 'Suspended', 'Expired'
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Soft Delete fields
    private Timestamp deletedAt;   // null = đang hoạt động, non-null = đã xóa mềm
    private Integer deletedBy;     // user_id của thủ thư đã thực hiện xóa mềm


    // =============================================
    // CONSTRUCTORS
    // =============================================

    /* Constructor rỗng */
    public Reader() {
    }

    /**
     * Constructor đầy đủ tham số dùng khi tạo mới hoặc chỉnh sửa độc giả từ form.
     * Không bao gồm các trường hệ thống tự sinh (createdAt, updatedAt, deletedAt, deletedBy).
     *
     * @param readerId            ID độc giả (0 khi tạo mới, >0 khi chỉnh sửa)
     * @param fullName            Họ và tên đầy đủ
     * @param phone               Số điện thoại (có thể null)
     * @param email               Email (định danh duy nhất, bắt buộc)
     * @param membershipExpiredAt Ngày hết hạn thẻ thành viên (có thể null)
     * @param status              Trạng thái: 'Active', 'Suspended', 'Expired'
     */
    public Reader(int readerId, String fullName, String phone, String email,
                  Timestamp membershipExpiredAt, String status) {
        this.readerId = readerId;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.membershipExpiredAt = membershipExpiredAt;
        this.status = status;
    }


    // =============================================
    // GETTERS & SETTERS
    // =============================================

    public int getReaderId() {
        return readerId;
    }

    public void setReaderId(int readerId) {
        this.readerId = readerId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Timestamp getMembershipExpiredAt() {
        return membershipExpiredAt;
    }

    public void setMembershipExpiredAt(Timestamp membershipExpiredAt) {
        this.membershipExpiredAt = membershipExpiredAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Timestamp getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Timestamp deletedAt) {
        this.deletedAt = deletedAt;
    }

    public Integer getDeletedBy() {
        return deletedBy;
    }

    public void setDeletedBy(Integer deletedBy) {
        this.deletedBy = deletedBy;
    }


    // =============================================
    // HELPER METHODS — Tiện ích dùng trong JSP/Service
    // =============================================

    /**
     * Kiểm tra độc giả có đang bị xóa mềm không.
     * @return true nếu đã xóa mềm (deletedAt != null)
     */
    public boolean isDeleted() {
        return deletedAt != null;
    }

    /**
     * Kiểm tra thẻ thành viên còn hạn không.
     * @return true nếu membershipExpiredAt chưa được set hoặc vẫn còn trong tương lai
     */
    public boolean isMembershipValid() {
        if (membershipExpiredAt == null) return false;
        return membershipExpiredAt.after(new Timestamp(System.currentTimeMillis()));
    }

    @Override
    public String toString() {
        return "Reader{" +
                "readerId=" + readerId +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", status='" + status + '\'' +
                ", deletedAt=" + deletedAt +
                '}';
    }
}
