<%-- Exam Result Page --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Exam Result | Training Institute Portal</title>
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
                <a href="${pageContext.request.contextPath}/student/exam/list" class="btn-link" style="display:block;margin-bottom:8px">← Back to Exams</a>
                <h1 class="page-title">Exam Result</h1>
                <p class="page-subtitle">${exam.examName}</p>
            </div>
        </div>

        <!-- Result Card -->
        <div class="card" style="max-width:700px;margin:0 auto 28px">
            <div class="card-body" style="text-align:center;padding:48px">
                <c:choose>
                    <c:when test="${attempt.passed}">
                        <div style="font-size:72px;margin-bottom:16px">🎉</div>
                        <h2 style="font-size:28px;font-weight:800;color:var(--accent);margin-bottom:8px">Congratulations!</h2>
                        <p style="color:var(--text-muted);margin-bottom:32px">You have successfully passed the certification exam.</p>
                    </c:when>
                    <c:otherwise>
                        <div style="font-size:72px;margin-bottom:16px">📚</div>
                        <h2 style="font-size:28px;font-weight:800;color:var(--secondary);margin-bottom:8px">Better Luck Next Time</h2>
                        <p style="color:var(--text-muted);margin-bottom:32px">You did not meet the passing criteria this time.</p>
                    </c:otherwise>
                </c:choose>

                <!-- Score Circle -->
                <div style="display:inline-flex;flex-direction:column;align-items:center;justify-content:center;width:160px;height:160px;border-radius:50%;background:${attempt.passed ? 'rgba(67,233,123,.1)' : 'rgba(255,101,132,.1)'};border:4px solid ${attempt.passed ? 'var(--accent)' : 'var(--secondary)'};margin-bottom:32px">
                    <span style="font-size:42px;font-weight:800;color:${attempt.passed ? 'var(--accent)' : 'var(--secondary)'}">${attempt.totalScore}</span>
                    <span style="font-size:14px;color:var(--text-muted)">/ ${exam.totalMarks}</span>
                </div>

                <!-- Stats Row -->
                <div style="display:flex;justify-content:center;gap:24px;flex-wrap:wrap;margin-bottom:24px">
                    <div style="text-align:center">
                        <div style="font-size:22px;font-weight:800">${attempt.mcqScore}</div>
                        <div style="font-size:12px;color:var(--text-muted)">MCQ Score</div>
                    </div>
                    <div style="text-align:center">
                        <div style="font-size:22px;font-weight:800">${attempt.subjectiveScore}</div>
                        <div style="font-size:12px;color:var(--text-muted)">Subjective</div>
                    </div>
                    <div style="text-align:center">
                        <div style="font-size:22px;font-weight:800">${exam.passingMarks}</div>
                        <div style="font-size:12px;color:var(--text-muted)">Pass Mark</div>
                    </div>
                    <div style="text-align:center">
                        <div style="font-size:22px;font-weight:800">${attempt.tabSwitchCount}</div>
                        <div style="font-size:12px;color:var(--text-muted)">Tab Switches</div>
                    </div>
                </div>

                <div style="display:flex;gap:12px;justify-content:center">
                    <a href="${pageContext.request.contextPath}/student/dashboard" class="btn btn-secondary">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/student/applications" class="btn btn-primary">
                        <i class="fas fa-briefcase"></i> My Applications
                    </a>
                </div>
            </div>
        </div>

        <!-- Answer Review -->
        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-list-check"></i> Answer Review</h3>
            </div>
            <div class="card-body">
                <c:forEach var="q" items="${answers}" varStatus="s">
                <div style="background:var(--bg-input);border:1px solid var(--border-light);border-radius:12px;padding:20px;margin-bottom:16px">
                    <div style="display:flex;justify-content:space-between;margin-bottom:12px">
                        <span style="font-weight:700">Q${s.count}. <span class="badge ${q.type eq 'MCQ' ? 'badge-primary' : 'badge-info'}">${q.type}</span></span>
                        <span style="color:var(--accent);font-weight:700">${q.marksAwarded} / ${q.marks} marks</span>
                    </div>
                    <p style="color:var(--text-light);margin-bottom:12px">${q.questionText}</p>
                    <c:if test="${not empty q.descriptiveAnswer}">
                        <p style="color:var(--text-muted);font-size:13px;padding:10px;background:var(--bg-dark);border-radius:8px">${q.descriptiveAnswer}</p>
                    </c:if>
                </div>
                </c:forEach>
            </div>
        </div>
    </main>
</body>
</html>
