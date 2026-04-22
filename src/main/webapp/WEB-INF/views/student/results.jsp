<%-- Student Assessment Results --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Assessment Results | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Assessment Results"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Assessment Results</h1>
                <p class="page-subtitle">View your certification scores and grades</p>
            </div>
        </div>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Exam ID</th><th>Exam Name</th><th>Company/Role</th><th>Status</th><th>Action</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="exam" items="${exams}">
                    <tr>
                        <td>#${exam.examId}</td>
                        <td><strong>${exam.examName}</strong></td>
                        <td>${exam.companyName} - ${exam.internshipRole}</td>
                        <td><span class="status-badge status-${exam.status.toLowerCase()}">${exam.status}</span></td>
                        <td>
                            <!-- We safely direct them back to Exam List -->
                            <a href="${pageContext.request.contextPath}/student/exam/list" class="btn btn-sm btn-secondary">Go to Exams</a>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty exams}">
                        <tr><td colspan="5" class="empty-state">No assessments or grades published yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>
