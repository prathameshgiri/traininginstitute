<%-- Admin Students Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Students | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Registered Students</h1>
                <p class="page-subtitle">Manage student profiles</p>
            </div>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>ID</th><th>Name</th><th>Email</th><th>Course</th><th>CGPA</th><th>Phone</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${students}">
                    <tr>
                        <td>${s.studentId}</td>
                        <td><strong>${s.name}</strong></td>
                        <td>${s.email}</td>
                        <td>${s.course}</td>
                        <td><span class="cgpa-badge">${s.cgpa}</span></td>
                        <td>${s.phone}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty students}"><tr><td colspan="6" class="empty-state">No students found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>
