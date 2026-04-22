package com.traininginstitute.dao;

import com.traininginstitute.model.AuditLog;
import com.traininginstitute.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * AuditLogDAO - Security logging and suspicious activity tracking.
 * Manages session tracking and audit trails.
 * @author Dr. Geeta Mete
 */
public class AuditLogDAO {

    private static final Logger LOGGER = Logger.getLogger(AuditLogDAO.class.getName());

    /**
     * Insert an audit log entry (fire-and-forget, never throws to caller).
     */
    public void log(AuditLog log) {
        String sql = "INSERT INTO audit_logs (user_id, action, action_type, ip_address, user_agent, " +
                     "session_id, additional_data, severity) VALUES (?,?,?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            if (log.getUserId() > 0) ps.setInt(1, log.getUserId()); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, log.getAction());
            ps.setString(3, log.getActionType());
            ps.setString(4, log.getIpAddress());
            ps.setString(5, log.getUserAgent() != null && log.getUserAgent().length() > 499
                    ? log.getUserAgent().substring(0, 499) : log.getUserAgent());
            ps.setString(6, log.getSessionId());
            ps.setString(7, log.getAdditionalData());
            ps.setString(8, log.getSeverity() != null ? log.getSeverity() : "INFO");
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.warning("Failed to write audit log: " + e.getMessage());
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    /**
     * Convenience: Log a simple action.
     */
    public void logAction(int userId, String action, String actionType, String ip,
                          String userAgent, String sessionId, String severity) {
        AuditLog log = new AuditLog(userId, action, actionType, ip, userAgent, sessionId, severity);
        this.log(log);
    }

    /**
     * Get all logs (admin view, paginated).
     */
    public List<AuditLog> getAllLogs(int limit, int offset) throws SQLException {
        String sql = "SELECT al.*, u.name AS user_name, u.email AS user_email " +
                     "FROM audit_logs al LEFT JOIN users u ON al.user_id = u.user_id " +
                     "ORDER BY al.log_time DESC LIMIT ? OFFSET ?";
        List<AuditLog> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit); ps.setInt(2, offset);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    /**
     * Get suspicious activity logs.
     */
    public List<AuditLog> getSuspiciousLogs(int limit) throws SQLException {
        String sql = "SELECT al.*, u.name AS user_name, u.email AS user_email " +
                     "FROM audit_logs al LEFT JOIN users u ON al.user_id = u.user_id " +
                     "WHERE al.severity IN ('WARNING','CRITICAL') OR al.action_type IN ('TAB_SWITCH','SECURITY_ALERT') " +
                     "ORDER BY al.log_time DESC LIMIT ?";
        List<AuditLog> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    /**
     * Get logs for a specific user.
     */
    public List<AuditLog> getLogsByUser(int userId) throws SQLException {
        String sql = "SELECT al.*, u.name AS user_name, u.email AS user_email " +
                     "FROM audit_logs al LEFT JOIN users u ON al.user_id = u.user_id " +
                     "WHERE al.user_id = ? ORDER BY al.log_time DESC LIMIT 100";
        List<AuditLog> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    // ================================================================
    // SESSION TRACKING
    // ================================================================

    public void createSession(String sessionId, int userId, String ip, String userAgent) throws SQLException {
        String sql = "INSERT INTO session_tracking (session_id, user_id, ip_address, user_agent, last_activity) " +
                     "VALUES (?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE " +
                     "ip_address = VALUES(ip_address), last_activity = NOW(), is_active = TRUE";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId); ps.setInt(2, userId);
            ps.setString(3, ip); ps.setString(4, userAgent);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public void updateSessionActivity(String sessionId) {
        String sql = "UPDATE session_tracking SET last_activity = NOW() WHERE session_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.warning("Session activity update failed: " + e.getMessage());
        } finally { DBConnection.close(ps, conn); }
    }

    public void invalidateSession(String sessionId) throws SQLException {
        String sql = "UPDATE session_tracking SET is_active = FALSE WHERE session_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    /**
     * Validate: Check if session IP matches registered IP (binding check).
     */
    public boolean validateSessionBinding(String sessionId, String currentIp) throws SQLException {
        String sql = "SELECT ip_address FROM session_tracking WHERE session_id = ? AND is_active = TRUE";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String registeredIp = rs.getString("ip_address");
                return registeredIp != null && registeredIp.equals(currentIp);
            }
        } finally { DBConnection.close(rs, ps, conn); }
        return false;
    }

    public int getTotalLogs() throws SQLException {
        String sql = "SELECT COUNT(*) FROM audit_logs";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return 0;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setLogId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setAction(rs.getString("action"));
        log.setActionType(rs.getString("action_type"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setSessionId(rs.getString("session_id"));
        log.setAdditionalData(rs.getString("additional_data"));
        log.setSeverity(rs.getString("severity"));
        log.setLogTime(rs.getTimestamp("log_time"));
        try { log.setUserName(rs.getString("user_name")); } catch (SQLException ignored) {}
        try { log.setUserEmail(rs.getString("user_email")); } catch (SQLException ignored) {}
        return log;
    }
}
