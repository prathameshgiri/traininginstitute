<%-- Admin Reports Menu --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Reports | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <style>
        .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }
        .report-card { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08); border-radius: 12px; padding: 24px; text-decoration: none; color: inherit; transition: all 0.3s ease; display: flex; flex-direction: column; align-items: center; text-align: center; }
        .report-card:hover { transform: translateY(-5px); background: rgba(255,255,255,0.06); border-color: var(--primary); }
        .report-icon { font-size: 32px; color: var(--primary); margin-bottom: 16px; }
        .report-title { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
        .report-desc { font-size: 14px; color: var(--text-muted); }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Analytics & Reports</h1>
                <p class="page-subtitle">View system analytics and intelligence reports</p>
            </div>
        </div>
        <div class="report-grid">
            <a href="${pageContext.request.contextPath}/admin/report/selected-per-company" class="report-card">
                <i class="fas fa-building report-icon"></i>
                <div class="report-title">Selection Per Company</div>
                <div class="report-desc">View stats of students selected across partner companies.</div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/application-counts" class="report-card">
                <i class="fas fa-chart-bar report-icon"></i>
                <div class="report-title">Application Counts</div>
                <div class="report-desc">Internship popularity and competition metrics.</div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/exam-rank-list" class="report-card">
                <i class="fas fa-trophy report-icon"></i>
                <div class="report-title">Exam Rank List</div>
                <div class="report-desc">Ranking and scores of students in certification exams.</div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/question-performance" class="report-card">
                <i class="fas fa-tasks report-icon"></i>
                <div class="report-title">Question Performance</div>
                <div class="report-desc">Identify difficult questions and student weak points.</div>
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/suspicious-activities" class="report-card">
                <i class="fas fa-shield-alt report-icon" style="color:var(--danger)"></i>
                <div class="report-title">Suspicious Activities</div>
                <div class="report-desc">Tab switches and potential cheating during exams.</div>
            </a>
        </div>
    </main>
</body>
</html>
