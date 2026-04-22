<%-- Student Applications Tracking --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Applications | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="My Applications"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">My Applications</h1>
                <p class="page-subtitle">Track the status of your internship applications</p>
            </div>
        </div>

        <c:if test="${param.success eq 'applied'}">
            <div class="alert-message alert-success"><i class="fas fa-check-circle"></i> Successfully applied for the internship! Good luck.</div>
        </c:if>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Date Applied</th><th>Company</th><th>Role</th><th>Cover Letter</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="app" items="${applications}">
                    <tr>
                        <td><fmt:formatDate value="${app.appliedDate}" pattern="dd MMM yyyy" /></td>
                        <td><strong>${app.companyName}</strong></td>
                        <td>${app.internshipRole}</td>
                        <td style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            <c:out value="${empty app.coverLetter ? '-' : app.coverLetter}" />
                        </td>
                        <td><span class="status-badge status-${app.status.toLowerCase()}">${app.status}</span></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty applications}">
                        <tr><td colspan="5" class="empty-state">You have not applied to any internships yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>
