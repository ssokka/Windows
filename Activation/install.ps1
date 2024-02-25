iex ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')

$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 정품 인증'
	
	$host.ui.RawUI.WindowTitle = $name
	
	Write-Host -f Green "`n### $name"
	
	$str = ("$(cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()
	if (!($str -match '인증되었습니다')) {
		$site = "https://github.com/ssokka/Windows/raw/master/Activation"
		$file = 'restore.7z'
		$dir = "$Env:TEMP\ssokka"
		$zip = "$dir\$file"
		$exe = "$dir\restore.exe"
		$null = ni $dir -it d -ea ig
		if (!(gmo 7Zip4Powershell -l)) {
			Set-ExecutionPolicy Bypass -f
			$null = Install-PackageProvider NuGet -min 2.8.5.201 -Force
			Register-PSRepository -d -ea ig
			Set-PSRepository PSGallery -i Trusted
			$null = inmo 7Zip4PowerShell -f
		}
		Start-BitsTransfer "$site/$file" $zip
		Write-Host -n "암호: "
		$lline = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			try { $test = $(Get-7Zip $zip -s ($pass = read-host -a)) } catch {}
			if ($test) { break } else { ccp $x $y }
		}
		Add-MpPreference -ExclusionPath $dir -f
		Expand-7Zip $zip $dir -s $pass
		start -n -wait $exe '/activate'
		($zip, $exe) | % { ri $_ -Force -ea ig }
	}
	
	("$(cscript /Nologo "$Env:WinDir\System32\slmgr.vbs" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()

	Write-Host -f Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | fl -Force | Out-String)
	Write-Error ($_.InvocationInfo | fl -Force | Out-String)
}
Write-Host -n "`n아무 키나 누르십시오..."
Read-Host
