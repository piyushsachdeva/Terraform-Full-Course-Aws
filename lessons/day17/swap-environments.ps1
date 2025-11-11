# Script to perform the Blue-Green swap

param(
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$BlueEnv = "",
    
    [Parameter(Mandatory=$false)]
    [string]$GreenEnv = ""
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Blue-Green Environment Swap" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get environment names from Terraform output if not provided
if ([string]::IsNullOrEmpty($BlueEnv) -or [string]::IsNullOrEmpty($GreenEnv)) {
    Write-Host "Getting environment names from Terraform..." -ForegroundColor Yellow
    
    try {
        $tfOutput = terraform output -json | ConvertFrom-Json
        $BlueEnv = $tfOutput.blue_environment_name.value
        $GreenEnv = $tfOutput.green_environment_name.value
        
        Write-Host "[SUCCESS] Found environments:" -ForegroundColor Green
        Write-Host "   Blue (Production): $BlueEnv" -ForegroundColor Blue
        Write-Host "   Green (Staging): $GreenEnv" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Could not read Terraform outputs." -ForegroundColor Red
        Write-Host "   Please run 'terraform apply' first or provide environment names manually." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "[WARNING] This will swap the CNAMEs of both environments!" -ForegroundColor Yellow
Write-Host "   Production traffic will be redirected to the staging environment." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue or Ctrl+C to cancel..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "Swapping environment CNAMEs..." -ForegroundColor Yellow

# Perform the swap
try {
    aws elasticbeanstalk swap-environment-cnames `
        --source-environment-name $BlueEnv `
        --destination-environment-name $GreenEnv `
        --region $Region
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "[SUCCESS] Swap initiated successfully!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INFO] The swap typically takes 1-2 minutes to complete." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can verify the swap by:" -ForegroundColor Cyan
    Write-Host "1. Checking the Elastic Beanstalk console" -ForegroundColor White
    Write-Host "2. Visiting the environment URLs (wait a few minutes)" -ForegroundColor White
    Write-Host "3. Running: terraform output instructions" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Error performing swap:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure AWS CLI is configured correctly" -ForegroundColor White
    Write-Host "2. Verify both environments are healthy" -ForegroundColor White
    Write-Host "3. Check that no other operation is in progress" -ForegroundColor White
    exit 1
}
