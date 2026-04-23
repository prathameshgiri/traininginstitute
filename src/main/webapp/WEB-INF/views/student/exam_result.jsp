<%-- Exam Result Page - QUALIFIED / DISQUALIFIED --%>
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
    <style>
        .result-hero {
            border-radius: 20px;
            padding: 52px 40px;
            text-align: center;
            margin-bottom: 28px;
            position: relative;
            overflow: hidden;
        }
        .result-hero.qualified {
            background: linear-gradient(135deg, rgba(67,233,123,.12), rgba(56,249,215,.08));
            border: 2px solid rgba(67,233,123,.35);
        }
        .result-hero.disqualified {
            background: linear-gradient(135deg, rgba(255,101,132,.12), rgba(255,75,43,.08));
            border: 2px solid rgba(255,101,132,.35);
        }
        .verdict-text {
            font-size: 42px;
            font-weight: 900;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .verdict-qualified { color: #43e97b; }
        .verdict-disqualified { color: #ff6584; }
        .score-big {
            font-size: 72px;
            font-weight: 900;
            line-height: 1;
            margin: 20px 0 4px;
        }
        .score-big.qualified { color: #43e97b; }
        .score-big.disqualified { color: #ff6584; }
        .score-sub { font-size: 18px; color: var(--text-muted, #888); margin-bottom: 24px; }
        .criteria-note {
            display: inline-block;
            background: rgba(255,255,255,.06);
            border-radius: 30px;
            padding: 8px 24px;
            font-size: 14px;
            color: var(--text-muted, #888);
        }
        .criteria-note strong { color: var(--text-light, #ccc); }
        .stats-strip {
            display: flex; justify-content: center; gap: 40px; flex-wrap: wrap;
            margin: 32px 0 0;
        }
        .stat-box { text-align: center; }
        .stat-box .val { font-size: 28px; font-weight: 800; }
        .stat-box .lbl { font-size: 12px; color: var(--text-muted, #888); text-transform: uppercase; letter-spacing: .6px; }
        .confetti { font-size: 52px; display: block; margin-bottom: 12px; animation: bounce 1s ease infinite alternate; }
        @keyframes bounce { from { transform: scale(1); } to { transform: scale(1.12); } }
        .q-review-item {
            background: var(--bg-input, #252840);
            border: 1px solid var(--border-light, rgba(255,255,255,.08));
            border-radius: 12px; padding: 20px; margin-bottom: 14px;
        }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <a href="${pageContext.request.contextPath}/student/results" class="btn-link" style="display:block;margin-bottom:8px">
                    ← My Results
                </a>
                <h1 class="page-title">Exam Result</h1>
                <p class="page-subtitle">${exam.examName}</p>
            </div>
        </div>

        <%-- RESULT HERO --%>
        <div class="result-hero ${attempt.passed ? 'qualified' : 'disqualified'}">
            <c:choose>
                <c:when test="${attempt.passed}">
                    <span class="confetti">🎉</span>
                    <div class="verdict-text verdict-qualified">
                        <i class="fas fa-check-circle"></i> QUALIFIED
                    </div>
                    <p style="color:var(--text-muted);margin-bottom:0">Congratulations! You have successfully passed the certification exam.</p>
                </c:when>
                <c:otherwise>
                    <span class="confetti" style="animation:none">📚</span>
                    <div class="verdict-text verdict-disqualified">
                        <i class="fas fa-times-circle"></i> DISQUALIFIED
                    </div>
                    <p style="color:var(--text-muted);margin-bottom:0">You did not meet the passing criteria. Keep practising and try again!</p>
                </c:otherwise>
            </c:choose>

            <div class="score-big ${attempt.passed ? 'qualified' : 'disqualified'}">
                ${attempt.totalScore}
            </div>
            <div class="score-sub">out of ${exam.totalMarks} marks</div>

            <div class="criteria-note">
                Pass Criteria: <strong>${exam.passingMarks} / ${exam.totalMarks}</strong> correct answers required
            </div>

            <div class="stats-strip">
                <div class="stat-box">
                    <div class="val">${attempt.mcqScore}</div>
                    <div class="lbl">Correct</div>
                </div>
                <div class="stat-box">
                    <div class="val">${exam.totalMarks - attempt.mcqScore}</div>
                    <div class="lbl">Incorrect</div>
                </div>
                <div class="stat-box">
                    <div class="val">${exam.passingMarks}</div>
                    <div class="lbl">Pass Mark</div>
                </div>
                <div class="stat-box">
                    <div class="val">${attempt.tabSwitchCount}</div>
                    <div class="lbl">Tab Switches</div>
                </div>
            </div>
        </div>

        <%-- Action Buttons --%>
        <div style="display:flex;gap:12px;justify-content:center;margin-bottom:28px">
            <a href="${pageContext.request.contextPath}/student/results" class="btn btn-secondary">
                <i class="fas fa-list"></i> All My Results
            </a>
            <a href="${pageContext.request.contextPath}/student/exam/list" class="btn btn-primary">
                <i class="fas fa-laptop-code"></i> Browse Exams
            </a>
        </div>

        <%-- Answer Review --%>
        <div class="card">
            <div class="card-header">
                <h3><i class="fas fa-list-check"></i> Answer Review</h3>
            </div>
            <div class="card-body">
                <c:forEach var="q" items="${answers}" varStatus="s">
                <div class="q-review-item">
                    <div style="display:flex;justify-content:space-between;margin-bottom:10px">
                        <span style="font-weight:700">
                            Q${s.count}.
                            <span class="badge ${q.type eq 'MCQ' ? 'badge-primary' : 'badge-info'}">${q.type}</span>
                        </span>
                        <span style="font-weight:700;
                            color:${q.marksAwarded > 0 ? '#43e97b' : '#ff6584'}">
                            ${q.marksAwarded} / ${q.marks}
                            <c:if test="${q.marksAwarded > 0}"> <i class="fas fa-check"></i></c:if>
                            <c:if test="${q.marksAwarded <= 0 and not empty q.selectedOption}"> <i class="fas fa-times"></i></c:if>
                        </span>
                    </div>
                    <p style="color:var(--text-light);margin-bottom:10px">${q.questionText}</p>
                    <c:if test="${not empty q.descriptiveAnswer}">
                        <p style="color:var(--text-muted);font-size:13px;padding:10px;background:var(--bg-dark);border-radius:8px">${q.descriptiveAnswer}</p>
                    </c:if>
                </div>
                </c:forEach>
                <c:if test="${empty answers}">
                    <p style="text-align:center;color:var(--text-muted);padding:24px">No answers recorded.</p>
                </c:if>
            </div>
        </div>
    </main>
</body>
</html>
