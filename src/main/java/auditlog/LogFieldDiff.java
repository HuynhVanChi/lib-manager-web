package auditlog;

/**
 * Lớp DTO lưu trữ sự khác biệt giữa các trường thông tin cũ và mới.
 * Dùng để hiển thị đối chiếu dữ liệu audit log ở phía Server-side.
 */
public class LogFieldDiff {
    private String fieldKey;      // Ví dụ: "reader_id"
    private String friendlyName;  // Ví dụ: "Mã độc giả"
    private String oldValue;      // Ví dụ: "Nguyễn Văn A" hoặc "—"
    private String newValue;      // Ví dụ: "Nguyễn Văn B" hoặc "—"
    private boolean changed;      // Trạng thái thay đổi (true/false)

    public LogFieldDiff() {
    }

    public LogFieldDiff(String fieldKey, String friendlyName, String oldValue, String newValue, boolean changed) {
        this.fieldKey = fieldKey;
        this.friendlyName = friendlyName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.changed = changed;
    }

    public String getFieldKey() {
        return fieldKey;
    }

    public void setFieldKey(String fieldKey) {
        this.fieldKey = fieldKey;
    }

    public String getFriendlyName() {
        return friendlyName;
    }

    public void setFriendlyName(String friendlyName) {
        this.friendlyName = friendlyName;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public boolean isChanged() {
        return changed;
    }

    public void setChanged(boolean changed) {
        this.changed = changed;
    }
}
