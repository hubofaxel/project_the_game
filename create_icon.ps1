# Base64 string of a small valid PNG file (16x16 transparent)
$base64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAATSURBVDhPYxgFo2AUjAIwYGAAAAQQAAGnRHxjAAAAAElFTkSuQmCC"

# Convert base64 to bytes
$bytes = [Convert]::FromBase64String($base64)

# Create directory if it doesn't exist
$directory = "assets/images/ui"
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

# Write bytes to file
[System.IO.File]::WriteAllBytes("$directory/icon.png", $bytes)

Write-Host "Icon created successfully!"