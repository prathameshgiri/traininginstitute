<%-- Student Assessment Results - My Exam History --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Results | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="My Results"/>
    <style>
        .result-card {
            background: var(--bg-card, #1e2235);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 16px;
            border: 1px solid var(--border-light, rgba(255,255,255,.08));
            display: flex;
            align-items: center;
            gap: 24px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .result-card:hover { transform: translateY(-2px); box-shadow: 0 8px 32px rgba(0,0,0,.3); }
        .result-score-circle {
            width: 90px; height: 90px; border-radius: 50%;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            flex-shrink: 0; font-weight: 800; border: 3px solid;
        }
        .score-qualify { border-color: #43e97b; background: rgba(67,233,123,.1); color: #43e97b; }
        .score-disqualify { border-color: #ff6584; background: rgba(255,101,132,.1); color: #ff6584; }
        .score-pending { border-color: #f6d365; background: rgba(246,211,101,.1); color: #f6d365; }
        .result-info { flex: 1; }
        .result-exam-name { font-size: 17px; font-weight: 700; margin-bottom: 4px; }
        .result-meta { font-size: 13px; color: var(--text-muted, #888); }
        .qualify-badge {
            font-size: 13px; font-weight: 700; padding: 6px 16px; border-radius: 20px;
            letter-spacing: .5px; text-transform: uppercase;
        }
        .badge-qualified { background: rgba(67,233,123,.15); color: #43e97b; border: 1px solid rgba(67,233,123,.4); }
        .badge-disqualified { background: rgba(255,101,132,.15); color: #ff6584; border: 1px solid rgba(255,101,132,.4); }
        .badge-inprogress { background: rgba(246,211,101,.15); color: #f6d365; border: 1px solid rgba(246,211,101,.4); }
        .stats-row { display: flex; gap: 28px; margin-top: 10px; }
        .stat-item { text-align: center; }
        .stat-val { font-size: 22px; font-weight: 800; }
        .stat-lbl { font-size: 11px; color: var(--text-muted,#888); text-transform: uppercase; letter-spacing:.5px; }
        .summary-banner {
            border-radius: 16px; padding: 24px 32px;
            background: linear-gradient(135deg, rgba(102,126,234,.15), rgba(118,75,162,.15));
            border: 1px solid rgba(102,126,234,.25); margin-bottom: 28px;
            display: flex; gap: 40px; align-items: center;
        }
        .summary-num { font-size: 36px; font-weight: 800; }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">My Exam Results</h1>
                <p class="page-subtitle">Track your performance across all certification exams</p>
            </div>
            <a href="${pageContext.request.contextPath}/student/exam/list" class="btn btn-secondary">
                <i class="fas fa-laptop-code"></i> Take Exams
            </a>
        </div>

        <c:if test="${not empty myAttempts}">
        <%-- Summary Banner --%>
        <div class="summary-banner">
            <div class="stat-item">
                <div class="summary-num">${fn:length(myAttempts)}</div>
                <div class="stat-lbl">Exams Taken</div>
            </div>
            <div class="stat-item">
                <c:set var="qCount" value="0"/>
                <c:forEach var="a" items="${myAttempts}">
                    <c:if test="${a.passed and (a.status eq 'SUBMITTED' or a.status eq 'AUTO_SUBMITTED')}">
                        <c:set var="qCount" value="${qCount + 1}"/>
                    </c:if>
                </c:forEach>
                <div class="summary-num" style="color:#43e97b">${qCount}</div>
                <div class="stat-lbl">Qualified</div>
            </div>
            <div class="stat-item">
                <div class="summary-num" style="color:#ff6584">${fn:length(myAttempts) - qCount}</div>
                <div class="stat-lbl">Not Qualified</div>
            </div>
            <div style="flex:1;text-align:right;font-size:14px;color:var(--text-muted)">
                <i class="fas fa-info-circle"></i> Qualify requires <strong>12 / 20</strong> correct answers
            </div>
        </div>

        <%-- Result Cards --%>
        <c:forEach var="attempt" items="${myAttempts}">
        <div class="result-card">
            <%-- Score Circle --%>
            <div class="result-score-circle
                ${(attempt.status eq 'SUBMITTED' or attempt.status eq 'AUTO_SUBMITTED') ?
                  (attempt.passed ? 'score-qualify' : 'score-disqualify') : 'score-pending'}">
                <span style="font-size:24px">${attempt.status eq 'IN_PROGRESS' ? '...' : attempt.totalScore}</span>
                <span style="font-size:11px">${attempt.status eq 'IN_PROGRESS' ? 'In Progress' : '/ ' += attempt.totalMarks}</span>
            </div>

            <%-- Info --%>
            <div class="result-info">
                <div class="result-exam-name">${attempt.examName}</div>
                <div class="result-meta">
                    <i class="fas fa-calendar-alt"></i>
                    <fmt:formatDate value="${attempt.submitTime}" pattern="dd MMM yyyy, hh:mm a"/>
                    &nbsp;&nbsp;
                    <i class="fas fa-trophy"></i> Pass Mark: ${attempt.passingMarks} / ${attempt.totalMarks}
                </div>
                <div class="stats-row" style="margin-top:10px">
                    <div>
                        <span class="qualify-badge
                            ${(attempt.status eq 'SUBMITTED' or attempt.status eq 'AUTO_SUBMITTED') ?
                              (attempt.passed ? 'badge-qualified' : 'badge-disqualified') : 'badge-inprogress'}">
                            <c:choose>
                                <c:when test="${attempt.status eq 'IN_PROGRESS'}">
                                    <i class="fas fa-spinner fa-spin"></i> In Progress
                                </c:when>
                                <c:when test="${attempt.passed}">
                                    <i class="fas fa-check-circle"></i> QUALIFIED
                                </c:when>
                                <c:otherwise>
                                    <i class="fas fa-times-circle"></i> DISQUALIFIED
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </div>

            <%-- View Result Button --%>
            <div>
                <c:if test="${attempt.status ne 'IN_PROGRESS'}">
                <a href="${pageContext.request.contextPath}/student/exam/result?attempt_id=${attempt.attemptId}"
                   class="btn btn-secondary" style="white-space:nowrap">
                    <i class="fas fa-eye"></i> View Details
                </a>
                </c:if>
                <c:if test="${attempt.status eq 'IN_PROGRESS'}">
                <a href="${pageContext.request.contextPath}/student/exam/take?attempt_id=${attempt.attemptId}"
                   class="btn btn-primary" style="white-space:nowrap">
                    <i class="fas fa-play"></i> Continue
                </a>
                </c:if>
            </div>
        </div>
        </c:forEach>
        </c:if>

        <c:if test="${empty myAttempts}">
        <div class="card" style="padding:60px;text-align:center">
            <i class="fas fa-clipboard-list" style="font-size:56px;color:var(--text-dim,#555);display:block;margin-bottom:16px"></i>
            <h3 style="margin-bottom:8px">No Exam Results Yet</h3>
            <p style="color:var(--text-muted);margin-bottom:24px">You haven't attempted any exams. Start a certification exam to track your progress.</p>
            <a href="${pageContext.request.contextPath}/student/exam/list" class="btn btn-primary">
                <i class="fas fa-laptop-code"></i> Browse Exams
            </a>
        </div>
        </c:if>
    </main>
</body>
</html>
