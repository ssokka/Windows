# windows euc-kr crlf

# set parameters
Param (
    [ValidateScript({@('.ttc','.ttf') -contains [IO.Path]::GetExtension($_)})]
    [string] $file = 'D2Coding.ttc',
    [string] $url = "https://raw.githubusercontent.com/ssokka/Fonts/master/$file",
    [switch] $m,            # force download module.psm1
    [switch] $p,            # pause then exit
    [switch] $d,            # debug mode
    [switch] $t             # test mode
)

# set messages
$ErrorMessage = " ! ������ �߻��߽��ϴ�.`n"
$ExitMessage = " * ��ũ��Ʈ�� �����մϴ�. �ƹ� Ű�� �����ʽÿ�.`n"

# download and import main.psm1
try {
    $module = 'module.psm1'
    if ((!(Test-Path $module) -or $m) -and !$t) {
        $temp = "${env:TEMP}\ssokka"
        New-Item $temp -Type Directory -Force | Out-Null
        Push-Location $temp
        [Net.WebClient]::new().DownloadFile("https://raw.githubusercontent.com/ssokka/Windows/master/PowerShell/$module", "$temp\$module")
    }
    Import-Module "$temp\$module" -ErrorAction:Stop
}
catch {
    Write-Error ($_.Exception | Format-List -Force | Out-String)
    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    Write-Host $ErrorMessage -ForegroundColor DarkRed
    Write-Host $ExitMessage -NoNewline -ForegroundColor Gray; [void][Console]::ReadKey($true)
    exit 1
}

# set window position size
wps -n:$t

# set title
wt "$file �۲�"

# set font files
$tff = [IO.Path]::Combine(${env:TEMP}, $file)
$sff = [IO.Path]::Combine(${env:SystemRoot}, 'Fonts', $file)
$uff = [IO.Path]::Combine(${env:LOCALAPPDATA}, 'Microsoft', 'Windows', 'Fonts', $file)

# set font registry keys
$frk = 'Microsoft\Windows NT\CurrentVersion\Fonts'
$srk = "HKLM:\SOFTWARE\$frk"
$urk = "HKCU:\Software\$frk"

# check system font file
if (Test-Path $sff) {
    wh ' ��ġ' DarkGreen -n
    e 0
}

# check user font file
if (!(Test-Path $uff)) {
    if (!(df $url $tff -e -r)) {
        e 1
    }
    $i = wh ' ��ġ' DarkGreen -r
    adm powershell.exe "(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere('$tff')"
    if (!(Test-Path $uff)) {
        wh ' ����' DarkRed -n
        wh "! ������ �������� �ʽ��ϴ�." -n
        wh "! `$uff = $uff"
        e 1
    }
}

if (!$i) {
    wh ' ��ġ' DarkGreen
}

# check user registry font name
$urn = (Get-ItemProperty $urk).PSObject.Properties | Where-Object Value -like *$file | Select-Object -ExpandProperty Name
if ($urn) {
    # check system registry font name and file
    if ((Get-ItemProperty $srk $urn -ErrorAction SilentlyContinue) -and (Test-Path $sff)) {
        e 0
    }
} else {
    wh ' ����' DarkRed -n
    wh "! �۲� �̸��� �������� �ʽ��ϴ�." -n
    wh "! $tff"
    e 1
}

# copy user font file to system font file
adm powershell.exe "Copy-Item '$uff' '$sff' -Force"
if (!(Test-Path $sff)) {
    wh ' ����' DarkRed -n
    wh "! ������ �������� �ʽ��ϴ�." -n
    wh "! $sff"
    e 1
}

# remove user font regisrty and file
adm powershell.exe "Stop-Service FontCache"
Remove-ItemProperty $urk -Name $urn
Remove-Item $uff -Force
adm powershell.exe "Start-Service FontCache"

# add system registry font name
adm powershell.exe "New-ItemProperty '$srk' '$urn' -PropertyType String -Value '$file'"
$srn = (Get-ItemProperty $srk).PSObject.Properties | Where-Object Value -like *$file | Select-Object -ExpandProperty Name
if (!$srn) {
    wh ' ����' DarkRed -n
    wh "! �۲� �̸��� �������� �ʽ��ϴ�." -n
    wh "! $urn : $srk"
    e 1
}
if (!$e -and $srn -ne $urn) {
    adm powershell.exe "Remove-ItemProperty '$srk' -Name '$srn'"
    Remove-Item $sff -Force
    wh ' ����' DarkRed -n
    wh "! �۲� �̸��� �ٸ��ϴ�." -n
    wh "! $urn �� $srk"
    e 1
}

e 0
