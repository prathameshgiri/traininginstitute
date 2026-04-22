package com.traininginstitute.dao;

import com.traininginstitute.model.Student;
import com.traininginstitute.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


/**
 * StudentDAO - Student Profile CRUD operations
 * @author Dr. Geeta Mete
 */
public class StudentDAO {



    /**
     * Create student profile after user registration (with transaction).
     */
    public int createStudentProfile(Connection conn, Student student) throws SQLException {
        String sql = "INSERT INTO students (user_id, course, cgpa, phone, enrollment_number, batch_year) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, student.getUserId());
            ps.setString(2, student.getCourse());
            ps.setDouble(3, student.getCgpa());
            ps.setString(4, student.getPhone());
            ps.setString(5, student.getEnrollmentNumber());
            ps.setInt(6, student.getBatchYear());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally {
            DBConnection.close(rs, ps);
        }
        return -1;
    }

    /**
     * Find student by user_id.
     */
    public Student findByUserId(int userId) throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id WHERE s.user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Find student by student_id.
     */
    public Student findById(int studentId) throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id WHERE s.student_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Get all students (admin view).
     */
    public List<Student> getAllStudents() throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id ORDER BY u.name";
        List<Student> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Get students eligible (CGPA >= threshold) for a specific internship.
     */
    public List<Student> getEligibleStudents(double minCgpa) throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id WHERE s.cgpa >= ? ORDER BY s.cgpa DESC";
        List<Student> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDouble(1, minCgpa);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    /**
     * Update student profile information.
     */
    public void updateProfile(Student student) throws SQLException {
        String sql = "UPDATE students SET course = ?, cgpa = ?, phone = ?, address = ?, skills = ? WHERE student_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, student.getCourse());
            ps.setDouble(2, student.getCgpa());
            ps.setString(3, student.getPhone());
            ps.setString(4, student.getAddress());
            ps.setString(5, student.getSkills());
            ps.setInt(6, student.getStudentId());
            ps.executeUpdate();
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Update profile picture path.
     */
    public void updateProfilePic(int studentId, String picPath) throws SQLException {
        String sql = "UPDATE students SET profile_pic = ? WHERE student_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, picPath);
            ps.setInt(2, studentId);
            ps.executeUpdate();
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Total student count for dashboard.
     */
    public int getTotalStudents() throws SQLException {
        String sql = "SELECT COUNT(*) FROM students";
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

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentId(rs.getInt("student_id"));
        s.setUserId(rs.getInt("user_id"));
        s.setCourse(rs.getString("course"));
        s.setCgpa(rs.getDouble("cgpa"));
        s.setPhone(rs.getString("phone"));
        s.setAddress(rs.getString("address"));
        s.setProfilePic(rs.getString("profile_pic"));
        s.setSkills(rs.getString("skills"));
        s.setResumePath(rs.getString("resume_path"));
        s.setEnrollmentNumber(rs.getString("enrollment_number"));
        s.setBatchYear(rs.getInt("batch_year"));
        // Joined fields
        try { s.setName(rs.getString("name")); } catch (SQLException ignored) {}
        try { s.setEmail(rs.getString("email")); } catch (SQLException ignored) {}
        return s;
    }
}
