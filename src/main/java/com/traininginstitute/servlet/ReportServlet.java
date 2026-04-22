package com.traininginstitute.servlet;

import com.traininginstitute.dao.*;

import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import com.traininginstitute.util.DBConnection;

/**
 * ReportServlet - Advanced Analytics and Reporting Engine.
 * Generates 5 report types by executing SQL views and aggregation queries.
 * @author Dr. Geeta Mete
 */
@WebServlet("/admin/report/*")
public class ReportServlet extends HttpServlet {

    private final Gson gson = new Gson();

    private ExamDAO    examDAO;

    @Override
    public void init() {

        examDAO    = new ExamDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "/list";

        switch (info) {
            case "/selected-per-company":      report1(req, resp); break;
            case "/application-counts":        report2(req, resp); break;
            case "/exam-rank-list":            report3(req, resp); break;
            case "/question-performance":      report4(req, resp); break;
            case "/suspicious-activities":     report5(req, resp); break;
            case "/dashboard-stats":           dashboardStats(req, resp); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/reports");
        }
    }

    /** Report 1: Students selected per company */
    private void report1(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT * FROM v_selected_students_per_company ORDER BY company_name";
        List<Map<String, Object>> data = executeQuery(sql);
        req.setAttribute("reportTitle", "Students Selected Per Company");
        req.setAttribute("reportData",  gson.toJson(data));
        req.setAttribute("data",        data);
        req.setAttribute("reportType",  "1");
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 2: Internship-wise application count */
    private void report2(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT * FROM v_internship_application_counts ORDER BY total_applications DESC";
        List<Map<String, Object>> data = executeQuery(sql);
        req.setAttribute("reportTitle", "Internship-wise Application Statistics");
        req.setAttribute("reportData",  gson.toJson(data));
        req.setAttribute("data",        data);
        req.setAttribute("reportType",  "2");
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 3: Exam Rank List */
    private void report3(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String examIdParam = req.getParameter("exam_id");
        String sql = "SELECT * FROM v_exam_rank_list";
        if (examIdParam != null && !examIdParam.isEmpty()) {
            sql += " WHERE exam_id = " + Integer.parseInt(examIdParam);
        }
        sql += " ORDER BY exam_id, rank_position";
        List<Map<String, Object>> data = executeQuery(sql);
        req.setAttribute("reportTitle", "Exam Rank List");
        req.setAttribute("reportData",  gson.toJson(data));
        req.setAttribute("data",        data);
        req.setAttribute("reportType",  "3");
        try { req.setAttribute("exams", examDAO.getAllExams()); } catch (Exception ignored) {}
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 4: Question-wise performance analysis */
    private void report4(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String examIdParam = req.getParameter("exam_id");
        String sql = "SELECT * FROM v_question_performance";
        if (examIdParam != null && !examIdParam.isEmpty()) {
            sql += " WHERE exam_id = " + Integer.parseInt(examIdParam);
        }
        sql += " ORDER BY success_rate ASC";
        List<Map<String, Object>> data = executeQuery(sql);
        req.setAttribute("reportTitle", "Question-wise Performance Analysis");
        req.setAttribute("reportData",  gson.toJson(data));
        req.setAttribute("data",        data);
        req.setAttribute("reportType",  "4");
        try { req.setAttribute("exams", examDAO.getAllExams()); } catch (Exception ignored) {}
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 5: Suspicious activity logs */
    private void report5(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT * FROM v_suspicious_activities ORDER BY log_time DESC LIMIT 500";
        List<Map<String, Object>> data = executeQuery(sql);
        req.setAttribute("reportTitle", "Suspicious Activity Logs");
        req.setAttribute("reportData",  gson.toJson(data));
        req.setAttribute("data",        data);
        req.setAttribute("reportType",  "5");
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Dashboard statistics (JSON for AJAX charts) */
    private void dashboardStats(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();
        Map<String, Object> stats = new LinkedHashMap<>();

        String appsByStatusSql = "SELECT status, COUNT(*) AS count FROM applications GROUP BY status";
        String examPassRateSql = "SELECT e.exam_name, " +
            "SUM(CASE WHEN ea.is_passed = TRUE THEN 1 ELSE 0 END) AS passed, " +
            "COUNT(ea.attempt_id) AS total " +
            "FROM exams e LEFT JOIN exam_attempts ea ON e.exam_id = ea.exam_id " +
            "WHERE ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
            "GROUP BY e.exam_id";
        String monthlyRegSql = "SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, COUNT(*) AS count " +
            "FROM users WHERE role = 'STUDENT' GROUP BY month ORDER BY month DESC LIMIT 12";

        stats.put("applicationsByStatus", executeQuery(appsByStatusSql));
        stats.put("examPassRate", executeQuery(examPassRateSql));
        stats.put("monthlyRegistrations", executeQuery(monthlyRegSql));

        out.print(gson.toJson(stats));
    }

    /** Generic SQL → List<Map> executor */
    private List<Map<String, Object>> executeQuery(String sql) {
        List<Map<String, Object>> result = new ArrayList<>();
        Connection conn = null; Statement st = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) row.put(meta.getColumnLabel(i), rs.getObject(i));
                result.add(row);
            }
        } catch (SQLException e) {
            // return empty
        } finally {
            DBConnection.close(rs, st, conn);
        }
        return result;
    }
}
