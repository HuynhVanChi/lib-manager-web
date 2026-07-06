package common;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Lớp quản lý kết nối Cơ sở dữ liệu cho dự án LibraryOS.
 * Đã chuẩn hóa JDBC: Mỗi lần gọi getConnection() sẽ trả về một đối tượng Connection mới,
 * đảm bảo an toàn đa luồng và độc lập giao dịch (Transaction).
 */
public class DBConnection {
    private static String dbUrl = null;
    private static String dbUser = null;
    private static String dbPassword = null;

    // Nạp cấu hình từ file database.properties một lần duy nhất khi nạp Class
    static {
        try (InputStream input = Thread.currentThread().getContextClassLoader().getResourceAsStream("database.properties")) {
            Properties prop = new Properties();

            if (input == null) {
                System.err.println("Xin lỗi, không tìm thấy file database.properties trong resources.");
            } else {
                prop.load(input);
                dbUrl = prop.getProperty("db.url");
                dbUser = prop.getProperty("db.user");
                dbPassword = prop.getProperty("db.password");

                // Đăng ký Driver MySQL
                Class.forName("com.mysql.cj.jdbc.Driver");
            }
        } catch (Exception e) {
            System.err.println("Lỗi nghiêm trọng khi khởi tạo cấu hình kết nối DBConnection:");
            e.printStackTrace();
        }
    }

    /**
     * Trả về một đối tượng Connection mới hoàn toàn đến Database.
     * CHÚ Ý: Người gọi phương thức này phải tự chịu trách nhiệm đóng kết nối sau khi sử dụng xong
     * (Khuyên dùng cú pháp try-with-resources của Java).
     *
     * @return Connection kết nối mới đến Database
     * @throws SQLException khi không thể kết nối đến cơ sở dữ liệu
     */
    public static Connection getConnection() throws SQLException {
        if (dbUrl == null || dbUser == null) {
            throw new SQLException("Cấu hình DBConnection chưa được khởi tạo thành công (file database.properties bị thiếu hoặc lỗi).");
        }
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }
}