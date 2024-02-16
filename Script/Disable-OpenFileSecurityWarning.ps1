[Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

[int] $w = 758
[int] $h = 472
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

#chcp 65001
echo "`n### 파일 열기 보안 경고 끄기"

$data = @(
	[pscustomobject]@{
		k = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments'
		v = 'SaveZoneInformation'
		t = 'REG_DWORD'
		d = '1'
	}
	[pscustomobject]@{
		k = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations'
		v = 'LowRiskFileTypes'
		t = 'REG_SZ'
		d = '.avi; .bat; .cmd; .exe; .htm; .html; .lnk; .mpg; .mpeg; .mov; .mp3; .mp4; .mkv; .msi; .m3u; .rar; .reg ; .txt; .vbs; .wav; .zip; .7z'
	}
	[pscustomobject]@{
		k = 'HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security'
		v = 'DisableSecuritySettingsCheck'
		t = 'REG_DWORD'
		d = '1'
	}
	[pscustomobject]@{
		k = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
		v = '1806'
		t = 'REG_DWORD'
		d = '0'
	}
	[pscustomobject]@{
		k = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
		v = '1806'
		t = 'REG_DWORD'
		d = '0'
	}
)

$data | % { reg add $_.k /v $_.v /t $_.t /d $_.d /f }

echo ""
gpupdate /force

sleep -m 500
cmd /c pause
