<%-- Report View - Training Institute Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${reportTitle} | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <c:set var="pageTitle" value="Reports"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <a href="${pageContext.request.contextPath}/admin/reports" class="btn-link" style="display:block;margin-bottom:8px">
                    ← Back to Reports
                </a>
                <h1 class="page-title">${reportTitle}</h1>
            </div>
            <button onclick="printReport()" class="btn btn-secondary">
                <i class="fas fa-print"></i> Print Report
            </button>
        </div>

        <!-- Report Nav (5 reports) -->
        <div class="filter-row" style="margin-bottom:24px">
            <a href="${pageContext.request.contextPath}/admin/report/selected-per-company"
               class="filter-chip ${reportType eq '1' ? 'active' : ''}">
               Report 1: Selected Per Company
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/application-counts"
               class="filter-chip ${reportType eq '2' ? 'active' : ''}">
               Report 2: Application Counts
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/exam-rank-list"
               class="filter-chip ${reportType eq '3' ? 'active' : ''}">
               Report 3: Exam Rank List
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/question-performance"
               class="filter-chip ${reportType eq '4' ? 'active' : ''}">
               Report 4: Question Performance
            </a>
            <a href="${pageContext.request.contextPath}/admin/report/suspicious-activities"
               class="filter-chip ${reportType eq '5' ? 'active' : ''}">
               Report 5: Suspicious Activity
            </a>
        </div>

        <!-- Exam Selector for Reports 3 & 4 -->
        <c:if test="${reportType eq '3' or reportType eq '4'}">
        <div class="card" style="padding:20px;margin-bottom:24px;display:flex;gap:16px;align-items:center">
            <label style="font-weight:600;color:var(--text-muted);font-size:13px">Filter by Exam:</label>
            <form method="get" style="display:flex;gap:10px;flex:1">
                <select name="exam_id" class="form-control" style="max-width:400px">
                    <option value="">All Exams</option>
                    <c:forEach var="exam" items="${exams}">
                    <option value="${exam.examId}" ${param.exam_id == exam.examId ? 'selected' : ''}>${exam.examName}</option>
                    </c:forEach>
                </select>
                <button type="submit" class="btn btn-primary">Filter</button>
            </form>
        </div>
        </c:if>

        <!-- Chart (for report types 1, 2, 3) -->
        <c:if test="${reportType eq '1' or reportType eq '2' or reportType eq '3'}">
        <div class="card" style="margin-bottom:24px">
            <div class="card-header"><h3><i class="fas fa-chart-bar"></i> Visual Overview</h3></div>
            <div class="card-body">
                <canvas id="reportChart" height="120"></canvas>
            </div>
        </div>
        </c:if>

        <!-- Data Table -->
        <div class="card">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Search..." oninput="searchTable()">
                </div>
                <span style="color:var(--text-muted);font-size:14px">${data.size()} records</span>
            </div>
            <div style="overflow-x:auto">
                <table class="data-table" id="reportTable">
                    <thead>
                        <c:if test="${not empty data}">
                        <tr>
                            <c:forEach var="key" items="${data[0].keySet()}">
                            <th>${key.replace('_', ' ').toUpperCase()}</th>
                            </c:forEach>
                        </tr>
                        </c:if>
                    </thead>
                    <tbody>
                        <c:forEach var="row" items="${data}">
                        <tr>
                            <c:forEach var="entry" items="${row}">
                            <td>
                                <c:choose>
                                    <c:when test="${entry.key eq 'severity'}">
                                        <span class="badge badge-${entry.value eq 'CRITICAL' ? 'danger' : entry.value eq 'WARNING' ? 'warning' : 'info'}">${entry.value}</span>
                                    </c:when>
                                    <c:when test="${entry.key eq 'is_passed'}">
                                        <span class="badge ${entry.value ? 'badge-success' : 'badge-danger'}">${entry.value ? 'PASSED' : 'FAILED'}</span>
                                    </c:when>
                                    <c:when test="${entry.key eq 'rank_position'}">
                                        <c:choose>
                                            <c:when test="${entry.value eq 1}">🥇 ${entry.value}</c:when>
                                            <c:when test="${entry.value eq 2}">🥈 ${entry.value}</c:when>
                                            <c:when test="${entry.value eq 3}">🥉 ${entry.value}</c:when>
                                            <c:otherwise>${entry.value}</c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:when test="${entry.key eq 'success_rate'}">
                                        <div style="display:flex;align-items:center;gap:8px">
                                            <div style="flex:1;background:var(--bg-input);border-radius:4px;height:6px;max-width:80px">
                                                <div style="width:${entry.value}%;height:100%;background:${entry.value >= 70 ? 'var(--accent)' : entry.value >= 40 ? 'var(--warning)' : 'var(--secondary)'};border-radius:4px"></div>
                                            </div>
                                            ${entry.value}%
                                        </div>
                                    </c:when>
                                    <c:otherwise>${entry.value}</c:otherwise>
                                </c:choose>
                            </td>
                            </c:forEach>
                        </tr>
                        </c:forEach>
                        <c:if test="${empty data}">
                        <tr><td colspan="20" class="empty-state">No data available for this report.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script>
    // Dynamic chart based on report type
    const reportType = '${reportType}';
    const reportData = ${reportData};

    if (document.getElementById('reportChart')) {
        const ctx = document.getElementById('reportChart').getContext('2d');
        const COLORS = ['#6C63FF','#43E97B','#FF6584','#FFA500','#4CC9F0','#FF9BB5','#FFD166'];

        if (reportType === '1') {
            // Selected per company - Bar chart
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: reportData.map(d => d.company_name || d.company_name),
                    datasets: [{ label: 'Selected Students',
                        data: reportData.map(d => d.selected_count),
                        backgroundColor: COLORS, borderRadius: 8 }]
                },
                options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true,ticks:{color:'#8888AA'},grid:{color:'rgba(255,255,255,.05)'}},x:{ticks:{color:'#8888AA'},grid:{display:false}}} }
            });
        } else if (reportType === '2') {
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: reportData.map(d => (d.company_name||'') + ' - ' + (d.role||'')),
                    datasets: [
                        { label:'Applied',     data: reportData.map(d => d.applied_count||0),     backgroundColor:'#6C63FF', borderRadius:4 },
                        { label:'Shortlisted', data: reportData.map(d => d.shortlisted_count||0), backgroundColor:'#FFA500', borderRadius:4 },
                        { label:'Selected',    data: reportData.map(d => d.selected_count||0),    backgroundColor:'#43E97B', borderRadius:4 },
                        { label:'Rejected',    data: reportData.map(d => d.rejected_count||0),    backgroundColor:'#FF6584', borderRadius:4 }
                    ]
                },
                options: { plugins:{legend:{labels:{color:'#8888AA'}}}, scales:{y:{beginAtZero:true,ticks:{color:'#8888AA'},grid:{color:'rgba(255,255,255,.05)'}},x:{ticks:{color:'#8888AA'},grid:{display:false}}} }
            });
        } else if (reportType === '3') {
            const examNames = [...new Set(reportData.map(d => d.exam_name))].slice(0,5);
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: reportData.slice(0,10).map(d => d.student_name),
                    datasets: [{ label:'Score', data: reportData.slice(0,10).map(d => d.total_score),
                        backgroundColor: reportData.slice(0,10).map((d,i) => ['#FFD700','#C0C0C0','#CD7F32'][i] || '#6C63FF'),
                        borderRadius:8 }]
                },
                options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true,max:100,ticks:{color:'#8888AA'},grid:{color:'rgba(255,255,255,.05)'}},x:{ticks:{color:'#8888AA'},grid:{display:false}}} }
            });
        }
    }

    function searchTable() {
        const q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#reportTable tbody tr').forEach(r => {
            r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }

    function printReport() {
        window.print();
    }
    </script>
    <style>
    @media print {
        .navbar, .filter-row, .table-controls, .header-actions { display: none !important; }
        .main-content { padding: 0; }
        body { background: #fff; color: #000; }
        .card { border: 1px solid #ccc; box-shadow: none; }
        .data-table thead th, .data-table tbody td { color: #000; background: #fff; }
    }
    </style>
</body>
</html>
