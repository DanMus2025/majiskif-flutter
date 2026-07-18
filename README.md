# majiskif

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Scripts disponibles

Depuis la racine du depot, il ne reste que trois scripts `.bat` utiles:

- `deploy_git.bat` pour commit et push vers GitHub
- `build_android_apk.bat` pour generer `dist\KESE.apk`
- `build_windows_setup.bat` pour generer `dist\KESE-Setup.exe`

### Build Android

```bat
build_android_apk.bat
```

### Installateur Windows

```bat
build_windows_setup.bat
```

Pour la signature Windows, tu peux definir:

- `SIGNTOOL_EXE` vers `signtool.exe`
- `WINDOWS_CERT_PFX` vers le certificat
- `WINDOWS_CERT_PASSWORD` vers le mot de passe
- `WINDOWS_TIMESTAMP_URL` optionnellement
- `REQUIRE_WINDOWS_SIGNATURE=1` pour rendre la signature obligatoire

### Envoi vers GitHub

```bat
deploy_git.bat
```
