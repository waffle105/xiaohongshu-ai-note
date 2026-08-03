param(
    [Parameter(Mandatory = $true)]
    [string]$FolderPath,

    [Parameter(Mandatory = $true)]
    [string]$CoverPath,

    [Parameter(Mandatory = $true)]
    [string[]]$ImagePaths
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $FolderPath -PathType Container)) { throw "FolderPath was not found: $FolderPath" }
if (-not (Test-Path -LiteralPath $CoverPath -PathType Leaf)) { throw "CoverPath was not found: $CoverPath" }
if ($ImagePaths.Count -eq 0) { throw 'Provide at least one body image.' }

$supported = @('.png', '.jpg', '.jpeg', '.webp')
function Copy-NamedImage {
    param([string]$SourcePath, [string]$DestinationStem)

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) { throw "Image was not found: $SourcePath" }
    $extension = [System.IO.Path]::GetExtension($SourcePath).ToLowerInvariant()
    if ($extension -notin $supported) { throw "Unsupported image extension: $extension" }
    $destination = Join-Path $FolderPath ($DestinationStem + $extension)
    if (Test-Path -LiteralPath $destination) { throw "Refusing to overwrite existing file: $destination" }
    Copy-Item -LiteralPath $SourcePath -Destination $destination
    return $destination
}

$savedCover = Copy-NamedImage -SourcePath $CoverPath -DestinationStem 'cover'
$savedImages = @()
for ($index = 0; $index -lt $ImagePaths.Count; $index++) {
    $savedImages += Copy-NamedImage -SourcePath $ImagePaths[$index] -DestinationStem (($index + 1).ToString('D2'))
}

[pscustomobject]@{
    Cover = $savedCover
    Images = $savedImages
}
