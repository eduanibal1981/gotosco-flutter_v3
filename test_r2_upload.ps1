# test_r2_upload.ps1

# =================CONFIGURATION =================
# 1. Supabase Credentials (GET THESE FROM DASHBOARD)
$SupabaseUrl = "https://ixjkvasziamjkeupqvfc.supabase.co"
$SupabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4amt2YXN6aWFtamtldXBxdmZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcxMTMwNTUsImV4cCI6MjA4MjY4OTA1NX0.FsZCUPXl5akkSQKBuZUMaz96G7xcdafrP4da41TsiIc"  # <--- REPLACE THIS

# 2. Test User Credentials (A valid user in your Authentication > Users table)
$Email = "driver1@test.com"         # <--- REPLACE THIS
$Password = "Test@1234"          # <--- REPLACE THIS

# 3. File to Upload
$FilePath = "G:\keke.png"   # <--- REPLACE THIS
# ================================================

# Helper to print steps
function Print-Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Print-Success($msg) { Write-Host "OK: $msg" -ForegroundColor Green }
function Print-Error($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }

$ErrorActionPreference = "Stop"

try {
    # ---------------------------------------------------------
    # STEP 1: LOG IN (Get Access Token)
    # ---------------------------------------------------------
    Print-Step "Step 1: Logging in to get Access Token"
    
    $AuthUrl = "$SupabaseUrl/auth/v1/token?grant_type=password"
    $AuthBody = @{
        email    = $Email
        password = $Password
    } | ConvertTo-Json

    $AuthHeaders = @{
        "apikey"       = $SupabaseAnonKey
        "Content-Type" = "application/json"
    }

    try {
        $AuthResponse = Invoke-RestMethod -Uri $AuthUrl -Method Post -Body $AuthBody -Headers $AuthHeaders
        $AccessToken = $AuthResponse.access_token
        $UserId = $AuthResponse.user.id
        Print-Success "Logged in as User ID: $UserId"
        # Write-Host "Token: $AccessToken" # Uncomment to see token
    }
    catch {
        $Err = $_.Exception.Response
        Print-Error "Login Failed. Code: $($Err.StatusCode)"
        # Read error stream if possible
        $Reader = New-Object System.IO.StreamReader($Err.GetResponseStream())
        Write-Host $Reader.ReadToEnd() -ForegroundColor Yellow
        exit
    }

    # ---------------------------------------------------------
    # STEP 2: REQUEST UPLOAD URL (Call Edge Function)
    # ---------------------------------------------------------
    Print-Step "Step 2: Calling 'request-upload' Edge Function"

    if (-not (Test-Path $FilePath)) {
        Print-Error "File not found: $FilePath"
        exit
    }

    $File = Get-Item $FilePath
    $FileSize = $File.Length
    $FunctionUrl = "$SupabaseUrl/functions/v1/request-upload"

    $FunctionBody = @{
        asset_type        = "license" # or "driver_photo", etc.
        file_size         = $FileSize
        original_filename = $File.Name
        content_type      = "image/png" # Adjust based on file
    } | ConvertTo-Json

    $FunctionHeaders = @{
        "Authorization" = "Bearer $AccessToken"
        "apikey"        = $SupabaseAnonKey
        "Content-Type"  = "application/json"
    }

    try {
        $FuncResponse = Invoke-RestMethod -Uri $FunctionUrl -Method Post -Body $FunctionBody -Headers $FunctionHeaders
        $UploadUrl = $FuncResponse.upload_url
        $AssetId = $FuncResponse.asset_id
        Print-Success "Got Upload URL!"
        Write-Host "Asset ID: $AssetId" -ForegroundColor Gray
        Write-Host "Upload URL: $UploadUrl" -ForegroundColor Gray
    }
    catch {
        $Err = $_.Exception.Response
        Print-Error "Edge Function Call Failed. Code: $($Err.StatusCode)"
        $Reader = New-Object System.IO.StreamReader($Err.GetResponseStream())
        Write-Host $Reader.ReadToEnd() -ForegroundColor Yellow
        
        Write-Host "`nTroubleshooting Tip: If this is 401 'Invalid JWT', your project might use new Keys but you are using an old Anon Key, OR the server time skew is rejecting the token." -ForegroundColor Magenta
        exit
    }

    # ---------------------------------------------------------
    # STEP 3: UPLOAD TO R2 (Direct PUT)
    # ---------------------------------------------------------
    Print-Step "Step 3: Uploading file directly to R2"

    try {
        # Read file bytes
        $FileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        
        # Invoke-RestMethod for PUT with raw bytes is tricky in older PS, using HttpClient
        $HttpClient = New-Object System.Net.Http.HttpClient
        $Content = New-Object System.Net.Http.ByteArrayContent -ArgumentList (, $FileBytes)
        $Content.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png")
        
        $PutResponse = $HttpClient.PutAsync($UploadUrl, $Content).Result
        
        if ($PutResponse.IsSuccessStatusCode) {
            Print-Success "Upload Successful!"
        }
        else {
            Print-Error "Upload Failed: $($PutResponse.StatusCode)"
            Write-Host $PutResponse.Content.ReadAsStringAsync().Result
        }
    }
    catch {
        Print-Error "Upload Step Failed: $_"
    }

}
catch {
    Print-Error "Unexpected Error: $_"
}
