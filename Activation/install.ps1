Invoke-Expression ([Net.WebClient]::new()).DownloadString('https://raw.githubusercontent.com/ssokka/Windows/master/Script/ps/header.ps1')
$ErrorActionPreference = 'Stop'

try {
	$name = 'Windows 정품 인증'
	$host.ui.RawUI.WindowTitle = $name
	Write-Host -ForegroundColor Green "`n### $name"

	$slmgr = "$Env:WinDir\System32\slmgr.vbs"
	$str = ("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()
	if (!($str -match '인증되었습니다')) {
		$site = 'https://github.com/ssokka/Windows/raw/master/Activation'
		$file = 'restore.7z'
		$path = "$Env:Temp\Download"
		$exec = 'restore.exe'
		$null = New-Item "$path" -ItemType Directory -ErrorAction Ignore
		install-7zip
 		ddr $false
		Start-BitsTransfer "$site/$file" "$path\$file"
		Write-Host -NoNewline '암호: '
		$lline = 0
		while ($true) {
			$x, $y = [Console]::CursorLeft, [Console]::CursorTop
			try { $test = $(Get-7Zip "$path\$file" -s ($pass = Read-Host -AsSecureString)) } catch {}
			if ($test) { break } else { ccp $x $y }
		}
		Expand-7Zip "$path\$file" "$path" -SecurePassword $pass
		Start-Process -NoNewWindow -Wait "$path\$exec" '/activate'
		Remove-Item "$path" -Recurse -Force -ErrorAction Ignore
		ddr $true
	}
	("$(cscript /Nologo "$slmgr" /xpr)" -replace '.*?(컴퓨터.*)','$1').Trim()
	Write-Host -ForegroundColor Green "`n### 완료"
}
catch {
	Write-Error ($_.Exception | Format-List -Force | Out-String)
	Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}

Write-Host -NoNewline "`n아무 키나 누르십시오..."
Read-Host
