<#
push_to_github.ps1

Simple helper to initialize a git repo (if necessary), create a .gitignore,
commit files and push to a remote GitHub repository. This script does NOT embed
credentials — for HTTPS pushes you will be prompted for credentials or use a
credential helper. For SSH pushes you must have your SSH key added to GitHub.

Usage:
  Open PowerShell in the project folder and run:
    .\push_to_github.ps1

The script will prompt for the remote URL (default is your repo) and whether to
use SSH or HTTPS. It will avoid overwriting an existing remote unless you
confirm.
#>

Set-StrictMode -Version Latest

$DefaultRemote = 'https://github.com/tsengchunchieh-cmd/hw5a.git'

## Move to script directory (project root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location -Path $ScriptDir

Write-Host "Working directory: $ScriptDir"

function Require-Git {
    try {
        git --version > $null 2>&1
    } catch {
        Write-Error "Git not found in PATH. Please install Git first: https://git-scm.com/"
        exit 1
    }
}

Require-Git

if (-not (Test-Path -Path '.git')) {
    Write-Host "No git repository found. Initializing..."
    git init
} else {
    Write-Host "Git repository detected."
}

## Configure username/email if not set
if (-not (git config user.name)) {
    $name = Read-Host "Git user.name is not set. Enter your name (or leave blank to skip)"
    if ($name) { git config user.name "$name" }
}
if (-not (git config user.email)) {
    $email = Read-Host "Git user.email is not set. Enter your email (or leave blank to skip)"
    if ($email) { git config user.email "$email" }
}

## Create a minimal .gitignore if it doesn't exist
if (-not (Test-Path -Path '.gitignore')) {
    @"
__pycache__/
*.pyc
.venv/
env/
.env
.pytest_cache/
.vscode/
*.egg-info/
"@ | Out-File -Encoding utf8 .gitignore
    Write-Host "Created .gitignore"
} else {
    Write-Host ".gitignore already exists"
}

Write-Host "Staging files..."
git add .

try {
    git commit -m "Initial commit: Streamlit AI detector" 2>&1 | Out-String | Write-Host
} catch {
    Write-Host "No changes to commit or commit failed. Continuing..."
}

## Ensure branch is main
git branch -M main 2>$null

## Determine remote URL and protocol
$useDefault = Read-Host "Use default remote ($DefaultRemote)? (Y/n)"
if ($useDefault -eq '' -or $useDefault -match '^[Yy]') {
    $remoteUrl = $DefaultRemote
} else {
    $remoteUrl = Read-Host "Enter remote URL (HTTPS or SSH)"
}

Write-Host "Remote: $remoteUrl"

if (git remote | Select-String -Quiet '^origin$') {
    $current = git remote get-url origin
    Write-Host "Existing 'origin' remote found: $current"
    $replace = Read-Host "Replace existing 'origin' remote with $remoteUrl? (y/N)"
    if ($replace -match '^[Yy]') {
        git remote remove origin
        git remote add origin $remoteUrl
    } else {
        Write-Host "Keeping existing remote. Will attempt to push to 'origin'."
    }
} else {
    git remote add origin $remoteUrl
}

Write-Host "Pushing to origin main... You may be prompted for credentials depending on your setup."

try {
    git push -u origin main
} catch {
    Write-Host "Push failed. Common fixes:"
    Write-Host " - Run: git fetch origin && git pull --rebase origin main"
    Write-Host " - If you intentionally want to overwrite remote: git push -u origin main --force"
    Write-Host " - Or configure credentials (gh auth login or a PAT / SSH key)."
}

Write-Host "Done. Verify at: $remoteUrl"
