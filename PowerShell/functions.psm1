$Global:ConsolePadding = 1
$Global:CursorLeft = 1
$Global:LastCursorLeft = 0
# https://www.whatismybrowser.com/guides/the-latest-user-agent/chrome
$Global:UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36'

$host.PrivateData.DebugForegroundColor = 'DarkYellow'
$host.PrivateData.ErrorForegroundColor = 'DarkRed'

if ($debug) {
    $DebugPreference = 'Continue'
}
if ($verbose) {
    $VerbosePreference = 'Continue'
}

function WriteHost {
    [Alias('wh')]
    param(
        [object] $o, # object
        [string] $f = 'Gray', # forground color
        [int] $c = [Console]::get_CursorLeft(), # console cursor left
        [switch] $l, # stop get current cursor left then set last get cursor
        [switch] $n, # new line
        [switch] $r # return
    )
    if ($l) {
        $c = $Global:LastCursorLeft
    }
    if ($o) {
        [Console]::CursorLeft = $c
        Write-Host $o -NoNewline -ForegroundColor $f
        if (!$l -and $debug) {
            $n = $true
        }
    }
    if ($n) {
        Write-Host
    }
    if (!$l) {
        $Global:CursorLeft = $Global:LastCursorLeft = [Console]::get_CursorLeft()
    }
    if ($debug) {
        $Global:CursorLeft = $Global:LastCursorLeft = 1
    }
    if ($r) {
        return $true
    }
}

function WriteTitle {
    [Alias('wt')]
    param (
        [string] $t # title
    )
    $t = "# $t"
    $Host.UI.RawUI.WindowTitle = $t
    Write-Host
    wh $t DarkGreen $Global:ConsolePadding
}

function BeautifulLine {
    [Alias('bl')]
    param(
        [object] $o, # object
        [switch] $s = $false # sort
    )
    $o = $o | Format-List -Force | Out-String -Stream
    if ($s) {
        $o = $o | Sort-Object
    }
    $o = $o | Out-String | ForEach-Object { $_.Trim() }
    return $o
}

function WriteDebug {
    [Alias('wd')]
    param(
        [string] $t, # title
        [object] $o, # object
        [switch] $s = $false # sort
    )
    if ($debug) {
        Write-Host
        Write-Debug ("# {0}`n{1}" -f ($t, (bl $o -s:$s)))
    }
}

function FileInfo {
    [Alias('fi')]
    param (
        [string] $f # file
    )
    $i = [IO.FileInfo] $f
    wd 'FileInfo' ($i | Select-Object *)
    return $i
}

function Sudo {
    [Alias('admin','root')]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({@('.bat','.cmd','.exe','msi') -contains [IO.Path]::GetExtension($_)})]
        [string] $e, # exec
        [Parameter(Mandatory=$true)]
        [string] $a, # arguments
        [ValidateSet('nm','hd','mn','mx')]
        [string] $w = 'hd', # window style
        [switch] $n =$true # no wait
    )
    if ($e -like 'powershell*') {
        $a = '-nop -ep bybass -c "& { ' + $a + ' }"'
    }
    switch ($w) {
        nm { $WindowStyle = 'Normal'; break }
        hd { $WindowStyle = 'Hidden'; break }
        mn { $WindowStyle = 'Minimized'; break }
        mx { $WindowStyle = 'Maximized'; break }
    }
    Start-Process $e $a -Verb RunAs -WindowStyle $WindowStyle -Wait:$n
}

function ConvertByteSize {
    [Alias('cbs')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [AllowNull()]
        [AllowEmptyString()]
        [int64] $b, # byte
        [ValidateScript({@('k','m','g','t') -contains $_})]
        [string] $m = 'm', # minimum unit
        [switch] $n # no display unit
    )
    if (!$b -or $b -le 0) {
        $b = 0
    }
    switch ($b) {
        { $_ -lt 1MB } { $u = 'KB'; $c = $_/1KB; if ($m -eq 'k') { break } }
        { $_ -lt 1GB } { $u = 'MB'; $c = $_/1MB; if ($m -eq 'm') { break } }
        { $_ -lt 1TB } { $u = 'GB'; $c = $_/1GB; if ($m -eq 'g') { break } }
        { $_ -lt 1PB } { $u = 'TB'; $c = $_/1TB; if ($m -eq 't') { break } }
    }
    if ($n) {
        $u = ''
    }
    return "{0:N1}$u" -f $c
}

function DownloadFile {
    [Alias('download','df','dl')]
    param (
        [Parameter(Mandatory=$true)]
        [string] $u, # uri
        [Parameter(Mandatory=$true)]
        [string] $o, # out
        [switch] $p, # proxy
        [switch] $r = $true
    )
    try {
        # [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12,Tls13'
        $request = [Net.WebRequest]::Create($u)
        $request.UserAgent = $Global:UserAgent
        wd 'Request' $request
        $response = $request.GetResponse()
        wd 'Response' $response
        $LastModified = $response.LastModified
        $headers = [PSObject]::new()
        $response.Headers.AllKeys | ForEach-Object {
            Add-Member -InputObject $headers -NotePropertyName $_ -NotePropertyValue $response.Headers.GetValues($_)[0]
        }
        wd 'Headers' $headers
        $GithubApi = [PSCustomObject]@{
            Match = '(?i).*?github.*?/(.*?)/(.*?)/(.*)'
            Remove = @('/blob','/master','\?raw=true')
            Replace = 'https://api.github.com/repos/$1/$2/commits?path=$3&page=1&per_page=1'
            Uri = $u
            Json = $null
            LastCommitDate = $null
        }
        if ($u -match $GithubApi.Match) {
            $GithubApi.Remove | ForEach-Object { $GithubApi.Uri = $GithubApi.Uri -replace $_, '' }
            $GithubApi.Uri = $GithubApi.Uri -replace $GithubApi.Match, $GithubApi.Replace
            $wc = [Net.WebClient]::new()
            $wc.Headers['User-Agent'] = $Global:UserAgent
            $GithubApi.json = $wc.DownloadString($GithubApi.Uri)
            $GithubApi.LastCommitDate = Get-Date ($GithubApi.json | ConvertFrom-Json).commit.author.date
            wd "GithubApi" $GithubApi
            $LastModified = $GithubApi.LastCommitDate
            $p = $true
        }
        $FileInfo = FileInfo $o
        $Download = [PSCustomObject]@{
            FileInfoExists = $FileInfo.Exists
            ResponseContentLength = $response.ContentLength
            LastModified = $LastModified
            FileInfoLastWriteTime = $FileInfo.LastWriteTime
            Task = if ($FileInfo.Exists -and $response.ContentLength -eq $FileInfo.Length -and $LastModified -eq $FileInfo.LastWriteTime) { $false } else { $true }
        }
        wd "Download" $Download
        if (!$Download.Task) {
            if ($r) {
                return $true
            } else {
                return
            }
        }
        $f = 'DarkYellow'
        if ($debug) {
            $f = 'White'
            wh -n
        }
        wh ' 다운로드 ' $f
        $StartTime = Get-Date
        if ($p) {
            try {
                $ProxySite = 'https://www.proxysite.com/'
                $ProxyUri = 'http://us15.proxysite.com/process.php?d'
                $ProxyRequest = [Net.WebRequest]::Create("$ProxyUri=$u")
                $ProxyRequest.UserAgent = $Global:UserAgent
                $ProxyRequest.Referer = $ProxySite
                wd 'ProxyRequest' $ProxyRequest
                $ProxyResponse = $ProxyRequest.GetResponse()
                wd 'ProxyResponse' $ProxyResponse
                $ProxyHeaders = [PSObject]::new()
                $ProxyResponse.Headers.AllKeys | ForEach-Object {
                    Add-Member -InputObject $ProxyHeaders -NotePropertyName $_ -NotePropertyValue $ProxyResponse.Headers.GetValues($_)[0]
                }
                wd 'ProxyHeaders' $ProxyHeaders
                $response = $ProxyResponse
            }
            catch {
                if ($debug) {
                    Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
                    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
                }
            }
            wd 'Response' $response
        }
        $fi = [System.IO.FileInfo] $o
        $fs = $fi.OpenWrite()
        $cl = $response.ContentLength
        $rs = $response.GetResponseStream()
        $bf = [byte[]]::new(4KB)
        $rf = $rs.Read($bf,0,$bf.length)
        $rc = $rf
        while ($rf -gt 0) {
            $fs.Write($bf, 0, $rf)
            $rf = $rs.Read($bf,0,$bf.length)
            $rc = $rc + $rf
            wh ('{0}/{1} {2}%' -f ((cbs $rc -n), (cbs $cl), ('{0:N0}' -f ($rc/$cl*100)))) $f -l
        }
        $response.Close()
        $rs.Dispose()
        $fs.Dispose()
        $fs.Close()
        $fi.CreationTime = $fi.LastWriteTime = $LastModified
        $TaskTime = (Get-Date).Subtract($StartTime).Seconds
        wh " $TaskTime(s)" $f
        $FileInfo = FileInfo $o
        if ($r) {
            return $true
        } else {
            return
        }
    }
    catch {
        wh "실패" DarkRed -n
        Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction Continue
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
        if ($r) {
            return $false
        } else {
            return
        }
    }
}

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
