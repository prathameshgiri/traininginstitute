<%-- Online Exam Taking Page - Training Institute Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Exam: ${attempt.examName} | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/exam.css">
</head>
<body class="exam-body" id="examBody">

    <!-- EXAM HEADER (fixed) -->
    <header class="exam-header">
        <div class="exam-title-section">
            <div class="exam-icon">📝</div>
            <div>
                <h2 class="exam-heading">${attempt.examName}</h2>
                <p class="exam-meta">${attempt.totalMarks} Marks &nbsp;|&nbsp; ${totalQ} Questions</p>
            </div>
        </div>

        <!-- Timer -->
        <div class="exam-timer" id="timerBox">
            <i class="fas fa-clock"></i>
            <span id="timerDisplay" class="timer-text">--:--</span>
        </div>

        <!-- Submit Button -->
        <button class="btn-submit-exam" onclick="confirmSubmit()" id="submitBtn">
            <i class="fas fa-paper-plane"></i> Submit Exam
        </button>
    </header>

    <!-- TAB SWITCH WARNING BANNER -->
    <div class="tab-warning" id="tabWarning" style="display:none">
        <i class="fas fa-exclamation-triangle"></i>
        <strong>Warning!</strong> Tab switch detected. This activity is logged.
        Tab switches: <span id="switchCountDisplay">0</span>/5
        <button onclick="dismissWarning()">✕</button>
    </div>

    <div class="exam-layout">
        <!-- LEFT: Question Panel -->
        <div class="question-panel">
            <!-- Question Navigation Pills -->
            <div class="q-nav-panel">
                <div class="q-nav-header">
                    <span>Questions</span>
                    <div class="q-legend">
                        <span class="leg-answered">Answered</span>
                        <span class="leg-marked">Marked</span>
                        <span class="leg-unanswered">Not visited</span>
                    </div>
                </div>
                <div class="q-nav-grid" id="qNavGrid">
                    <c:forEach var="q" items="${questions}" varStatus="status">
                    <button class="q-nav-btn
                        ${q.answered ? 'answered' : ''}
                        ${q.markedReview ? 'marked' : ''}
                        ${status.index == currentQ ? 'current' : ''}"
                        onclick="navigateTo(${status.index})"
                        id="qBtn${status.index}"
                        title="Q${status.count}: ${q.type}">
                        ${status.count}
                    </button>
                    </c:forEach>
                </div>
            </div>

            <!-- Status Summary -->
            <div class="q-summary">
                <div class="summary-item">
                    <span class="summary-num" id="answeredCount">0</span>
                    <span class="summary-lbl">Answered</span>
                </div>
                <div class="summary-item">
                    <span class="summary-num" id="markedCount">0</span>
                    <span class="summary-lbl">Marked</span>
                </div>
                <div class="summary-item">
                    <span class="summary-num" id="unansweredCount">${totalQ}</span>
                    <span class="summary-lbl">Remaining</span>
                </div>
            </div>
        </div>

        <!-- RIGHT: Current Question -->
        <div class="question-area">
            <c:forEach var="q" items="${questions}" varStatus="status">
            <div class="question-card ${status.index == currentQ ? 'active' : ''}"
                 id="qCard${status.index}" data-qindex="${status.index}">

                <!-- Question Header -->
                <div class="q-header">
                    <div class="q-number">
                        <span>Q ${status.count}</span>
                        <span class="q-type-badge ${q.type.toLowerCase()}">${q.type}</span>
                    </div>
                    <div class="q-marks">${q.marks} mark${q.marks > 1 ? 's' : ''}</div>
                </div>

                <!-- Question Text -->
                <div class="q-text">${q.questionText}</div>

                <c:if test="${not empty q.imagePath}">
                    <img src="${pageContext.request.contextPath}/${q.imagePath}" class="q-image" alt="Question Image">
                </c:if>

                <!-- MCQ Options -->
                <c:if test="${q.type eq 'MCQ'}">
                <div class="options-grid" id="opts${status.index}">
                    <c:forEach var="opt" items="${q.options}">
                    <label class="option-label ${q.selectedOption eq opt.optionId ? 'selected' : ''}"
                           id="optLabel_${opt.optionId}">
                        <input type="radio"
                               name="option_${status.index}"
                               value="${opt.optionId}"
                               ${q.selectedOption eq opt.optionId ? 'checked' : ''}
                               onchange="saveAnswer(${status.index}, ${q.questionId}, ${opt.optionId}, null)"
                               class="option-radio">
                        <span class="option-letter">${opt.optionLabel}</span>
                        <span class="option-text">${opt.optionText}</span>
                    </label>
                    </c:forEach>
                </div>
                </c:if>

                <!-- Subjective Answer -->
                <c:if test="${q.type eq 'SUBJECTIVE'}">
                <div class="subjective-area">
                    <label class="subj-label">Your Answer:</label>
                    <textarea class="subj-textarea"
                              id="subj_${status.index}"
                              rows="8"
                              placeholder="Type your detailed answer here..."
                              onkeyup="debouncedSave(${status.index}, ${q.questionId})">${q.descriptiveAnswer}</textarea>
                    <div class="char-count"><span id="charCount${status.index}">0</span> characters</div>
                </div>
                </c:if>

                <!-- Question Footer Actions -->
                <div class="q-actions">
                    <button class="btn-mark-review ${q.markedReview ? 'marked' : ''}"
                            onclick="toggleMarkReview(${status.index}, ${q.questionId})"
                            id="markBtn${status.index}">
                        <i class="fas fa-flag"></i>
                        <span id="markText${status.index}">${q.markedReview ? 'Unmark Review' : 'Mark for Review'}</span>
                    </button>
                    <div class="nav-btns">
                        <c:if test="${status.index > 0}">
                        <button class="btn-nav prev" onclick="navigateTo(${status.index - 1})">
                            <i class="fas fa-chevron-left"></i> Previous
                        </button>
                        </c:if>
                        <c:if test="${status.index < totalQ - 1}">
                        <button class="btn-nav next" onclick="navigateTo(${status.index + 1})">
                            Next <i class="fas fa-chevron-right"></i>
                        </button>
                        </c:if>
                    </div>
                </div>

                <!-- Auto-save indicator -->
                <div class="autosave-indicator" id="saveInd${status.index}">
                    <i class="fas fa-circle-notch fa-spin"></i> Saving...
                </div>
            </div>
            </c:forEach>
        </div>
    </div>

    <!-- Confirm Submit Modal -->
    <div class="modal-overlay" id="submitModal" style="display:none">
        <div class="modal-box">
            <div class="modal-icon">📋</div>
            <h3>Submit Exam?</h3>
            <p>Once submitted, you cannot change your answers.</p>
            <div class="modal-stats">
                <div>Answered: <strong id="modalAnswered">0</strong></div>
                <div>Marked for Review: <strong id="modalMarked">0</strong></div>
                <div>Unanswered: <strong id="modalUnanswered">${totalQ}</strong></div>
            </div>
            <div class="modal-actions">
                <button class="btn-modal-cancel" onclick="closeSubmitModal()">Continue Exam</button>
                <form action="${pageContext.request.contextPath}/student/exam/submit" method="post" style="display:inline">
                    <input type="hidden" name="attempt_id" value="${attempt.attemptId}">
                    <button type="submit" class="btn-modal-submit">
                        <i class="fas fa-paper-plane"></i> Yes, Submit
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
    const ATTEMPT_ID   = ${attempt.attemptId};
    const TOTAL_Q      = ${totalQ};
    const CTX          = '${pageContext.request.contextPath}';
    let currentIndex   = ${currentQ};
    let remainingSecs  = ${remainingSeconds};
    let tabSwitches    = 0;
    let saveTimers     = {};

    // ============================================================
    // TIMER
    // ============================================================
    function updateTimer() {
        if (remainingSecs <= 0) {
            document.getElementById('timerDisplay').textContent = '00:00';
            document.getElementById('timerBox').classList.add('expired');
            autoSubmitExam();
            return;
        }
        const m = Math.floor(remainingSecs / 60);
        const s = remainingSecs % 60;
        document.getElementById('timerDisplay').textContent =
            String(m).padStart(2,'0') + ':' + String(s).padStart(2,'0');

        if (remainingSecs <= 300) document.getElementById('timerBox').classList.add('warning');
        if (remainingSecs <= 60)  document.getElementById('timerBox').classList.add('critical');
        remainingSecs--;
    }

    setInterval(updateTimer, 1000);
    updateTimer();

    // Sync timer with server every 30s
    setInterval(() => {
        fetch(CTX + '/student/exam/time?attempt_id=' + ATTEMPT_ID)
            .then(r => r.json())
            .then(data => {
                if (data.isExpired || data.autoSubmitted) {
                    window.location.href = CTX + '/student/exam/result?attempt_id=' + ATTEMPT_ID + '&auto=true';
                } else {
                    remainingSecs = parseInt(data.remaining);
                }
            });
    }, 30000);

    // ============================================================
    // NAVIGATION
    // ============================================================
    function navigateTo(index) {
        document.querySelector('.question-card.active')?.classList.remove('active');
        document.getElementById('qCard' + index)?.classList.add('active');

        document.querySelector('.q-nav-btn.current')?.classList.remove('current');
        document.getElementById('qBtn' + index)?.classList.add('current');

        currentIndex = index;
        updateCounts();
    }

    // ============================================================
    // SAVE ANSWER (AJAX)
    // ============================================================
    function saveAnswer(qIndex, questionId, selectedOption, descriptiveAnswer) {
        const ind = document.getElementById('saveInd' + qIndex);
        if (ind) { ind.classList.add('visible'); }

        const body = new URLSearchParams({
            attempt_id: ATTEMPT_ID,
            question_id: questionId,
            is_marked_review: document.getElementById('markBtn' + qIndex)?.classList.contains('marked') ? 'true' : 'false'
        });
        if (selectedOption !== null) body.append('selected_option', selectedOption);
        if (descriptiveAnswer !== null) body.append('descriptive_answer', descriptiveAnswer);

        fetch(CTX + '/student/exam/save-answer', { method:'POST', body })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    // Mark nav button as answered
                    const btn = document.getElementById('qBtn' + qIndex);
                    if (btn) { btn.classList.add('answered'); btn.classList.remove('unanswered'); }
                    updateCounts();
                }
                if (ind) setTimeout(() => ind.classList.remove('visible'), 1500);
            })
            .catch(() => { if (ind) ind.classList.remove('visible'); });

        // Update selected option highlight
        if (selectedOption !== null) {
            document.querySelectorAll('[name="option_' + qIndex + '"] + .option-label, .option-label').forEach(l => l.classList.remove('selected'));
            document.querySelectorAll(`#opts${qIndex} .option-label`).forEach(l => l.classList.remove('selected'));
            const radio = document.querySelector(`input[value="${selectedOption}"]`);
            if (radio) radio.closest('.option-label').classList.add('selected');
        }
    }

    // Attach to radio buttons via event delegation
    document.querySelectorAll('.option-radio').forEach(radio => {
        radio.addEventListener('change', function() {
            const label = this.closest('.option-label');
            const grid  = this.closest('.options-grid');
            grid.querySelectorAll('.option-label').forEach(l => l.classList.remove('selected'));
            label.classList.add('selected');
        });
    });

    // Debounced save for subjective
    const debounceTimers = {};
    function debouncedSave(qIndex, questionId) {
        clearTimeout(debounceTimers[qIndex]);
        const ta = document.getElementById('subj_' + qIndex);
        const cc = document.getElementById('charCount' + qIndex);
        if (cc && ta) cc.textContent = ta.value.length;
        debounceTimers[qIndex] = setTimeout(() => {
            saveAnswer(qIndex, questionId, null, ta ? ta.value : '');
        }, 1500);
    }

    // ============================================================
    // MARK FOR REVIEW
    // ============================================================
    function toggleMarkReview(qIndex, questionId) {
        const btn  = document.getElementById('markBtn' + qIndex);
        const text = document.getElementById('markText' + qIndex);
        const navBtn = document.getElementById('qBtn' + qIndex);
        const isMarked = !btn.classList.contains('marked');

        btn.classList.toggle('marked', isMarked);
        navBtn.classList.toggle('marked', isMarked);
        text.textContent = isMarked ? 'Unmark Review' : 'Mark for Review';

        // Save with mark flag
        const body = new URLSearchParams({
            attempt_id: ATTEMPT_ID,
            question_id: questionId,
            is_marked_review: isMarked
        });
        fetch(CTX + '/student/exam/save-answer', { method:'POST', body });
        updateCounts();
    }

    // ============================================================
    // ANTI-CHEAT: TAB SWITCH DETECTION
    // ============================================================
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            tabSwitches++;
            document.getElementById('switchCountDisplay').textContent = tabSwitches;
            document.getElementById('tabWarning').style.display = 'flex';

            fetch(CTX + '/student/exam/tab-switch', {
                method: 'POST',
                body: new URLSearchParams({ attempt_id: ATTEMPT_ID })
            }).then(r => r.json()).then(data => {
                if (data.autoSubmitted) {
                    alert('Exam auto-submitted due to repeated violations.');
                    window.location.href = CTX + '/student/exam/result?attempt_id=' + ATTEMPT_ID;
                }
            });
        }
    });

    function dismissWarning() {
        document.getElementById('tabWarning').style.display = 'none';
    }

    // Prevent right-click
    document.addEventListener('contextmenu', e => e.preventDefault());

    // Prevent copy-paste during exam
    document.addEventListener('copy', e => e.preventDefault());

    // ============================================================
    // COUNTS
    // ============================================================
    function updateCounts() {
        const answered  = document.querySelectorAll('.q-nav-btn.answered').length;
        const marked    = document.querySelectorAll('.q-nav-btn.marked').length;
        const remaining = TOTAL_Q - answered;
        document.getElementById('answeredCount').textContent  = answered;
        document.getElementById('markedCount').textContent    = marked;
        document.getElementById('unansweredCount').textContent= remaining;
        if (document.getElementById('modalAnswered'))  document.getElementById('modalAnswered').textContent  = answered;
        if (document.getElementById('modalMarked'))    document.getElementById('modalMarked').textContent    = marked;
        if (document.getElementById('modalUnanswered'))document.getElementById('modalUnanswered').textContent= remaining;
    }
    updateCounts();

    // ============================================================
    // SUBMIT MODAL
    // ============================================================
    function confirmSubmit() {
        updateCounts();
        document.getElementById('submitModal').style.display = 'flex';
    }
    function closeSubmitModal() {
        document.getElementById('submitModal').style.display = 'none';
    }

    function autoSubmitExam() {
        fetch(CTX + '/student/exam/save-answer', { method:'POST',
            body: new URLSearchParams({ attempt_id: ATTEMPT_ID, question_id: -1 })
        }).finally(() => {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = CTX + '/student/exam/submit';
            const inp = document.createElement('input');
            inp.type = 'hidden'; inp.name = 'attempt_id'; inp.value = ATTEMPT_ID;
            form.appendChild(inp); document.body.appendChild(form); form.submit();
        });
    }

    // Char count init for subjective
    document.querySelectorAll('.subj-textarea').forEach((ta, idx) => {
        const cc = document.getElementById('charCount' + idx);
        if (cc) cc.textContent = ta.value.length;
    });
    </script>
</body>
</html>
