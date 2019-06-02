#Requires -Version 5.0

<#
.SYNOPSIS
List commits across multiple Git repositories.

.DESCRIPTION
This script aggregates a filtered list of commits across multiple Git repositories.

.PARAMETER author
Filters the commits to ones with author header lines that match the specified pattern.

.PARAMETER since
Filters the commits to a specific time range.

.PARAMETER directory
Specifies the directory that holds Git repositories.

.EXAMPLE
.\list_git_commits.ps1

.EXAMPLE
.\list_git_commits.ps1 -author "Finn Kumkar" -since "1 week ago"

.EXAMPLE
.\list_git_commits.ps1 -directory "./workspace"
#>

[CmdletBinding()]
Param (

    [string]$author,
    [string]$since,
    [string]$directory
)

# Workaround to use UTF-8 consistently (https://github.com/PowerShell/PowerShell/issues/4681).
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Default the optional author match pattern to a wildcard.
if (!$author) {
    $author = ".*"
}

# Default the optional since date to everything within the last month.
if (!$since) {
    $since = "1 month ago"
}

# Default the optional repositories directory to the current path.
if (!$directory) {
    $directory = "."
}

# Work with absolute paths.
$directory = Resolve-Path -Path "$directory" | Select-Object -ExpandProperty Path

Clear-Host
Write-Host "Finding all commits of '$author' in '$directory' since '$since'..."

# Measure the execution time of this script.
$stopwatch = [System.Diagnostics.Stopwatch]::startNew()

# Recursively find all bare and non bare Git repositories.
$repositoryDirectories = Get-ChildItem -Recurse `
                                       -Attributes Hidden,!Hidden `
                                       -Directory "$directory" `
                                       -filter "*.git"

$progressBarTitle = ("Aggregating commits across $($repositoryDirectories.Count) " +
                     "Git repositories in '$directory'...")

$index = 0
$commits = @()

$repositoryDirectories | ForEach-Object {

    $index++

    $percentComplete = [math]::Round($index / $repositoryDirectories.Count * 100)

    Write-Progress -Activity "$progressBarTitle" `
                   -Status "$percentComplete% complete, scanning: $($_.Name)" `
                   -PercentComplete $percentComplete;

    # Always use the raw repository name.
    $repositoryName = if ($_.Name -eq ".git") {
        "$($_.Parent.Name)"
    }
    else {
        "$($_.Name -Replace ".git")"
    }

    $format = @("${repositoryName}", "%h", "%an", "%aI", "%s") -Join "`t"
    $log = git --git-dir="$($_.FullName)" `
               --no-pager `
               log --pretty=format:"$format" `
                   --all `
                   --no-merges `
                   --since="$since" `
                   --author="$author"

    if (!$log) {
        Return
    }

    $commits += $log.split("`r`n") | ForEach-Object {

        $fields = $_.split("`t")

        New-Object PSCustomObject -Property @{
            Author = $fields[2]
            Date = $fields[3]
            Day = $(Get-Date $fields[3]).ToString('yyyy-MM-dd dddd')
            Hash = $fields[1]
            Repository = $fields[0]
            Subject = $fields[4]
            Time = $(Get-Date $fields[3]).ToString('HH:mm:ss')
        }
    }
}

Write-Progress -Activity "$progressBarTitle" `
               -Status "Ready" `
               -Completed

# Log the found commits sorted by date and repository and grouped by day.
$commits | `
Sort-Object -Property Date, Repository `
            -Unique | `
Format-Table -Property Hash, Repository, Author, Time, Subject `
             -GroupBy Day `
             -AutoSize

$stopwatch.Stop()
$durationInSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 3)
Write-Host "Found $($commits.Count) commits in ${durationInSeconds} seconds.`n"
