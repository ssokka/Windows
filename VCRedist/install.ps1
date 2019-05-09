# Windows | ANSI | CP949 | EUC-KR | CRLF
# PS2EXE	https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-9b4b0493
# PS2EXE.cmd	ps2exe.cmd "VCRedist" "Microsoft Visual C++ ����� ���� ��Ű�� ��ġ"
# [ADM] PS	powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -F .\install.ps1

$OSBit = if ([IntPtr]::Size -eq 4) { 32 } else { 64 }

$title = 'Microsoft Visual C++ ����� ���� ��Ű�� {0}��Ʈ ��ġ' -f $OSBit
$host.UI.RawUI.WindowTitle = $title
Write-Host -ForegroundColor Yellow "`r`n`r`n # $title ���� #`r`n"

$OSArchs = 86, 64
$restart = $null

$json = 'https://raw.githubusercontent.com/ssokka/Windows/master/VCRedist/install.json'
try {
	$data = Invoke-RestMethod $json -ErrorAction Stop
} catch {
	Write-Host -ForegroundColor Red ""$_.Exception.Message
	Write-Host -ForegroundColor Red " `$json = $json"
	Write-Host -ForegroundColor Red "`r`n ������ �߻��Ͽ� ��ġ�� �����մϴ�.`r`n"
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
		$status = "   $name | �ٿ�ε�"
		Write-Host "`r$status ��..." -NoNewline
		try {
			(New-Object System.Net.WebClient).DownloadFile("$url", "$file")
		} catch [System.Net.WebException],[System.IO.IOException] {
			$ErrorStatus = $true
			$ErrorMessage = $_.Exception.Message
		} catch {
			$ErrorStatus = $true
			$ErrorMessage = "�� �� ���� ������ �߻��Ͽ����ϴ�."
		}
		if (-not(Test-Path -Path "$file")) {
			$ErrorStatus = $true
			$ErrorMessage = "$file �� �������� �ʽ��ϴ�."
		}
		if ($ErrorStatus) {
			Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
			Write-Host -ForegroundColor Red "`r$status ���� | $ErrorMessage | $url"
			continue osarch
		}
		Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
		$status = "   $name | ��ġ"
		Write-Host "`r$status ��..." -NoNewline
		$process = Start-Process -FilePath "$file" -ArgumentList $CLO -PassThru -Verb RunAs -Wait
		Write-Host "`r" -NoNewline; 0..($Host.UI.RawUI.BufferSize.Width | ForEach-Object { Write-Host " " -NoNewline }
		if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
			if ($process.ExitCode -eq 3010) { $restart = $true }
			Write-Host "`r$status �Ϸ�"
		} else {
			Write-Host -ForegroundColor Red "`r$status ����"
		}
	}
}

Write-Host -ForegroundColor Yellow "`r`n # $title ���� #`r`n"

if ($restart) {
	Write-Host " ��ġ�� �Ϸ��Ϸ��� ��ǻ�͸� �ٽ� �����ؾ� �մϴ�."
	Write-Host -ForegroundColor Red " ���� ��ǻ�͸� �ٽ� �����Ͻðڽ��ϱ�? [Y/N] " -NoNewline
	$input = Read-Host
	if ($input -eq "y") { Restart-Computer -Force }
} else {
	Write-Host " �ƹ�Ű�� �����ʽÿ�." -NoNewline
	Read-Host
}

function Write-HostCurrentLine {
	Param($String)
	Write-Host "`r" -NoNewline
	for ($i = 1; $i -le $String.Length; $i++) { Write-Host "  " -NoNewline }
}