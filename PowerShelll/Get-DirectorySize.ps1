
param(
    [switch]$Export
)

$CurrentPath = Get-Location

Write-Host "Directory: $CurrentPath" -ForegroundColor Cyan
Write-Host "Calculating sizes..." -ForegroundColor Yellow

$Results = Get-ChildItem -Path $CurrentPath -Force |
    ForEach-Object {
        if ($_.PSIsContainer) {
            $SizeBytes = (Get-ChildItem -Path $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum

            [PSCustomObject]@{
                Type     = "Folder"
                Name     = $_.Name
                SizeMB   = [math]::Round(($SizeBytes / 1MB), 2)
                FullPath = $_.FullName
            }
        }
        else {
            [PSCustomObject]@{
                Type     = "File"
                Name     = $_.Name
                SizeMB   = [math]::Round(($_.Length / 1MB), 2)
                FullPath = $_.FullName
            }
        }
    } |
    Sort-Object SizeMB -Descending

# Display results
$Results | Format-Table -AutoSize

# Export only when -Export is specified
if ($Export) {
    $ReportPath = Join-Path $CurrentPath "DirectorySizeReport.csv"

    $Results | Export-Csv -Path $ReportPath -NoTypeInformation

    Write-Host "`nReport saved: $ReportPath" -ForegroundColor Green
}
else {
    Write-Host "`nCSV export disabled." -ForegroundColor Yellow
}
