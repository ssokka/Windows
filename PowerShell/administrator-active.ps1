$user = "Administrator"

$help = "`n" + @"
PowerShell[.exe] -NoProfile -ExecutionPolicy Bypass -File administrator-active.ps1 {-Yes|-No} [-NoPause]`n
 -Yes     : $user 계정 활성화
 -No      : $user 계정 비활성화 및 암호 초기화
 -NoPause : 일시 정지없이 종료
"@

if ($args.Count -eq 0) { $help; exit 0 }
$args = $args.ToLower()

$pause = $true
switch ($args) { { $_ -eq "-nopause" } { $pause = $false; break } }

switch ($args)
{
    { $_ -eq "-yes" } { $active = $true; $text = "활성"; break }
    { $_ -eq "-no" } { $active = $false; $text = "비활성"; break }
}
if ($active -eq $null) { $help; exit 1 }

$title = "# $user 계정 $text" + "화"
$Host.UI.RawUI.WindowTitle = $title
Write-Host "`n $title" -ForegroundColor DarkGreen

$pass = '""'
if ($active) {
    $active = "yes"
    Write-Host "`n ! $user 계정 암호 설정 : " -NoNewline -ForegroundColor DarkRed
    $pass = Read-Host
    if (-not [string]::IsNullOrEmpty($pass)) { $pass = ConvertTo-SecureString -String $pass -AsPlainText -Force }
}
if (-not $active) { $active = "no" }

Start-Process -FilePath "net.exe" -ArgumentList "user $user '$pass' /active:$active" -Verb RunAs -WindowStyle Hidden -Wait

if ($(Get-LocalUser -Name $user | Select-object -ExpandProperty Enabled)) {
    $status = "활성"
} else {
    $status = "비활성"
}
Write-Host "`n ! $user 계정 $status" -ForegroundColor DarkYellow

if ($pause) {
    Write-Host "`n" -NoNewline
    cmd.exe /c pause
}
