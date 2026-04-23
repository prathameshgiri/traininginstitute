<%-- Admin Exam Results / Evaluation --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Student Exam Results | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Exams"/>
    <style>
        .filter-card { background: var(--bg-card); padding: 24px; border-radius: 16px; margin-bottom: 24px; border: 1px solid var(--border-light); }
        .result-row { transition: background 0.2s; }
        .result-row:hover { background: rgba(255,255,255,0.03); }
        .qualify-badge { font-weight: 700; padding: 4px 10px; border-radius: 20px; font-size: 12px; }
        .badge-qualified { background: rgba(67,233,123,.15); color: #43e97b; border: 1px solid rgba(67,233,123,.3); }
        .badge-disqualified { background: rgba(255,101,132,.15); color: #ff6584; border: 1px solid rgba(255,101,132,.3); }
        .badge-pending { background: rgba(246,211,101,.15); color: #f6d365; border: 1px solid rgba(246,211,101,.3); }
        .score-text { font-size: 16px; font-weight: 800; }
        .score-pass { color: #43e97b; }
        .score-fail { color: #ff6584; }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <a href="${pageContext.request.contextPath}/admin/exams" class="btn-link" style="display:block;margin-bottom:8px">← Back to Exams</a>
                <h1 class="page-title">Student Exam Results</h1>
                <p class="page-subtitle">View attempts, scores, and qualification status for students</p>
            </div>
        </div>

        <div class="filter-card">
            <form action="${pageContext.request.contextPath}/admin/evaluate" method="get" style="display:flex; gap:16px; align-items:flex-end;">
                <div class="form-group" style="flex:1; margin-bottom:0;">
                    <label class="form-label">Select Exam to View Results</label>
                    <select name="exam_id" class="form-control" required>
                        <option value="">-- Choose an Exam --</option>
                        <c:forEach var="ex" items="${exams}">
                            <option value="${ex.examId}" ${param.exam_id == ex.examId ? 'selected' : ''}>
                                ${ex.examName} (ID: ${ex.examId})
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> View Results</button>
            </form>
        </div>

        <c:if test="${not empty selectedExam}">
        <div class="card">
            <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
                <h3><i class="fas fa-poll"></i> Results for: ${selectedExam.examName}</h3>
                <span style="font-size:14px; color:var(--text-muted);">Passing Marks: <strong>${selectedExam.passingMarks}/${selectedExam.totalMarks}</strong></span>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Attempt ID</th>
                        <th>Student Name</th>
                        <th>Date Taken</th>
                        <th>Score</th>
                        <th>Violations</th>
                        <th>Status</th>
                        <th>Result</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="att" items="${attempts}">
                    <tr class="result-row">
                        <td>#${att.attemptId}</td>
                        <td><strong>${att.studentName}</strong></td>
                        <td><fmt:formatDate value="${att.submitTime}" pattern="dd MMM yyyy, hh:mm a" /></td>
                        <td>
                            <span class="score-text ${att.passed ? 'score-pass' : 'score-fail'}">
                                ${att.totalScore}
                            </span>
                            <span style="font-size:12px; color:var(--text-muted);">/ ${att.totalMarks}</span>
                        </td>
                        <td>
                            <c:if test="${att.tabSwitchCount > 0}">
                                <span style="color:#ff6584; font-size:12px;"><i class="fas fa-exclamation-triangle"></i> ${att.tabSwitchCount} Tab Switches</span>
                            </c:if>
                            <c:if test="${att.tabSwitchCount == 0}">
                                <span style="color:var(--text-muted); font-size:12px;">None</span>
                            </c:if>
                        </td>
                        <td>
                            <span style="font-size:12px; color:var(--text-muted);">${att.status}</span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${att.status eq 'IN_PROGRESS'}">
                                    <span class="qualify-badge badge-pending">IN PROGRESS</span>
                                </c:when>
                                <c:when test="${att.passed}">
                                    <span class="qualify-badge badge-qualified"><i class="fas fa-check-circle"></i> QUALIFIED</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="qualify-badge badge-disqualified"><i class="fas fa-times-circle"></i> DISQUALIFIED</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty attempts}">
                        <tr><td colspan="7" class="empty-state">No student has taken this exam yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        </c:if>
        
        <c:if test="${empty selectedExam and not empty param.exam_id}">
             <div class="alert-message alert-error">Selected exam not found.</div>
        </c:if>

    </main>
</body>
</html>
