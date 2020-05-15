# windows euc-kr crlf

# set parameters
Param (
    [switch] $d2coding, # install d2coding.ttc
    [switch] $install, # install 30day trial
    [switch] $restore, # restore my data
    [switch] $setting, # setting
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
    Write-Host " ! ������ �߻��߽��ϴ�.`n" -ForegroundColor:DarkRed
    Write-Host " * ��ũ��Ʈ�� �����մϴ�. �ƹ� Ű�� �����ʽÿ�.`n" -NoNewline -ForegroundColor:Gray; [void][Console]::ReadKey($true)
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
$ProgramInfo | Add-Member Version 6 -MemberType:NoteProperty
$ProgramInfo | Add-Member Company "NetSarang" -MemberType:NoteProperty
$ProgramInfo | Add-Member Directory "$ProgramFiles\$($ProgramInfo.Company)\$($ProgramInfo.Name) $($ProgramInfo.Version)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Executable "$($ProgramInfo.Name).exe" -MemberType:NoteProperty
$ProgramInfo | Add-Member Registry "Software\$($ProgramInfo.Company)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Repository "$ProgramRepository/$($ProgramInfo.Name)" -MemberType:NoteProperty
$ProgramInfo | Add-Member Download "https://www.majorgeeks.com/mg/getmirror/xshell,1.html" -MemberType:NoteProperty
wd "ProgramInfo" $ProgramInfo

# file info for debug
$FileInfo = fi "$($ProgramInfo.Directory)\$($ProgramInfo.Executable)"

if ($d2coding) {
    $ps1 = "font.ps1"
    if (df "$repository/Windows/master/Font/$ps1" "$temp\$ps1" -d:$false -r) {
        & "$temp\$ps1" -p:$false
    }
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
    $url = [Net.WebClient]::new().DownloadString($ProgramInfo.Download) -replace '(?is).*(http.*?exe).*', '$1'
    df $url "$temp\$($ProgramInfo.Executable)" -e
    wh " ��ġ" $f
    se reg.exe "delete `"HKCU\$($ProgramInfo.Registry)`" /f"
    se reg.exe "delete `"HKLM\$($ProgramInfo.Registry)`" /f /reg:32" "RunAs"
    $iss | ForEach-Object {
        se "$temp\$($ProgramInfo.Executable)" "-s -f1`"$temp\$_`""
    }
    wh -n
}

$FileInfo = fi "$($ProgramInfo.Directory)\$($ProgramInfo.Executable)"

if ($restore -and $FileInfo.Exists) {
    $exe = 'restore.exe'
    if (df "$($ProgramInfo.Repository)/$exe" "$temp\$exe" -d:$false -r) {
        wt "$title"
        wh " ���� �ڷ� ����" $f
        se "$temp\$exe"
        wh -n
    }
}

if ($setting -and $FileInfo.Exists) {
    $c = 3
    wt "$title"
    wh " ����" $f -n
    # user data folder
    $udf = "${env:USERPROFILE}\Documents\NetSarang Computer\$($ProgramInfo.Version)"
    se reg.exe "add `"HKCU\$($ProgramInfo.Registry)\Common\$($ProgramInfo.Version)\UserData`" /v UserDataPath /t REG_SZ /d `"$udf`" /f"
    $drv = @(Get-WmiObject -class win32_logicaldisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID -ne "C:" })[0].DeviceID
    if ($drv) {
        $lnk = "$drv\Programs\$($ProgramInfo.Name)"
        Move-Item "$udf\*" $lnk -Force -ErrorAction:SilentlyContinue
        Remove-Item $udf -Recurse -ErrorAction:SilentlyContinue
        se cmd.exe "/c mklink /d `"$udf`" `"$lnk`"" "RunAs"
    }
    New-Item $udf -Type:Directory -Force | Out-Null
    wh "* ����� ������ ���� : $udf" -c:$c -n
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
  * �޴� > ���� > ���� ��� ����
     > ����
       [V] ����ġ �ʰ� ������ ������ �� �ڵ����� �ٽ� ����
       > ���� ����
         [V] ��Ʈ��ũ�� ���� ������ �� ���ڿ��� ����
         ����: 280��, ���ڿ�:  (������ĭ)
         [V] ��Ʈ��ũ�� ���� ������ �� TCP ���� ���� ��Ŷ ����
     > �͹̳�
       �͹̳� ����: linux
       ���� ũ��: 200000
     > ���
       �� ����ǥ: New Black
       �۲�: D2Coding
       �ѱ� �۲�: D2Coding
       �۲� ǰ��: Natural ClearType
     > ����
       > �α�
         [ ] ������ �����ϴ� ��� �����
         [V] ���� �� �α� ����
         [V] �α� ���Ͽ� ���
     * ���� ����
"@) -n
    Get-ChildItem "$udf\$($ProgramInfo.Name)\Sessions\" -Include @("default", "*.xsh") -Recurse | ForEach-Object {
        ir $_ "AutoReconnect" "1"
        ir $_ "SendKeepAlive" "1"
        ir $_ "SendKeepAliveInterval" "280"
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
        ir $_ "WriteFileTimestamp" "1"
        wh $_ -c:7 -n
    }
}

if ($keymap -and $FileInfo.Exists) {
    $exe = 'keymap.exe'
    df "$($ProgramInfo.Repository)/$exe" "$temp\$exe" -d:$false
    if (Test-Path "$temp\$exe") {
        wt "$title"
        wh " ���� Ű ���� �߰� ����" $f
        se "$temp\$exe"
        wh -n
    }
}