# windows euc-kr crlf

# global values
$Global:ConsolePadding = 1
$Global:CursorLeft = 1
$Global:LastCursorLeft = 0
# https://www.whatismybrowser.com/guides/the-latest-user-agent/chrome
$Global:UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36"
$Global:OSBit = if ([IntPtr]::Size -eq 4) { 32 } else { 64 }
$Global:ProgramFiles = if ($OSBit -eq 64) { ${env:ProgramFiles} } else { ${env:ProgramFiles(x86)} }
$Global:ProgramRepository = "https://raw.githubusercontent.com/ssokka/Windows/master"

# $Host.PrivateData.DebugForegroundColor = "DarkYellow"
# $Host.PrivateData.ErrorForegroundColor = "DarkRed"

# for debug
if ($d) {
    $DebugPreference = "Continue"
}

function WindowPositionSize {
    [Alias("wps")]
    param(
        [int] $w = 758, # width 120, 638 (100), 120 (758)
        [int] $h = 472, # height 30, 402 (25), 30 (472)
        [switch] $n = $false # no window position size
    )
    if ($n) {
        return
    }
    Add-Type -AssemblyName System.Windows.Forms
    $area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea
    $x = ($area.Width - $w) / 2
    $y = ($area.Height - $h) / 2
    Add-Type -Name:Window -Namespace:Console -MemberDefinition:'
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H);'
    [Console.Window]::MoveWindow([Console.Window]::GetConsoleWindow(), $x, $y, $w, $h) | Out-Null
    [console]::BufferWidth = [Math]::Min($Host.UI.RawUI.WindowSize.Width, $Host.UI.RawUI.BufferSize.Width)
    [console]::BufferHeight = 9999
}

function WriteHost {
    [Alias("wh")]
    param(
        [object] $o, # object
        [string] $f = "Gray", # forground color
        [int] $c, # console cursor left
        [switch] $d = $true, # display
        [switch] $l, # stop get current cursor left then set last get cursor
        [switch] $n, # new line
        [switch] $r # return
    )
    if (!$d) {
        return
    }
    if ($l) {
        $c = $Global:LastCursorLeft
    }
    if ($o) {
        if (!$c) {
            $c = [Console]::get_CursorLeft()
        }
        if ($c -eq 0) {
            $c = $Global:ConsolePadding
        }
        [Console]::CursorLeft = $c
        if ($o -like "!*") {
            $f = "DarkRed"
        }
        Write-Host $o -NoNewline -ForegroundColor:$f
        if (!$l -and $Global:d) {
            $n = $true
        }
    }
    if ($n) {
        Write-Host
    }
    if (!$l) {
        $Global:CursorLeft = $Global:LastCursorLeft = [Console]::get_CursorLeft()
    }
    if ($Global:d) {
        $Global:CursorLeft = $Global:LastCursorLeft = 1
    }
    if ($r) {
        return $true
    }
}

function WriteTitle {
    [Alias("wt")]
    param(
        [string] $t # title
    )
    $t = "# $t"
    $Host.UI.RawUI.WindowTitle = $t
    Write-Host
    wh $t Green
}

function BeautifulLine {
    [Alias("bl")]
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
    [Alias("wd")]
    param(
        [string] $t, # title
        [object] $o, # object
        [switch] $s = $false # sort
    )
    if ($Global:d) {
        Write-Host
        Write-Debug "# $t`n$(bl $o -s:$s)"
    }
}

function Exit {
    [Alias("e")]
    param(
        [int] $c # exit code
    )
    if ($c -and $c -gt 0) {
		wh -n
        wh "! 오류가 발생했습니다." -n
    }
    if ($Global:p) {
        wh -n
        wh "* 스크립트를 종료합니다. 아무 키나 누르십시오."; [void][Console]::ReadKey($true)
        wh -n
    }
    if ($Global:r) {
        Remove-Item $temp -Recurse -Force | Out-Null
    }
    exit $c
}

function FileInfo {
    [Alias("fi")]
    param(
        [string] $f # file
    )
    $i = [IO.FileInfo] $f
    wd "FileInfo" ($i | Select-Object *)
    return $i
}

function StartProcess {
    [Alias("se")]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({@(".bat",".cmd",".exe","msi") -contains [IO.Path]::GetExtension($_)})]
        [string] $f, # filepath
        [string] $a, # argumentlist
        [string] $v = "Open", # verb
        [ValidateSet("nm","hd","mn","mx")]
        [string] $s = "hd", # windowstyle
        [switch] $w = $true # wait
    )
    if ($f -like "powershell*") {
        if ($a) {
            $a = '-nop -ep bybass -c "& { ' + $a + ' }"'
        }
        $v = "RunAs"
    }
    switch ($s) {
        nm { $WindowStyle = "Normal"; break }
        hd { $WindowStyle = "Hidden"; break }
        mn { $WindowStyle = "Minimized"; break }
        mx { $WindowStyle = "Maximized"; break }
    }
    if ($a) {
        Start-Process $f $a -Verb:$v -WindowStyle:$WindowStyle -Wait:$w
    } else {
        Start-Process $f -Wait
    }
}

function IniReplace {
    [Alias("ir")]
    param (
        [Parameter(Mandatory=$true)]
        [string] $i, # ini file
        [Parameter(Mandatory=$true)]
        [string] $k, # key
        [Parameter(Mandatory=$true)]
        [string] $d # data
    )
    if (!(Test-Path $i)) {
        return
    }
    (Get-Content $i) -Replace ('^('+$k+')=.*?$'), ('$1='+$d) | Set-Content $i
}

function ConvertByteSize {
    [Alias("cbs")]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [AllowNull()]
        [AllowEmptyString()]
        [int64] $b, # byte
        [ValidateScript({@("k","m","g","t") -contains $_})]
        [string] $m = "m", # minimum unit
        [switch] $n # no display unit
    )
    if (!$b -or $b -le 0) {
        $b = 0
    }
    switch ($b) {
        { $_ -lt 1MB } { $u = "KB"; $c = $_/1KB; if ($m -eq "k") { break } }
        { $_ -lt 1GB } { $u = "MB"; $c = $_/1MB; if ($m -eq "m") { break } }
        { $_ -lt 1TB } { $u = "GB"; $c = $_/1GB; if ($m -eq "g") { break } }
        { $_ -lt 1PB } { $u = "TB"; $c = $_/1TB; if ($m -eq "t") { break } }
    }
    if ($n) {
        $u = ""
    }
    return "{0:N1}$u" -f $c
}

function DownloadFile {
    [Alias("download","df","dl")]
    param(
        [Parameter(Mandatory=$true)]
        [string] $u, # uri
        [Parameter(Mandatory=$true)]
        [string] $o, # out
        [switch] $p, # proxy
        [switch] $d = $true, # display
        [switch] $e, # error then exit
        [switch] $r # return
    )
    try {
        $StartTime = Get-Date
        # [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]"Ssl3,Tls,Tls11,Tls12,Tls13"
        $request = [Net.WebRequest]::Create($u)
        $request.UserAgent = $Global:UserAgent
        wd "Request" $request
        $response = $request.GetResponse()
        wd "Response" $response
        $LastModified = $response.LastModified
        $headers = [PSObject]::new()
        $response.Headers.AllKeys | ForEach-Object {
            Add-Member -InputObject $headers -NotePropertyName:$_ -NotePropertyValue:$response.Headers.GetValues($_)[0]
        }
        wd "Headers" $headers
        $GithubApi = [PSCustomObject]@{
            Match = '(?i).*?github.*?/(.*?)/(.*?)/(.*)'
            Remove = @('/blob','/master','\?raw=true')
            Replace = 'https://api.github.com/repos/$1/$2/commits?path=$3&page=1&per_page=1'
            Uri = $u
            Json = $null
            LastCommitDate = $null
        }
        if ($u -match $GithubApi.Match) {
            $GithubApi.Remove | ForEach-Object { $GithubApi.Uri = $GithubApi.Uri -replace $_, "" }
            $GithubApi.Uri = $GithubApi.Uri -replace $GithubApi.Match, $GithubApi.Replace
            $wc = [Net.WebClient]::new()
            $wc.Headers["User-Agent"] = $Global:UserAgent
            $GithubApi.json = $wc.DownloadString($GithubApi.Uri)
            $GithubApi.LastCommitDate = Get-Date ($GithubApi.json | ConvertFrom-Json).commit.author.date
            wd "GithubApi" $GithubApi
            $LastModified = $GithubApi.LastCommitDate
            $p = $true
        }
        # if ($u -match '(?i).*?majorgeeks.com.*?exe$') {
        #     $p = $true
        # }
        $FileInfo = FileInfo $o
        New-Item $FileInfo.Directory -Type Directory -Force | Out-Null
        $DownloadInfo = [PSCustomObject]@{
            FileInfFullName = $FileInfo.FullName
            FileInfoExists = $FileInfo.Exists
            ResponseContentLength = $response.ContentLength
            FileInfoLength = $FileInfo.Length
            LastModified = $LastModified
            FileInfoLastWriteTime = $FileInfo.LastWriteTime
            Task = if ($FileInfo.Exists -and $response.ContentLength -eq $FileInfo.Length -and $LastModified -eq $FileInfo.LastWriteTime) { $false } else { $true }
        }
        wd "DownloadInfo" $DownloadInfo
        if (!$DownloadInfo.Task) {
            if ($r) {
                return $true
            }
            return
        }
        $f = "Yellow"
        wh " 다운로드" $f -d:$d
        if ($p) {
            try {
                $ProxySite = "https://www.proxysite.com/"
                $ProxyUri = "http://us15.proxysite.com/process.php?d"
                $ProxyRequest = [Net.WebRequest]::Create("$ProxyUri=$u")
                $ProxyRequest.UserAgent = $Global:UserAgent
                $ProxyRequest.Referer = $ProxySite
                wd "ProxyRequest" $ProxyRequest
                $ProxyResponse = $ProxyRequest.GetResponse()
                wd "ProxyResponse" $ProxyResponse
                $ProxyHeaders = [PSObject]::new()
                $ProxyResponse.Headers.AllKeys | ForEach-Object {
                    Add-Member -InputObject $ProxyHeaders -NotePropertyName:$_ -NotePropertyValue:$ProxyResponse.Headers.GetValues($_)[0]
                }
                wd "ProxyHeaders" $ProxyHeaders
                $response.Close()
                $response = $ProxyResponse
            }
            catch {
                if ($Global:d) {
                    Write-Error ($_.Exception | Format-List -Force | Out-String) -ErrorAction:Continue
                    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String) -ErrorAction:Continue
                }
            }
            wd "Response" $response
        }
        $ResponseStream = $response.GetResponseStream()
        $buffer = [byte[]]::new(4KB)
        $ReadBuffer = $ResponseStream.Read($buffer,0,$buffer.length)
        $receive = $ReadBuffer
        $FileInfo = [System.IO.FileInfo] $o
        $FileStream = $FileInfo.OpenWrite()
        while ($ReadBuffer -gt 0) {
            $FileStream.Write($buffer, 0, $ReadBuffer)
            $ReadBuffer = $ResponseStream.Read($buffer, 0, $buffer.length)
            $receive = $receive + $ReadBuffer
            wh (" {0}/{1} {2}%" -f ((cbs $receive -n), (cbs $response.ContentLength), ("{0:N0}" -f ($receive/$response.ContentLength*100)))) $f -l -d:$d
        }
        $response.Close()
        $ResponseStream.Dispose()
        $FileStream.Dispose()
        $FileStream.Close()
        $FileInfo.CreationTime = $FileInfo.LastWriteTime = $LastModified
        $TaskTime = (Get-Date).Subtract($StartTime).Seconds
        wh (" {0}s" -f $TaskTime) $f -d:$d
        $FileInfo = FileInfo $o
        if ($r) {
            return $true
        }
    }
    catch {
        wh " 실패" DarkRed -n
        Write-Error ($_.Exception | Format-List -Force | Out-String)
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
        if ($e) {
            e 1
        }
        if ($r) {
            return $false
        }
    }
}
