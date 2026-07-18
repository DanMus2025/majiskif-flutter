$env:Path = "C:\dev\flutter\bin;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;$env:Path"
Set-Location $PSScriptRoot

flutter clean
flutter pub get
flutter run -d chrome --web-renderer html
