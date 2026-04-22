package com.traininginstitute.dao;

import com.traininginstitute.model.User;
import com.traininginstitute.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


/**
 * UserDAO - Data Access Object for User Authentication & Management
 * Implements secure login, session management, and CRUD operations.
 * @author Dr. Geeta Mete
 */
public class UserDAO {



    /**
     * Authenticate user credentials and enforce single-session policy.
     * Returns User object if valid, null otherwise.
     */
    public User authenticate(String email, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                String hashedPwd = rs.getString("password");
                if (BCrypt.checkpw(password, hashedPwd)) {
                    return mapRow(rs);
                }
            }
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Register a new user with BCrypt password hashing.
     */
    public int register(User user) throws SQLException {
        String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12)));
            ps.setString(4, user.getRole());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return -1;
    }

    /**
     * Find user by ID.
     */
    public User findById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
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
     * Check if email already exists.
     */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return false;
    }

    /**
     * Mark user as logged in and update last_login timestamp.
     */
    public void setLoginStatus(int userId, boolean status) throws SQLException {
        String sql = "UPDATE users SET is_logged_in = ?, last_login = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, status);
            ps.setTimestamp(2, status ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setInt(3, userId);
            ps.executeUpdate();
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Check if user is already logged in (single-session enforcement).
     */
    public boolean isAlreadyLoggedIn(int userId) throws SQLException {
        String sql = "SELECT is_logged_in FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getBoolean("is_logged_in");
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return false;
    }

    /**
     * Get all users (admin view).
     */
    public List<User> getAllUsers() throws SQLException {
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        List<User> users = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) users.add(mapRow(rs));
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return users;
    }

    /**
     * Update user profile (name only - admins can do more).
     */
    public void updateName(int userId, String name) throws SQLException {
        String sql = "UPDATE users SET name = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Change password with BCrypt hashing.
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword) throws SQLException {
        String sql = "SELECT password FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String currentHash = rs.getString("password");
                if (BCrypt.checkpw(oldPassword, currentHash)) {
                    DBConnection.close(rs, ps);
                    ps = conn.prepareStatement("UPDATE users SET password = ? WHERE user_id = ?");
                    ps.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt(12)));
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                    return true;
                }
            }
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return false;
    }

    /**
     * Dashboard statistics for admin.
     */
    public int getTotalCount(String role) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, role);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return 0;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setLoggedIn(rs.getBoolean("is_logged_in"));
        u.setLastLogin(rs.getTimestamp("last_login"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
