package com.traininginstitute.model;

import java.sql.Timestamp;

/**
 * AuditLog Model - Security & Activity Tracking
 * @author Dr. Geeta Mete
 */
public class AuditLog {
    private int logId;
    private int userId;
    private String action;
    private String actionType;  // LOGIN, LOGOUT, TAB_SWITCH, EXAM_START, EXAM_SUBMIT, etc.
    private String ipAddress;
    private String userAgent;
    private String sessionId;
    private String additionalData;
    private String severity;    // INFO, WARNING, CRITICAL
    private Timestamp logTime;

    // Joined fields
    private String userName;
    private String userEmail;

    public AuditLog() {}

    public AuditLog(int userId, String action, String actionType, String ipAddress,
                    String userAgent, String sessionId, String severity) {
        this.userId = userId;
        this.action = action;
        this.actionType = actionType;
        this.ipAddress = ipAddress;
        this.userAgent = userAgent;
        this.sessionId = sessionId;
        this.severity = severity;
    }

    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public String getAdditionalData() { return additionalData; }
    public void setAdditionalData(String additionalData) { this.additionalData = additionalData; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }

    public Timestamp getLogTime() { return logTime; }
    public void setLogTime(Timestamp logTime) { this.logTime = logTime; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getSeverityBadgeClass() {
        switch (severity) {
            case "CRITICAL": return "badge-danger";
            case "WARNING":  return "badge-warning";
            default:         return "badge-info";
        }
    }
}
