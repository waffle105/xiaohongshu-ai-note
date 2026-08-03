param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$BodyFile,

    [Parameter(Mandatory = $true)]
    [string]$Source,

    [string[]]$Tags = @(),

    [string]$RootDirectory = 'C:\Users\zyiho\Documents\01-work\Codex\小红书和公众号\每日AI进化笔记'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $BodyFile -PathType Leaf)) {
    throw "BodyFile was not found: $BodyFile"
}
if ([string]::IsNullOrWhiteSpace($Title)) { throw 'Title cannot be empty.' }
if ($Title.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) {
    throw 'Title contains characters that cannot be used in a folder name.'
}
if ($Tags.Count -gt 5) { throw 'Use no more than five tags.' }

New-Item -ItemType Directory -Path $RootDirectory -Force | Out-Null
$existingNumbers = @(Get-ChildItem -LiteralPath $RootDirectory -Directory | ForEach-Object {
    if ($_.Name -match '^(\d+)-') { [int]$Matches[1] }
})
$nextNumber = if ($existingNumbers.Count -eq 0) { 1 } else { [int](($existingNumbers | Measure-Object -Maximum).Maximum) + 1 }
$prefix = ([int]$nextNumber).ToString('000')
$folderPath = Join-Path $RootDirectory "$prefix-$Title"
if (Test-Path -LiteralPath $folderPath) { throw "Target folder already exists: $folderPath" }

$body = (Get-Content -LiteralPath $BodyFile -Raw -Encoding utf8).Trim()
$normalizedTags = @($Tags | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
    $tag = $_.Trim()
    if ($tag.StartsWith('#')) { $tag } else { "#$tag" }
})
$content = @(
    "【每日AI进化笔记-$prefix】"
    ''
    $body
    ''
    "出处：$Source"
    ($normalizedTags -join ' ')
) -join [Environment]::NewLine

New-Item -ItemType Directory -Path $folderPath | Out-Null
$contentPath = Join-Path $folderPath 'content.txt'
[System.IO.File]::WriteAllText($contentPath, $content, [System.Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    Prefix = $prefix
    FolderPath = $folderPath
    ContentPath = $contentPath
    CoverPath = (Join-Path $folderPath 'cover.png')
    ImagePattern = (Join-Path $folderPath '01.png, 02.png, ...')
}
