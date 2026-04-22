package com.traininginstitute.dao;

import com.traininginstitute.model.Application;
import com.traininginstitute.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * ApplicationDAO - Internship Application Management with Transaction Support
 * Implements Case 1 transaction: Insert application + Insert application_log
 * @author Dr. Geeta Mete
 */
public class ApplicationDAO {

    private static final Logger LOGGER = Logger.getLogger(ApplicationDAO.class.getName());

    /**
     * TRANSACTION: Apply for internship.
     * Inserts into applications + application_logs atomically.
     * Returns: "SUCCESS:appId" | "DUPLICATE" | "EXPIRED" | "INELIGIBLE" | "ERROR:msg"
     */
    public String applyForInternship(int studentId, int internshipId, String coverLetter) {
        Connection conn = null;
        PreparedStatement psApp = null;
        PreparedStatement psLog = null;
        PreparedStatement psCheck = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Check duplicate application
            psCheck = conn.prepareStatement(
                "SELECT COUNT(*) FROM applications WHERE student_id = ? AND internship_id = ?");
            psCheck.setInt(1, studentId);
            psCheck.setInt(2, internshipId);
            rs = psCheck.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                conn.rollback();
                return "DUPLICATE";
            }

            // 2. Check deadline and CGPA eligibility
            DBConnection.close(rs, psCheck);
            psCheck = conn.prepareStatement(
                "SELECT i.deadline, i.eligibility_cgpa, s.cgpa " +
                "FROM internships i JOIN students s ON s.student_id = ? " +
                "WHERE i.internship_id = ?");
            psCheck.setInt(1, studentId);
            psCheck.setInt(2, internshipId);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                java.sql.Date deadline = rs.getDate("deadline");
                double minCgpa = rs.getDouble("eligibility_cgpa");
                double studentCgpa = rs.getDouble("cgpa");

                if (deadline != null && deadline.before(new java.util.Date())) {
                    conn.rollback();
                    return "EXPIRED";
                }
                if (studentCgpa < minCgpa) {
                    conn.rollback();
                    return "INELIGIBLE:" + minCgpa;
                }
            }

            // 3. Insert application
            DBConnection.close(rs, psCheck);
            psApp = conn.prepareStatement(
                "INSERT INTO applications (student_id, internship_id, cover_letter) VALUES (?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            psApp.setInt(1, studentId);
            psApp.setInt(2, internshipId);
            psApp.setString(3, coverLetter);
            psApp.executeUpdate();

            rs = psApp.getGeneratedKeys();
            int appId = -1;
            if (rs.next()) appId = rs.getInt(1);

            // 4. Insert application log (same transaction)
            psLog = conn.prepareStatement(
                "INSERT INTO application_logs (application_id, action, new_status) VALUES (?, ?, ?)");
            psLog.setInt(1, appId);
            psLog.setString(2, "Application Submitted by Student");
            psLog.setString(3, "APPLIED");
            psLog.executeUpdate();

            conn.commit();
            LOGGER.info("Application submitted successfully. AppId=" + appId);
            return "SUCCESS:" + appId;

        } catch (SQLIntegrityConstraintViolationException e) {
            DBConnection.rollback(conn);
            return "DUPLICATE";
        } catch (SQLException e) {
            LOGGER.severe("Apply internship transaction failed: " + e.getMessage());
            DBConnection.rollback(conn);
            return "ERROR:" + e.getMessage();
        } finally {
            DBConnection.close(rs, psLog, psApp, psCheck, conn);
        }
    }

    /**
     * TRANSACTION: Update application status (SHORTLISTED/REJECTED/SELECTED).
     */
    public boolean updateStatus(int applicationId, String newStatus, int adminId, String remarks) {
        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psLog = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Get old status
            PreparedStatement psOld = conn.prepareStatement(
                "SELECT status FROM applications WHERE application_id = ?");
            psOld.setInt(1, applicationId);
            rs = psOld.executeQuery();
            String oldStatus = rs.next() ? rs.getString("status") : "UNKNOWN";
            DBConnection.close(rs, psOld);

            // Update application
            psUpdate = conn.prepareStatement(
                "UPDATE applications SET status = ?, reviewed_date = NOW(), reviewed_by = ?, remarks = ? " +
                "WHERE application_id = ?");
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, adminId);
            psUpdate.setString(3, remarks);
            psUpdate.setInt(4, applicationId);
            psUpdate.executeUpdate();

            // Log the action
            psLog = conn.prepareStatement(
                "INSERT INTO application_logs (application_id, action, performed_by, old_status, new_status, remarks) " +
                "VALUES (?, ?, ?, ?, ?, ?)");
            psLog.setInt(1, applicationId);
            psLog.setString(2, "Status updated to " + newStatus);
            psLog.setInt(3, adminId);
            psLog.setString(4, oldStatus);
            psLog.setString(5, newStatus);
            psLog.setString(6, remarks);
            psLog.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            LOGGER.severe("Update status transaction failed: " + e.getMessage());
            DBConnection.rollback(conn);
            return false;
        } finally {
            DBConnection.close(psLog, psUpdate, conn);
        }
    }

    /**
     * Get all applications for an internship (admin view).
     */
    public List<Application> getByInternshipId(int internshipId) throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course, s.cgpa, s.enrollment_number, " +
                     "i.role AS internship_role, c.company_name " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.internship_id = ? ORDER BY s.cgpa DESC";
        return executeListQuery(sql, internshipId);
    }

    /**
     * Get all applications by a student.
     */
    public List<Application> getByStudentId(int studentId) throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course, s.cgpa, s.enrollment_number, " +
                     "i.role AS internship_role, c.company_name, i.location AS internship_location " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.student_id = ? ORDER BY a.applied_date DESC";
        return executeListQuery(sql, studentId);
    }

    /**
     * Get all applications (admin dashboard).
     */
    public List<Application> getAllApplications() throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course, s.cgpa, s.enrollment_number, " +
                     "i.role AS internship_role, c.company_name " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "ORDER BY a.applied_date DESC";
        return executeListQuery(sql, -1);
    }

    /**
     * Check if student has already applied for an internship.
     */
    public boolean hasApplied(int studentId, int internshipId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM applications WHERE student_id = ? AND internship_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setInt(2, internshipId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return false;
    }

    /**
     * Get application by ID with full joined info.
     */
    public Application getById(int applicationId) throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course, s.cgpa, s.enrollment_number, " +
                     "i.role AS internship_role, c.company_name " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.application_id = ?";
        List<Application> result = executeListQuery(sql, applicationId);
        return result.isEmpty() ? null : result.get(0);
    }

    public int getTotalApplications() throws SQLException {
        String sql = "SELECT COUNT(*) FROM applications";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return 0;
    }

    private List<Application> executeListQuery(String sql, int param) throws SQLException {
        List<Application> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            if (param >= 0) ps.setInt(1, param);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    private Application mapRow(ResultSet rs) throws SQLException {
        Application a = new Application();
        a.setApplicationId(rs.getInt("application_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setInternshipId(rs.getInt("internship_id"));
        a.setStatus(rs.getString("status"));
        a.setCoverLetter(rs.getString("cover_letter"));
        a.setAppliedDate(rs.getTimestamp("applied_date"));
        a.setReviewedDate(rs.getTimestamp("reviewed_date"));
        a.setRemarks(rs.getString("remarks"));
        try { a.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        try { a.setStudentEmail(rs.getString("student_email")); } catch (SQLException ignored) {}
        try { a.setCourse(rs.getString("course")); } catch (SQLException ignored) {}
        try { a.setCgpa(rs.getDouble("cgpa")); } catch (SQLException ignored) {}
        try { a.setEnrollmentNumber(rs.getString("enrollment_number")); } catch (SQLException ignored) {}
        try { a.setInternshipRole(rs.getString("internship_role")); } catch (SQLException ignored) {}
        try { a.setCompanyName(rs.getString("company_name")); } catch (SQLException ignored) {}
        try { a.setInternshipLocation(rs.getString("internship_location")); } catch (SQLException ignored) {}
        return a;
    }
}
