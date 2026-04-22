<%-- Admin Dashboard - Training Institute Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Admin Dashboard | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <c:set var="pageTitle" value="Dashboard"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>

    <main class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <div>
                <h1 class="page-title">Admin Dashboard</h1>
                <p class="page-subtitle">Welcome back, <strong>${sessionScope.user.name}</strong> — here's your overview</p>
            </div>
            <div class="header-actions">
                <span class="badge-live"><i class="fas fa-circle pulse-dot"></i> Live</span>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card stat-primary">
                <div class="stat-icon"><i class="fas fa-user-graduate"></i></div>
                <div class="stat-info">
                    <h3>${totalStudents}</h3>
                    <p>Total Students</p>
                </div>
                <div class="stat-change positive"><i class="fas fa-arrow-up"></i> Active</div>
            </div>
            <div class="stat-card stat-secondary">
                <div class="stat-icon"><i class="fas fa-building"></i></div>
                <div class="stat-info">
                    <h3>${totalCompanies}</h3>
                    <p>Partner Companies</p>
                </div>
            </div>
            <div class="stat-card stat-accent">
                <div class="stat-icon"><i class="fas fa-briefcase"></i></div>
                <div class="stat-info">
                    <h3>${totalInternships}</h3>
                    <p>Open Internships</p>
                </div>
            </div>
            <div class="stat-card stat-warning">
                <div class="stat-icon"><i class="fas fa-file-alt"></i></div>
                <div class="stat-info">
                    <h3>${totalApplications}</h3>
                    <p>Applications</p>
                </div>
            </div>
        </div>

        <!-- Charts + Recent Activity -->
        <div class="dashboard-grid">
            <!-- Application Status Chart -->
            <div class="card chart-card">
                <div class="card-header">
                    <h3><i class="fas fa-chart-doughnut"></i> Application Status</h3>
                    <span class="card-badge">Live</span>
                </div>
                <div class="card-body">
                    <canvas id="appStatusChart" height="250"></canvas>
                </div>
            </div>

            <!-- Monthly Trend Chart -->
            <div class="card chart-card">
                <div class="card-header">
                    <h3><i class="fas fa-chart-line"></i> Registration Trend</h3>
                    <span class="card-badge">Monthly</span>
                </div>
                <div class="card-body">
                    <canvas id="trendChart" height="250"></canvas>
                </div>
            </div>
        </div>

        <!-- Recent Applications -->
        <div class="card full-width-card">
            <div class="card-header">
                <h3><i class="fas fa-clock"></i> Recent Applications</h3>
                <a href="${pageContext.request.contextPath}/admin/applications" class="btn-link">View All →</a>
            </div>
            <div class="card-body p-0">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Company / Role</th>
                            <th>CGPA</th>
                            <th>Applied</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="app" items="${recentApplications}">
                        <tr>
                            <td>
                                <div class="user-cell">
                                    <div class="avatar-sm">${app.studentName.charAt(0)}</div>
                                    <div>
                                        <div class="cell-name">${app.studentName}</div>
                                        <div class="cell-sub">${app.course}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="cell-name">${app.companyName}</div>
                                <div class="cell-sub">${app.internshipRole}</div>
                            </td>
                            <td><span class="cgpa-badge">${app.cgpa}</span></td>
                            <td><fmt:formatDate value="${app.appliedDate}" pattern="dd MMM yyyy"/></td>
                            <td>
                                <span class="status-badge status-${app.status.toLowerCase()}">${app.status}</span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/applications" class="btn-icon" title="View">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </td>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty recentApplications}">
                            <tr><td colspan="6" class="empty-state">No applications yet</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Suspicious Activity Alerts -->
        <c:if test="${not empty recentLogs}">
        <div class="card full-width-card alert-card">
            <div class="card-header">
                <h3><i class="fas fa-exclamation-triangle text-warning"></i> Security Alerts</h3>
                <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn-link">View All →</a>
            </div>
            <div class="card-body p-0">
                <table class="data-table">
                    <thead>
                        <tr><th>User</th><th>Action</th><th>Type</th><th>IP</th><th>Severity</th><th>Time</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${recentLogs}">
                        <tr>
                            <td>${empty log.userName ? 'Unknown' : log.userName}</td>
                            <td>${log.action}</td>
                            <td><span class="badge badge-info">${log.actionType}</span></td>
                            <td><code>${log.ipAddress}</code></td>
                            <td><span class="badge ${log.severityBadgeClass}">${log.severity}</span></td>
                            <td><fmt:formatDate value="${log.logTime}" pattern="dd MMM HH:mm"/></td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        </c:if>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3>Quick Actions</h3>
            <div class="action-grid">
                <a href="${pageContext.request.contextPath}/admin/companies?action=add" class="action-card">
                    <i class="fas fa-plus-circle"></i>
                    <span>Add Company</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/internships?action=add" class="action-card">
                    <i class="fas fa-briefcase"></i>
                    <span>Post Internship</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/exams?action=add" class="action-card">
                    <i class="fas fa-clipboard-list"></i>
                    <span>Create Exam</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/report/selected-per-company" class="action-card">
                    <i class="fas fa-chart-bar"></i>
                    <span>View Reports</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/evaluate" class="action-card">
                    <i class="fas fa-check-double"></i>
                    <span>Evaluate Exams</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/audit-logs" class="action-card">
                    <i class="fas fa-shield-alt"></i>
                    <span>Audit Logs</span>
                </a>
            </div>
        </div>
    </main>

    <script>
    // Load dashboard charts via AJAX
    fetch('${pageContext.request.contextPath}/admin/report/dashboard-stats')
        .then(r => r.json())
        .then(stats => {
            // Application Status Donut Chart
            const appData = stats.applicationsByStatus || [];
            const labels  = appData.map(d => d.status);
            const counts  = appData.map(d => d.count);
            const colors  = ['#6C63FF','#FFA500','#43E97B','#FF6584','#4CC9F0'];
            new Chart(document.getElementById('appStatusChart').getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels,
                    datasets: [{ data: counts, backgroundColor: colors, borderWidth: 3, borderColor: '#161629' }]
                },
                options: {
                    cutout: '70%',
                    plugins: { legend: { position: 'bottom', labels: { color: '#8888AA', font: { family:'Inter' } } } }
                }
            });

            // Monthly Registration Trend
            const monthData = stats.monthlyRegistrations || [];
            new Chart(document.getElementById('trendChart').getContext('2d'), {
                type: 'line',
                data: {
                    labels: monthData.map(d => d.month).reverse(),
                    datasets: [{
                        label: 'Student Registrations',
                        data: monthData.map(d => d.count).reverse(),
                        borderColor: '#6C63FF',
                        backgroundColor: 'rgba(108,99,255,.1)',
                        tension: .4,
                        fill: true,
                        pointBackgroundColor: '#6C63FF',
                        pointRadius: 5
                    }]
                },
                options: {
                    plugins: { legend: { labels: { color: '#8888AA', font: { family:'Inter' } } } },
                    scales: {
                        x: { ticks: { color: '#8888AA' }, grid: { color: 'rgba(255,255,255,.05)' } },
                        y: { ticks: { color: '#8888AA' }, grid: { color:'rgba(255,255,255,.05)' }, beginAtZero: true }
                    }
                }
            });
        }).catch(() => {});
    </script>
</body>
</html>
