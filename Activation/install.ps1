Invoke-Expression ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 정품 인증'
	
	$host.ui.RawUI.WindowTitle = $name
	
	Write-Host -ForegroundColor Green "`n### $name"
	
	$str = ("$(cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()
	if (!($str -match '인증되었습니다')) {
		$site = 'https://github.com/ssokka/Windows/raw/master/Activation'
		$file = 'restore.7z'
		$dir = "$Env:TEMP\ssokka"
		$zip = "$dir\$file"
		$exe = "$dir\restore.exe"
		$null = New-Item $dir -ItemType Directory -ErrorAction Ignore
		Add-MpPreference -ExclusionPath "$dir" -Force
		if (!(Get-Module 7Zip4Powershell -ListAvailable)) {
			Set-ExecutionPolicy Bypass -Force
			$null = Install-PackageProvider NuGet -min 2.8.5.201 -Force
			Register-PSRepository -Default -ErrorAction Ignore
			Set-PSRepository PSGallery -InstallationPolicy Trusted
			$null = Install-Module 7Zip4PowerShell -Force
		}
 		drtp $false
		Start-BitsTransfer "$site/$file" $zip
		Write-Host -NoNewline '암호: '
		$lline = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			try { $test = $(Get-7Zip $zip -s ($pass = Read-Host -AsSecureString)) } catch {}
			if ($test) { break } else { ccp $x $y }
		}
		Expand-7Zip $zip $dir -SecurePassword $pass
		Start-Process -NoNewWindow -Wait $exe '/activate'
		($zip, $exe) | % { Remove-Item $_ -Force -ErrorAction Ignore }
		drtp $true
	}
	
	("$(cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()

	Write-Host -ForegroundColor Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String)
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}
Write-Host -NoNewline "`n아무 키나 누르십시오..."
Read-Host
