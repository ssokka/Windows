iex ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 정품 인증'
	
	$host.ui.RawUI.WindowTitle = $name
	
	if (!(( cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr) -match '정품 인증되었 습다')) {
		Write-Host -f Green "`n### $name"
		if (!(gmo 7Zip4Powershell -l)) {
			Set-ExecutionPolicy Bypass -f
			$null = Install-PackageProvider NuGet -min 2.8.5.201 -Force
			Register-PSRepository -d -ea ig
			Set-PSRepository PSGallery -i Trusted
			$null = inmo 7Zip4PowerShell -f
		}
		$tdir = "$Env:TEMP\ssokka"
		$file = 'restore.7z'
		$url = "https://github.com/ssokka/Windows/raw/master/Activation/$file"
		$zip = "$tdir\$file"
		Start-BitsTransfer $url $zip
		Write-Host -n "암호: "
		$lline = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			try { $test = $(Get-7Zip $zip -s ($pass = read-host -a)) } catch {}
			if ($test) { break } else { ccp $x $y }
		}
		$null = ni $tdir -it d -ea ig
		Add-MpPreference $tdir -f
		Expand-7Zip $zip $tdir -s $pass
		ri $zip -Force -ea ig
		start -n -wait restore.exe '/activate'
	}
	
	Write-Host -f Green "`n### $name 확인"
	cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr

	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}
Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
