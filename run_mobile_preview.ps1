$flutterPath = 'C:\dev\flutter\bin'
$gitCmdPath = 'C:\Program Files\Git\cmd'
$gitBinPath = 'C:\Program Files\Git\bin'
$port = 5200

$env:Path = "$flutterPath;$gitCmdPath;$gitBinPath;$env:Path"

Set-Location 'C:\tmp\MajiskifFlutter'

$ip = (
  Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {
    $_.IPAddress -notlike '127.*' -and
    $_.IPAddress -notlike '169.254*' -and
    $_.PrefixOrigin -ne 'WellKnown'
  } |
  Select-Object -First 1 -ExpandProperty IPAddress
)

if (-not $ip) {
  $ip = (
    ipconfig |
    Select-String 'IPv4' |
    ForEach-Object { ($_ -split ':')[-1].Trim() } |
    Where-Object {
      $_ -and
      $_ -notlike '127.*' -and
      $_ -notlike '169.254*'
    } |
    Select-Object -First 1
  )
}

Write-Host ''
Write-Host 'Preview mobile Majiskif' -ForegroundColor Green
Write-Host '----------------------------------------' -ForegroundColor DarkGreen
Write-Host "Projet : C:\tmp\MajiskifFlutter"
Write-Host "Port   : $port"

if ($ip) {
  Write-Host "Ouvre ceci sur le telephone :" -ForegroundColor Yellow
  Write-Host "http://$ip`:$port" -ForegroundColor Cyan
} else {
  Write-Host "Adresse IP non detectee automatiquement." -ForegroundColor Red
  Write-Host "Lance 'ipconfig' dans un autre terminal pour verifier l'IPv4 locale." -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Le PC et le telephone doivent etre sur le meme reseau local.' -ForegroundColor Yellow
Write-Host ''

flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port $port
