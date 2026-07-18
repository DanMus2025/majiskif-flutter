$env:Path = "C:\dev\flutter\bin;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;$env:Path"
Set-Location $PSScriptRoot

flutter clean
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5200
