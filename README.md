# List commits across multiple local Git repositories

A PowerShell script that aggregates a filtered list of commits across multiple local Git repositories. It will sort the found commits by date and repository and then render them in tables grouped by day.

This script enables you to quickly check on what projects you worked on at what specific day. It comes in very handy if you are "abusing" Git commits for time tracking.

## Features

### Recursively finds Git repositories

The script will recusively find all Git repositories within a given `-directory`. If the optional `-directory` param is omitted it will fallback to the current directory `"."`.

### Handles bare and non-bare Git repositories

The script will find both bare and non-bare Git repositories. It follows the convention, that bare repository directories are suffixed with a `.git`.

**Info:** Git repositories come in two flavors: Either bare or non-bare. For bare repository the `$GIT_DIR` is the `<directory>` itself. For non-bare repository the `$GIT_DIR` is in the sub directory `<directory>/.git`.

### Filters authors and time range

The commits can be filtered by a specific author pattern (regular expression) with the `-author` param. If the optional `-author` param is omitted it will fallback to match every author `".*"`.

The commits can be filtered to a specific time range `-since` param. If the optional `-since` param is omitted it will fallback to match every commit since `"1 month ago"`.

### Sorts and groups the commits list

The found commits will be sorted by date and repository and then grouped by day.

## Installation
Download and unpack the [latest release](https://github.com/countzero/list_git_commits/releases/latest) to your machine.

## Usage
Open a PowerShell console at the location of the unpacked release and execute the [./list_git_commits.ps1](https://github.com/countzero/list_git_commits/blob/master/list_git_commits.ps1).

## Examples

### List all commits of all authors in the last month
Execute the following to list all commits of all authors that have been made within the last month across all repositories in the current working directory.
```PowerShell
.\list_git_commits.ps1
```

### List all commits of "John Doe" in the last seven days
Execute the following to list all commits of "John Doe" that have been made within the last seven days across all repositories in the current working directory.
```PowerShell
.\list_git_commits.ps1 -author "John Doe" -since "1 week ago"
```

### List all commits since January 2019 in a specific non-bare Git repository
Execute the following to list all commits of all authors since January 2019 that have been made in a specific non-bare Git repository.
```PowerShell
.\list_git_commits.ps1 -directory "../workspace/list_git_commits" -since "2019-01-01"
```
