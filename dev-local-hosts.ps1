If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "-File " + $myinvocation.mycommand.definition + " "+$args+""
    Write-Host "Args: $args"
    Write-Host "Running as admin: $arguments $args"
    Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments
    break
}

#
# Powershell script for adding/removing/showing entries to the hosts file.
# https://gist.github.com/markembling/173887
# Known limitations:
# - does not handle entries with comments afterwards ("<ip>    <host>    # comment")
#

$file = "C:\Windows\System32\drivers\etc\hosts"
function add-host([string]$filename, [string]$ip, [string]$hostname) {
    remove-host $filename $hostname
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename

    Write-Host "Added host $ip $hostname"
}

function remove-host([string]$filename, [string]$hostname) {
    $c = Get-Content $filename
    $newLines = @()

    foreach ($line in $c) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2) {
            if ($bits[1] -ne $hostname) {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }

    # Write file
    Clear-Content $filename
    foreach ($line in $newLines) {
        $line | Out-File -encoding ASCII -append $filename
    }

    Write-Host "Removed host $hostname"
}

function print-hosts([string]$filename) {
    $c = Get-Content $filename

    foreach ($line in $c) {
        $bits = [regex]::Split($line, "[\t\s]{1,}")
        if ($bits.count -eq 2) {
            Write-Host $bits[0] `t`t $bits[1]
        }
    }
}

try {
    if ($args[0] -eq "add") {

        if ($args.count -lt 3) {
            throw "Not enough arguments for add: $args"
        } else {
            add-host $file $args[1] $args[2]
        }

    } elseif ($args[0] -eq "remove") {

        if ($args.count -lt 2) {
            throw "Not enough arguments for remove: $args"
        } else {
            remove-host $file $args[1]
        }

    } elseif ($args[0] -eq "show") {
        print-hosts $file
    } else {
        throw "Invalid operation '" + $args[0] + "' - must be one of 'add', 'remove', 'show'."
    }
} catch  {
    Write-Host $error[0]
    Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
}

Write-Host "`n`nPress any key to exit scrpt ..."; 
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") > $null;