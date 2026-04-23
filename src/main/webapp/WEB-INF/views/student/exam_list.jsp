<%-- Student Exam List - with attempt history --%>
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
    <style>
        .exam-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
        .exam-card {
            background: var(--bg-card, #1e2235);
            border: 1px solid var(--border-light, rgba(255,255,255,.08));
            border-radius: 18px; padding: 26px;
            display: flex; flex-direction: column; gap: 16px;
            transition: transform .2s, box-shadow .2s;
            position: relative; overflow: hidden;
        }
        .exam-card:hover { transform: translateY(-3px); box-shadow: 0 12px 40px rgba(0,0,0,.3); }
        .exam-card::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }
        .exam-card.attempted::before { background: linear-gradient(90deg, #43e97b, #38f9d7); }
        .exam-card.failed::before { background: linear-gradient(90deg, #ff6584, #ff4b2b); }
        .exam-header { display: flex; justify-content: space-between; align-items: flex-start; }
        .exam-name { font-size: 16px; font-weight: 700; margin-bottom: 4px; }
        .exam-desc { font-size: 13px; color: var(--text-muted, #888); line-height: 1.5; }
        .exam-meta { display: flex; gap: 14px; flex-wrap: wrap; font-size: 13px; color: var(--text-muted,#888); }
        .meta-item { display: flex; align-items: center; gap: 5px; }
        .result-bar {
            border-radius: 10px; padding: 12px 16px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .result-bar.qualified { background: rgba(67,233,123,.1); border: 1px solid rgba(67,233,123,.25); }
        .result-bar.disqualified { background: rgba(255,101,132,.1); border: 1px solid rgba(255,101,132,.25); }
        .result-bar.inprogress { background: rgba(246,211,101,.1); border: 1px solid rgba(246,211,101,.25); }
        .result-score { font-size: 22px; font-weight: 800; }
        .result-verdict { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; }
        .qualified .result-score, .qualified .result-verdict { color: #43e97b; }
        .disqualified .result-score, .disqualified .result-verdict { color: #ff6584; }
        .inprogress .result-score, .inprogress .result-verdict { color: #f6d365; }
        .btn-start-exam {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 12px; border-radius: 10px; font-weight: 600; font-size: 14px;
            border: none; cursor: pointer; width: 100%; transition: all .2s;
            background: linear-gradient(135deg, #667eea, #764ba2); color: #fff;
        }
        .btn-start-exam:hover { opacity: .85; transform: scale(1.01); }
        .btn-view-result {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 10px; border-radius: 10px; font-weight: 600; font-size: 13px;
            border: 1px solid var(--border-light, rgba(255,255,255,.12)); cursor: pointer;
            width: 100%; transition: all .2s; background: transparent;
            color: var(--text-light, #ccc); text-decoration: none;
        }
        .btn-view-result:hover { background: rgba(255,255,255,.06); }
        .btn-disabled {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 12px; border-radius: 10px; font-weight: 600; font-size: 14px;
            border: 1px solid var(--border-light, rgba(255,255,255,.1));
            width: 100%; background: transparent; color: var(--text-dim, #555); cursor: not-allowed;
        }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header" style="display:flex;justify-content:space-between;align-items:center">
            <div>
                <h1 class="page-title">Certification Exams</h1>
                <p class="page-subtitle">5 Exams Available · Score 12/20 or above to Qualify</p>
            </div>
            <a href="${pageContext.request.contextPath}/student/results" class="btn btn-secondary">
                <i class="fas fa-chart-bar"></i> My Results
            </a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert-message alert-error" style="margin-bottom:16px">
                <i class="fas fa-exclamation-circle"></i> ${param.error}
            </div>
        </c:if>

        <%-- Build a map of user's attempts keyed by exam_id for quick lookup --%>
        <c:set var="attemptMap" value="${myAttemptMap}"/>

        <div class="exam-grid">
            <c:forEach var="exam" items="${exams}">

            <%-- Determine if student has an attempt for this exam --%>
            <c:set var="myAttempt" value="${null}"/>
            <c:forEach var="att" items="${myAttempts}">
                <c:if test="${att.examId eq exam.examId}">
                    <c:set var="myAttempt" value="${att}"/>
                </c:if>
            </c:forEach>

            <c:set var="isSubmitted" value="${myAttempt ne null and (myAttempt.status eq 'SUBMITTED' or myAttempt.status eq 'AUTO_SUBMITTED')}"/>
            <c:set var="isInProgress" value="${myAttempt ne null and myAttempt.status eq 'IN_PROGRESS'}"/>

            <div class="exam-card ${isSubmitted ? (myAttempt.passed ? 'attempted' : 'failed') : ''}">
                <%-- Header --%>
                <div class="exam-header">
                    <div style="flex:1">
                        <div class="exam-name">${exam.examName}</div>
                        <div class="exam-desc">${exam.description}</div>
                    </div>
                    <span class="status-badge status-${exam.status.toLowerCase()}" style="flex-shrink:0;margin-left:10px">${exam.status}</span>
                </div>

                <%-- Meta --%>
                <div class="exam-meta">
                    <div class="meta-item"><i class="fas fa-clock" style="color:var(--primary)"></i>${exam.duration} mins</div>
                    <div class="meta-item"><i class="fas fa-question-circle" style="color:#764ba2"></i>${exam.totalQuestions} questions</div>
                    <div class="meta-item"><i class="fas fa-trophy" style="color:#f6d365"></i>Pass: ${exam.passingMarks}/${exam.totalMarks}</div>
                </div>

                <%-- Result bar if attempted --%>
                <c:if test="${isSubmitted}">
                <div class="result-bar ${myAttempt.passed ? 'qualified' : 'disqualified'}">
                    <div>
                        <div class="result-score">${myAttempt.totalScore} / ${exam.totalMarks}</div>
                        <div class="result-verdict">
                            <i class="fas ${myAttempt.passed ? 'fa-check-circle' : 'fa-times-circle'}"></i>
                            ${myAttempt.passed ? 'QUALIFIED' : 'DISQUALIFIED'}
                        </div>
                    </div>
                    <i class="fas ${myAttempt.passed ? 'fa-medal' : 'fa-book-open'}" style="font-size:28px;opacity:.6"></i>
                </div>
                </c:if>
                <c:if test="${isInProgress}">
                <div class="result-bar inprogress">
                    <div>
                        <div class="result-score">In Progress</div>
                        <div class="result-verdict"><i class="fas fa-spinner fa-spin"></i> Resume Exam</div>
                    </div>
                </div>
                </c:if>

                <%-- Action Button --%>
                <div>
                    <c:choose>
                        <c:when test="${isSubmitted}">
                            <a href="${pageContext.request.contextPath}/student/exam/result?attempt_id=${myAttempt.attemptId}"
                               class="btn-view-result">
                                <i class="fas fa-eye"></i> View Result
                            </a>
                        </c:when>
                        <c:when test="${isInProgress}">
                            <form action="${pageContext.request.contextPath}/student/exam/start" method="get">
                                <input type="hidden" name="exam_id" value="${exam.examId}">
                                <button type="submit" class="btn-start-exam">
                                    <i class="fas fa-play-circle"></i> Resume Exam
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${exam.status eq 'ACTIVE'}">
                            <form action="${pageContext.request.contextPath}/student/exam/start" method="get">
                                <input type="hidden" name="exam_id" value="${exam.examId}">
                                <button type="submit" class="btn-start-exam">
                                    <i class="fas fa-play-circle"></i> Start Exam
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <button class="btn-disabled" disabled>
                                <i class="fas fa-lock"></i>
                                ${exam.status eq 'SCHEDULED' ? 'Scheduled — Not Yet Open' : 'Exam Closed'}
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            </c:forEach>

            <c:if test="${empty exams}">
                <div class="exam-card" style="grid-column:1/-1;padding:48px;text-align:center">
                    <i class="fas fa-file-alt" style="font-size:48px;color:var(--text-dim,#555);display:block;margin-bottom:16px"></i>
                    <h3 style="margin-bottom:8px">No Exams Available</h3>
                    <p style="color:var(--text-muted)">No exams are currently available. Check back later.</p>
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>
