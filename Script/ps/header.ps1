Add-Type @'
	using System;
	using System.Runtime.InteropServices;
	public class Window {
		[DllImport("user32.dll")]
		public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
		[DllImport("user32.dll")]
		public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);    
		[DllImport("user32.dll")]
		public extern static bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
	}
	public struct RECT {
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}
'@
$ppid = (gwmi win32_process -Filter "processid='$PID'").ParentProcessId
$hwnd = (Get-Process -Id $ppid).MainWindowHandle
$rect = New-Object RECT
$null = [Window]::GetWindowRect($hwnd,[ref]$rect)
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top
$area = ([Windows.Forms.Screen]::PrimaryScreen).WorkingArea
$x = ($area.Width - $w) / 2
$y = ($area.Height - $h) / 2
sleep 5
$null = [Window]::MoveWindow($hwnd,$x,$y,$w,$h,$true)
$null = [Window]::ShowWindow($hwnd, 1)
$null = [Window]::ShowWindow($hwnd, 2)
$null = [Window]::ShowWindow($hwnd, 9)
