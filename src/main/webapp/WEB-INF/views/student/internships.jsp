<%-- Student Internship Listing Page --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Internships | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Internships"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Available Internships</h1>
                <p class="page-subtitle">Listings eligible for your CGPA of <strong>${student.formattedCgpa}</strong></p>
            </div>
        </div>

        <!-- Alert Messages -->
        <c:if test="${param.error eq 'already_applied'}">
            <div class="alert-message alert-error"><i class="fas fa-times-circle"></i> You have already applied for this internship.</div>
        </c:if>
        <c:if test="${param.error eq 'deadline_passed'}">
            <div class="alert-message alert-error"><i class="fas fa-clock"></i> The application deadline has passed.</div>
        </c:if>
        <c:if test="${param.error eq 'cgpa_low'}">
            <div class="alert-message alert-error"><i class="fas fa-exclamation-circle"></i> Your CGPA does not meet the requirement.</div>
        </c:if>
        <c:if test="${not empty param.success}">
            <div class="alert-message alert-success"><i class="fas fa-check-circle"></i> Application submitted successfully!</div>
        </c:if>

        <!-- Filter Row -->
        <div class="filter-row">
            <button class="filter-chip active" onclick="filterCards('all')">All Internships</button>
            <button class="filter-chip" onclick="filterCards('not_applied')">Not Applied</button>
            <button class="filter-chip" onclick="filterCards('applied')">Applied</button>
        </div>

        <!-- Internship Cards -->
        <c:if test="${empty internships}">
            <div class="card" style="padding:48px;text-align:center">
                <i class="fas fa-search" style="font-size:48px;color:var(--text-dim);margin-bottom:16px;display:block"></i>
                <h3 style="margin-bottom:8px">No Eligible Internships</h3>
                <p style="color:var(--text-muted)">There are no open internships matching your CGPA at this time. Check back later!</p>
            </div>
        </c:if>

        <div class="internship-grid" id="internshipGrid">
            <c:forEach var="intern" items="${internships}">
            <div class="internship-card" data-applied="${intern.hasApplied}">
                <!-- Company Header -->
                <div class="company-badge">
                    <div class="company-logo">🏢</div>
                    <div>
                        <div class="company-name">${intern.companyName}</div>
                        <div class="company-loc"><i class="fas fa-map-marker-alt"></i> ${intern.companyLocation}</div>
                    </div>
                    <c:if test="${intern.hasApplied}">
                        <span class="status-badge status-${intern.applicationStatus.toLowerCase()}" style="margin-left:auto">${intern.applicationStatus}</span>
                    </c:if>
                </div>

                <div class="internship-role">${intern.role}</div>
                <div class="internship-desc">${intern.description}</div>

                <div class="internship-meta">
                    <span class="meta-chip"><i class="fas fa-rupee-sign"></i>${intern.formattedStipend}</span>
                    <span class="meta-chip"><i class="fas fa-calendar-alt"></i>${intern.durationMonths} months</span>
                    <span class="meta-chip"><i class="fas fa-map-marker-alt"></i>${intern.location}</span>
                    <span class="meta-chip"><i class="fas fa-graduation-cap"></i>CGPA ≥ ${intern.eligibilityCgpa}</span>
                    <span class="meta-chip"><i class="fas fa-users"></i>${intern.seats} seats</span>
                    <span class="meta-chip deadline-chip">
                        <i class="fas fa-clock"></i>
                        Deadline: <fmt:formatDate xmlns:fmt="http://java.sun.com/jsp/jstl/fmt" value="${intern.deadline}" pattern="dd MMM yyyy"/>
                    </span>
                </div>

                <c:if test="${not empty intern.skillsRequired}">
                <div class="skills-display">
                    <span class="skills-label">Skills: </span>
                    <c:forTokens var="skill" items="${intern.skillsRequired}" delims=",">
                        <span class="skill-tag">${fn:trim(skill)}</span>
                    </c:forTokens>
                </div>
                </c:if>

                <div class="internship-actions">
                    <c:choose>
                        <c:when test="${intern.hasApplied}">
                            <button class="btn-apply applied" disabled>
                                <i class="fas fa-check"></i> Already Applied
                            </button>
                        </c:when>
                        <c:when test="${intern.deadlinePassed}">
                            <button class="btn-apply applied" disabled>
                                <i class="fas fa-calendar-times"></i> Deadline Passed
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button class="btn-apply" onclick="openApplyModal('${intern.internshipId}', '${intern.role}', '${intern.companyName}')">
                                <i class="fas fa-paper-plane"></i> Apply Now
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            </c:forEach>
        </div>
    </main>

    <!-- Apply Modal -->
    <div class="modal-overlay" id="applyModal" style="display:none">
        <div class="modal-box" style="text-align:left">
            <h3 style="margin-bottom:4px">Apply for Internship</h3>
            <p id="applyModalRole" style="color:var(--text-muted);margin-bottom:24px"></p>
            <form action="${pageContext.request.contextPath}/student/internships/apply" method="post">
                <input type="hidden" name="internship_id" id="applyInternshipId">
                <div class="form-group" style="margin-bottom:20px">
                    <label class="form-label">Cover Letter (Optional)</label>
                    <textarea name="cover_letter" class="form-control"
                              rows="5"
                              placeholder="Briefly describe why you are a good fit for this role..."></textarea>
                </div>
                <div class="modal-actions" style="justify-content:flex-start">
                    <button type="button" class="btn-modal-cancel" onclick="closeApplyModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Submit Application
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    function openApplyModal(internshipId, role, company) {
        document.getElementById('applyInternshipId').value = internshipId;
        document.getElementById('applyModalRole').textContent = role + ' @ ' + company;
        document.getElementById('applyModal').style.display = 'flex';
    }
    function closeApplyModal() {
        document.getElementById('applyModal').style.display = 'none';
    }
    function filterCards(type) {
        document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
        event.target.classList.add('active');
        const cards = document.querySelectorAll('.internship-card');
        cards.forEach(card => {
            const applied = card.dataset.applied === 'true';
            card.style.display =
                type === 'all' ? 'flex' :
                type === 'applied' && applied ? 'flex' :
                type === 'not_applied' && !applied ? 'flex' : 'none';
        });
    }
    </script>
    <style>
    .skills-display { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 16px; align-items: center; }
    .skills-label   { font-size: 12px; color: var(--text-muted); }
    .skill-tag {
        padding: 3px 10px; border-radius: 4px;
        font-size: 12px; font-weight: 600;
        background: rgba(76,201,240,.1);
        color: var(--accent2);
        border: 1px solid rgba(76,201,240,.2);
    }
    .deadline-chip { color: var(--secondary) !important; }
    </style>
</body>
</html>
