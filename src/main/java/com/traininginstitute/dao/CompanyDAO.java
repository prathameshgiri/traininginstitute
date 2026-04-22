package com.traininginstitute.dao;

import com.traininginstitute.model.Company;
import com.traininginstitute.model.Internship;
import com.traininginstitute.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * CompanyDAO + InternshipDAO combined for company-internship management.
 * @author Dr. Geeta Mete
 */
public class CompanyDAO {

    // ================================================================
    // COMPANY CRUD
    // ================================================================

    public List<Company> getAllCompanies() throws SQLException {
        String sql = "SELECT c.*, " +
                     "(SELECT COUNT(*) FROM internships i WHERE i.company_id = c.company_id) AS total_internships " +
                     "FROM companies c WHERE c.is_active = TRUE ORDER BY c.company_name";
        List<Company> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapCompany(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    public Company getById(int companyId) throws SQLException {
        String sql = "SELECT c.*, " +
                     "(SELECT COUNT(*) FROM internships i WHERE i.company_id = c.company_id) AS total_internships " +
                     "FROM companies c WHERE c.company_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, companyId);
            rs = ps.executeQuery();
            if (rs.next()) return mapCompany(rs);
        } finally { DBConnection.close(rs, ps, conn); }
        return null;
    }

    public int addCompany(Company c) throws SQLException {
        String sql = "INSERT INTO companies (company_name, location, industry, website, contact_email, " +
                     "contact_person, description, eligibility_cgpa) VALUES (?,?,?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, c.getCompanyName()); ps.setString(2, c.getLocation());
            ps.setString(3, c.getIndustry()); ps.setString(4, c.getWebsite());
            ps.setString(5, c.getContactEmail()); ps.setString(6, c.getContactPerson());
            ps.setString(7, c.getDescription()); ps.setDouble(8, c.getEligibilityCgpa());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return -1;
    }

    public void updateCompany(Company c) throws SQLException {
        String sql = "UPDATE companies SET company_name=?, location=?, industry=?, website=?, " +
                     "contact_email=?, contact_person=?, description=?, eligibility_cgpa=? WHERE company_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getCompanyName()); ps.setString(2, c.getLocation());
            ps.setString(3, c.getIndustry()); ps.setString(4, c.getWebsite());
            ps.setString(5, c.getContactEmail()); ps.setString(6, c.getContactPerson());
            ps.setString(7, c.getDescription()); ps.setDouble(8, c.getEligibilityCgpa());
            ps.setInt(9, c.getCompanyId());
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public void deleteCompany(int companyId) throws SQLException {
        String sql = "UPDATE companies SET is_active = FALSE WHERE company_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, companyId);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public int getTotalCompanies() throws SQLException {
        String sql = "SELECT COUNT(*) FROM companies WHERE is_active = TRUE";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return 0;
    }

    // ================================================================
    // INTERNSHIP CRUD
    // ================================================================

    public List<Internship> getAllInternships() throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location AS company_location, " +
                     "(SELECT COUNT(*) FROM applications a WHERE a.internship_id = i.internship_id) AS total_applications " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "ORDER BY i.deadline ASC";
        return executeInternshipList(sql, null);
    }

    public List<Internship> getOpenInternships() throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location AS company_location, c.logo_path AS company_logo, " +
                     "(SELECT COUNT(*) FROM applications a WHERE a.internship_id = i.internship_id) AS total_applications " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE i.status = 'OPEN' AND i.deadline >= CURDATE() " +
                     "ORDER BY i.deadline ASC";
        return executeInternshipList(sql, null);
    }

    /**
     * Get internships eligible for a student (CGPA filter).
     */
    public List<Internship> getEligibleInternships(double studentCgpa, int studentId) throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location AS company_location, c.logo_path AS company_logo, " +
                     "(SELECT COUNT(*) FROM applications a WHERE a.internship_id = i.internship_id) AS total_applications, " +
                     "(SELECT COUNT(*) FROM applications a2 WHERE a2.student_id = ? AND a2.internship_id = i.internship_id) > 0 AS has_applied, " +
                     "(SELECT a3.status FROM applications a3 WHERE a3.student_id = ? AND a3.internship_id = i.internship_id LIMIT 1) AS application_status " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE i.status = 'OPEN' AND i.deadline >= CURDATE() AND i.eligibility_cgpa <= ? " +
                     "ORDER BY i.deadline ASC";
        List<Internship> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId); ps.setInt(2, studentId); ps.setDouble(3, studentCgpa);
            rs = ps.executeQuery();
            while (rs.next()) {
                Internship i = mapInternship(rs);
                try { i.setHasApplied(rs.getBoolean("has_applied")); } catch (SQLException ignored) {}
                try { i.setApplicationStatus(rs.getString("application_status")); } catch (SQLException ignored) {}
                list.add(i);
            }
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    public Internship getInternshipById(int id) throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location AS company_location " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id WHERE i.internship_id = ?";
        executeInternshipList(sql + " -- param", id);
        // direct query
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return mapInternship(rs);
        } finally { DBConnection.close(rs, ps, conn); }
        return null;
    }

    public int addInternship(Internship i) throws SQLException {
        String sql = "INSERT INTO internships (company_id, role, description, stipend, duration_months, deadline, " +
                     "seats, location, skills_required, eligibility_cgpa, status) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, i.getCompanyId()); ps.setString(2, i.getRole());
            ps.setString(3, i.getDescription()); ps.setDouble(4, i.getStipend());
            ps.setInt(5, i.getDurationMonths()); ps.setDate(6, i.getDeadline());
            ps.setInt(7, i.getSeats()); ps.setString(8, i.getLocation());
            ps.setString(9, i.getSkillsRequired()); ps.setDouble(10, i.getEligibilityCgpa());
            ps.setString(11, i.getStatus() != null ? i.getStatus() : "OPEN");
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return -1;
    }

    public void updateInternship(Internship i) throws SQLException {
        String sql = "UPDATE internships SET role=?, description=?, stipend=?, duration_months=?, deadline=?, " +
                     "seats=?, location=?, skills_required=?, eligibility_cgpa=?, status=? WHERE internship_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, i.getRole()); ps.setString(2, i.getDescription());
            ps.setDouble(3, i.getStipend()); ps.setInt(4, i.getDurationMonths());
            ps.setDate(5, i.getDeadline()); ps.setInt(6, i.getSeats());
            ps.setString(7, i.getLocation()); ps.setString(8, i.getSkillsRequired());
            ps.setDouble(9, i.getEligibilityCgpa()); ps.setString(10, i.getStatus());
            ps.setInt(11, i.getInternshipId());
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public void deleteInternship(int id) throws SQLException {
        String sql = "UPDATE internships SET status = 'ARCHIVED' WHERE internship_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id); ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public int getTotalOpenInternships() throws SQLException {
        String sql = "SELECT COUNT(*) FROM internships WHERE status = 'OPEN' AND deadline >= CURDATE()";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return 0;
    }

    private List<Internship> executeInternshipList(String sql, Integer param) throws SQLException {
        List<Internship> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            if (param != null) ps.setInt(1, param);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapInternship(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    private Company mapCompany(ResultSet rs) throws SQLException {
        Company c = new Company();
        c.setCompanyId(rs.getInt("company_id"));
        c.setCompanyName(rs.getString("company_name"));
        c.setLocation(rs.getString("location"));
        c.setIndustry(rs.getString("industry"));
        c.setWebsite(rs.getString("website"));
        c.setContactEmail(rs.getString("contact_email"));
        c.setContactPerson(rs.getString("contact_person"));
        c.setDescription(rs.getString("description"));
        c.setEligibilityCgpa(rs.getDouble("eligibility_cgpa"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setActive(rs.getBoolean("is_active"));
        try { c.setTotalInternships(rs.getInt("total_internships")); } catch (SQLException ignored) {}
        return c;
    }

    private Internship mapInternship(ResultSet rs) throws SQLException {
        Internship i = new Internship();
        i.setInternshipId(rs.getInt("internship_id"));
        i.setCompanyId(rs.getInt("company_id"));
        i.setRole(rs.getString("role"));
        i.setDescription(rs.getString("description"));
        i.setStipend(rs.getDouble("stipend"));
        i.setDurationMonths(rs.getInt("duration_months"));
        i.setDeadline(rs.getDate("deadline"));
        i.setSeats(rs.getInt("seats"));
        i.setLocation(rs.getString("location"));
        i.setSkillsRequired(rs.getString("skills_required"));
        i.setEligibilityCgpa(rs.getDouble("eligibility_cgpa"));
        i.setStatus(rs.getString("status"));
        i.setCreatedAt(rs.getTimestamp("created_at"));
        try { i.setCompanyName(rs.getString("company_name")); } catch (SQLException ignored) {}
        try { i.setCompanyLocation(rs.getString("company_location")); } catch (SQLException ignored) {}
        try { i.setCompanyLogo(rs.getString("company_logo")); } catch (SQLException ignored) {}
        try { i.setTotalApplications(rs.getInt("total_applications")); } catch (SQLException ignored) {}
        return i;
    }
}
