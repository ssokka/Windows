# Windows | ANSI | CP949 | EUC-KR | CRLF
# PS2EXE	https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-9b4b0493
# PS2EXE.cmd	ps2exe.cmd "VCRedist" "Microsoft Visual C++ 재배포 가능 패키지 설치"
# [ADM] PS	powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -F .\install.ps1

$OSBit = if ([IntPtr]::Size -eq 4) { 32 } else { 64 }

$title = 'Microsoft Visual C++ 재배포 가능 패키지 {0}비트 설치' -f $OSBit
$host.UI.RawUI.WindowTitle = $title
Write-Host -ForegroundColor Yellow "`r`n`r`n # $title 시작 #`r`n"

$OSArchs = 86, 64
$restart = $null

$json = 'https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.json'
try {
	$data = Invoke-RestMethod $json -ErrorAction Stop
} catch {
	Write-Host -ForegroundColor Red ""$_.Exception.Message
	Write-Host -ForegroundColor Red " `$json = $json"
	Write-Host -ForegroundColor Red "`r`n 오류가 발생하여 설치를 종료합니다.`r`n"
	Exit
}
[array]::Reverse($data)

:data foreach ($item in $data) {
	if ($item.Product -gt 2013 -and $item.Product -lt $data[-1].Product) { continue data }
	:osarch foreach ($OSArch in $OSArchs) {
		if ($OSBit -eq 32 -and $OSArch -eq 64) { continue data }
		if ([string]::IsNullOrWhitespace($item.ServicePack)) {
			$SPName = '   '
			$SPFile = ''
		} else {
			$SPName = 'SP{0}' -f $item.ServicePack
			$SPFile = '-{0}' -f $SPName
		}
		$name = '{0} | {1} | x{2}' -f $item.Product, $SPName, $OSArch
		$file = '{0}\VCRedist-{1}{2}-x{3}.exe' -f $env:TEMP, $item.Product, $SPFile, $OSArch
		$log = '{0} "{1}"' -f $item.LogOption, $file -replace '\.exe', '.log'
		if ($item.Product -eq 2005) { $log = '' }
		$CLO = '{0} {1}' -f $item.CommandLineOptions, $log
		$url = if ($OSArch -eq 86) { $item.x86 } else { $item.x64 }
		$ErrorStatus = $false
		$status = "   $name | 다운로드"
		Write-Host "`r$status 중..." -NoNewline
		try {
			(New-Object System.Net.WebClient).DownloadFile("$url", "$file")
		} catch [System.Net.WebException],[System.IO.IOException] {
			$ErrorStatus = $true
			$ErrorMessage = $_.Exception.Message
		} catch {
			$ErrorStatus = $true
			$ErrorMessage = "알 수 없는 오류가 발생하였습니다."
		}
		if (-not(Test-Path -Path "$file")) {
			$ErrorStatus = $true
			$ErrorMessage = "$file 이 존재하지 않습니다."
		}
		if ($ErrorStatus) {
			Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
			Write-Host -ForegroundColor Red "`r$status 실패 | $ErrorMessage | $url"
			continue osarch
		}
		Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
		$status = "   $name | 설치"
		Write-Host "`r$status 중..." -NoNewline
		$process = Start-Process -FilePath "$file" -ArgumentList $CLO -PassThru -Verb RunAs -Wait
		Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
		if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
			if ($process.ExitCode -eq 3010) { $restart = $true }
			Write-Host "`r$status 완료"
		} else {
			Write-Host -ForegroundColor Red "`r$status 실패"
		}
	}
}

Write-Host -ForegroundColor Yellow "`r`n # $title 종료 #`r`n"

if ($restart) {
	Write-Host " 설치를 완료하려면 컴퓨터를 다시 시작해야 합니다."
	Write-Host -ForegroundColor Red " 지금 컴퓨터를 다시 시작하시겠습니까? [Y/N] " -NoNewline
	$input = Read-Host
	if ($input -eq "y") { Restart-Computer -Force }
} else {
	Write-Host " 아무키나 누르십시오." -NoNewline
	Read-Host
}

function Write-HostCurrentLine {
	Param($String)
	Write-Host "`r" -NoNewline
	for ($i = 1; $i -le $String.Length; $i++) { Write-Host "  " -NoNewline }
}