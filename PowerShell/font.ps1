# windows euc-kr crlf

# set parameters
Param (
    [ValidateScript({@('.ttc','.ttf') -contains [IO.Path]::GetExtension($_)})]
    [string] $file = 'D2Coding.ttc',
    [string] $url = "https://raw.githubusercontent.com/ssokka/Fonts/master/$file",
    # https://drive.google.com/uc?export=download&id=fileid
    # [string] $url = 'https://drive.google.com/uc?export=download&id=fileid',
    [switch] $debug,
    [switch] $verbose
)

# download functions.psm1
[Net.WebClient]::new().DownloadFile('https://raw.githubusercontent.com/ssokka/Windows/master/PowerShell/functions.psm1', 'functions.psm1')

# import functions.psm1
Import-Module ([IO.Path]::Combine($PSScriptRoot, 'functions.psm1'))
Get-Command -Module functions | Out-Null

# set directory
$tff = [IO.Path]::Combine(${env:TEMP},$file)
$sff = [IO.Path]::Combine(${env:SystemRoot},'Fonts',$file)
$uff = [IO.Path]::Combine(${env:LOCALAPPDATA},'Microsoft','Windows','Fonts',$file)

# set registry
$frk = 'Microsoft\Windows NT\CurrentVersion\Fonts'
$srk = "HKLM:\SOFTWARE\$frk"
$urk = "HKCU:\Software\$frk"

# check system font file
if (Test-Path $sff) {
    exit 0
}

wt "$file �۲�"

# check user font file
if (!(Test-Path $uff)) {
    if (!(df $url $tff)) {
        exit 1
    }
    $iMsg = wh ' ��ġ' DarkGreen -r
    sudo powershell.exe "(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere('$tff')"
    if (!(Test-Path $uff)) {
        $eMsg = $space + "! ������ �������� �ʽ��ϴ�.`n"
        $eMsg += $space + "! `$uff = $uff"
    }
}

if (!$iMsg) {
    wh ' ��ġ' DarkGreen
}

# check user registry font name
if (!$eMsg) {
    $urn = (Get-ItemProperty $urk).PSObject.Properties | Where-Object Value -like *$file | Select-Object -ExpandProperty Name
    if ($urn) {
        # check system registry font name and file
        if ((Get-ItemProperty $srk $urn -ErrorAction SilentlyContinue) -and (Test-Path $sff)) {
            exit 0
        }
    } else {
        $eMsg = $space + "! �۲� �̸��� �������� �ʽ��ϴ�.`n"
        $eMsg += $space + "! $tff"
    }
}

# copy user font file to system font file
if (!$eMsg) {
    sudo powershell.exe "Copy-Item '$uff' '$sff' -Force"
    if (!(Test-Path $sff)) {
        $eMsg = $space + "! ������ �������� �ʽ��ϴ�.`n"
        $eMsg += $space + "! $sff"
    }
}

# remove user font regisrty and file
if (!$eMsg) {
    sudo powershell.exe "Stop-Service FontCache"
    Remove-ItemProperty $urk -Name $urn
    Remove-Item $uff -Force
    sudo powershell.exe "Start-Service FontCache"
}

# add system registry font name
if (!$eMsg) {
    sudo powershell.exe "New-ItemProperty '$srk' '$urn' -PropertyType String -Value '$file'"
    $srn = (Get-ItemProperty $srk).PSObject.Properties | Where-Object Value -like *$file | Select-Object -ExpandProperty Name
    if (!$srn) {
        $eMsg = $space + "! �۲� �̸��� �������� �ʽ��ϴ�.`n"
        $eMsg += $space + "! $urn : $srk"
    }
    if (!$eMsg -and $srn -ne $urn) {
        sudo powershell.exe "Remove-ItemProperty '$srk' -Name '$srn'"
        Remove-Item $sff -Force
        $eMsg = $space + "! �۲� �̸��� �ٸ��ϴ�.`n"
        $eMsg += $space + "! $urn �� $srk"
    }
}

if ($eMsg) {
    wh ($space + "����`n" + $eMsg) DarkRed -n
    exit 1
} else {
    wh -n
    exit 0
}
