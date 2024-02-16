chcp 65001

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
gpupdate /force
