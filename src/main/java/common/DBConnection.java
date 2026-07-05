package common;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBConnection {
    private static Connection connection = null;

    public static Connection getConnection() {
        if (connection == null) {
            try {
                // Đọc file database.properties từ thư mục resources
                InputStream input = Thread.currentThread().getContextClassLoader().getResourceAsStream("database.properties");
                Properties prop = new Properties();

                if (input == null) {
                    System.out.println("Xin lỗi, không tìm thấy file database.properties");
                    return null;
                }
                prop.load(input);

                // Lấy thông tin cấu hình
                String dbUrl = prop.getProperty("db.url");
                String dbUser = prop.getProperty("db.user");
                String dbPassword = prop.getProperty("db.password");

                // Nạp Driver và Kết nối
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return connection;
    }
}