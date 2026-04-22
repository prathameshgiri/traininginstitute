<%-- Student Dashboard - Training Institute Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Student Dashboard | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Dashboard"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Welcome, ${student.name}! 👋</h1>
                <p class="page-subtitle">Your internship & exam journey at a glance</p>
            </div>
        </div>

        <!-- Profile Summary Card -->
        <div class="profile-hero-card">
            <div class="profile-avatar-lg">${student.name.charAt(0)}</div>
            <div class="profile-details">
                <h2>${student.name}</h2>
                <p>${student.email}</p>
                <div class="profile-chips">
                    <span class="meta-chip"><i class="fas fa-graduation-cap"></i>${student.course}</span>
                    <span class="meta-chip"><i class="fas fa-id-card"></i>${student.enrollmentNumber}</span>
                    <span class="meta-chip cgpa-chip"><i class="fas fa-star"></i>CGPA: ${student.formattedCgpa}</span>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/student/profile" class="btn btn-secondary btn-sm">
                <i class="fas fa-edit"></i> Edit Profile
            </a>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card stat-primary">
                <div class="stat-icon"><i class="fas fa-file-alt"></i></div>
                <div class="stat-info">
                    <h3>${myApplications.size()}</h3>
                    <p>Applications Submitted</p>
                </div>
            </div>
            <div class="stat-card stat-accent">
                <div class="stat-icon"><i class="fas fa-briefcase"></i></div>
                <div class="stat-info">
                    <h3>${openInternships.size()}</h3>
                    <p>Open Internships</p>
                </div>
            </div>
            <div class="stat-card stat-secondary">
                <div class="stat-icon"><i class="fas fa-star"></i></div>
                <div class="stat-info">
                    <h3>${student.formattedCgpa}</h3>
                    <p>Your CGPA</p>
                </div>
            </div>
            <div class="stat-card stat-warning">
                <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                <div class="stat-info">
                    <h3>
                        <c:set var="selectedCount" value="0"/>
                        <c:forEach var="app" items="${myApplications}">
                            <c:if test="${app.status eq 'SELECTED' or app.status eq 'CONFIRMED'}">
                                <c:set var="selectedCount" value="${selectedCount + 1}"/>
                            </c:if>
                        </c:forEach>
                        ${selectedCount}
                    </h3>
                    <p>Selections</p>
                </div>
            </div>
        </div>

        <!-- My Applications -->
        <div class="card full-width-card">
            <div class="card-header">
                <h3><i class="fas fa-file-alt"></i> My Applications</h3>
                <a href="${pageContext.request.contextPath}/student/internships" class="btn btn-primary btn-sm">
                    <i class="fas fa-search"></i> Browse Internships
                </a>
            </div>
            <div class="card-body p-0">
                <table class="data-table">
                    <thead><tr>
                        <th>Company / Role</th><th>Location</th><th>Applied On</th><th>Status</th>
                    </tr></thead>
                    <tbody>
                        <c:forEach var="app" items="${myApplications}">
                        <tr>
                            <td>
                                <div class="cell-name">${app.companyName}</div>
                                <div class="cell-sub">${app.internshipRole}</div>
                            </td>
                            <td>${app.internshipLocation}</td>
                            <td><fmt:formatDate value="${app.appliedDate}" pattern="dd MMM yyyy"/></td>
                            <td><span class="status-badge status-${app.status.toLowerCase()}">${app.status}</span></td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty myApplications}">
                            <tr><td colspan="4" class="empty-state">
                                <i class="fas fa-inbox" style="font-size:32px;display:block;margin-bottom:12px;color:var(--text-dim)"></i>
                                No applications yet. <a href="${pageContext.request.contextPath}/student/internships">Browse internships →</a>
                            </td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Available Internships Preview -->
        <div class="card full-width-card">
            <div class="card-header">
                <h3><i class="fas fa-briefcase"></i> Open Internships (Eligible for You)</h3>
                <a href="${pageContext.request.contextPath}/student/internships" class="btn-link">View All →</a>
            </div>
            <div class="card-body">
                <c:if test="${empty openInternships}">
                    <p class="empty-state">No eligible open internships at this time.</p>
                </c:if>
                <div class="internship-grid">
                    <c:forEach var="intern" items="${openInternships}" end="2">
                    <div class="internship-card">
                        <div class="company-badge">
                            <div class="company-logo">🏢</div>
                            <div>
                                <div class="company-name">${intern.companyName}</div>
                                <div class="company-loc"><i class="fas fa-map-marker-alt"></i> ${intern.location}</div>
                            </div>
                        </div>
                        <div class="internship-role">${intern.role}</div>
                        <div class="internship-meta">
                            <span class="meta-chip"><i class="fas fa-rupee-sign"></i>${intern.formattedStipend}</span>
                            <span class="meta-chip"><i class="fas fa-calendar"></i>${intern.durationMonths}mo</span>
                            <span class="meta-chip"><i class="fas fa-graduation-cap"></i>CGPA ≥ ${intern.eligibilityCgpa}</span>
                        </div>
                        <div class="internship-actions">
                            <a href="${pageContext.request.contextPath}/student/internships" class="btn-apply">Apply Now →</a>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </main>
    <style>
    .profile-hero-card {
        display: flex; align-items: center; gap: 24px;
        background: var(--bg-card);
        border: 1px solid var(--border-light);
        border-radius: var(--radius);
        padding: 28px 32px;
        margin-bottom: 28px;
        position: relative;
        overflow: hidden;
    }
    .profile-hero-card::before {
        content: '';
        position: absolute; top: 0; left: 0; right: 0; height: 4px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
    }
    .profile-avatar-lg {
        width: 72px; height: 72px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        display: flex; align-items: center; justify-content: center;
        font-size: 28px; font-weight: 800; color: #fff;
        flex-shrink: 0;
        box-shadow: 0 8px 24px rgba(108,99,255,.4);
    }
    .profile-details h2 { font-size: 20px; font-weight: 800; margin-bottom: 4px; }
    .profile-details p  { color: var(--text-muted); font-size: 14px; margin-bottom: 12px; }
    .profile-chips { display: flex; flex-wrap: wrap; gap: 8px; }
    .cgpa-chip { background: rgba(108,99,255,.15) !important; color: var(--primary) !important; font-weight: 700; }
    </style>
</body>
</html>
