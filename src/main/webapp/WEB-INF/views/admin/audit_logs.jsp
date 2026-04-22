<%-- Admin Audit Logs --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Audit Logs | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">System Audit Logs</h1>
                <p class="page-subtitle">Track detailed system actions and security events</p>
            </div>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Time</th><th>User ID</th><th>Action</th><th>Type</th><th>Severity</th><th>IP Address</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                    <tr>
                        <td>${log.logTime}</td>
                        <td>User #${log.userId}</td>
                        <td>${log.actionDetails}</td>
                        <td>${log.actionType}</td>
                        <td><span class="status-badge status-${log.severity ne null ? log.severity.toLowerCase() : 'info'}">${log.severity}</span></td>
                        <td>${log.ipAddress}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty logs}"><tr><td colspan="6" class="empty-state">No logs found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>
