# Purpose: 
#   1. Delete files older than 5 days from a target folder.

# Define the paths - CHANGE THESE TO YOUR PATHS
$sourceFolder = "D:\Path\Files\"   # The folder to clean and archive


# Function to Write colorful status messages
function Write-Status {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ------ STEP 1: Delete files older than 5 days ------
Write-Status "Step 1: Searching for files created more than 5 days ago..." "Yellow"
    
$cutoffDate = (Get-Date).AddDays(-5)
$oldFiles = Get-ChildItem -Path $sourceFolder | Where-Object { $_.CreationTime -lt $cutoffDate }

if ($oldFiles) {
    Write-Status "Found $($oldFiles.Count) file(s) to delete." "Yellow"
    $oldFiles | ForEach-Object {
        try {
            Remove-Item $_.FullName -Force
            Write-Status "Deleted: $($_.Name)" "Red"
        }
        catch {
            Write-Status "ERROR: Failed to delete $($_.Name). Error: $($_.Exception.Message)" "Red"
        }
    }
}
else {
    Write-Status "No files older than 5 days found. Skipping deletion." "Green"
}
