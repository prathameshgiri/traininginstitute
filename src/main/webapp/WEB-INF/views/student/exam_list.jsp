<%-- Student Exam List --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Certification Exams | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Exams"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Certification Exams</h1>
                <p class="page-subtitle">Available exams for your selected internships</p>
            </div>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert-message alert-error"><i class="fas fa-exclamation-circle"></i> Error: ${param.error}</div>
        </c:if>

        <div class="internship-grid">
            <c:forEach var="exam" items="${exams}">
            <div class="card" style="padding: 24px; position:relative;">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 16px;">
                    <div>
                        <h3 style="margin-bottom: 4px;">${exam.examName}</h3>
                        <p style="color:var(--text-muted); font-size:14px;">${exam.companyName} - ${exam.internshipRole}</p>
                    </div>
                    <span class="status-badge status-${exam.status.toLowerCase()}">${exam.status}</span>
                </div>
                
                <p style="margin-bottom: 20px; font-size: 14px; line-height:1.5;">${exam.description}</p>
                
                <div style="display:flex; flex-wrap:wrap; gap:16px; margin-bottom: 20px; font-size:13px; color:var(--text-muted)">
                    <div><i class="fas fa-clock" style="color:var(--primary)"></i> Duration: ${exam.duration} mins</div>
                    <div><i class="fas fa-star" style="color:var(--accent2)"></i> Passing Marks: ${exam.passingMarks}/${exam.totalMarks}</div>
                </div>

                <div style="border-top: 1px solid rgba(255,255,255,0.1); padding-top: 16px;">
                    <form action="${pageContext.request.contextPath}/student/exam/start" method="get">
                        <input type="hidden" name="exam_id" value="${exam.examId}">
                        <c:choose>
                            <c:when test="${exam.status eq 'ACTIVE'}">
                                <button type="submit" class="btn btn-primary" style="width:100%; justify-content:center;">
                                    <i class="fas fa-play-circle"></i> Start Exam
                                </button>
                            </c:when>
                            <c:when test="${exam.status eq 'SCHEDULED'}">
                                <button type="button" class="btn-apply applied" style="width:100%; justify-content:center;" disabled>
                                    <i class="fas fa-calendar-alt"></i> Scheduled
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-apply applied" style="width:100%; justify-content:center;" disabled>
                                    <i class="fas fa-lock"></i> Closed
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </form>
                </div>
            </div>
            </c:forEach>
            <c:if test="${empty exams}">
                <div class="card" style="padding:48px;text-align:center;width:100%;grid-column: 1 / -1;">
                    <i class="fas fa-file-alt" style="font-size:48px;color:var(--text-dim);margin-bottom:16px;display:block"></i>
                    <h3 style="margin-bottom:8px">No Exams Currently Available</h3>
                    <p style="color:var(--text-muted)">There are no exams available to take at this moment.</p>
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>
