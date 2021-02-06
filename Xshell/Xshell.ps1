# windows euc-kr crlf

# set parameters
Param (
    [switch] $d2coding, # install d2coding.ttc
    [switch] $install, # install trial 30 day
    [switch] $setting, # setting
    [switch] $restore, # restore my data
    [switch] $keymap, # keymap
    [switch] $m, # force download module.psm1
    [switch] $r, # remove working directory
    [switch] $p, # pause then exit
    [switch] $d, # debug mode
    [switch] $t # test mode
)

$repository = "https://raw.githubusercontent.com/ssokka"

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
$title = "Xshell"

# program info
$ProgramFiles = if ($OSBit -eq 64) { ${env:ProgramFiles(x86)} } else { ${env:ProgramFiles} }
$ProgramInfo = [PSCustomObject]@{}
$ProgramInfo | Add-Member Name $title -MemberType:NoteProperty
$ProgramInfo | Add-Member Version 7 -MemberType:NoteProperty
$ProgramInfo | Add-Member Company "NetSarang" -MemberType:NoteProperty
$ProgramInfo | Add-Member Directory "$ProgramFiles\$($ProgramInfo.Company)\$($ProgramInfo.Name) $($ProgramInfo.Version)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Executable "$($ProgramInfo.Name).exe" -MemberType:NoteProperty
$ProgramInfo | Add-Member Registry "Software\$($ProgramInfo.Company)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Repository "$ProgramRepository/$($ProgramInfo.Name)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Download "https://www.filehorse.com/download-xshell-free/download/" -MemberType:NoteProperty
wd "ProgramInfo" $ProgramInfo

# file info for debug
$FileInfo = fi "$($ProgramInfo.Directory)\$($ProgramInfo.Executable)"

if ($d2coding) {
    if ($p) {
        $p = $false
        $b = $true
    }
    $ps1 = "font.ps1"
    if (df "$repository/Windows/master/Font/$ps1" "$temp\$ps1" -d:$false -r) {
        & "$temp\$ps1"
    }
    $p = $b
}

# kill program
se taskkill.exe "/im `"$($ProgramInfo.Executable)`" /t /f"

$f = "Yellow"

if ($install) {
    wt "$title"
    $iss = @('uninstall.iss', 'install.iss')
    $iss | ForEach-Object {
        df "$($ProgramInfo.Repository)/$_" "$temp\$_" -d:$false -e
    }
    $url = [Net.WebClient]::new().DownloadString($ProgramInfo.Download) -replace '(?is).*(https://www.filehorse.com/download/file/.*?)".*', '$1'
    df $url "$temp\$($ProgramInfo.Executable)" -e
    wh " 설치" $f
    se reg.exe "delete `"HKCU\$($ProgramInfo.Registry)`" /f"
    se reg.exe "delete `"HKLM\$($ProgramInfo.Registry)`" /f /reg:32" "RunAs"
    $iss | ForEach-Object {
        se "$temp\$($ProgramInfo.Executable)" "-s -f1`"$temp\$_`""
    }
    wh -n
}

$FileInfo = fi "$($ProgramInfo.Directory)\$($ProgramInfo.Executable)"

if ($setting -and $FileInfo.Exists) {
    $c = 3
    wt "$title"
    wh " 설정" $f -n
    # user data folder
    $udf = "${env:USERPROFILE}\Documents\NetSarang Computer\$($ProgramInfo.Version)"
    se reg.exe "add `"HKCU\$($ProgramInfo.Registry)\Common\$($ProgramInfo.Version)\UserData`" /v UserDataPath /t REG_SZ /d `"$udf`" /f"
    # $drv = @(Get-WmiObject -class win32_logicaldisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID -ne $env:SystemDrive })[0].DeviceID
    # if ($drv) {
    #     $dst = "$drv\Programs\$($ProgramInfo.Name)"
    #     New-Item $dst -Type:Directory -Force | Out-Null
    #     Move-Item "$udf\*" $dst -Force -ErrorAction:SilentlyContinue
    #     Remove-Item $udf -Recurse -ErrorAction:SilentlyContinue
    #     se cmd.exe "/c mklink /d `"$udf`" `"$dst`"" "RunAs"
    # }
    wh "* 사용자 데이터 폴더 : $udf" -c:$c -n
    # https://github.com/ssokka/Windows/blob/master/Xshell/setting.reg
    $reg = "setting.reg"
    if (df "$($ProgramInfo.Repository)/$reg" "$temp\$reg" -d:$false -r) {
        se regedit.exe "/s `"$temp\$reg`"" "RunAs"
        Get-Content "$temp\$reg" | ForEach-Object {
            if ($_ -like ";*") {
                wh ($_ -replace '^;', '*') -c:$c -n
            }
        }
    }
    $ini = "$($ProgramInfo.Name).ini"
    if (df "$($ProgramInfo.Repository)/$ini" "$temp\$ini" -d:$false -r) {
        Copy-Item "$temp\$ini" "$udf\$($ProgramInfo.Name)\$ini"
        Get-Content "$temp\$ini" | ForEach-Object {
            if ($_ -like ";*") {
                wh ($_ -replace '^;', '*') -c:$c -n
            }
        }
    }
    # session
    wh (@"
  * 메뉴 > 파일 > 세션 등록 정보
     > 연결
       [V] 예기치 않게 연결이 끊겼을 때 자동으로 다시 연결
       > SSH
         [V] 처음 연결시 자동으로 수락 및 호스트 키 저장
       > 연결 유지
         [V] 네트워크가 유휴 상태일 때 문자열을 보냄
         간격: 290초, 문자열:  (공백한칸)
         [V] 네트워크가 유휴 상태일 때 TCP 연결 유지 패킷 보냄
     > 터미널
       터미널 종류: linux
       버퍼 크기: 200000
     > 모양
       색 구성표: New Black
       글꼴: D2Coding
       한글 글꼴: D2Coding
       글꼴 품질: Natural ClearType
     > 고급
       > 로깅
         [ ] 파일이 존재하는 경우 덮어쓰기
         [V] 연결 시 로깅 시작
         [ ] 로그 파일에 기록
  * 적용 파일
"@) -n
    Get-ChildItem "$udf\$($ProgramInfo.Name)\Sessions\" -Include @("default", "*.xsh") -Recurse | ForEach-Object {
        ir $_ "AutoReconnect" "1"
        ir $_ "SaveHostKey" "1"
        ir $_ "SendKeepAlive" "1"
        ir $_ "SendKeepAliveInterval" "290"
        ir $_ "KeepAliveString" " "
        ir $_ "TCPKeepAlive" "1"
        ir $_ "Type" "linux"
        ir $_ "ScrollbackSize" "200000"
        ir $_ "ColorScheme" "New Black"
        if (Test-Path "${env:SystemRoot}\Fonts\D2Coding*") {
            ir $_ "FontFace" "D2Coding"
            ir $_ "AsianFont" "D2Coding"
        }
        ir $_ "FontQuality" "6"
        ir $_ "Overwrite" "0"
        ir $_ "AutoStart" "1"
        ir $_ "WriteFileTimestamp" "0"
        wh $_ -c:7 -n
    }
}

if ($restore -and $FileInfo.Exists) {
    $exe = 'restore.exe'
    if (df "$($ProgramInfo.Repository)/$exe" "$temp\$exe" -d:$false -r) {
        wt "$title"
        wh " 개인 자료 복원" $f
        se "$temp\$exe"
        wh -n
    }
}

# if ($keymap -and $FileInfo.Exists) {
#     $exe = 'keymap.exe'
#     df "$($ProgramInfo.Repository)/$exe" "$temp\$exe" -d:$false
#     if (Test-Path "$temp\$exe") {
#         wt "$title"
#         wh " 개인 키 매핑 추가 설정" $f
#         se "$temp\$exe"
#         wh -n
#     }
# }

wh -n
if ($p) {
    e 0
}
