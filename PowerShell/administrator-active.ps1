$user = "Administrator"

$help = "`n" + @"
PowerShell[.exe] -NoProfile -ExecutionPolicy Bypass -File administrator-active.ps1 {-Yes|-No} [-NoPause]`n
 -Yes     : $user ���� Ȱ��ȭ
 -No      : $user ���� ��Ȱ��ȭ �� ��ȣ �ʱ�ȭ
 -NoPause : �Ͻ� �������� ����
"@

if ($args.Count -eq 0) { $help; exit 0 }
$args = $args.ToLower()

$pause = $true
switch ($args) { { $_ -eq "-nopause" } { $pause = $false; break } }

switch ($args)
{
    { $_ -eq "-yes" } { $active = $true; $text = "Ȱ��"; break }
    { $_ -eq "-no" } { $active = $false; $text = "��Ȱ��"; break }
}
if ($active -eq $null) { $help; exit 1 }

$title = "# $user ���� $text" + "ȭ"
$Host.UI.RawUI.WindowTitle = $title
Write-Host "`n $title" -ForegroundColor DarkGreen

$pass = '""'
if ($active) {
    $active = "yes"
    Write-Host "`n ! $user ���� ��ȣ ���� : " -NoNewline -ForegroundColor DarkRed
    $pass = Read-Host
    if (-not [string]::IsNullOrEmpty($pass)) { $pass = ConvertTo-SecureString -String $pass -AsPlainText -Force }
}
if (-not $active) { $active = "no" }

Start-Process -FilePath "net.exe" -ArgumentList "user $user '$pass' /active:$active" -Verb RunAs -WindowStyle Hidden -Wait

if ($(Get-LocalUser -Name $user | Select-object -ExpandProperty Enabled)) {
    $status = "Ȱ��"
} else {
    $status = "��Ȱ��"
}
Write-Host "`n ! $user ���� $status" -ForegroundColor DarkYellow

if ($pause) {
    Write-Host "`n" -NoNewline
    cmd.exe /c pause
}
