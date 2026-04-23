<%-- Admin Exams Management - Full Question Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Exams | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Exams"/>
    <style>
        .exam-row { cursor:pointer; transition: background 0.2s; }
        .exam-row:hover { background: rgba(var(--primary-rgb, 102,126,234), 0.08); }
        .exam-row.selected { background: rgba(var(--primary-rgb, 102,126,234), 0.15); }
        .q-panel { background: var(--bg-card, #1e2235); border-radius: 16px; padding: 28px; margin-top: 24px; }
        .q-panel-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
        .q-item { background: var(--bg-input, #252840); border:1px solid var(--border-light, rgba(255,255,255,.08));
                  border-radius:12px; padding:16px 20px; margin-bottom:12px; display:flex;
                  justify-content:space-between; align-items:flex-start; gap:12px; }
        .q-item-left { flex:1; }
        .q-item-text { font-weight:500; margin-bottom:8px; }
        .q-item-opts { display:flex; gap:10px; flex-wrap:wrap; }
        .opt-chip { font-size:12px; padding:3px 10px; border-radius:20px;
                    background:rgba(255,255,255,.06); color:var(--text-muted,#888); }
        .opt-chip.correct { background:rgba(67,233,123,.15); color:#43e97b; }
        .q-del-btn { background:rgba(255,101,132,.15); border:none; color:#ff6584;
                     border-radius:8px; padding:6px 12px; cursor:pointer; font-size:12px;
                     transition:all .2s; white-space:nowrap; }
        .q-del-btn:hover { background:rgba(255,101,132,.3); }
        .badge-mcq { background:rgba(102,126,234,.2); color:#667eea; font-size:11px;
                     padding:2px 8px; border-radius:10px; }
        .exam-status-active  { color:#43e97b; }
        .exam-status-scheduled { color:#f6d365; }
        .count-badge { background: var(--primary,#667eea); color:#fff; font-size:11px;
                       padding:2px 8px; border-radius:10px; margin-left:8px; }
        .qualify-note { font-size:13px; color:var(--text-muted,#888); margin-top:4px; }
        .section-divider { border:none; border-top:1px solid var(--border-light,rgba(255,255,255,.08));
                           margin:24px 0; }
    </style>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h1 class="page-title">Exam Management</h1>
                <p class="page-subtitle">5 Certification Exams · 20 Questions Each · Qualify at 12+</p>
            </div>
            <button class="btn btn-primary" id="btnAddExam" onclick="document.getElementById('addModal').style.display='flex'">
                <i class="fas fa-plus"></i> Add Exam
            </button>
        </div>

        <%-- Alerts --%>
        <c:if test="${not empty param.success}">
            <div class="alert-message alert-success" style="margin-bottom:16px">
                <i class="fas fa-check-circle"></i>
                <c:choose>
                    <c:when test="${param.success eq 'created'}">Exam created successfully!</c:when>
                    <c:when test="${param.success eq 'question_added'}">Question added successfully!</c:when>
                    <c:when test="${param.success eq 'question_deleted'}">Question deleted.</c:when>
                    <c:when test="${param.success eq 'exam_updated'}">Exam updated successfully!</c:when>
                    <c:otherwise>Operation successful.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-message alert-error" style="margin-bottom:16px">
                <i class="fas fa-exclamation-circle"></i> Error: ${param.error}
            </div>
        </c:if>

        <%-- Exam List Table --%>
        <div class="card">
            <div class="card-header"><h3><i class="fas fa-clipboard-list"></i> All Exams</h3></div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Exam Name</th>
                        <th>Duration</th>
                        <th>Marks (Pass / Total)</th>
                        <th>Questions</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="e" items="${exams}" varStatus="st">
                    <tr class="exam-row ${selectedExamId eq e.examId ? 'selected' : ''}">
                        <td>${st.count}</td>
                        <td>
                            <strong>${e.examName}</strong>
                            <div class="qualify-note">${e.description}</div>
                        </td>
                        <td>${e.duration} mins</td>
                        <td>
                            <strong>${e.passingMarks}</strong> / ${e.totalMarks}
                            <div class="qualify-note">${e.passingMarks}+ = Qualified</div>
                        </td>
                        <td>
                            <span class="count-badge">${e.totalQuestions}</span>
                        </td>
                        <td>
                            <span class="status-badge status-${e.status.toLowerCase()}">${e.status}</span>
                        </td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <a href="${pageContext.request.contextPath}/admin/exams?exam_id=${e.examId}"
                               class="btn btn-sm btn-secondary" title="Manage Questions">
                                <i class="fas fa-question-circle"></i> Questions
                            </a>
                            <button class="btn btn-sm btn-secondary"
                                    onclick="openEditExam(${e.examId},'${fn:escapeXml(e.examName)}','${fn:escapeXml(e.description)}',${e.duration},${e.totalMarks},${e.passingMarks},'${e.status}')"
                                    title="Edit Exam">
                                <i class="fas fa-edit"></i>
                            </button>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty exams}"><tr><td colspan="7" class="empty-state">No exams found.</td></tr></c:if>
                </tbody>
            </table>
        </div>

        <%-- ===== QUESTION MANAGEMENT PANEL ===== --%>
        <c:if test="${not empty selectedExam}">
        <div class="q-panel">
            <div class="q-panel-header">
                <div>
                    <h3 style="margin-bottom:4px">
                        <i class="fas fa-list-ol" style="color:var(--primary)"></i>
                        ${selectedExam.examName} — Questions
                        <span class="count-badge">${fn:length(examQuestions)} / 20</span>
                    </h3>
                    <p class="qualify-note">Pass mark: ${selectedExam.passingMarks} / ${selectedExam.totalMarks} &nbsp;|&nbsp; Status: ${selectedExam.status}</p>
                </div>
                <c:if test="${fn:length(examQuestions) < 20}">
                <button class="btn btn-primary" onclick="document.getElementById('addQModal').style.display='flex'">
                    <i class="fas fa-plus"></i> Add Question
                </button>
                </c:if>
                <c:if test="${fn:length(examQuestions) >= 20}">
                <span style="color:#43e97b;font-weight:600"><i class="fas fa-check-circle"></i> 20/20 Questions Ready</span>
                </c:if>
            </div>

            <c:if test="${empty examQuestions}">
                <div style="text-align:center;padding:40px;color:var(--text-muted)">
                    <i class="fas fa-inbox" style="font-size:40px;display:block;margin-bottom:12px"></i>
                    No questions yet. Add 20 MCQ questions to make this exam available.
                </div>
            </c:if>

            <c:forEach var="q" items="${examQuestions}" varStatus="qs">
            <div class="q-item">
                <div class="q-item-left">
                    <div class="q-item-text">
                        <span style="color:var(--text-muted);margin-right:8px">Q${qs.count}.</span>
                        <span class="badge-mcq">MCQ</span>
                        &nbsp;${q.questionText}
                    </div>
                    <div class="q-item-opts">
                        <c:forEach var="opt" items="${q.options}">
                            <span class="opt-chip ${opt.correct ? 'correct' : ''}">
                                ${opt.optionLabel}. ${opt.optionText}
                                <c:if test="${opt.correct}"> ✓</c:if>
                            </span>
                        </c:forEach>
                    </div>
                </div>
                <form action="${pageContext.request.contextPath}/admin/exams/questions/delete" method="post" style="display:inline"
                      onsubmit="return confirm('Delete this question?')">
                    <input type="hidden" name="question_id" value="${q.questionId}">
                    <input type="hidden" name="exam_id" value="${selectedExam.examId}">
                    <button type="submit" class="q-del-btn"><i class="fas fa-trash"></i> Delete</button>
                </form>
            </div>
            </c:forEach>

            <hr class="section-divider">
            <%-- Results section for this exam --%>
            <div style="text-align:right">
                <a href="${pageContext.request.contextPath}/admin/evaluate?exam_id=${selectedExam.examId}" class="btn btn-secondary">
                    <i class="fas fa-chart-bar"></i> View Student Results for this Exam
                </a>
            </div>
        </div>

        <%-- Add Question Modal (shown when exam is selected) --%>
        <div class="modal-overlay" id="addQModal" style="display:none">
            <div class="modal-box" style="text-align:left;max-width:620px;">
                <h3 style="margin-bottom:20px;font-weight:600">
                    <i class="fas fa-plus-circle" style="color:var(--primary)"></i>
                    Add Question — ${selectedExam.examName}
                </h3>
                <form action="${pageContext.request.contextPath}/admin/exams/questions/add" method="post">
                    <input type="hidden" name="exam_id" value="${selectedExam.examId}">
                    <input type="hidden" name="type" value="MCQ">
                    <input type="hidden" name="marks" value="1">
                    <input type="hidden" name="sequence_no" value="${fn:length(examQuestions) + 1}">

                    <div class="form-group" style="margin-bottom:14px">
                        <label class="form-label">Question Text *</label>
                        <textarea name="question_text" class="form-control" rows="3" required placeholder="Enter your MCQ question..."></textarea>
                    </div>

                    <div class="form-group" style="margin-bottom:14px">
                        <label class="form-label">Difficulty</label>
                        <select name="difficulty" class="form-control">
                            <option value="EASY">Easy</option>
                            <option value="MEDIUM" selected>Medium</option>
                            <option value="HARD">Hard</option>
                        </select>
                    </div>

                    <label class="form-label" style="margin-bottom:10px;display:block">Options (mark 1 correct) *</label>
                    <div style="display:grid;gap:10px;margin-bottom:18px">
                        <c:forEach begin="0" end="3" var="i">
                        <c:set var="labels" value="A,B,C,D"/>
                        <c:set var="lbl" value="${fn:split(labels,',')[i]}"/>
                        <div style="display:flex;align-items:center;gap:10px">
                            <input type="radio" name="correct_option" value="${i}" ${i eq 0 ? 'checked' : ''} required>
                            <span style="font-weight:600;color:var(--primary);min-width:18px">${lbl}.</span>
                            <input type="text" name="option_text" class="form-control" required
                                   placeholder="Option ${lbl} text..." style="flex:1">
                        </div>
                        </c:forEach>
                    </div>

                    <div style="display:flex;justify-content:flex-end;gap:10px">
                        <button type="button" class="btn-modal-cancel" onclick="document.getElementById('addQModal').style.display='none'">Cancel</button>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Question</button>
                    </div>
                </form>
            </div>
        </div>
        </c:if>

    </main>

    <%-- Create Exam Modal --%>
    <div class="modal-overlay" id="addModal" style="display:none">
        <div class="modal-box" style="text-align:left; max-width:520px;">
            <h3 style="margin-bottom:20px; font-weight:600;"><i class="fas fa-laptop-code" style="color:var(--primary)"></i> Create New Exam</h3>
            <form action="${pageContext.request.contextPath}/admin/exams/add" method="post">
                <div class="form-group" style="margin-bottom:14px">
                    <label class="form-label">Exam Name *</label>
                    <input type="text" name="exam_name" class="form-control" required placeholder="e.g. Java Fundamentals Exam">
                </div>
                <div class="form-group" style="margin-bottom:14px">
                    <label class="form-label">Description *</label>
                    <textarea name="description" class="form-control" rows="2" required></textarea>
                </div>
                <div class="form-group" style="margin-bottom:14px">
                    <label class="form-label">Linked Internship (optional)</label>
                    <select name="internship_id" class="form-control">
                        <option value="">None</option>
                        <c:forEach var="i" items="${internships}">
                            <option value="${i.internshipId}">${i.companyName} - ${i.role}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:14px">
                    <div class="form-group">
                        <label class="form-label">Duration (mins)</label>
                        <input type="number" name="duration" class="form-control" value="30" min="10" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Total Marks</label>
                        <input type="number" name="total_marks" class="form-control" value="20" min="1" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Pass Marks</label>
                        <input type="number" name="passing_marks" class="form-control" value="12" min="1" required>
                    </div>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:18px">
                    <div class="form-group">
                        <label class="form-label">Start Time</label>
                        <input type="datetime-local" name="start_time" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">End Time</label>
                        <input type="datetime-local" name="end_time" class="form-control" required>
                    </div>
                </div>
                <div style="display:flex;justify-content:flex-end;gap:10px">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('addModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Exam</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Edit Exam Modal --%>
    <div class="modal-overlay" id="editModal" style="display:none">
        <div class="modal-box" style="text-align:left;max-width:520px;">
            <h3 style="margin-bottom:20px;font-weight:600;"><i class="fas fa-edit" style="color:var(--primary)"></i> Edit Exam</h3>
            <form action="${pageContext.request.contextPath}/admin/exams/update" method="post">
                <input type="hidden" name="exam_id" id="editExamId">
                <div class="form-group" style="margin-bottom:14px">
                    <label class="form-label">Exam Name</label>
                    <input type="text" name="exam_name" id="editExamName" class="form-control" required>
                </div>
                <div class="form-group" style="margin-bottom:14px">
                    <label class="form-label">Description</label>
                    <textarea name="description" id="editExamDesc" class="form-control" rows="2"></textarea>
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:14px">
                    <div class="form-group">
                        <label class="form-label">Duration (mins)</label>
                        <input type="number" name="duration" id="editDuration" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Total Marks</label>
                        <input type="number" name="total_marks" id="editTotalMarks" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Pass Marks</label>
                        <input type="number" name="passing_marks" id="editPassMarks" class="form-control" required>
                    </div>
                </div>
                <div class="form-group" style="margin-bottom:18px">
                    <label class="form-label">Status</label>
                    <select name="status" id="editStatus" class="form-control">
                        <option value="SCHEDULED">SCHEDULED</option>
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="COMPLETED">COMPLETED</option>
                        <option value="CANCELLED">CANCELLED</option>
                    </select>
                </div>
                <div style="display:flex;justify-content:flex-end;gap:10px">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('editModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Update</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    function openEditExam(id, name, desc, dur, total, pass_, status) {
        document.getElementById('editExamId').value = id;
        document.getElementById('editExamName').value = name;
        document.getElementById('editExamDesc').value = desc;
        document.getElementById('editDuration').value = dur;
        document.getElementById('editTotalMarks').value = total;
        document.getElementById('editPassMarks').value = pass_;
        document.getElementById('editStatus').value = status;
        document.getElementById('editModal').style.display = 'flex';
    }
    // Auto-open question modal if success=question_added
    window.addEventListener('DOMContentLoaded', () => {
        const params = new URLSearchParams(window.location.search);
        if (params.get('success') === 'question_added' && document.getElementById('addQModal')) {
            // stay closed — user can click again
        }
    });
    </script>
</body>
</html>
