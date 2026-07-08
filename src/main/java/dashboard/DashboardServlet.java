package dashboard;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controller chính cho Dashboard.
 * Xử lý hai luồng chính:
 * 1. GET /dashboard: Trả về trang JSP tĩnh (giao diện nền).
 * 2. GET /dashboard?action=api: Trả về dữ liệu JSON của toàn bộ Dashboard thông qua AJAX.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("api".equalsIgnoreCase(action)) {
            handleAPIRequest(response);
        } else {
            // Forward tới view JSP của Dashboard
            request.getRequestDispatcher("/views/dashboard/index.jsp").forward(request, response);
        }
    }

    /**
     * Truy vấn toàn bộ dữ liệu từ DAO, đóng gói thành JSON và trả về cho Client.
     */
    private void handleAPIRequest(HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            try {
                // 1. Lấy metrics KPI
                DashboardMetricsDTO metrics = dashboardDAO.getDashboardMetrics();
                
                // 2. Lấy dữ liệu biểu đồ
                List<ChartDataPointDTO> borrowByDay = dashboardDAO.getBorrowCountByDay();
                List<ChartDataPointDTO> borrowByWeek = dashboardDAO.getBorrowCountByWeek();
                List<ChartDataPointDTO> borrowByMonth = dashboardDAO.getBorrowCountByMonth();
                
                // 3. Lấy dữ liệu Top 10
                List<ChartDataPointDTO> top10Books = dashboardDAO.getTop10Books();
                List<ChartDataPointDTO> topAuthors = dashboardDAO.getTopAuthors();
                List<ChartDataPointDTO> topCategories = dashboardDAO.getTopCategories();
                
                // Đóng gói tất cả vào một DTO duy nhất
                DashboardDataDTO dashboardData = new DashboardDataDTO(
                        metrics, borrowByDay, borrowByWeek, borrowByMonth, 
                        top10Books, topAuthors, topCategories
                );
                
                // Trả về JSON thành công
                out.print(gson.toJson(dashboardData));
                
            } catch (SQLException e) {
                // Ghi nhận lỗi và trả về lỗi JSON cho phía Client hiển thị
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Lỗi truy vấn cơ sở dữ liệu: " + e.getMessage() + "\"}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
            }
            out.flush();
        }
    }
}
