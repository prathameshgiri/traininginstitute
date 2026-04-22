$readmePath = "d:\Workspaces\OpenSource Projects\Aarvi Kulkarni\README.md"
$codeBase = "d:\Workspaces\OpenSource Projects\Aarvi Kulkarni\src\main"

Add-Content -Path $readmePath -Value "`n---`n## 11. Appendix A: Core Database Schema Source Code (Reference)`n"
Add-Content -Path $readmePath -Value "```sql"
Get-Content "$codeBase\resources\database\schema.sql" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "`n---`n## 12. Appendix B: Core System Servlet Controller Code Reference`n"
Add-Content -Path $readmePath -Value "### LoginServlet.java`n```java"
Get-Content "$codeBase\java\com\traininginstitute\servlet\LoginServlet.java" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "### AdminDashboardServlet.java`n```java"
Get-Content "$codeBase\java\com\traininginstitute\servlet\AdminDashboardServlet.java" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "### StudentServlet.java`n```java"
Get-Content "$codeBase\java\com\traininginstitute\servlet\StudentServlet.java" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "### ExamServlet.java`n```java"
Get-Content "$codeBase\java\com\traininginstitute\servlet\ExamServlet.java" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "`n---`n## 13. Appendix C: Frontend JSP UI Code Reference`n"
Add-Content -Path $readmePath -Value "### Navbar.jsp`n```jsp"
Get-Content "$codeBase\webapp\WEB-INF\views\common\navbar.jsp" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

Add-Content -Path $readmePath -Value "### Internships.jsp`n```jsp"
Get-Content "$codeBase\webapp\WEB-INF\views\admin\internships.jsp" | Add-Content -Path $readmePath
Add-Content -Path $readmePath -Value "```"

$lines = (Get-Content $readmePath).Count
Write-Host "New README length is exactly $lines lines."
