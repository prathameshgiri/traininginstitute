# ============================================================
#  Training Institute Portal - One-Click Run Script
#  Usage: Right-click -> "Run with PowerShell"
#         OR in terminal: .\run.ps1
# ============================================================

$JAVA_HOME_PATH     = "C:\Program Files\Java\jdk-25"
$CATALINA_HOME_PATH = "C:\DevTools\apache-tomcat-10.1.30"
$MAVEN_CMD          = "C:\DevTools\apache-maven-3.9.6\bin\mvn.cmd"
$MYSQL_EXE          = "C:\xampp\mysql\bin\mysql.exe"
$PROJECT_ROOT       = $PSScriptRoot

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Training Institute Portal - Launcher" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Set environment variables ─────────────────────
$env:JAVA_HOME     = $JAVA_HOME_PATH
$env:CATALINA_HOME = $CATALINA_HOME_PATH
Write-Host "[1/5] Environment variables set." -ForegroundColor Green

# ── Step 2: Check MySQL is running ────────────────────────
Write-Host "[2/5] Checking MySQL..." -ForegroundColor Yellow
$mysqlRunning = netstat -ano | Select-String ":3306 " | Select-String "LISTENING"
if (-not $mysqlRunning) {
    Write-Host "      MySQL not running. Starting via XAMPP..." -ForegroundColor Yellow
    Start-Process "C:\xampp\xampp_start.exe" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    $mysqlRunning = netstat -ano | Select-String ":3306 " | Select-String "LISTENING"
    if (-not $mysqlRunning) {
        Write-Host ""
        Write-Host "  ERROR: MySQL still not running!" -ForegroundColor Red
        Write-Host "  Please open XAMPP Control Panel and click START next to MySQL." -ForegroundColor Red
        Write-Host "  Then run this script again." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}
Write-Host "      MySQL is running." -ForegroundColor Green

# ── Step 3: Kill any old Tomcat/Java processes ────────────
Write-Host "[3/5] Stopping old Tomcat (if any)..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "      Done." -ForegroundColor Green

# ── Step 4: Build the project ────────────────────────────
Write-Host "[4/5] Building project (Maven)..." -ForegroundColor Yellow
Push-Location $PROJECT_ROOT
& $MAVEN_CMD clean package -q
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: Maven build failed!" -ForegroundColor Red
    Write-Host "  Check the error above and fix it." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "      Build successful!" -ForegroundColor Green

# ── Step 5: Deploy WAR and start Tomcat ──────────────────
Write-Host "[5/5] Deploying and starting Tomcat..." -ForegroundColor Yellow
Remove-Item "$CATALINA_HOME_PATH\webapps\TrainingInstitutePortal" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$CATALINA_HOME_PATH\webapps\TrainingInstitutePortal.war" -Force -ErrorAction SilentlyContinue
Copy-Item "$PROJECT_ROOT\target\TrainingInstitutePortal.war" "$CATALINA_HOME_PATH\webapps\" -Force
Pop-Location

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Tomcat Starting..." -ForegroundColor Cyan
Write-Host "  Wait for: 'Server startup in [XXXX] ms'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  URL: http://localhost:8080/TrainingInstitutePortal/login" -ForegroundColor White
Write-Host ""
Write-Host "  Admin  : admin@traininginstitute.com / Admin@123" -ForegroundColor White
Write-Host "  Student: aarvi.kulkarni@student.com  / Student@123" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

& "$CATALINA_HOME_PATH\bin\catalina.bat" run
