param (
    [switch] $debug,
    [switch] $verbose
)

$repository = "https://raw.githubusercontent.com/ssokka"

# default url
if (!$url) {
    $url = "$repository/Fonts/master/$file"
}

# working directory
$temp = "${env:TEMP}\ssokka"
New-Item $temp -Type Directory -Force | Out-Null

# module download and import
try {
    $module = "module.psm1"
    if ((!(Test-Path $module) -or $m) -and !$t) {
        [Net.WebClient]::new().DownloadFile("$repository/Windows/master/PowerShell/$module", "$temp\$module")
    }
    Import-Module "$temp\$module" -ErrorAction:Stop
}
catch {
    Write-Error ($_.Exception | Format-List -Force | Out-String)
    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    Write-Host " ! 오류가 발생했습니다.`n" -ForegroundColor DarkRed
    Write-Host " * 스크립트를 종료합니다. 아무 키나 누르십시오.`n" -NoNewline -ForegroundColor Gray; [void][Console]::ReadKey($true)
    exit 1
}

$ps1 = "font.ps1"
df "$repository/Windows/master/PowerShell/$ps1" "$temp\$ps1" -d:$false
if (Test-Path "$temp\$ps1") {
    & "$temp\$ps1"
}

exit

$title = '명령 프롬프트 - powershell'



$file = "D2Coding.ttc"
$url = "https://raw.githubusercontent.com/ssokka/Fonts/master"
$url = "$url/$file"
$url = "https://raw.githubusercontent.com/ssokka/Fonts/master/$file"
# $url = 'http://us15.proxysite.com/process.php?d=https://raw.githubusercontent.com/ssokka/Fonts/master/D2Coding.ttc'

# $file = "test.jpg"
# $url = 'https://t.me/c/1199424013/7'

$out = "$env:TEMP\$file"

df $url $out -r:$false

exit

wh " 다운로드 " $fc
$Global:event = $null;
$Global:dfc = $false;
$wc = [System.Net.WebClient]::new()
$wc.Headers["User-Agent"] = $ua
wd "WebClient 생성자" $wc
$st = Get-Date
$task = $wc.DownloadFileTaskAsync($url, $out)
Register-ObjectEvent $wc DownloadProgressChanged WebClient.DownloadProgressChanged {
    $Global:event = $event
} | Out-Null
Register-ObjectEvent $wc DownloadFileCompleted WebClient.DownloadFileComplete {
    $Global:dfc = $true;
    Unregister-Event WebClient.DownloadProgressChanged;
    Unregister-Event WebClient.DownloadFileComplete;
} | Out-Null
while (!$Global:dfc) {
    if ($task.IsFaulted) {
        # throw
        break
    }
    $p = $Global:event.SourceArgs.ProgressPercentage
    if (!$p) {
        continue
    }
    $t = cbs $($Global:event.SourceArgs.TotalBytesToReceive)
    $r = cbs $($Global:event.SourceArgs.BytesReceived)
    [Console]::CursorLeft = $Global:CursorLeft
    [Console]::ForegroundColor = $fc
    [Console]::Write("{0}/{1} {2}%" -f ($r,$t,$p))
}
$et = (Get-Date).Subtract($st).Seconds
$awc += $et
$cavg += $et
wh " $et(s)" $fc -n
$wc.CancelAsync()
$wc.Dispose()

# catch {
#     wh "실패`n" DarkRed -nl
#     Write-Error ($task | Format-List | Out-String)
#     Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
#     Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
# }
# finally {
    # $wc.CancelAsync()
    # $wc.Dispose()
# }

# }

# function OLD-DownloadFile {
#     [CmdletBinding()]
#     [Alias("download","df,""dl")]
#     param (
#         [Parameter(Mandatory=$true,Position=0)]
#         [string] $url,
#         [Parameter(Mandatory=$true,Position=1)]
#         [string] $file,
#         [Parameter(Position=2)]
#         [switch] $nl,
#         [switch] $ret
#     )
#     try {
#         wh ($space + "다운로드") DarkYellow
#         $cLen = [Net.WebRequest]::Create($url).GetResponse().Headers.GetValues("Content-Length")[0]
#     }
#     catch {
#         $eMsg = $_.Exception.Message
#     }
#     if (!$eMsg -and ($null -eq $cLen -or $cLen -ne (fi $file).Length)) {
#         try {
#             # [Net.WebClient]::new().DownloadFile($url, $file)
#             $client = New-Object WebClient;
#             $client.Timeout = 1800000
#             $client.DownloadFile($url, $file)
#         }
#         catch {
#             $eMsg = $_.Exception.Message
#         }
#     }
#     $info = fi $file
#     if (!$eMsg) {
#         if (!$info.Exist) {
#             $eMsg = "파일이 존재하지 않습니다."
#         }
#         if ($info.Length -eq 0 -or $info.Length -ne $cLen) {
#             "`n" + $info.Length.GetType()
#             $cLen.GetType()
#             $eMsg = "파일이 손상되었습니다."
#         }
#     }
#     if ($eMsg) {
#         $eMsg = $space + "실패`n" + $space + "! " + $eMsg + "`n"
#         $eMsg += $space + "! `$url = $url" + $(if ($cLen) { " [$cLen]" }) + "`n"
#         $eMsg += $space + "! `$file = $file" + $(if ($info.Length) { " [$info.Length]" })
#         wh ($eMsg) DarkRed -nl
#         if ($ret) {
#             return $false
#         }
#     }
#     if ($nl) {
#         wh -nl
#     }
#     if ($ret) {
#         return $true
#     }
# }

function ClearCurrentLine {
    [CmdletBinding()]
    [Alias("ccl")]
    param ()
	Write-Host "`r" -NoNewline;
	1..($Host.UI.RawUI.BufferSize.Width - 1) | ForEach-Object { Write-Host " " -NoNewline }
	Write-Host "`r" -NoNewline;
}
