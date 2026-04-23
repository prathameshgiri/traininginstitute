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

import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * ReportServlet - Advanced Analytics and Reporting Engine.
 * Generates 5 report types by executing SQL views and aggregation queries.
 * @author Dr. Geeta Mete
 */
@WebServlet("/admin/report/*")
public class ReportServlet extends HttpServlet {

    private final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime src, Type typeOfSrc, JsonSerializationContext context) {
                    return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                }
            })
            .create();

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
        req.setAttribute("reportTitle", "Students Selected Per Company");
        req.setAttribute("reportData",  executeQueryAsJson(sql));
        req.setAttribute("data",        executeQuery(sql));
        req.setAttribute("reportType",  "1");
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 2: Internship-wise application count */
    private void report2(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT * FROM v_internship_application_counts ORDER BY total_applications DESC";
        req.setAttribute("reportTitle", "Internship-wise Application Statistics");
        req.setAttribute("reportData",  executeQueryAsJson(sql));
        req.setAttribute("data",        executeQuery(sql));
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
        req.setAttribute("reportTitle", "Exam Rank List");
        req.setAttribute("reportData",  executeQueryAsJson(sql));
        req.setAttribute("data",        executeQuery(sql));
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
        req.setAttribute("reportTitle", "Question-wise Performance Analysis");
        req.setAttribute("reportData",  executeQueryAsJson(sql));
        req.setAttribute("data",        executeQuery(sql));
        req.setAttribute("reportType",  "4");
        try { req.setAttribute("exams", examDAO.getAllExams()); } catch (Exception ignored) {}
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Report 5: Suspicious activity logs */
    private void report5(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT * FROM v_suspicious_activities ORDER BY log_time DESC LIMIT 500";
        req.setAttribute("reportTitle", "Suspicious Activity Logs");
        req.setAttribute("reportData",  executeQueryAsJson(sql));
        req.setAttribute("data",        executeQuery(sql));
        req.setAttribute("reportType",  "5");
        req.getRequestDispatcher("/WEB-INF/views/admin/report_view.jsp").forward(req, resp);
    }

    /** Dashboard statistics (JSON for AJAX charts) */
    private void dashboardStats(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String appsByStatusSql = "SELECT status, COUNT(*) AS count FROM applications GROUP BY status";
        String examPassRateSql = "SELECT e.exam_name, " +
            "SUM(CASE WHEN ea.is_passed = TRUE THEN 1 ELSE 0 END) AS passed, " +
            "COUNT(ea.attempt_id) AS total " +
            "FROM exams e LEFT JOIN exam_attempts ea ON e.exam_id = ea.exam_id " +
            "WHERE ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
            "GROUP BY e.exam_id";
        String monthlyRegSql = "SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, COUNT(*) AS count " +
            "FROM users WHERE role = 'STUDENT' GROUP BY month ORDER BY month DESC LIMIT 12";

        // Build JSON manually - no Gson
        out.print("{\"applicationsByStatus\":" + executeQueryAsJson(appsByStatusSql)
            + ",\"examPassRate\":" + executeQueryAsJson(examPassRateSql)
            + ",\"monthlyRegistrations\":" + executeQueryAsJson(monthlyRegSql) + "}");
    }

    /** Generic SQL → JSON string (no Gson, all values converted to strings) */
    private String executeQueryAsJson(String sql) {
        StringBuilder json = new StringBuilder("[");
        Connection conn = null; Statement st = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            st = conn.createStatement();
            rs = st.executeQuery(sql);
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            boolean firstRow = true;
            while (rs.next()) {
                if (!firstRow) json.append(",");
                firstRow = false;
                json.append("{");
                for (int i = 1; i <= cols; i++) {
                    if (i > 1) json.append(",");
                    String colName = meta.getColumnLabel(i);
                    String val = rs.getString(i); // getString avoids all LocalDateTime issues
                    json.append("\"").append(colName.replace("\"","\\\"")).append("\":");
                    if (val == null) {
                        json.append("null");
                    } else {
                        // Try to keep numbers as numbers for chart.js
                        int colType = meta.getColumnType(i);
                        if ((colType == java.sql.Types.INTEGER || colType == java.sql.Types.BIGINT
                                || colType == java.sql.Types.SMALLINT || colType == java.sql.Types.TINYINT
                                || colType == java.sql.Types.FLOAT || colType == java.sql.Types.DOUBLE
                                || colType == java.sql.Types.DECIMAL || colType == java.sql.Types.NUMERIC
                                || colType == java.sql.Types.BIT || colType == java.sql.Types.BOOLEAN)
                                && !val.isEmpty()) {
                            json.append(val);
                        } else {
                            json.append("\"").append(val.replace("\\","\\\\").replace("\"","\\\"")
                                    .replace("\n","\\n").replace("\r","\\r")).append("\"");
                        }
                    }
                }
                json.append("}");
            }
        } catch (SQLException e) {
            // return empty array
        } finally {
            DBConnection.close(rs, st, conn);
        }
        return json.append("]").toString();
    }

    /** Generic SQL → List<Map> for JSP table rendering */
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
                for (int i = 1; i <= cols; i++) {
                    // Always use getString to avoid LocalDateTime reflection crash
                    row.put(meta.getColumnLabel(i), rs.getString(i));
                }
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
