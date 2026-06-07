param(
  [Parameter(Position = 0)]
  [string]$Command = "help",

  [string]$DeviceId = "1592533185000B8",
  [string]$AdminPassword = "kaju_admin_dev_password"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $PSCommandPath
$Root = Split-Path -Parent $ScriptDir
$EnvFile = Join-Path $Root ".env"
$FlutterDir = Join-Path $Root "kajupilot"
$ApiDir = Join-Path $Root "kajupilot-api"
$AdminDir = Join-Path $Root "kajupilot-admin"
$FlutterApiBaseUrl = "http://127.0.0.1:3000/api/v1"

function In-Root {
  param([scriptblock]$Block)
  Push-Location $Root
  try {
    & $Block
  } finally {
    Pop-Location
  }
}

function In-Flutter {
  param([scriptblock]$Block)
  Push-Location $FlutterDir
  try {
    & $Block
  } finally {
    Pop-Location
  }
}

function In-Api {
  param([scriptblock]$Block)
  Push-Location $ApiDir
  try {
    & $Block
  } finally {
    Pop-Location
  }
}

function In-Admin {
  param([scriptblock]$Block)
  Push-Location $AdminDir
  try {
    & $Block
  } finally {
    Pop-Location
  }
}

function Compose-Dev {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ComposeArgs)
  $capturedArgs = $ComposeArgs
  In-Root {
    docker compose --env-file .env -f docker-compose.yml -f docker-compose.dev.yml @capturedArgs
  }
}

function Ensure-Env {
  if (Test-Path $EnvFile) {
    Write-Host ".env already exists. Keeping it unchanged."
    return
  }

  $envContent = @"
COMPOSE_PROJECT_NAME=kajupilot
DEPLOY_TARGET=local
DB_PASSWORD=kaju_dev_password
JWT_SECRET=dev_jwt_secret_1234567890_abcdefghijklmnopqrstuvwxyz_2026
ADMIN_SETUP_CODE=KAJU-2026
ADMIN_SECRET=dev_admin_secret
ADMIN_USER=parth
ADMIN_PASS_HASH=replace_me_with_caddy_hash_password_output
API_HOST=:80
ADMIN_HOST=admin.localhost
ADMIN_API_URL=http://api:3000/api/v1
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
ALLOWED_ORIGINS=http://localhost:3001,http://admin.localhost
AI_PROVIDER=openai
OPENAI_API_KEY=replace_me
OPENAI_MODEL=gpt-4o-mini
OPENAI_INPUT_COST_PER_1M=0.15
OPENAI_OUTPUT_COST_PER_1M=0.60
GROQ_API_KEY=replace_me
GROQ_MODEL=meta-llama/llama-4-scout-17b-16e-instruct
GROQ_INPUT_COST_PER_1M=0.11
GROQ_OUTPUT_COST_PER_1M=0.34
AI_MAX_TOKENS=700
AI_TEMPERATURE=0.2
AI_PARSE_RATE_LIMIT_PER_HOUR=20
"@

  Set-Content -Path $EnvFile -Value $envContent -Encoding utf8
  Write-Host "Created .env with development defaults."
  Write-Host "Add real OPENAI_API_KEY and GROQ_API_KEY later when AI calls go live."
}

function Assert-Env {
  if (-not (Test-Path $EnvFile)) {
    throw "Missing .env. Run: make env"
  }
}

function Read-EnvMap {
  Assert-Env

  $envMap = @{}
  Get-Content $EnvFile | ForEach-Object {
    if ($_ -match "^\s*#" -or $_ -notmatch "=") {
      return
    }

    $parts = $_ -split "=", 2
    $envMap[$parts[0].Trim()] = $parts[1].Trim()
  }

  return ,$envMap
}

function Test-BcryptHash {
  param([string]$Hash)

  return $Hash -match '^\$2[aby]\$'
}

function Get-Adb {
  $adb = Get-Command adb -ErrorAction SilentlyContinue
  if ($adb) {
    return $adb.Source
  }

  $sdkAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  if (Test-Path $sdkAdb) {
    return $sdkAdb
  }

  throw "adb not found. Install Android platform-tools or ensure Flutter/Android SDK is on PATH."
}

function Show-Help {
  Write-Host ""
  Write-Host "KajuPilot dev commands"
  Write-Host ""
  Write-Host "First-time setup:"
  Write-Host "  make env              Create .env if missing"
  Write-Host "  make env-check        Show important .env values and warnings"
  Write-Host "  make doctor           Check Docker, Flutter, and Android device visibility"
  Write-Host ""
  Write-Host "Docker dev stack:"
  Write-Host "  make up               Build/start postgres, redis, api, admin with dev ports"
  Write-Host "  make migrate          Run Prisma migrations inside the API container"
  Write-Host "  make health           Check API health and AI provider config"
  Write-Host "  make logs             Follow API/admin/postgres/redis logs"
  Write-Host "  make ps               Show containers"
  Write-Host "  make down             Stop containers"
  Write-Host "  make restart          Restart dev stack"
  Write-Host ""
  Write-Host "Phone app:"
  Write-Host "  make flutter-devices  List Flutter devices"
  Write-Host "  make flutter-phone    Run on IQOO using adb reverse and hot reload"
  Write-Host "  make flutter-phone DEVICE_ID=<id>"
  Write-Host "  make apk              Build debug APK"
  Write-Host ""
  Write-Host "Checks:"
  Write-Host "  make checks           Run Flutter/API/Admin checks"
  Write-Host ""
  Write-Host "Direct PowerShell fallback:"
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts/dev.ps1 up"
  Write-Host ""
}

switch ($Command) {
  "help" {
    Show-Help
  }

  "env" {
    Ensure-Env
  }

  "env-check" {
    $envMap = Read-EnvMap
    $content = Get-Content $EnvFile
    $interesting = $content | Where-Object {
      $_ -match "^(DEPLOY_TARGET|ADMIN_SETUP_CODE|API_HOST|ADMIN_HOST|NEXT_PUBLIC_API_URL|ALLOWED_ORIGINS|AI_PROVIDER|OPENAI_MODEL|GROQ_MODEL)="
    }
    $interesting | ForEach-Object { Write-Host $_ }
    if ($content -match "replace_me") {
      Write-Host ""
      Write-Host "Warning: .env still contains replace_me placeholders."
      Write-Host "That is okay for health/setup, but update API keys before real AI calls."
    }

    $rawAdminHash = $envMap["ADMIN_PASS_HASH"]
    if ($rawAdminHash -and (Test-BcryptHash $rawAdminHash)) {
      Write-Host ""
      Write-Host 'Warning: ADMIN_PASS_HASH looks raw. For Docker Compose, escape each "$" as "$$" in .env.'
      Write-Host "Run: make hash"
    }

    if ($rawAdminHash -and $rawAdminHash.StartsWith("`$`$2")) {
      Write-Host ""
      Write-Host "ADMIN_PASS_HASH looks Docker Compose safe."
    }
  }

  "doctor" {
    docker --version
    docker compose version
    In-Flutter { flutter.bat --version }
    In-Flutter { flutter.bat devices }
    $adb = Get-Adb
    & $adb devices
  }

  "hash" {
    $hash = docker run --rm caddy:2-alpine caddy hash-password --plaintext $AdminPassword
    $escapedHash = $hash -replace "\$", '$$$$'

    Write-Host "Raw Caddy hash:"
    Write-Host $hash
    Write-Host ""
    Write-Host "Paste this Docker Compose safe line into .env:"
    Write-Host "ADMIN_PASS_HASH=$escapedHash"
  }

  "up" {
    Assert-Env
    Compose-Dev up -d --build postgres redis api admin
  }

  "up-full" {
    Assert-Env
    Compose-Dev up -d --build
  }

  "rebuild" {
    Assert-Env
    Compose-Dev up -d --build --force-recreate api admin
  }

  "migrate" {
    Assert-Env
    Compose-Dev exec api npx prisma migrate deploy
  }

  "ps" {
    Assert-Env
    Compose-Dev ps
  }

  "logs" {
    Assert-Env
    Compose-Dev logs -f api admin postgres redis
  }

  "health" {
    Invoke-RestMethod "http://localhost:3000/api/v1/health"
    Invoke-RestMethod "http://localhost:3000/api/v1/ai/providers"
  }

  "down" {
    Assert-Env
    Compose-Dev down
  }

  "restart" {
    Assert-Env
    Compose-Dev restart
  }

  "flutter-devices" {
    In-Flutter { flutter.bat devices }
  }

  "flutter-phone" {
    $adb = Get-Adb
    & $adb reverse tcp:3000 tcp:3000
    In-Flutter {
      flutter.bat run -d $DeviceId --dart-define=API_BASE_URL=$FlutterApiBaseUrl
    }
  }

  "flutter-build" {
    In-Flutter { flutter.bat build apk --debug }
  }

  "api-build" {
    In-Api { npm.cmd run build }
  }

  "api-test" {
    In-Api { npm.cmd test }
  }

  "api-audit" {
    In-Api { npm.cmd audit }
  }

  "admin-build" {
    In-Admin { npm.cmd run build }
  }

  "admin-audit" {
    In-Admin { npm.cmd audit }
  }

  "checks" {
    In-Flutter { dart.bat format lib test }
    In-Flutter { flutter.bat analyze }
    In-Flutter { flutter.bat test }
    In-Api { npm.cmd run build }
    In-Api { npm.cmd test }
    In-Api { npm.cmd audit }
    In-Admin { npm.cmd run build }
    In-Admin { npm.cmd audit }
  }

  default {
    throw "Unknown command '$Command'. Run: make help"
  }
}
