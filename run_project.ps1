# PowerShell script to download portable Maven and run the LibraryOS web application

$MavenVersion = "3.9.6"
$MavenZipUrl = "https://archive.apache.org/dist/maven/maven-3/$MavenVersion/binaries/apache-maven-$MavenVersion-bin.zip"
$InstallDir = "$Home\.gemini\antigravity\portable-maven"
$MavenHome = "$InstallDir\apache-maven-$MavenVersion"
$MvnPath = "$MavenHome\bin\mvn.cmd"

# 1. Create install directory if it doesn't exist
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

# 2. Download and extract Maven if not already present
if (!(Test-Path $MvnPath)) {
    Write-Host "Dang tai Apache Maven $MavenVersion..." -ForegroundColor Cyan
    $ZipPath = "$InstallDir\maven.zip"
    
    # Download Maven
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $MavenZipUrl -OutFile $ZipPath -UseBasicParsing
    
    Write-Host "Dang giai nen Maven..." -ForegroundColor Cyan
    Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
    Remove-Item $ZipPath -Force
    Write-Host "Da cai dat Maven cam tay tai: $MavenHome" -ForegroundColor Green
}

# 3. Compile and Run the web application using Jetty embedded server
Write-Host "Dang khoi dong server LibraryOS (Jetty)..." -ForegroundColor Cyan
Write-Host "Vui long cho giay lat..." -ForegroundColor Yellow

# Start the Jetty server
& $MvnPath jetty:run
