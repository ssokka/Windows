# windows euc-kr crlf

# parameters
Param (
    [ValidateScript({@(".ttc",".ttf") -contains [IO.Path]::GetExtension($_)})]
    [string] $file = "D2Coding.ttc",
    [string] $url,
    [switch] $m, # force download module.psm1
    [switch] $r, # remove working directory
    [switch] $p, # pause then exit
    [switch] $d, # debug mode
    [switch] $t # test mode
)

$repository = "https://raw.githubusercontent.com/ssokka"

# default url
if (!$url) {
    $url = "$repository/Fonts/master/$file"
}

# working directory
$temp = "${env:TEMP}\ssokka"
New-Item $temp -Type:Directory -Force | Out-Null

# module download and import
try {
    $module = "module.psm1"
    if ($t) {
        Copy-Item $module "$temp\$module" -Force
    } else {
        if ((!(Test-Path $module) -or $m)) {
            [Net.WebClient]::new().DownloadFile("$repository/Windows/master/PowerShell/$module", "$temp\$module")
        }
    }
    Import-Module "$temp\$module" -ErrorAction:Stop
}
catch {
    Write-Error ($_.Exception | Format-List -Force | Out-String)
    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    Write-Host " ! 오류가 발생했습니다.`n" -ForegroundColor:DarkRed
    Write-Host " * 스크립트를 종료합니다. 아무 키나 누르십시오.`n" -NoNewline -ForegroundColor:Gray; [void][Console]::ReadKey($true)
    exit 1
}

# window position and size
wps -n:$t

# title
wt "글꼴"

# font files
$tff = "$temp\$file"
$sff = "${env:SystemRoot}\Fonts\$file"
$uff = "${env:LOCALAPPDATA}\Microsoft\Windows\Fonts\$file"

# font registry keys
$frk = "Microsoft\Windows NT\CurrentVersion\Fonts"
$srk = "HKLM:\SOFTWARE\$frk"
$urk = "HKCU:\Software\$frk"

$f = "DarkYellow"

# check system font file
if (Test-Path $sff) {
    wh " $file 설치" $f -n
    e 0
}

# check user font file
if (!(Test-Path $uff)) {
    df $url $tff -e
    $i = wh " $file 설치" $f -r
    (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($tff)
    if (!(Test-Path $uff)) {
        wh " 실패" DarkRed -n
        wh "! 파일이 존재하지 않습니다." -n
        wh "! $uff"
        e 1
    }
}

if (!$i) {
    wh " $file 설치" $f
}

# check user registry font name
$urn = (Get-ItemProperty $urk).PSObject.Properties | Where-Object Value -like "*$file" | Select-Object -ExpandProperty:Name
if ($urn) {
    # check system registry font name and file
    if ((Get-ItemProperty $srk $urn -ErrorAction:SilentlyContinue) -and (Test-Path $sff)) {
        e 0
    }
} else {
    wh " 실패" DarkRed -n
    wh "! 글꼴 이름이 존재하지 않습니다." -n
    wh "! $tff"
    e 1
}

# copy user font file to system font file
run powershell.exe "Copy-Item '$uff' '$sff' -Force"
if (!(Test-Path $sff)) {
    wh " 실패" DarkRed -n
    wh "! 파일이 존재하지 않습니다." -n
    wh "! $sff"
    e 1
}

# remove user font regisrty and file
run powershell.exe "Stop-Service FontCache"
Remove-ItemProperty $urk $urn
run powershell.exe "Remove-Item $uff -Force"
run powershell.exe "Start-Service FontCache"

# add system registry font name
run powershell.exe "New-ItemProperty '$srk' '$urn' -PropertyType:String -Value '$file'"
$srn = (Get-ItemProperty $srk).PSObject.Properties | Where-Object Value -like "*$file" | Select-Object -ExpandProperty:Name
if (!$srn) {
    wh " 실패" DarkRed -n
    wh "! 글꼴 이름이 존재하지 않습니다." -n
    wh "! $srk"
    e 1
}
if (!$e -and $srn -ne $urn) {
    run powershell.exe "Remove-ItemProperty '$srk' '$srn'"
    Remove-Item $sff -Force
    wh " 실패" DarkRed -n
    wh "! 글꼴 이름이 다릅니다." -n
    wh "! $urn ≠ $srk"
    e 1
}

wh -n
e 0
