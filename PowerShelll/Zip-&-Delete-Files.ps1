# Purpose: 
#   1. Zip all remaining files in the folder.
#   2. Delete the original files only if they were successfully added to the ZIP.

# Import the .NET Compression assembly
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

# Define the paths - CHANGE THESE TO YOUR PATHS
$sourceFolder = "D:\Retail Training\Client\True Bell\Repo\Truebell\Apps\Casino\src\report\" # The folder to clean and archive
$destinationFolder = "D:\Retail Training\Client\True Bell\Repo\Truebell\Apps\Casino\src\report\" # The folder to clean and archive


Write-Status "Step 2: Zipping all remaining files in '$sourceFolder'..." "Yellow"
$filesToZip = Get-ChildItem -Path $sourceFolder -File

if (-not $filesToZip) {
    Write-Status "No files found to zip. Exiting script." "Green"
    exit
}

foreach ($file in $filesToZip) {

    # Check if the destination directory for the ZIP exists, create it if not
    if (-not (Test-Path -Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null
    }

    $zipFileName = "$($file.BaseName).zip";

    # Create a new ZIP archive
    $zipArchive = [System.IO.Compression.ZipFile]::Open($destinationFolder + $zipFileName, [System.IO.Compression.ZipArchiveMode]::Create)

    try {
        # Add the file to the ZIP archive. The second argument is the entry name inside the ZIP.
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $file.Name)
        Write-Status "Added to ZIP: $($file.Name)" "Green"

        if (Test-Path $file.FullName) {
            try {
                Remove-Item $file.FullName -Force
                Write-Status "Cleaned up: $($file.Name)" "Magenta"
            }
            catch {
                Write-Status "WARNING: Could not delete original file '$($file.Name)'. Error: $($_.Exception.Message)" "Red"
            }
        }
    }
    catch {
        Write-Status "ERROR: Failed to add '$($file.Name)' to ZIP. Error: $($_.Exception.Message)" "Red"
    }
    $zipArchive.Dispose();
}
