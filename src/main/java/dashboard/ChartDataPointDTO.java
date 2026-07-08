package dashboard;

/**
 * DTO đại diện cho một điểm dữ liệu trên biểu đồ (Cặp khóa - giá trị).
 * Thích hợp cho cả biểu đồ Line, Bar, Pie và Doughnut.
 */
public class ChartDataPointDTO {
    private String label; // Nhãn hiển thị (ngày, tuần, tháng, tên sách, tên tác giả, tên thể loại)
    private double value; // Giá trị thống kê (số lượt mượn, phần trăm, số lượng)

    public ChartDataPointDTO() {}

    public ChartDataPointDTO(String label, double value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }
}
