#Requires -RunAsAdministrator
# powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ssokka/windows/master/mvcr/install.ps1'))"

$title = 'Microsoft Visual C++ ����� ���� ��Ű�� ��ġ'

Write-Host "`r`n### $title ���� ###`r`n" -ForegroundColor Blue

if ([IntPtr]::Size -eq 8) {
	$bit = 64
} else {
	$bit = 32
}

$data = Invoke-RestMethod "https://raw.githubusercontent.com/ssokka/windows/master/mvcr/data.json"
$restart = $null

foreach ($item in $data) {
	if (($item.Version -gt 2013) -and ($item.Version -lt $data[-1].Version)) { continue }
	for ($i = 1; $i -le 2; $i++) {
		if ($i -eq 1) {
			$OSArch = 'x86'
		} else {
			$OSArch = 'x64'
			if ($bit -eq 32) { continue }
		}
		if (-not [string]::IsNullOrWhitespace($item.ServicePack)) {
			$ServicePackName = " SP{0}" -f $item.ServicePack
			$ServicePackFile = "-sp{0}" -f $item.ServicePack
		} else {
			$ServicePackName = ""
			$ServicePackFile = ""
		}
		$name = "{0}{1} {2}" -f $item.Version, $ServicePackName, $OSArch
		$file = "{0}\mvcr-{1}{2}-{3}.exe" -f $env:TEMP, $item.Version, $ServicePackFile, $OSArch
		$url = "{0}{1}.exe" -f $item.URL, $OSArch
		Write-Host -NoNewline "    + $name �ٿ�ε�"
		(New-Object System.Net.WebClient).DownloadFile("$url", "$file")
		if (Test-Path -Path "$file") {
			Write-Host -NoNewline " �Ϸ�"
		} else {
			Write-Host " ���� !"
			continue
		}
		Write-Host -NoNewline " ��ġ"
		Start-Process -FilePath "$file" -ArgumentList $item.CommandLineOptions -Verb RunAs -Wait
		if ($LastExitCode -eq 3010) { $restart = $true }
		if (($LastExitCode -ne 0) -and ($LastExitCode -ne 3010)) { Write-Host " ���� !" }
	}
	""
}

Write-Host "### $title �Ϸ� ###`r`n"

if ($restart) {
	Write-Host -NoNewline -ForegroundColor Redt "��ġ�� �Ϸ��Ϸ��� ��ǻ�͸� �ٽ� �����ؾ� �մϴ�.`r`n���� ��ǻ�͸� �ٽ� �����Ͻðڽ��ϱ�? [Y/N]"
	$input = Read-Host
	if ($input -eq "y") { Restart-Computer -Force }
} else {
	Write-Host -NoNewline "�ƹ�Ű�� �����ʽÿ�."
	Read-Host
}
