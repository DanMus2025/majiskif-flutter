import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'audio_attachment_player.dart';
import 'cloud_service.dart';
import 'document_preview_widget.dart';
import 'image_picker_service.dart';
import 'local_store_service.dart';
import 'network_status_service.dart';
import 'realtime_sync_service.dart';
import 'attention_feedback_service.dart';
import 'url_action_service.dart';
import 'voice_note_recorder.dart';

void main() => runApp(const MajiskifApp());

const _green = Color(0xFF0C5D6D);
const _greenDark = Color(0xFF073B48);
const _surface = Color(0xFFF5FAF7);
const _ink = Color(0xFF10251D);
const _muted = Color(0xFF61746B);
const _warning = Color(0xFFFFF1D0);
const _danger = Color(0xFFA83B30);
const _darkScaffold = Color(0xFF071118);
const _darkPanel = Color(0xFF0F1B24);
const _darkPanelRaised = Color(0xFF132530);
const _darkAccentSurface = Color(0xFF103241);
const _darkAccentStrong = Color(0xFF154456);
const _darkLine = Color(0xFF254A5C);
const _darkMuted = Color(0xFFA5BDC8);
const _darkText = Color(0xFFF2FBFD);
const _darkSuccessTint = Color(0xFF89F6D0);
const _darkWarningTint = Color(0xFFFFD489);
const _dtechLogoAsset = 'assets/branding/logo-dtech.png';
const _keseLogoAsset = 'assets/branding/logo-kese.png';
const _architectAsset = 'assets/branding/img-architecte.jpeg';
const _whatsAppAsset = 'assets/branding/wt.png';
const _creatorEmail = 'danielmusagara@gmail.com';
const _creatorPhone = '+243971238634';
const _defaultCloudBaseUrl = String.fromEnvironment(
  'KESE_CLOUD_BASE_URL',
  defaultValue: 'https://majiskif-kese-cloud-api.onrender.com/api/v1/cloud',
);
const _appVersionLabel = '1.0.0';

const _companyPresentationParagraphs = [
  'Fondée en 2011 en République démocratique du Congo par Musagara Daniel, D-Square Technologies est une entreprise spécialisée dans les technologies numériques, l’innovation et le développement de solutions intelligentes adaptées aux réalités africaines et internationales.',
  'Depuis sa création, l’entreprise s’est donnée pour mission de transformer les défis des entreprises en opportunités grâce à des outils technologiques performants, accessibles et orientés vers la productivité. À travers une approche moderne et stratégique, D-Square Technologies accompagne les particuliers, les commerçants, les startups, les PME ainsi que les grandes entreprises dans leur transition numérique.',
  'Grâce à son expertise et à sa vision orientée vers l’innovation, D-Square Technologies développe des solutions capables d’améliorer la productivité, d’optimiser la gestion interne des entreprises et de simplifier les opérations quotidiennes.',
  'L’entreprise met un accent particulier sur la qualité, la fiabilité, la sécurité et l’efficacité de ses solutions afin de répondre aux exigences du marché moderne et aux besoins réels des utilisateurs.',
];

const _companyDomains = [
  'Développement de logiciels et applications intelligentes',
  'Création de sites web professionnels et plateformes numériques',
  'Conception d’applications web, desktop et mobiles',
  'Solutions de gestion commerciale et administrative',
  'Transformation digitale des entreprises',
  'Innovation numérique et automatisation des tâches',
  'Gestion et sécurisation des données',
  'Conseil et accompagnement technologique',
  'Développement de systèmes connectés et synchronisés',
];

const _founderPresentationParagraphs = [
  'Musagara Daniel est un entrepreneur technologique congolais, CEO & Founder de D-Square Technologies.',
  'Passionné par la technologie, l’innovation et la transformation numérique, il œuvre depuis plusieurs années dans la conception de solutions intelligentes destinées à moderniser la gestion des entreprises et à faciliter l’accès aux outils numériques en Afrique.',
  'Détenteur de plusieurs qualifications, certifications internationales, formations spécialisées et distinctions dans le domaine des technologies de l’information, il se distingue par sa vision moderne orientée vers l’innovation, la performance et la création de solutions concrètes adaptées aux réalités du marché.',
  'Technologue, développeur et innovateur engagé, il consacre son expertise à la création de systèmes modernes capables d’améliorer la productivité, la gestion commerciale et la communication professionnelle au sein des entreprises.',
  'À travers D-Square Technologies, il ambitionne de contribuer activement à l’évolution numérique de la République démocratique du Congo et du continent africain en proposant des solutions technologiques fiables, intelligentes et accessibles.',
];

const _kesePresentationParagraphs = [
  'KESE est une solution technologique innovante développée par D-Square Technologies afin d’accompagner les petites, moyennes et grandes entreprises dans la gestion intelligente et moderne de leurs activités commerciales.',
  'Pensée comme une véritable assistante commerciale numérique, KESE simplifie les tâches complexes, automatise plusieurs opérations quotidiennes et aide les entrepreneurs à gérer efficacement leur business depuis n’importe quel endroit.',
  'Grâce à son système avancé de synchronisation automatique des données, l’application permet aux équipes de rester connectées en temps réel, facilitant ainsi la collaboration, le suivi des opérations et la prise de décisions rapides.',
  'L’application intègre également un système de communication interne intelligent permettant aux utilisateurs d’une même entreprise d’échanger directement entre eux grâce à un chat intégré. Cette fonctionnalité facilite le partage rapide d’informations, la coordination des équipes, la transmission des instructions ainsi que la collaboration entre les différents services de l’entreprise sans avoir recours à des plateformes externes.',
  'Grâce à son interface moderne, sa rapidité et son système intelligent de gestion, KESE aide les entreprises à gagner du temps, réduire les erreurs, améliorer leur organisation et accroître leurs performances commerciales.',
  'KESE n’est pas simplement une application de gestion : c’est un partenaire technologique conçu pour accompagner l’évolution des entreprises modernes.',
];

const _keseFeatures = [
  'Gestion complète des ventes',
  'Gestion des produits et des stocks',
  'Comptabilité simplifiée',
  'Gestion des facturations et des paiements',
  'Gestion des dépenses et des revenus',
  'Suivi des opérations commerciales',
  'Gestion des utilisateurs et des équipes',
  'Système de chat interne entre les utilisateurs d’une même entreprise',
  'Synchronisation automatique des données',
  'Sauvegarde et sécurisation des informations',
  'Communication fluide entre les différents points de gestion',
  'Accès rapide et centralisé aux données de l’entreprise',
];

const _kesePlatforms = [
  'Version Desktop',
  'Version Web',
  'Version Android',
  'Toutes les versions sont connectées entre elles afin d’assurer une continuité parfaite des opérations et une mise à jour instantanée des données.',
];

const Map<String, String> _searchFoldMap = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ă': 'a',
  'ą': 'a',
  'æ': 'ae',
  'ç': 'c',
  'ć': 'c',
  'ĉ': 'c',
  'ċ': 'c',
  'č': 'c',
  'ď': 'd',
  'đ': 'd',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ĕ': 'e',
  'ė': 'e',
  'ę': 'e',
  'ě': 'e',
  'ĝ': 'g',
  'ğ': 'g',
  'ġ': 'g',
  'ģ': 'g',
  'ĥ': 'h',
  'ħ': 'h',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ĩ': 'i',
  'ī': 'i',
  'ĭ': 'i',
  'į': 'i',
  'ı': 'i',
  'ĵ': 'j',
  'ķ': 'k',
  'ĺ': 'l',
  'ļ': 'l',
  'ľ': 'l',
  'ŀ': 'l',
  'ł': 'l',
  'ñ': 'n',
  'ń': 'n',
  'ņ': 'n',
  'ň': 'n',
  'ŋ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ŏ': 'o',
  'ő': 'o',
  'œ': 'oe',
  'ŕ': 'r',
  'ŗ': 'r',
  'ř': 'r',
  'ś': 's',
  'ŝ': 's',
  'ş': 's',
  'š': 's',
  'ß': 'ss',
  'ť': 't',
  'ţ': 't',
  'ŧ': 't',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ũ': 'u',
  'ū': 'u',
  'ŭ': 'u',
  'ů': 'u',
  'ű': 'u',
  'ų': 'u',
  'ŵ': 'w',
  'ý': 'y',
  'ÿ': 'y',
  'ŷ': 'y',
  'ź': 'z',
  'ż': 'z',
  'ž': 'z',
  '’': "'",
  '‘': "'",
  '´': "'",
  '`': "'",
  '“': '"',
  '”': '"',
  '«': '"',
  '»': '"',
  '–': '-',
  '—': '-',
  '−': '-',
  '\u00a0': ' ',
};

const Map<String, int> _pdfWinAnsiExtraBytes = {
  '€': 0x80,
  '‚': 0x82,
  'ƒ': 0x83,
  '„': 0x84,
  '…': 0x85,
  '†': 0x86,
  '‡': 0x87,
  'ˆ': 0x88,
  '‰': 0x89,
  'Š': 0x8A,
  '‹': 0x8B,
  'Œ': 0x8C,
  'Ž': 0x8E,
  '‘': 0x91,
  '’': 0x92,
  '“': 0x93,
  '”': 0x94,
  '•': 0x95,
  '–': 0x96,
  '—': 0x97,
  '˜': 0x98,
  '™': 0x99,
  'š': 0x9A,
  '›': 0x9B,
  'œ': 0x9C,
  'ž': 0x9E,
  'Ÿ': 0x9F,
};

String _normalizeSearchText(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) return '';
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_searchFoldMap[char] ?? char);
  }
  return buffer.toString();
}

bool _matchesSearchText(String haystack, String query) {
  final normalizedQuery = _normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return true;
  return _normalizeSearchText(haystack).contains(normalizedQuery);
}

List<int> _pdfEncodeText(String value) {
  final bytes = <int>[];
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final extra = _pdfWinAnsiExtraBytes[char];
    if (extra != null) {
      bytes.add(extra);
      continue;
    }
    if (rune >= 0x20 && rune <= 0x7E) {
      bytes.add(rune);
      continue;
    }
    if (rune >= 0xA0 && rune <= 0xFF) {
      bytes.add(rune);
      continue;
    }
    final folded = _normalizeSearchText(char);
    if (folded.isEmpty) {
      bytes.add(0x3F);
      continue;
    }
    var wrote = false;
    for (final foldedRune in folded.runes) {
      if (foldedRune >= 0x20 && foldedRune <= 0x7E) {
        bytes.add(foldedRune);
        wrote = true;
      }
    }
    if (!wrote) bytes.add(0x3F);
  }
  return bytes;
}

String _pdfTextLiteral(String value) {
  final hex = _pdfEncodeText(value)
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
  return '<$hex>';
}

Uint8List _buildPdfFromObjects(List<String> objects) {
  final pdf = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(latin1.encode(pdf.toString()).length);
    pdf.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }
  final xrefOffset = latin1.encode(pdf.toString()).length;
  pdf.writeln('xref');
  pdf.writeln('0 ${objects.length + 1}');
  pdf.writeln('0000000000 65535 f ');
  for (var i = 1; i < offsets.length; i++) {
    pdf.writeln('${offsets[i].toString().padLeft(10, '0')} 00000 n ');
  }
  pdf.writeln('trailer << /Size ${objects.length + 1} /Root 1 0 R >>');
  pdf.writeln('startxref');
  pdf.writeln(xrefOffset);
  pdf.write('%%EOF');
  return Uint8List.fromList(latin1.encode(pdf.toString()));
}

class _PdfEmbeddedImage {
  const _PdfEmbeddedImage({
    required this.width,
    required this.height,
    required this.compressedData,
  });

  final int width;
  final int height;
  final Uint8List compressedData;
}

Future<Uint8List?> _logoSourceBytes(String source) async {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('data:')) {
    final data = UriData.parse(trimmed);
    return data.contentAsBytes();
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    try {
      final response = await http.get(Uri.parse(trimmed));
      if (response.statusCode >= 200 && response.statusCode < 300 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}

Future<_PdfEmbeddedImage?> _loadPdfLogoImage(String source) async {
  final bytes = await _logoSourceBytes(source);
  if (bytes == null || bytes.isEmpty) return null;
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;
    final rgba = byteData.buffer.asUint8List();
    final rgb = Uint8List(image.width * image.height * 3);
    for (var sourceIndex = 0, targetIndex = 0; sourceIndex < rgba.length; sourceIndex += 4) {
      final alpha = rgba[sourceIndex + 3] / 255.0;
      rgb[targetIndex++] = ((rgba[sourceIndex] * alpha) + (255 * (1 - alpha))).round();
      rgb[targetIndex++] = ((rgba[sourceIndex + 1] * alpha) + (255 * (1 - alpha))).round();
      rgb[targetIndex++] = ((rgba[sourceIndex + 2] * alpha) + (255 * (1 - alpha))).round();
    }
    return _PdfEmbeddedImage(
      width: image.width,
      height: image.height,
      compressedData: rgb,
    );
  } catch (_) {
    return null;
  }
}

String _pdfImageObject(_PdfEmbeddedImage image) {
  final stream = latin1.decode(image.compressedData);
  return '''
<< /Type /XObject /Subtype /Image /Width ${image.width} /Height ${image.height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Length ${image.compressedData.length} >>
stream
$stream
endstream''';
}

void _drawPdfImage(
  StringBuffer content,
  _PdfEmbeddedImage image, {
  required num x,
  required num y,
  required num width,
  required num height,
}) {
  content.writeln('q');
  content.writeln('$width 0 0 $height $x $y cm');
  content.writeln('/ImLogo Do');
  content.writeln('Q');
}

String _platformName() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.windows => 'windows',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.linux => 'linux',
    _ => 'flutter',
  };
}

void _applyPushSyncResponseToStore(
  AppStore store,
  List<SyncQueueEntry> pendingEntries,
  KeseCloudPushResponse pushResponse,
) {
  final pendingById = {
    for (final entry in pendingEntries) entry.id: entry,
  };
  final acceptedIds = <String>{};
  final conflictIds = <String>{};
  for (final operation in pushResponse.operations) {
    if (operation.syncStatus == 'accepted') {
      acceptedIds.add(operation.id);
      continue;
    }
    if (operation.syncStatus != 'conflict') continue;
    conflictIds.add(operation.id);
    final localEntry = pendingById[operation.id];
    if (localEntry == null) continue;
    store.registerSyncConflict(
      entityName: localEntry.entityName,
      localEntityId: localEntry.entityId,
      serverEntityId: operation.entityId,
      conflictType: 'duplicate_entity_id',
      localPayload: _asMap(jsonDecode(localEntry.payloadJson)),
      serverPayload: _asMap(jsonDecode(operation.payloadJson)),
    );
  }
  final resolvedIds = <String>{...acceptedIds, ...conflictIds};
  final ignoredIds = pendingEntries
      .where((entry) => !resolvedIds.contains(entry.id))
      .map((entry) => entry.id)
      .toSet();
  if (acceptedIds.isNotEmpty || ignoredIds.isNotEmpty) {
    store.updateSyncQueueStatus(
      entryIds: {...acceptedIds, ...ignoredIds},
      status: SyncOperationStatus.synced,
    );
  }
  if (conflictIds.isNotEmpty) {
    store.updateSyncQueueStatus(
      entryIds: conflictIds,
      status: SyncOperationStatus.conflict,
      lastError: 'Conflit detecte pendant la synchronisation cloud.',
    );
  }
}

String _cloudRoleToLocal(String value) {
  switch (value.trim().toLowerCase()) {
    case 'admin':
      return 'Admin';
    case 'manager':
      return 'Gestionnaire';
    case 'cashier':
      return 'Caissier';
    default:
      return value;
  }
}

String _normalizeLicenseDuration(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'trial-24h' ||
      normalized == 'trial_24h' ||
      normalized == '24h' ||
      normalized == 'essai-24h') {
    return 'trial-24h';
  }
  if (normalized == '1y' || normalized == '1-year' || normalized == '1an') {
    return '1y';
  }
  if (normalized == '2y' || normalized == '2-years' || normalized == '2ans') {
    return '2y';
  }
  if (normalized == '5y' || normalized == '5-years' || normalized == '5ans') {
    return '5y';
  }
  if (normalized == 'indefinite' ||
      normalized == 'illimitee' ||
      normalized == 'illimite' ||
      normalized == 'perpetuelle') {
    return 'indefinite';
  }
  return '1y';
}

String _extractLicenseDuration(String value) {
  final parts = value.trim().split('@');
  return _normalizeLicenseDuration(parts.isEmpty ? value : parts.last);
}

String _extractCommercialPlan(String value) {
  final parts = value.trim().split('@');
  return parts.firstWhere((part) => part.trim().isNotEmpty, orElse: () => 'standard');
}

String _licenseDurationLabel(String value) {
  return switch (_extractLicenseDuration(value)) {
    'trial-24h' => 'Essai 24 heures',
    '1y' => '1 an',
    '2y' => '2 ans',
    '5y' => '5 ans',
    'indefinite' => 'Illimitée',
    _ => '1 an',
  };
}

String _formatLicenseExpiry(DateTime? value) {
  if (value == null) return 'Sans expiration';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year à $hour:$minute';
}

String _slugFromName(String value, {String fallback = 'tenant'}) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return normalized.isEmpty ? fallback : normalized;
}

String _inferLocalRoleForOffline({
  required bool firstActivation,
  required String username,
}) {
  final normalized = username.trim().toLowerCase();
  if (firstActivation ||
      normalized.contains('admin') ||
      normalized.contains('gestion')) {
    return 'Admin';
  }
  return 'Caissier';
}

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _panelColor(BuildContext context) =>
    _isDark(context) ? _darkPanel : Colors.white;

Color _softPanelColor(BuildContext context) =>
    _isDark(context) ? _darkPanelRaised : const Color(0xFFF0F8FB);

Color _softAccentColor(BuildContext context) =>
    _isDark(context) ? _darkAccentSurface : const Color(0xFFE7F5F8);

Color _softAccentStrong(BuildContext context) =>
    _isDark(context) ? _darkAccentStrong : const Color(0xFFEAF7FA);

Color _panelBorderColor(BuildContext context) =>
    _isDark(context) ? _darkLine : const Color(0xFFC5DDE5);

Color _mutedTextColor(BuildContext context) =>
    _isDark(context) ? _darkMuted : _muted;

Color _strongTextColor(BuildContext context) =>
    _isDark(context) ? _darkText : _ink;

Color _warningSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF3B2C15) : _warning;

Color _dangerSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF3A1F1D) : const Color(0xFFFFF1EF);

class MajiskifApp extends StatefulWidget {
  const MajiskifApp({super.key});

  @override
  State<MajiskifApp> createState() => _MajiskifAppState();
}

class _MajiskifAppState extends State<MajiskifApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late AppStore _store;
  late final LocalStoreService _localStore;
  late final KeseCloudService _cloudService;
  AppLaunchStage _launchStage = AppLaunchStage.splashBrand;
  CreatorActivationSeed? _creatorSeed;
  KeseCloudCreatorSession? _creatorSession;
  static const _brandSplashDuration = Duration(seconds: 4);
  static const _appSplashDuration = Duration(milliseconds: 3000);
  Timer? _persistDebounce;

  bool _shouldShowLoginAfterSplash() =>
      _store.cloudSession != null || _store.cloudAccessConfigured;

  @override
  void initState() {
    super.initState();
    _localStore = createLocalStoreService();
    _cloudService = KeseCloudService();
    _store = AppStore.demo();
    _attachStore(_store);
    _initializeApp();
  }

  Future<String?> _activateCloudSession({
    required String baseUrl,
    required String licenseCode,
    required String username,
    required String pin,
    required String deviceLabel,
  }) async {
    try {
      final auth = await _cloudService.activate(
        baseUrl: baseUrl,
        licenseCode: licenseCode,
        username: username,
        pin: pin,
        deviceUuid: _store.deviceId,
        deviceLabel: deviceLabel,
        platformName: _platformName(),
        appVersion: _appVersionLabel,
      );
      await _completeCloudSession(
        baseUrl: baseUrl,
        auth: auth,
        pin: pin,
        preferredLicenseCode: licenseCode,
        openAppAfterAuth: false,
      );
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'Activation cloud impossible pour le moment.';
    }
  }

  Future<String?> _loginCloudSession({
    required String baseUrl,
    required String tenantKey,
    required String username,
    required String pin,
    required String deviceLabel,
  }) async {
    try {
      final auth = await _cloudService.login(
        baseUrl: baseUrl,
        tenantKey: tenantKey,
        username: username,
        pin: pin,
        deviceUuid: _store.deviceId,
        deviceLabel: deviceLabel,
        platformName: _platformName(),
        appVersion: _appVersionLabel,
      );
      await _completeCloudSession(
        baseUrl: baseUrl,
        auth: auth,
        pin: pin,
        preferredLicenseCode: auth.license.licenseCode,
        openAppAfterAuth: true,
      );
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'Connexion cloud impossible pour le moment.';
    }
  }

  Future<String?> _attachDeviceToExistingCompany({
    required String baseUrl,
    required String tenantKey,
    required String username,
    required String pin,
    required String deviceLabel,
  }) async {
    try {
      final auth = await _cloudService.login(
        baseUrl: baseUrl,
        tenantKey: tenantKey,
        username: username,
        pin: pin,
        deviceUuid: _store.deviceId,
        deviceLabel: deviceLabel,
        platformName: _platformName(),
        appVersion: _appVersionLabel,
      );
      await _completeCloudSession(
        baseUrl: baseUrl,
        auth: auth,
        pin: pin,
        preferredLicenseCode: auth.license.licenseCode,
        openAppAfterAuth: false,
      );
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'Rattachement cloud impossible pour le moment.';
    }
  }

  Future<KeseCloudTenantCreateResponse> _createCloudTenant({
    required String baseUrl,
    required String companyName,
    String? cloudBaseUrl,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String branchName,
    required String adminFullName,
    required String adminUsername,
    required String adminPin,
    required String planCode,
    required String licenseDuration,
    required int maxDevices,
    required int maxUsers,
  }) {
    final creatorSession = _creatorSession;
    if (creatorSession == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    return _cloudService.createTenant(
      baseUrl: baseUrl,
      accessToken: creatorSession.accessToken,
      companyName: companyName,
      cloudBaseUrl: cloudBaseUrl,
      ownerName: ownerName,
      phone: phone,
      email: email,
      address: address,
      branchName: branchName,
      adminFullName: adminFullName,
      adminUsername: adminUsername,
      adminPin: adminPin,
      planCode: planCode,
      licenseDuration: licenseDuration,
      maxDevices: maxDevices,
      maxUsers: maxUsers,
    );
  }

  Future<String?> _prepareOfflineActivation({
    required bool firstActivation,
    required String baseUrl,
    required String companyName,
    required String licenseCode,
    required String tenantKey,
    required String username,
    required String pin,
    required String deviceLabel,
  }) async {
    final normalizedBaseUrl = baseUrl.trim().isEmpty
        ? ''
        : KeseCloudService.normalizeBaseUrl(baseUrl);
    final trimmedUsername = username.trim();
    final trimmedPin = pin.trim();
    final trimmedCompany = companyName.trim();
    final trimmedTenantKey = tenantKey.trim();
    final offlineRole = _inferLocalRoleForOffline(
      firstActivation: firstActivation,
      username: trimmedUsername,
    );
    final normalizedUsername = trimmedUsername.toLowerCase();
    final existingUserIndex = _store.users.indexWhere(
      (user) => user.username.trim().toLowerCase() == normalizedUsername,
    );
    final localUser = AppUser(
      code: existingUserIndex >= 0
          ? _store.users[existingUserIndex].code
          : _store.codes.nextUser(),
      name: existingUserIndex >= 0
          ? _store.users[existingUserIndex].name
          : trimmedUsername,
      username: trimmedUsername,
      role: existingUserIndex >= 0 ? _store.users[existingUserIndex].role : offlineRole,
      pin: trimmedPin,
      isBlocked: false,
    );
    if (existingUserIndex >= 0) {
      _store.users[existingUserIndex]
        ..username = localUser.username
        ..pin = localUser.pin
        ..isBlocked = false;
    } else {
      _store.users.add(localUser);
    }
    _store.activeUser = existingUserIndex >= 0 ? _store.users[existingUserIndex] : localUser;
    if (trimmedCompany.isNotEmpty) {
      _store.settings.companyName = trimmedCompany;
    }
    if (firstActivation) {
      _store.tenantId = 'pending-${_slugFromName(trimmedCompany, fallback: "kese")}';
    } else if (trimmedTenantKey.isNotEmpty) {
      _store.tenantId = trimmedTenantKey;
    }
    _store.pendingCloudActivation = PendingCloudActivation(
      firstActivation: firstActivation,
      baseUrl: normalizedBaseUrl,
      companyName: trimmedCompany,
      licenseCode: licenseCode.trim(),
      tenantKey: trimmedTenantKey,
      username: trimmedUsername,
      pin: trimmedPin,
      deviceLabel: deviceLabel.trim(),
      createdAt: DateTime.now(),
    );
    _store.alerts.insert(
      0,
      AppAlert.warning(
        'Activation cloud en attente',
        firstActivation
            ? 'La licence a été préparée hors ligne. Appuie sur Synchroniser dès que la connexion revient pour terminer la liaison cloud.'
            : 'Le rattachement de cet appareil est préparé hors ligne. Appuie sur Synchroniser dès que la connexion revient.',
      ),
    );
    await _persistStore();
    return null;
  }

  Future<String?> _synchronizePendingCloudActivation() async {
    final pending = _store.pendingCloudActivation;
    if (pending == null) return 'Aucune activation locale en attente.';
    try {
      final auth = pending.firstActivation
          ? await _cloudService.activate(
              baseUrl: pending.baseUrl,
              licenseCode: pending.licenseCode,
              username: pending.username,
              pin: pending.pin,
              deviceUuid: _store.deviceId,
              deviceLabel: pending.deviceLabel,
              platformName: _platformName(),
              appVersion: _appVersionLabel,
            )
          : await _cloudService.login(
              baseUrl: pending.baseUrl,
              tenantKey: pending.tenantKey,
              username: pending.username,
              pin: pending.pin,
              deviceUuid: _store.deviceId,
              deviceLabel: pending.deviceLabel,
              platformName: _platformName(),
              appVersion: _appVersionLabel,
            );
      await _completeCloudSession(
        baseUrl: pending.baseUrl,
        auth: auth,
        pin: pending.pin,
        preferredLicenseCode: pending.firstActivation
            ? pending.licenseCode
            : auth.license.licenseCode,
        openAppAfterAuth: _launchStage == AppLaunchStage.app,
      );
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'La synchronisation de l’activation locale a échoué.';
    }
  }

  Future<String?> _authenticateCreator({
    required String baseUrl,
    required String username,
    required String pin,
  }) async {
    try {
      final response = await _cloudService.creatorAuth(
        baseUrl: baseUrl,
        username: username,
        pin: pin,
      );
      _creatorSession = KeseCloudCreatorSession(
        baseUrl: KeseCloudService.normalizeBaseUrl(baseUrl),
        accessToken: response.accessToken,
        username: response.username,
        expiresAt: response.expiresAt,
      );
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'Connexion créateur impossible pour le moment.';
    }
  }

  Future<KeseCloudCreatorTenantsResponse> _loadCreatorOverview() async {
    final session = _creatorSession;
    if (session == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    return _cloudService.creatorTenants(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
  }

  Future<KeseCloudCreatorSession> _updateCreatorProfile({
    required String username,
    required String currentPin,
    required String pin,
  }) async {
    final session = _creatorSession;
    if (session == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    final response = await _cloudService.creatorUpdateProfile(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      currentPin: currentPin,
      username: username,
      pin: pin,
    );
    final updated = KeseCloudCreatorSession(
      baseUrl: session.baseUrl,
      accessToken: response.accessToken,
      username: response.username,
      expiresAt: response.expiresAt,
    );
    setState(() => _creatorSession = updated);
    return updated;
  }

  void _updateCreatorCloudBaseUrl(String baseUrl) {
    final session = _creatorSession;
    if (session == null) return;
    setState(() {
      _creatorSession = KeseCloudCreatorSession(
        baseUrl: KeseCloudService.normalizeBaseUrl(baseUrl),
        accessToken: session.accessToken,
        username: session.username,
        expiresAt: session.expiresAt,
      );
    });
  }

  Future<KeseCloudLicense> _updateCreatorLicense({
    required int licenseId,
    String? licenseCode,
    String? status,
    String? planCode,
    String? licenseDuration,
    int? maxDevices,
    int? maxUsers,
    String? cloudBaseUrl,
  }) async {
    final session = _creatorSession;
    if (session == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    return _cloudService.creatorUpdateLicense(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      licenseId: licenseId,
      licenseCode: licenseCode,
      status: status,
      planCode: planCode,
      licenseDuration: licenseDuration,
      maxDevices: maxDevices,
      maxUsers: maxUsers,
      cloudBaseUrl: cloudBaseUrl,
    );
  }

  Future<KeseCloudLicense> _resetCreatorLicense({
    required int licenseId,
  }) async {
    final session = _creatorSession;
    if (session == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    return _cloudService.creatorResetLicense(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      licenseId: licenseId,
    );
  }

  Future<void> _deleteCreatorLicense({
    required int licenseId,
  }) async {
    final session = _creatorSession;
    if (session == null) {
      throw const KeseCloudException('Session créateur introuvable.');
    }
    await _cloudService.creatorDeleteLicense(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      licenseId: licenseId,
    );
  }

  void _openCreatorAccess() {
    setState(() => _launchStage = AppLaunchStage.creatorAuth);
  }

  void _applyCreatorSeed({
    required String baseUrl,
    required KeseCloudTenantCreateResponse response,
    required String adminPin,
  }) {
    final hint = response.activationHint;
    setState(() {
      _creatorSeed = CreatorActivationSeed(
        baseUrl: KeseCloudService.normalizeBaseUrl(
          response.tenant.cloudBaseUrl ?? baseUrl,
        ),
        companyName: response.tenant.companyName,
        ownerName: response.tenant.ownerName ?? '',
        tenantKey: (hint['tenant_key'] ?? response.tenant.tenantKey).toString(),
        licenseCode:
            (hint['license_code'] ?? response.license.licenseCode).toString(),
        adminUsername:
            (hint['admin_username'] ?? response.adminUser.username).toString(),
        adminPin: adminPin,
      );
      _launchStage = AppLaunchStage.activation;
    });
  }

  Future<String?> _submitForgotPasswordRequest(AppUser requester) async {
    _store.sendForgotPasswordRequest(requester);
    await _persistStore();
    final session = _store.cloudSession;
    if (session == null || !currentNetworkOnline()) {
      return null;
    }
    try {
      final pendingEntries = _store.pendingSyncEntries;
      final pushResponse = await _cloudService.push(
        session: session,
        operations: pendingEntries
            .map(
              (entry) => {
                'operation_uid': entry.id,
                'entity_name': entry.entityName,
                'entity_id': entry.entityId,
                'operation_name': entry.operationName,
                'payload_json': entry.payloadJson,
                'payload_hash': entry.payloadHash,
                'created_at': entry.createdAt.toIso8601String(),
              },
            )
            .toList(),
      );
      _applyPushSyncResponseToStore(_store, pendingEntries, pushResponse);
      final pullResponse = await _cloudService.pull(
        session: session,
        afterId: session.lastPulledOperationId,
      );
      _store.applyCloudOperations(pullResponse.operations);
      _store.cloudSession = session.copyWith(
        lastPulledOperationId: pullResponse.cursor,
      );
      _scheduleStorePersist();
      return null;
    } on KeseCloudException catch (error) {
      return error.message;
    } catch (_) {
      return 'La demande est enregistree localement et sera envoyee des que la connexion cloud sera disponible.';
    }
  }

  Future<void> _completeCloudSession({
    required String baseUrl,
    required KeseCloudAuthResponse auth,
    required String pin,
    required String preferredLicenseCode,
    required bool openAppAfterAuth,
  }) async {
    final bootstrapFuture = _cloudService.bootstrap(
      baseUrl: baseUrl,
      accessToken: auth.accessToken,
    );
    final initialPullFuture = _cloudService.pull(
      session: KeseCloudSession(
        baseUrl: KeseCloudService.normalizeBaseUrl(baseUrl),
        accessToken: auth.accessToken,
        tenantKey: '',
        licenseCode: preferredLicenseCode,
        deviceUuid: auth.device.deviceUuid,
        deviceLabel: auth.device.deviceLabel,
        platformName: auth.device.platformName,
        username: auth.user.username,
        role: auth.user.role,
        lastPulledOperationId: 0,
        connectedAt: DateTime.now(),
        expiresAt: auth.expiresAt,
      ),
      afterId: 0,
    );
    final results = await Future.wait([bootstrapFuture, initialPullFuture]);
    final bootstrap = results[0] as KeseCloudBootstrapResponse;
    final initialPull = results[1] as KeseCloudPullResponse;
    if (!mounted) return;

    final existingUsersByUsername = {
      for (final user in _store.users) user.username.trim().toLowerCase(): user,
    };
    final hydratedUsers = bootstrap.users.map((cloudUser) {
      final normalizedUsername = cloudUser.username.trim().toLowerCase();
      final existingUser = existingUsersByUsername[normalizedUsername];
      final localPin = normalizedUsername == auth.user.username.trim().toLowerCase()
          ? pin
          : (existingUser?.pin ?? 'Kese@2026');
      return AppUser(
        code: 'cloud-user-${cloudUser.id}',
        name: cloudUser.fullName,
        username: cloudUser.username,
        role: _cloudRoleToLocal(cloudUser.role),
        pin: localPin,
        isBlocked: cloudUser.isBlocked,
      );
    }).toList();

    final activeCloudUser = hydratedUsers.where((user) {
      return user.username.trim().toLowerCase() ==
          auth.user.username.trim().toLowerCase();
    }).firstOrNull;
    final resolvedActiveUser = activeCloudUser ??
        AppUser(
          code: 'cloud-user-${auth.user.id}',
          name: auth.user.fullName,
          username: auth.user.username,
          role: _cloudRoleToLocal(auth.user.role),
          pin: pin,
          isBlocked: auth.user.isBlocked,
        );
    if (activeCloudUser == null) {
      hydratedUsers.add(resolvedActiveUser);
    }

    setState(() {
      _store.tenantId = bootstrap.tenant.tenantKey;
      _store.branchId = bootstrap.branch.branchCode;
      _store.deviceId = auth.device.deviceUuid;
      _store.cloudSession = KeseCloudSession(
        baseUrl: KeseCloudService.normalizeBaseUrl(baseUrl),
        accessToken: auth.accessToken,
        tenantKey: bootstrap.tenant.tenantKey,
        licenseCode: preferredLicenseCode,
        deviceUuid: auth.device.deviceUuid,
        deviceLabel: auth.device.deviceLabel,
        platformName: auth.device.platformName,
        username: auth.user.username,
        role: auth.user.role,
        lastPulledOperationId: initialPull.cursor,
        connectedAt: DateTime.now(),
        expiresAt: auth.expiresAt,
      );
      _store.cloudAccessConfigured = true;
      _store.pendingCloudActivation = null;
      _store.settings.companyName = bootstrap.tenant.companyName;
      _store.settings.ownerName =
          bootstrap.tenant.ownerName ?? _store.settings.ownerName;
      _store.settings.phone = bootstrap.tenant.phone ?? _store.settings.phone;
      _store.settings.email = bootstrap.tenant.email ?? _store.settings.email;
      _store.settings.address =
          bootstrap.tenant.address ?? _store.settings.address;
      _store.users
        ..clear()
        ..addAll(hydratedUsers);
      _store.activeUser = resolvedActiveUser;
      _store.applyCloudOperations(initialPull.operations);
      final refreshedActiveUser = _store.users.where((user) {
        return user.username.trim().toLowerCase() ==
            auth.user.username.trim().toLowerCase();
      }).firstOrNull;
      if (refreshedActiveUser != null) {
        _store.activeUser = refreshedActiveUser;
      }
      _launchStage =
          openAppAfterAuth ? AppLaunchStage.app : AppLaunchStage.login;
      _scheduleStorePersist();
    });
    await _persistStore();
  }

  Future<void> _initializeApp() async {
    await _restoreStore();
    if (!mounted) return;
    _runSplashSequence();
  }

  Future<void> _restoreStore() async {
    try {
      final snapshotJson = await _localStore.loadSnapshotJson();
      if (snapshotJson == null || snapshotJson.trim().isEmpty) return;
      final decoded = jsonDecode(snapshotJson);
      if (decoded is! Map<String, dynamic>) return;
      _store = _storeFromJson(decoded);
      if (_store.cloudSession != null) {
        _store.cloudAccessConfigured = true;
      }
      if (_store.cloudSession == null && _store.pendingCloudActivation != null) {
        _store.pendingCloudActivation = null;
        unawaited(_persistStore());
      }
      _attachStore(_store);
    } catch (_) {
      _store = AppStore.demo();
      _attachStore(_store);
    }
  }

  void _attachStore(AppStore store) {
    store.onChanged = _scheduleStorePersist;
  }

  void _scheduleStorePersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_persistStore());
    });
  }

  Future<void> _persistStore() async {
    try {
      await _localStore.saveSnapshotJson(jsonEncode(_storeToJson(_store)));
    } catch (_) {}
  }

  Map<String, dynamic> _payloadMap(String payloadJson) {
    try {
      final decoded = jsonDecode(payloadJson);
      return decoded is Map
          ? decoded.map((key, value) => MapEntry('$key', value))
          : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  void _applyPushSyncResponse(
    AppStore store,
    List<SyncQueueEntry> pendingEntries,
    KeseCloudPushResponse pushResponse,
  ) {
    final pendingById = {
      for (final entry in pendingEntries) entry.id: entry,
    };
    final acceptedIds = <String>{};
    final conflictIds = <String>{};
    for (final operation in pushResponse.operations) {
      if (operation.syncStatus == 'accepted') {
        acceptedIds.add(operation.id);
        continue;
      }
      if (operation.syncStatus != 'conflict') continue;
      conflictIds.add(operation.id);
      final localEntry = pendingById[operation.id];
      if (localEntry == null) continue;
      store.registerSyncConflict(
        entityName: localEntry.entityName,
        localEntityId: localEntry.entityId,
        serverEntityId: operation.entityId,
        conflictType: 'duplicate_entity_id',
        localPayload: _payloadMap(localEntry.payloadJson),
        serverPayload: _payloadMap(operation.payloadJson),
      );
    }
    final resolvedIds = <String>{...acceptedIds, ...conflictIds};
    final ignoredIds = pendingEntries
        .where((entry) => !resolvedIds.contains(entry.id))
        .map((entry) => entry.id)
        .toSet();
    if (acceptedIds.isNotEmpty || ignoredIds.isNotEmpty) {
      store.updateSyncQueueStatus(
        entryIds: {...acceptedIds, ...ignoredIds},
        status: SyncOperationStatus.synced,
      );
    }
    if (conflictIds.isNotEmpty) {
      store.updateSyncQueueStatus(
        entryIds: conflictIds,
        status: SyncOperationStatus.conflict,
        lastError: 'Conflit detecte pendant la synchronisation cloud.',
      );
    }
  }

  Future<void> _runSplashSequence() async {
    await Future<void>.delayed(_brandSplashDuration);
    if (!mounted) return;
    setState(() => _launchStage = AppLaunchStage.splashApp);
    await Future<void>.delayed(_appSplashDuration);
    if (!mounted) return;
    setState(() {
      _launchStage = _shouldShowLoginAfterSplash()
          ? AppLaunchStage.login
          : AppLaunchStage.activation;
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final androidDark = isAndroid && isDark;
    final scaffold = isDark ? _darkScaffold : _surface;
    final card = isDark ? _darkPanel : Colors.white;
    final raised = isDark ? _darkPanelRaised : Colors.white;
    final line = isDark ? _darkLine : const Color(0xFFD3E3E8);
    final text = isDark ? _darkText : _ink;
    final mutedText = isDark ? _darkMuted : _muted;
    final tonalSurface = isDark ? _darkAccentSurface : const Color(0xFFE7F5F8);
    final tonalStrong = isDark ? _darkAccentStrong : const Color(0xFFDDEFF4);
    final selectedNavText = isDark ? _darkText : const Color(0xFF073B48);
    final navText = isDark ? const Color(0xFF8FAEBA) : const Color(0xFF0A4C5D);
    return ThemeData(
      useMaterial3: true,
      platform: isAndroid ? TargetPlatform.android : defaultTargetPlatform,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      visualDensity: isAndroid
          ? const VisualDensity(horizontal: -0.2, vertical: -0.1)
          : VisualDensity.standard,
      materialTapTargetSize: isAndroid
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: _green,
        primary: _green,
        secondary: const Color(0xFF236FCA),
        surface: card,
        onSurface: text,
        outline: line,
        outlineVariant: line.withAlpha(isDark ? 150 : 220),
        shadow: Colors.black,
        primaryContainer: tonalStrong,
        secondaryContainer: tonalSurface,
      ),
      canvasColor: scaffold,
      shadowColor: Colors.black.withAlpha(isDark ? 120 : 36),
      splashFactory: isAndroid ? InkSparkle.splashFactory : InkRipple.splashFactory,
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? raised : card,
        hintStyle: TextStyle(color: mutedText),
        labelStyle: TextStyle(color: mutedText),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF57D9F0) : _green,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE98379)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFA79A), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark
              ? (androidDark ? const Color(0xFF16A7C0) : const Color(0xFF118AA1))
              : _green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? const Color(0xFF26414D) : const Color(0xFFB9D3D9),
          disabledForegroundColor: isDark ? const Color(0xFF7B97A3) : const Color(0xFF5E7881),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? _darkText : _greenDark,
          side: BorderSide(color: line),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? const Color(0xFF8BE6F8) : _green,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: isDark ? _darkText : _greenDark,
          backgroundColor: isDark ? _darkAccentSurface.withAlpha(160) : const Color(0xFFEAF7FA),
          hoverColor: isDark ? _darkAccentStrong.withAlpha(180) : const Color(0xFFDFF3F7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? _darkAccentSurface : const Color(0xFFEAF7FA),
        selectedColor: isDark ? _darkAccentStrong : const Color(0xFFD8F0F5),
        disabledColor: isDark ? _darkPanelRaised : const Color(0xFFEEF5F7),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF09141B) : const Color(0xFFFCFEFF),
        indicatorColor: isDark ? const Color(0xFF123948) : const Color(0xFFDDEFF4),
        height: isAndroid ? 74 : null,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withAlpha(isDark ? 110 : 25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? selectedNavText : navText,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? selectedNavText : navText,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? const Color(0xFF8BE6F8) : _green,
        textColor: text,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: line.withAlpha(isDark ? 180 : 255),
        thickness: 1,
        space: 1,
      ),
      dividerColor: line,
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: isAndroid,
        dragHandleColor: isDark ? const Color(0xFF4F6F7D) : const Color(0xFFB6CED6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark
            ? (androidDark ? const Color(0xFF169BB2) : const Color(0xFF118AA1))
            : _green,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF10232D) : const Color(0xFF113946),
        contentTextStyle: TextStyle(
          color: Colors.white.withAlpha(244),
          fontWeight: FontWeight.w700,
        ),
        actionTextColor: isDark ? _darkSuccessTint : const Color(0xFFA8F1FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
        insetPadding: isAndroid
            ? const EdgeInsets.fromLTRB(14, 0, 14, 14)
            : const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: line),
        ),
        textStyle: TextStyle(color: text, fontWeight: FontWeight.w700),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13313D) : const Color(0xFF123E4B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF1D5368) : const Color(0xFF1B5B6A),
          ),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark
            ? (androidDark ? const Color(0xFF52DAF5) : const Color(0xFF30C5DF))
            : _green,
        circularTrackColor: isDark ? const Color(0xFF173342) : const Color(0xFFDCEEF2),
        linearTrackColor: isDark ? const Color(0xFF173342) : const Color(0xFFDCEEF2),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: line),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? const Color(0xFF19A1B8) : _green;
          }
          return isDark ? _darkPanelRaised : Colors.white;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? const Color(0xFFB9F7FF) : Colors.white;
          }
          return isDark ? const Color(0xFF7D97A2) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? const Color(0xFF14879C) : _green;
          }
          return isDark ? const Color(0xFF26424F) : const Color(0xFFD5E3E8);
        }),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          isDark ? const Color(0xFF14303B) : const Color(0xFFE8F5F8),
        ),
        dataTextStyle: TextStyle(color: text),
        headingTextStyle: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
        ),
        dividerThickness: 0.5,
      ),
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0B1820) : _green,
        foregroundColor: isDark ? _darkText : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: isAndroid ? 62 : null,
      ),
    );
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    unawaited(_persistStore());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KESE',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: switch (_launchStage) {
        AppLaunchStage.splashBrand => const AppSplashPage(
          logoAsset: _dtechLogoAsset,
          title: '',
          subtitle: 'Built with DSquare Technologies by Musagara Daniel',
          accent: Color(0xFF0F6F82),
          duration: _brandSplashDuration,
          footerText: 'Copyright DTech 2026',
          petrolBackground: true,
        ),
        AppLaunchStage.splashApp => const AppSplashPage(
          logoAsset: _keseLogoAsset,
          title: 'KESE',
          subtitle: 'Votre assistante commerciale, en ligne comme hors ligne.',
          accent: Color(0xFFFF5B00),
          duration: _appSplashDuration,
          footerText: 'Chargement de votre espace commercial',
          circularLogoFrame: true,
        ),
        AppLaunchStage.activation => ActivationPage(
          store: _store,
          creatorSeed: _creatorSeed,
          darkMode: _themeMode == ThemeMode.dark,
          toggleTheme: () => setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          }),
          onActivated: () => setState(() {
            _launchStage = AppLaunchStage.login;
          }),
          onCloudActivate: _activateCloudSession,
          onAttachExistingCompany: _attachDeviceToExistingCompany,
          onPrepareOfflineActivation: _prepareOfflineActivation,
          onOpenCreatorAccess: _openCreatorAccess,
          onOpenLogin: () => setState(() {
            _launchStage = AppLaunchStage.login;
          }),
        ),
        AppLaunchStage.login => LoginPage(
          store: _store,
          darkMode: _themeMode == ThemeMode.dark,
          toggleTheme: () => setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          }),
          onLogin: (user) => setState(() {
            _store.activeUser = user;
            _launchStage = AppLaunchStage.app;
            _scheduleStorePersist();
          }),
          onCloudLogin: _loginCloudSession,
          onOpenCreatorAccess: _openCreatorAccess,
          onForgotPasswordRequest: _submitForgotPasswordRequest,
        ),
        AppLaunchStage.creatorAuth => CreatorAccessLoginPage(
          darkMode: _themeMode == ThemeMode.dark,
          toggleTheme: () => setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          }),
          onAuthenticate: _authenticateCreator,
          onAuthenticated: () => setState(() {
            _launchStage = AppLaunchStage.creator;
          }),
          onBack: () => setState(() {
            _launchStage = _shouldShowLoginAfterSplash()
                ? AppLaunchStage.login
                : AppLaunchStage.activation;
          }),
        ),
        AppLaunchStage.creator => CreatorSpacePage(
          darkMode: _themeMode == ThemeMode.dark,
          toggleTheme: () => setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          }),
          creatorSession: _creatorSession,
          onCreateTenant: _createCloudTenant,
          onLoadOverview: _loadCreatorOverview,
          onUpdateCreatorProfile: _updateCreatorProfile,
          onUpdateCreatorCloudBaseUrl: _updateCreatorCloudBaseUrl,
          onUpdateLicense: _updateCreatorLicense,
          onResetLicense: _resetCreatorLicense,
          onDeleteLicense: _deleteCreatorLicense,
          onOpenActivationFromResult: _applyCreatorSeed,
          onBack: () => setState(() {
            _launchStage = AppLaunchStage.creatorAuth;
          }),
        ),
        AppLaunchStage.app => MajiskifHome(
          store: _store,
          darkMode: _themeMode == ThemeMode.dark,
          toggleTheme: () => setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          }),
          onLogout: () => setState(() {
            _launchStage = AppLaunchStage.login;
            _scheduleStorePersist();
          }),
          onSynchronizePendingActivation: _synchronizePendingCloudActivation,
        ),
      },
    );
  }
}

enum AppLaunchStage {
  splashBrand,
  splashApp,
  activation,
  login,
  creatorAuth,
  creator,
  app,
}

class AppSplashPage extends StatelessWidget {
  const AppSplashPage({
    super.key,
    required this.logoAsset,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.duration,
    required this.footerText,
    this.petrolBackground = false,
    this.circularLogoFrame = false,
  });

  final String logoAsset;
  final String title;
  final String subtitle;
  final Color accent;
  final Duration duration;
  final String footerText;
  final bool petrolBackground;
  final bool circularLogoFrame;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle.trim().isNotEmpty;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: petrolBackground
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF041E27),
                          Color(0xFF0A4C5D),
                          Color(0xFF12839A),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3A1704),
                          Color(0xFFFF8A00),
                          Color(0xFFFFB347),
                        ],
                      ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -80,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(14),
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: Colors.white.withAlpha(22)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -70,
            child: Transform.rotate(
              angle: 0.28,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(22),
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: Colors.white.withAlpha(12)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 26),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: circularLogoFrame ? 220 : 250,
                        height: circularLogoFrame ? 220 : 160,
                        padding: EdgeInsets.all(circularLogoFrame ? 24 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(circularLogoFrame ? 20 : 0),
                          shape:
                              circularLogoFrame ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius:
                              circularLogoFrame ? null : BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withAlpha(circularLogoFrame ? 36 : 24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(28),
                              blurRadius: 34,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.business_center_rounded,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (hasTitle) ...[
                        const SizedBox(height: 28),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(18),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(18),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: duration,
                          builder: (context, value, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withAlpha(90),
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      hasSubtitle ? subtitle : footerText,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(value * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                footerText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(214),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef CloudActivateCallback = Future<String?> Function({
  required String baseUrl,
  required String licenseCode,
  required String username,
  required String pin,
  required String deviceLabel,
});

typedef CloudLoginCallback = Future<String?> Function({
  required String baseUrl,
  required String tenantKey,
  required String username,
  required String pin,
  required String deviceLabel,
});

typedef CreatorCreateTenantCallback =
    Future<KeseCloudTenantCreateResponse> Function({
  required String baseUrl,
  required String companyName,
  String? cloudBaseUrl,
  required String ownerName,
  required String phone,
  required String email,
  required String address,
  required String branchName,
  required String adminFullName,
  required String adminUsername,
  required String adminPin,
  required String planCode,
  required String licenseDuration,
  required int maxDevices,
  required int maxUsers,
});

typedef CreatorAccessCallback = Future<String?> Function({
  required String baseUrl,
  required String username,
  required String pin,
});

typedef CreatorLoadOverviewCallback =
    Future<KeseCloudCreatorTenantsResponse> Function();

typedef CreatorUpdateProfileCallback =
    Future<KeseCloudCreatorSession> Function({
  required String username,
  required String currentPin,
  required String pin,
});

typedef CreatorUpdateCloudBaseUrlCallback = void Function(String baseUrl);

typedef CreatorUpdateLicenseCallback = Future<KeseCloudLicense> Function({
  required int licenseId,
  String? licenseCode,
  String? status,
  String? planCode,
  String? licenseDuration,
  int? maxDevices,
  int? maxUsers,
  String? cloudBaseUrl,
});

typedef CreatorResetLicenseCallback = Future<KeseCloudLicense> Function({
  required int licenseId,
});

typedef CreatorDeleteLicenseCallback = Future<void> Function({
  required int licenseId,
});

typedef OfflineActivationCallback = Future<String?> Function({
  required bool firstActivation,
  required String baseUrl,
  required String companyName,
  required String licenseCode,
  required String tenantKey,
  required String username,
  required String pin,
  required String deviceLabel,
});

class CreatorActivationSeed {
  const CreatorActivationSeed({
    required this.baseUrl,
    required this.companyName,
    required this.ownerName,
    required this.tenantKey,
    required this.licenseCode,
    required this.adminUsername,
    required this.adminPin,
  });

  final String baseUrl;
  final String companyName;
  final String ownerName;
  final String tenantKey;
  final String licenseCode;
  final String adminUsername;
  final String adminPin;
}

class PendingCloudActivation {
  const PendingCloudActivation({
    required this.firstActivation,
    required this.baseUrl,
    required this.companyName,
    required this.licenseCode,
    required this.tenantKey,
    required this.username,
    required this.pin,
    required this.deviceLabel,
    required this.createdAt,
  });

  final bool firstActivation;
  final String baseUrl;
  final String companyName;
  final String licenseCode;
  final String tenantKey;
  final String username;
  final String pin;
  final String deviceLabel;
  final DateTime createdAt;

  PendingCloudActivation copyWith({
    bool? firstActivation,
    String? baseUrl,
    String? companyName,
    String? licenseCode,
    String? tenantKey,
    String? username,
    String? pin,
    String? deviceLabel,
    DateTime? createdAt,
  }) => PendingCloudActivation(
        firstActivation: firstActivation ?? this.firstActivation,
        baseUrl: baseUrl ?? this.baseUrl,
        companyName: companyName ?? this.companyName,
        licenseCode: licenseCode ?? this.licenseCode,
        tenantKey: tenantKey ?? this.tenantKey,
        username: username ?? this.username,
        pin: pin ?? this.pin,
        deviceLabel: deviceLabel ?? this.deviceLabel,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'firstActivation': firstActivation,
        'baseUrl': baseUrl,
        'companyName': companyName,
        'licenseCode': licenseCode,
        'tenantKey': tenantKey,
        'username': username,
        'pin': pin,
        'deviceLabel': deviceLabel,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingCloudActivation.fromJson(Map<String, dynamic> json) =>
      PendingCloudActivation(
        firstActivation: json['firstActivation'] != false,
        baseUrl: (json['baseUrl'] ?? '').toString(),
        companyName: (json['companyName'] ?? '').toString(),
        licenseCode: (json['licenseCode'] ?? '').toString(),
        tenantKey: (json['tenantKey'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        pin: (json['pin'] ?? '').toString(),
        deviceLabel: (json['deviceLabel'] ?? '').toString(),
        createdAt:
            DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
                DateTime.now(),
      );
}

enum _ActivationMode { firstActivation, existingCompany }

class _EntryScreenFrame extends StatelessWidget {
  const _EntryScreenFrame({
    required this.darkMode,
    required this.toggleTheme,
    required this.heroBadge,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroPoints,
    required this.formTitle,
    required this.formSubtitle,
    required this.logoAsset,
    required this.formChild,
    this.heroAccent = _green,
    this.formKicker = 'KESE Workspace',
    this.formHighlights = const [],
    this.preferStacked = false,
    this.formFirst = false,
    this.desktopFormMaxWidth,
    this.desktopShellMaxWidth,
    this.showFormLogo = true,
    this.showHeroLogo = true,
    this.showHighlightsLogo = false,
  });

  final bool darkMode;
  final VoidCallback toggleTheme;
  final String heroBadge;
  final String heroTitle;
  final String heroSubtitle;
  final List<String> heroPoints;
  final String formTitle;
  final String formSubtitle;
  final String logoAsset;
  final Widget formChild;
  final Color heroAccent;
  final String formKicker;
  final List<String> formHighlights;
  final bool preferStacked;
  final bool formFirst;
  final double? desktopFormMaxWidth;
  final double? desktopShellMaxWidth;
  final bool showFormLogo;
  final bool showHeroLogo;
  final bool showHighlightsLogo;

  @override
  Widget build(BuildContext context) {
    final background = darkMode
        ? const [Color(0xFF050C11), Color(0xFF0A1821), Color(0xFF113443)]
        : const [Color(0xFFF7FBFC), Color(0xFFEAF7FA), Color(0xFFDDF1F5)];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: background,
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -70,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(darkMode ? 12 : 26),
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(color: Colors.white.withAlpha(24)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -80,
            child: Transform.rotate(
              angle: 0.22,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(darkMode ? 28 : 12),
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = !preferStacked && constraints.maxWidth >= 1024;
                final desktop = !preferStacked && constraints.maxWidth >= 1260;
                final shellWidth =
                    desktop ? (desktopShellMaxWidth ?? 1380.0) : 1180.0;
                final formPanelMaxWidth =
                    desktop ? (desktopFormMaxWidth ?? 520.0) : 448.0;
                final framePadding = desktop ? 28.0 : 20.0;
                final formPanel = Container(
                  constraints: BoxConstraints(maxWidth: formPanelMaxWidth),
                  decoration: BoxDecoration(
                    color: _panelColor(context),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: _panelBorderColor(context)),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(darkMode ? 58 : 18),
                        blurRadius: darkMode ? 42 : 34,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -32,
                        right: -20,
                        child: Transform.rotate(
                          angle: -0.18,
                          child: Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: heroAccent.withAlpha(darkMode ? 26 : 34),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: heroAccent.withAlpha(52),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -24,
                        left: -16,
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: heroAccent.withAlpha(darkMode ? 18 : 26),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 26 : 22,
                          desktop ? 26 : 22,
                          desktop ? 26 : 22,
                          desktop ? 26 : 22,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showFormLogo) ...[
                                  Container(
                                    width: 58,
                                    height: 58,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _softAccentStrong(context),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: heroAccent.withAlpha(40),
                                      ),
                                    ),
                                    child: Image.asset(
                                      logoAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(
                                        Icons.business_center_rounded,
                                        color: heroAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: heroAccent.withAlpha(
                                            darkMode ? 28 : 18,
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: heroAccent.withAlpha(42),
                                          ),
                                        ),
                                        child: Text(
                                          formKicker,
                                          style: TextStyle(
                                            color: darkMode
                                                ? Colors.white
                                                : _greenDark,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        formTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formSubtitle,
                                        style: TextStyle(
                                          color: _mutedTextColor(context),
                                          height: 1.38,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: toggleTheme,
                                  icon: Icon(
                                    darkMode
                                        ? Icons.light_mode_rounded
                                        : Icons.dark_mode_rounded,
                                  ),
                                ),
                              ],
                            ),
                            if (formHighlights.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: formHighlights
                                          .map(
                                            (label) => _EntryFormChip(
                                              label: label,
                                              accent: heroAccent,
                                              darkMode: darkMode,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  if (showHighlightsLogo) ...[
                                    const SizedBox(width: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: SizedBox(
                                        height: 92,
                                        child: Image.asset(
                                          logoAsset,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(
                                            Icons.point_of_sale_rounded,
                                            color: heroAccent,
                                            size: 54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            const SizedBox(height: 18),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    heroAccent.withAlpha(110),
                                    _panelBorderColor(context),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            formChild,
                          ],
                        ),
                      ),
                    ],
                  ),
                );

                final heroPanel = Container(
                  constraints: BoxConstraints(minHeight: desktop ? 500 : 360),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: darkMode
                          ? [
                              const Color(0xFF08131B),
                              const Color(0xFF0B2B39),
                              const Color(0xFF106679),
                            ]
                          : [
                              const Color(0xFF0B4552),
                              const Color(0xFF0F6F82),
                              heroAccent,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withAlpha(26)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 28,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -48,
                        right: -36,
                        child: Transform.rotate(
                          angle: -0.24,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(18),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: Colors.white.withAlpha(22),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        left: -20,
                        child: Transform.rotate(
                          angle: 0.18,
                          child: Container(
                            width: 220,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(18),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withAlpha(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 30 : 24,
                          desktop ? 30 : 24,
                          desktop ? 30 : 24,
                          desktop ? 30 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withAlpha(22),
                                ),
                              ),
                              child: Text(
                                heroBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeroLogo) ...[
                                  Container(
                                    width: 86,
                                    height: 86,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                          color: Colors.black.withAlpha(darkMode ? 32 : 20),
                                          blurRadius: darkMode ? 24 : 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      logoAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        heroTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0,
                                            ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        heroSubtitle,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(230),
                                          height: 1.45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            ...heroPoints.map(
                              (point) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(18),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(232),
                                          height: 1.4,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(darkMode ? 12 : 14),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withAlpha(darkMode ? 16 : 18),
                                ),
                              ),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: const [
                                  _EntryStatChip(
                                    icon: Icons.wifi_tethering_rounded,
                                    label: 'Temps réel',
                                  ),
                                  _EntryStatChip(
                                    icon: Icons.devices_rounded,
                                    label: 'Multi-appareils',
                                  ),
                                  _EntryStatChip(
                                    icon: Icons.security_rounded,
                                    label: 'Accès sécurisé',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );

                final responsiveBody = wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (formFirst) ...[
                            SizedBox(
                              width: formPanelMaxWidth,
                              child: formPanel,
                            ),
                            SizedBox(width: desktop ? 28 : 24),
                            Flexible(child: heroPanel),
                          ] else ...[
                            Flexible(child: heroPanel),
                            SizedBox(width: desktop ? 28 : 24),
                            SizedBox(
                              width: formPanelMaxWidth,
                              child: formPanel,
                            ),
                          ],
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (formFirst) ...[
                            Align(
                              alignment: Alignment.center,
                              child: formPanel,
                            ),
                            const SizedBox(height: 18),
                            heroPanel,
                          ] else ...[
                            heroPanel,
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.center,
                              child: formPanel,
                            ),
                          ],
                        ],
                      );

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(framePadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: shellWidth),
                      child: desktop
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(darkMode ? 6 : 54),
                                borderRadius: BorderRadius.circular(42),
                                border: Border.all(
                                  color: Colors.white.withAlpha(
                                    darkMode ? 16 : 140,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      darkMode ? 36 : 10,
                                    ),
                                    blurRadius: darkMode ? 42 : 32,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: responsiveBody,
                            )
                          : responsiveBody,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryFormChip extends StatelessWidget {
  const _EntryFormChip({
    required this.label,
    required this.accent,
    required this.darkMode,
  });

  final String label;
  final Color accent;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withAlpha(darkMode ? 24 : 16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withAlpha(42)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: darkMode ? Colors.white : _greenDark,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EntryStatChip extends StatelessWidget {
  const _EntryStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseHelpBullet extends StatelessWidget {
  const _LicenseHelpBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _softAccentStrong(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: _green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _strongTextColor(context),
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseSectionCard extends StatelessWidget {
  const _LicenseSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: _mutedTextColor(context),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LicenseClauseTile extends StatelessWidget {
  const _LicenseClauseTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _strongTextColor(context),
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HelpParagraphs extends StatelessWidget {
  const _HelpParagraphs(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                line,
                style: TextStyle(
                  color: _strongTextColor(context),
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HelpBulletList extends StatelessWidget {
  const _HelpBulletList(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((line) => _LicenseHelpBullet(text: line))
          .toList(growable: false),
    );
  }
}

class _EntryContextCard extends StatelessWidget {
  const _EntryContextCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = _green,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withAlpha(38)),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivationModeButton extends StatelessWidget {
  static const _activeNavy = Color(0xFF143A63);

  const _ActivationModeButton({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? _activeNavy : _softPanelColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? _activeNavy.withAlpha(220)
                  : _panelBorderColor(context),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _activeNavy.withAlpha(34),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(18)
                      : _panelColor(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: selected ? Colors.white : _green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: selected
                            ? Colors.white.withAlpha(220)
                            : _mutedTextColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivationPage extends StatefulWidget {
  const ActivationPage({
    super.key,
    required this.store,
    required this.creatorSeed,
    required this.darkMode,
    required this.toggleTheme,
    required this.onActivated,
    required this.onCloudActivate,
    required this.onAttachExistingCompany,
    required this.onPrepareOfflineActivation,
    required this.onOpenCreatorAccess,
    required this.onOpenLogin,
  });

  final AppStore store;
  final CreatorActivationSeed? creatorSeed;
  final bool darkMode;
  final VoidCallback toggleTheme;
  final VoidCallback onActivated;
  final CloudActivateCallback onCloudActivate;
  final CloudLoginCallback onAttachExistingCompany;
  final OfflineActivationCallback onPrepareOfflineActivation;
  final VoidCallback onOpenCreatorAccess;
  final VoidCallback onOpenLogin;

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class ActivationLicenseHelpPage extends StatelessWidget {
  const ActivationLicenseHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et contacts'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF082D4A),
                            Color(0xFF0F4F7D),
                            Color(0xFF14618F),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(18),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Image.asset(
                                  _keseLogoAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.support_agent_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aide officielle KESE',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Présentation de D-Square Technologies, de Musagara Daniel et de KESE, avec les contacts officiels pour l’assistance, l’activation et le suivi technique.',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(236),
                                        fontWeight: FontWeight.w700,
                                        height: 1.55,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _LicenseSectionCard(
                                  title:
                                      'Présentation de l’Entreprise — D-Square Technologies',
                                  subtitle:
                                      'Technologies numériques, innovation et solutions intelligentes.',
                                  child: const _HelpParagraphs(
                                    _companyPresentationParagraphs,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _LicenseSectionCard(
                                  title:
                                      'Présentation du Fondateur — Musagara Daniel',
                                  subtitle:
                                      'Entrepreneur technologique, CEO & Founder de D-Square Technologies.',
                                  child: const _HelpParagraphs(
                                    _founderPresentationParagraphs,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _LicenseSectionCard(
                                title:
                                    'Présentation de l’Entreprise — D-Square Technologies',
                                subtitle:
                                    'Technologies numériques, innovation et solutions intelligentes.',
                                child: const _HelpParagraphs(
                                  _companyPresentationParagraphs,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _LicenseSectionCard(
                                title:
                                    'Présentation du Fondateur — Musagara Daniel',
                                subtitle:
                                    'Entrepreneur technologique, CEO & Founder de D-Square Technologies.',
                                child: const _HelpParagraphs(
                                  _founderPresentationParagraphs,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 18),
                    _LicenseSectionCard(
                      title: 'Domaines technologiques',
                      subtitle:
                          'Les principaux domaines d’intervention de D-Square Technologies.',
                      child: const _HelpBulletList(_companyDomains),
                    ),
                    const SizedBox(height: 18),
                    _LicenseSectionCard(
                      title: 'Présentation de l’Application — KESE',
                      subtitle:
                          'Une assistante commerciale numérique pour les entreprises modernes.',
                      child: const _HelpParagraphs(_kesePresentationParagraphs),
                    ),
                    const SizedBox(height: 18),
                    wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _LicenseSectionCard(
                                  title: 'Fonctionnalités principales de KESE',
                                  subtitle:
                                      'Les outils essentiels pour gérer l’activité commerciale.',
                                  child: const _HelpBulletList(_keseFeatures),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _LicenseSectionCard(
                                  title: 'Une solution disponible partout',
                                  subtitle:
                                      'Les plateformes prévues pour garder la continuité des opérations.',
                                  child: const _HelpBulletList(_kesePlatforms),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: const [
                              _LicenseSectionCard(
                                title: 'Fonctionnalités principales de KESE',
                                subtitle:
                                    'Les outils essentiels pour gérer l’activité commerciale.',
                                child: _HelpBulletList(_keseFeatures),
                              ),
                              SizedBox(height: 16),
                              _LicenseSectionCard(
                                title: 'Une solution disponible partout',
                                subtitle:
                                    'Les plateformes prévues pour garder la continuité des opérations.',
                                child: _HelpBulletList(_kesePlatforms),
                              ),
                            ],
                          ),
                    const SizedBox(height: 18),
                    Text(
                      'Contacts officiels',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pour toute question liée à l’activation, à la réactivation, à la maintenance ou aux droits d’utilisation, utilisez les contacts ci-dessous.',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: _BrandBanner()),
                              const SizedBox(width: 14),
                              const Expanded(child: _KeseBrandBanner()),
                            ],
                          )
                        : const Column(
                            children: [
                              _BrandBanner(),
                              SizedBox(height: 12),
                              _KeseBrandBanner(),
                            ],
                          ),
                    const SizedBox(height: 14),
                    const CreatorProfileCard(),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: _panelColor(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _panelBorderColor(context)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.alternate_email_rounded,
                              color: _green,
                            ),
                            title: const Text('Email'),
                            subtitle: const Text(_creatorEmail),
                            onTap: () => openExternalUrl('mailto:$_creatorEmail'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.phone_rounded,
                              color: _green,
                            ),
                            title: const Text('Téléphone'),
                            subtitle: const Text('+243 971 238 634'),
                            onTap: () => openExternalUrl('tel:+243971238634'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Image.asset(
                              _whatsAppAsset,
                              width: 22,
                              height: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.chat_rounded,
                                color: Color(0xFF25D366),
                              ),
                            ),
                            title: const Text('WhatsApp'),
                            subtitle: const Text('+243 971 238 634'),
                            onTap: () =>
                                openExternalUrl('https://wa.me/243971238634'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivationPageState extends State<ActivationPage> {
  _ActivationMode _mode = _ActivationMode.firstActivation;
  late final TextEditingController _cloudBaseUrl;
  late final TextEditingController _licenseCode;
  late final TextEditingController _tenantKey;
  late final TextEditingController _companyName;
  late final TextEditingController _username;
  late final TextEditingController _pin;
  late final TextEditingController _deviceLabel;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.creatorSeed;
    _cloudBaseUrl = TextEditingController(
      text: seed?.baseUrl ??
          widget.store.cloudSession?.baseUrl ??
          _defaultCloudBaseUrl,
    );
    _licenseCode = TextEditingController(
      text: seed?.licenseCode ?? widget.store.cloudSession?.licenseCode ?? '',
    );
    _tenantKey = TextEditingController(
      text: seed?.tenantKey ?? widget.store.cloudSession?.tenantKey ?? '',
    );
    _companyName = TextEditingController(
      text: seed?.companyName ??
          (widget.store.settings.companyName == 'Votre entreprise'
              ? ''
              : widget.store.settings.companyName),
    );
    _username = TextEditingController(
      text: seed?.adminUsername ??
          widget.store.cloudSession?.username ??
          'Admin',
    );
    _pin = TextEditingController(text: seed?.adminPin ?? 'Admin@2026');
    _deviceLabel = TextEditingController(
      text: widget.store.cloudSession?.deviceLabel ?? 'Appareil KESE principal',
    );
    if (seed != null) {
      widget.store.settings.companyName = seed.companyName;
      if (seed.ownerName.trim().isNotEmpty) {
        widget.store.settings.ownerName = seed.ownerName.trim();
      }
    }
  }

  @override
  void dispose() {
    _cloudBaseUrl.dispose();
    _licenseCode.dispose();
    _tenantKey.dispose();
    _companyName.dispose();
    _username.dispose();
    _pin.dispose();
    _deviceLabel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _pin.text.trim().isEmpty) {
      setState(
        () => _error = _mode == _ActivationMode.firstActivation
            ? 'Renseigne le compte administrateur fourni avec la licence.'
            : 'Renseigne un compte déjà rattaché à cette entreprise.',
      );
      return;
    }
    if (_pin.text.trim().length < 6) {
      setState(
        () => _error =
            'Le mot de passe doit contenir au moins 6 caractères.',
      );
      return;
    }
    if (_deviceLabel.text.trim().length < 2) {
      setState(() => _error = 'Donne un nom clair à cet appareil.');
      return;
    }
    if (_mode == _ActivationMode.firstActivation &&
        _companyName.text.trim().length < 2) {
      setState(
        () => _error =
            'Renseigne le nom de l’entreprise fourni avec cette activation.',
      );
      return;
    }
    if (_mode == _ActivationMode.firstActivation &&
        _licenseCode.text.trim().length < 8) {
      setState(() => _error = 'Le code licence est requis pour activer KESE.');
      return;
    }
    if (_mode == _ActivationMode.existingCompany &&
        _tenantKey.text.trim().length < 4) {
      setState(
        () => _error =
            'Renseigne la clé entreprise pour rattacher cet appareil.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    if (_mode == _ActivationMode.firstActivation) {
      widget.store.settings.companyName = _companyName.text.trim();
    }
    if (_cloudBaseUrl.text.trim().isEmpty) {
      setState(() {
        _busy = false;
        _error =
            'L’adresse cloud est obligatoire pour valider la licence et créer la base locale sécurisée.';
      });
      return;
    }
    if (!currentNetworkOnline()) {
      setState(() {
        _busy = false;
        _error =
            'La première liaison doit être validée en ligne. Après cette validation, KESE fonctionnera aussi hors ligne.';
      });
      return;
    }
    final result = _mode == _ActivationMode.firstActivation
        ? await widget.onCloudActivate(
            baseUrl: _cloudBaseUrl.text.trim(),
            licenseCode: _licenseCode.text.trim(),
            username: _username.text.trim(),
            pin: _pin.text.trim(),
            deviceLabel: _deviceLabel.text.trim(),
          )
        : await widget.onAttachExistingCompany(
            baseUrl: _cloudBaseUrl.text.trim(),
            tenantKey: _tenantKey.text.trim(),
            username: _username.text.trim(),
            pin: _pin.text.trim(),
            deviceLabel: _deviceLabel.text.trim(),
          );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result;
    });
    if (result == null) {
      final session = widget.store.cloudSession;
      if (session != null && _mode == _ActivationMode.firstActivation) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Activation réussie'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conserve bien cette clé entreprise. Elle servira à rattacher les autres appareils.',
                ),
                const SizedBox(height: 14),
                SelectableText(
                  session.tenantKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: _greenDark,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: session.tenantKey),
                  );
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clé entreprise copiée.'),
                    ),
                  );
                },
                child: const Text('Copier la clé'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Continuer'),
              ),
            ],
          ),
        );
      }
      widget.onActivated();
    }
  }

  Future<void> _submitOffline() async {
    if (_busy) return;
    setState(() {
      _error =
          'Pour sécuriser l’entreprise, la première liaison de cet appareil doit être validée en ligne. Ensuite, le travail hors ligne restera disponible.';
    });
  }

  Future<void> _openHelpPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ActivationLicenseHelpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirstActivation = _mode == _ActivationMode.firstActivation;
    return _EntryScreenFrame(
      darkMode: widget.darkMode,
      toggleTheme: widget.toggleTheme,
      desktopFormMaxWidth: 640,
      heroBadge: isFirstActivation ? 'Licence principale' : 'Ajout d’appareil',
      heroTitle: isFirstActivation
          ? 'Activez votre espace KESE'
          : 'Rattachez un nouvel appareil',
      heroSubtitle: isFirstActivation
          ? 'Entrez les accès fournis puis lancez l’activation principale.'
          : 'Utilisez la clé entreprise pour connecter ce poste.',
      heroPoints: isFirstActivation
          ? const [
              'Saisir le code licence et le compte admin.',
              'Récupérer ensuite la clé entreprise.',
              'Utiliser cette clé pour les autres postes.',
            ]
          : const [
              'Aucune recréation d’entreprise.',
              'Même liaison cloud que les autres appareils.',
              'Le compte saisi ouvre ce poste.',
            ],
      formTitle: 'Activer KESE',
      formSubtitle: isFirstActivation
          ? 'Entrez les accès remis par le créateur.'
          : 'Entrez la clé entreprise et les accès du poste.',
      formKicker: isFirstActivation
          ? 'Activation'
          : 'Ajout d’appareil',
      formHighlights: const [],
      logoAsset: _keseLogoAsset,
      heroAccent: const Color(0xFF0F6F82),
      formFirst: true,
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final firstButton = _ActivationModeButton(
                selected: isFirstActivation,
                icon: Icons.vpn_key_rounded,
                title: 'Première activation',
                subtitle: 'Premier appareil',
                onTap: () {
                  setState(() {
                    _mode = _ActivationMode.firstActivation;
                    _error = null;
                  });
                },
              );
              final secondButton = _ActivationModeButton(
                selected: !isFirstActivation,
                icon: Icons.devices_rounded,
                title: 'Ajouter un appareil',
                subtitle: 'Poste supplémentaire',
                onTap: () {
                  setState(() {
                    _mode = _ActivationMode.existingCompany;
                    _error = null;
                  });
                },
              );
              if (compact) {
                return Column(
                  children: [
                    firstButton,
                    const SizedBox(height: 10),
                    secondButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: firstButton),
                  const SizedBox(width: 10),
                  Expanded(child: secondButton),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _softPanelColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wideFields = constraints.maxWidth >= 560;
                if (isFirstActivation) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AppField(
                        label: 'Code licence',
                        controller: _licenseCode,
                      ),
                      const SizedBox(height: 10),
                      _AppField(
                        label: 'Nom de l’entreprise',
                        controller: _companyName,
                      ),
                      const SizedBox(height: 10),
                      if (wideFields)
                        Row(
                          children: [
                            Expanded(
                              child: _AppField(
                                label: 'Identifiant administrateur',
                                controller: _username,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _AppField(
                                label: 'Code secret administrateur',
                                controller: _pin,
                                number: true,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _AppField(
                          label: 'Identifiant administrateur',
                          controller: _username,
                        ),
                        const SizedBox(height: 10),
                        _AppField(
                          label: 'Code secret administrateur',
                          controller: _pin,
                          number: true,
                        ),
                      ],
                    ],
                  );
                }
                if (wideFields) {
                  return Row(
                    children: [
                      Expanded(
                        child: _AppField(
                          label: 'Clé entreprise',
                          controller: _tenantKey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AppField(
                          label: 'Identifiant existant',
                          controller: _username,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AppField(
                          label: 'Code secret de cet identifiant',
                          controller: _pin,
                          number: true,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AppField(
                      label: 'Clé entreprise',
                      controller: _tenantKey,
                    ),
                    const SizedBox(height: 10),
                    _AppField(
                      label: 'Identifiant existant',
                      controller: _username,
                    ),
                    const SizedBox(height: 10),
                    _AppField(
                      label: 'Code secret de cet identifiant',
                      controller: _pin,
                      number: true,
                    ),
                  ],
                );
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.cloud_off_rounded,
              title: isFirstActivation
                  ? 'Activation impossible'
                  : 'Rattachement impossible',
              subtitle: _error!,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: Icon(
              isFirstActivation
                  ? Icons.rocket_launch_rounded
                  : Icons.devices_rounded,
            ),
            label: Text(
              _busy
                  ? (isFirstActivation
                      ? 'Activation en cours...'
                      : 'Rattachement en cours...')
                  : (isFirstActivation
                      ? 'Activer la licence'
                      : 'Rattacher cet appareil'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : _submitOffline,
            icon: const Icon(Icons.cloud_off_rounded),
            label: Text(
              isFirstActivation
                  ? 'Hors ligne disponible après validation'
                  : 'Rattachement hors ligne désactivé',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openHelpPage,
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Aide et contacts licence'),
          ),
          if (widget.store.cloudSession != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onOpenLogin,
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Aller à la connexion'),
            ),
          ],
          const SizedBox(height: 16),
          _CreatorAccessHint(onLongPress: widget.onOpenCreatorAccess),
        ],
      ),
    );
  }
}

class CreatorSpacePage extends StatefulWidget {
  const CreatorSpacePage({
    super.key,
    required this.darkMode,
    required this.toggleTheme,
    required this.creatorSession,
    required this.onCreateTenant,
    required this.onLoadOverview,
    required this.onUpdateCreatorProfile,
    required this.onUpdateCreatorCloudBaseUrl,
    required this.onUpdateLicense,
    required this.onResetLicense,
    required this.onDeleteLicense,
    required this.onOpenActivationFromResult,
    required this.onBack,
  });

  final bool darkMode;
  final VoidCallback toggleTheme;
  final KeseCloudCreatorSession? creatorSession;
  final CreatorCreateTenantCallback onCreateTenant;
  final CreatorLoadOverviewCallback onLoadOverview;
  final CreatorUpdateProfileCallback onUpdateCreatorProfile;
  final CreatorUpdateCloudBaseUrlCallback onUpdateCreatorCloudBaseUrl;
  final CreatorUpdateLicenseCallback onUpdateLicense;
  final CreatorResetLicenseCallback onResetLicense;
  final CreatorDeleteLicenseCallback onDeleteLicense;
  final void Function({
    required String baseUrl,
    required KeseCloudTenantCreateResponse response,
    required String adminPin,
  }) onOpenActivationFromResult;
  final VoidCallback onBack;

  @override
  State<CreatorSpacePage> createState() => _CreatorSpacePageState();
}

class _CreatorSpacePageState extends State<CreatorSpacePage> {
  late final TextEditingController _companyName;
  late final TextEditingController _ownerName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _branchName;
  late final TextEditingController _adminFullName;
  late final TextEditingController _adminUsername;
  late final TextEditingController _adminPin;
  late final TextEditingController _planCode;
  late final TextEditingController _maxDevices;
  late final TextEditingController _maxUsers;
  late final TextEditingController _creatorUsername;
  late final TextEditingController _creatorCurrentPin;
  late final TextEditingController _creatorNewPin;
  late final TextEditingController _creatorConfirmPin;
  String _licenseDuration = '1y';
  bool _busy = false;
  bool _creatorProfileBusy = false;
  String? _error;
  String? _creatorProfileError;
  bool _overviewBusy = false;
  String? _overviewError;
  List<KeseCloudCreatorTenantOverview> _overviewItems = const [];
  KeseCloudTenantCreateResponse? _result;

  @override
  void initState() {
    super.initState();
    _companyName = TextEditingController();
    _ownerName = TextEditingController();
    _phone = TextEditingController(text: _creatorPhone);
    _email = TextEditingController(text: _creatorEmail);
    _address = TextEditingController(text: 'Bukavu');
    _branchName = TextEditingController(text: 'Site principal');
    _adminFullName = TextEditingController(text: 'Administrateur principal');
    _adminUsername = TextEditingController(text: 'admin');
    _adminPin = TextEditingController(text: 'Admin@2026');
    _planCode = TextEditingController(text: 'standard');
    _maxDevices = TextEditingController(text: '5');
    _maxUsers = TextEditingController(text: '20');
    _creatorUsername = TextEditingController(
      text: widget.creatorSession?.username ?? 'creator',
    );
    _creatorCurrentPin = TextEditingController();
    _creatorNewPin = TextEditingController();
    _creatorConfirmPin = TextEditingController();
    unawaited(_reloadOverview());
  }

  @override
  void dispose() {
    _companyName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _branchName.dispose();
    _adminFullName.dispose();
    _adminUsername.dispose();
    _adminPin.dispose();
    _planCode.dispose();
    _maxDevices.dispose();
    _maxUsers.dispose();
    _creatorUsername.dispose();
    _creatorCurrentPin.dispose();
    _creatorNewPin.dispose();
    _creatorConfirmPin.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CreatorSpacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextUsername = widget.creatorSession?.username ?? 'creator';
    if (_creatorUsername.text.trim() != nextUsername.trim() &&
        !_creatorProfileBusy) {
      _creatorUsername.text = nextUsername;
    }
  }

  Future<void> _reloadOverview() async {
    setState(() {
      _overviewBusy = true;
      _overviewError = null;
    });
    try {
      final response = await widget.onLoadOverview();
      if (!mounted) return;
      setState(() {
        _overviewItems = response.items;
        _overviewBusy = false;
      });
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      setState(() {
        _overviewBusy = false;
        _overviewError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _overviewBusy = false;
        _overviewError = 'Chargement de la supervision impossible.';
      });
    }
  }

  Future<void> _submit() async {
    if (_companyName.text.trim().length < 2) {
      setState(() => _error = 'Le nom de l’entreprise est requis.');
      return;
    }
    if (_adminFullName.text.trim().length < 2 ||
        _adminUsername.text.trim().length < 3 ||
        _adminPin.text.trim().length < 6) {
      setState(
        () => _error =
            'Renseigne correctement le compte administrateur initial.',
      );
      return;
    }
    final maxDevices = int.tryParse(_maxDevices.text.trim());
    if (maxDevices == null || maxDevices < 1) {
      setState(() => _error = 'Le nombre d’appareils doit être valide.');
      return;
    }
    final maxUsers = int.tryParse(_maxUsers.text.trim());
    if (maxUsers == null || maxUsers < 1) {
      setState(() => _error = 'Le nombre d’utilisateurs doit être valide.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = widget.creatorSession;
    if (session == null) {
      setState(() {
        _busy = false;
        _error = 'Session créateur introuvable.';
      });
      return;
    }
    try {
      final result = await widget.onCreateTenant(
        baseUrl: session.baseUrl,
        companyName: _companyName.text.trim(),
        cloudBaseUrl: session.baseUrl,
        ownerName: _ownerName.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        branchName: _branchName.text.trim(),
        adminFullName: _adminFullName.text.trim(),
        adminUsername: _adminUsername.text.trim(),
        adminPin: _adminPin.text.trim(),
        planCode: _planCode.text.trim(),
        licenseDuration: _licenseDuration,
        maxDevices: maxDevices,
        maxUsers: maxUsers,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _busy = false;
      });
      unawaited(_reloadOverview());
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Creation d’entreprise impossible pour le moment.';
      });
    }
  }

  Future<void> _submitCreatorProfileUpdate() async {
    final nextUsername = _creatorUsername.text.trim();
    final currentPin = _creatorCurrentPin.text.trim();
    final nextPin = _creatorNewPin.text.trim();
    final confirmPin = _creatorConfirmPin.text.trim();
    if (nextUsername.length < 3) {
      setState(() => _creatorProfileError = 'Identifiant créateur invalide.');
      return;
    }
    if (currentPin.length < 6) {
      setState(
        () => _creatorProfileError =
            'Le code secret créateur actuel est requis.',
      );
      return;
    }
    if (nextPin.length < 6) {
      setState(
        () => _creatorProfileError =
            'Le nouveau code secret créateur est invalide.',
      );
      return;
    }
    if (nextPin != confirmPin) {
      setState(
        () => _creatorProfileError =
            'La confirmation du nouveau code secret ne correspond pas.',
      );
      return;
    }
    setState(() {
      _creatorProfileBusy = true;
      _creatorProfileError = null;
    });
    try {
      final updatedSession = await widget.onUpdateCreatorProfile(
        username: nextUsername,
        currentPin: currentPin,
        pin: nextPin,
      );
      if (!mounted) return;
      _creatorCurrentPin.clear();
      _creatorNewPin.clear();
      _creatorConfirmPin.clear();
      _creatorUsername.text = updatedSession.username;
      setState(() {
        _creatorProfileBusy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accès créateur mis à jour.'),
        ),
      );
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      setState(() {
        _creatorProfileBusy = false;
        _creatorProfileError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _creatorProfileBusy = false;
        _creatorProfileError =
            'Mise à jour des accès créateur impossible pour le moment.';
      });
    }
  }

  Future<void> _openCreatorProfileEditor() async {
    _creatorProfileError = null;
    _creatorCurrentPin.clear();
    _creatorNewPin.clear();
    _creatorConfirmPin.clear();
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier les accès créateur',
                    onClose: () => Navigator.pop(sheetContext, false),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mettez à jour ici l’identifiant et le code secret du compte créateur.',
                    style: TextStyle(
                      color: _mutedTextColor(context),
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AppField(
                    label: 'Identifiant créateur',
                    controller: _creatorUsername,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Code secret créateur actuel',
                    controller: _creatorCurrentPin,
                    obscure: true,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Nouveau code secret créateur',
                    controller: _creatorNewPin,
                    obscure: true,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Confirmer le nouveau code secret',
                    controller: _creatorConfirmPin,
                    obscure: true,
                    number: true,
                  ),
                  if (_creatorProfileError != null) ...[
                    const SizedBox(height: 10),
                    _InfoBanner(
                      icon: Icons.lock_outline_rounded,
                      title: 'Mise à jour impossible',
                      subtitle: _creatorProfileError!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _creatorProfileBusy
                        ? null
                        : () async {
                            await _submitCreatorProfileUpdate();
                            if (!mounted) return;
                            if (_creatorProfileError == null) {
                              Navigator.pop(sheetContext, true);
                            } else {
                              setLocal(() {});
                            }
                          },
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: Text(
                      _creatorProfileBusy
                          ? 'Mise à jour...'
                          : 'Enregistrer les accès créateur',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _openCreatorCloudAddressEditor() async {
    final controller = TextEditingController(
      text: widget.creatorSession?.baseUrl ?? _defaultCloudBaseUrl,
    );
    String? error;
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier l’adresse cloud',
                    onClose: () => Navigator.pop(sheetContext, false),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Cette adresse sera utilisée pour les prochaines créations d'entreprises et pour les synchronisations cloud.",
                    style: TextStyle(
                      color: _mutedTextColor(context),
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AppField(
                    label: 'Adresse cloud créateur',
                    controller: controller,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: _danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.isEmpty) {
                        setLocal(
                          () => error = 'Renseigne une adresse cloud valide.',
                        );
                        return;
                      }
                      widget.onUpdateCreatorCloudBaseUrl(value);
                      Navigator.pop(sheetContext, true);
                    },
                    icon: const Icon(Icons.cloud_sync_rounded),
                    label: const Text('Enregistrer cette adresse'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (updated == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse cloud créateur mise à jour.'),
        ),
      );
    }
  }

  Future<void> _copyText(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copié.')),
    );
  }

  Future<void> _downloadActivationSheet() async {
    final result = _result;
    if (result == null) return;
    final tenantKey = result.tenant.tenantKey;
    final licenseCode = result.license.licenseCode;
    final adminUsername = result.adminUser.username;
    final adminPin = _adminPin.text.trim();
    final baseUrl =
        result.tenant.cloudBaseUrl ??
        widget.creatorSession?.baseUrl ??
        _defaultCloudBaseUrl;
    final lines = [
      'KESE - FICHE D ACTIVATION',
      '',
      'SERVEUR CLOUD : $baseUrl',
      'Entreprise : ${result.tenant.companyName}',
      'Responsable : ${_ownerName.text.trim()}',
      'Telephone : ${_phone.text.trim()}',
      'Email : ${_email.text.trim()}',
      'Adresse : ${_address.text.trim()}',
      'Site principal : ${result.branch.branchName}',
      'Code du site : ${result.branch.branchCode}',
      '',
      'CLE ENTREPRISE : $tenantKey',
      'CODE LICENCE : $licenseCode',
      'ADMINISTRATEUR : $adminUsername',
      'PIN ADMIN : $adminPin',
      'DUREE LICENCE : ${_licenseDurationLabel(result.license.planCode)}',
      'EXPIRATION : ${_formatLicenseExpiry(result.license.expiresAt)}',
      'PLAN : ${_planCode.text.trim()}',
      'APPAREILS MAX : ${result.license.maxDevices}',
      'UTILISATEURS MAX : ${result.license.maxUsers}',
      '',
      'INSTRUCTIONS',
      '1. Utiliser le code licence sur le premier appareil KESE.',
      '2. Conserver la cle entreprise pour rattacher les autres appareils.',
      '3. Utiliser le compte administrateur ci-dessus pour la premiere activation.',
    ];
    final bytes = Uint8List.fromList(utf8.encode(lines.join('\r\n')));
    final slug = _companyName.text.trim().isEmpty
        ? 'kese-activation'
        : _companyName.text
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
    await downloadBytes(
      '$slug-activation.txt',
      bytes,
      'text/plain;charset=utf-8',
    );
  }

  Future<void> _changeLicenseStatus(
    KeseCloudCreatorTenantOverview item,
    String nextStatus,
  ) async {
    final label = switch (nextStatus) {
      'active' => 'réactivée',
      'suspended' => 'suspendue',
      'revoked' => 'bloquée',
      _ => 'mise à jour',
    };
    try {
      await widget.onUpdateLicense(
        licenseId: item.license.id,
        status: nextStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Licence $label.')),
      );
      await _reloadOverview();
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _openLicenseEditor(KeseCloudCreatorTenantOverview item) async {
    final licenseCodeController = TextEditingController(
      text: item.license.licenseCode,
    );
    final planController = TextEditingController(
      text: _extractCommercialPlan(item.license.planCode),
    );
    final maxDevicesController = TextEditingController(
      text: item.license.maxDevices.toString(),
    );
    final maxUsersController = TextEditingController(
      text: item.license.maxUsers.toString(),
    );
    final cloudBaseUrlController = TextEditingController(
      text: item.tenant.cloudBaseUrl ?? '',
    );
    var duration = _extractLicenseDuration(item.license.planCode);
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier la licence',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.tenant.companyName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AppField(
                    label: 'Code licence',
                    controller: licenseCodeController,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Validité',
                    style: TextStyle(
                      color: _mutedTextColor(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      ('trial-24h', 'Essai 24 h'),
                      ('1y', '1 an'),
                      ('2y', '2 ans'),
                      ('5y', '5 ans'),
                      ('indefinite', 'Illimitée'),
                    ].map((entry) {
                      final code = entry.$1;
                      final label = entry.$2;
                      return ChoiceChip(
                        label: Text(label),
                        selected: duration == code,
                        onSelected: (_) => setLocal(() => duration = code),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _AppField(
                    label: 'Code plan',
                    controller: planController,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Appareils max',
                    controller: maxDevicesController,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Utilisateurs max',
                    controller: maxUsersController,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Adresse cloud de cette entreprise',
                    controller: cloudBaseUrlController,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: 'Modification impossible',
                      subtitle: error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () async {
                      final parsedMax =
                          int.tryParse(maxDevicesController.text.trim());
                      if (parsedMax == null || parsedMax < 1) {
                        setLocal(() => error = 'Le nombre d’appareils est invalide.');
                        return;
                      }
                      final parsedMaxUsers =
                          int.tryParse(maxUsersController.text.trim());
                      if (parsedMaxUsers == null || parsedMaxUsers < 1) {
                        setLocal(() => error = 'Le nombre d’utilisateurs est invalide.');
                        return;
                      }
                      if (licenseCodeController.text.trim().length < 8) {
                        setLocal(() => error = 'Le code licence est invalide.');
                        return;
                      }
                      try {
                        await widget.onUpdateLicense(
                          licenseId: item.license.id,
                          licenseCode: licenseCodeController.text.trim(),
                          planCode: planController.text.trim(),
                          licenseDuration: duration,
                          maxDevices: parsedMax,
                          maxUsers: parsedMaxUsers,
                          cloudBaseUrl: cloudBaseUrlController.text.trim(),
                        );
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Licence mise à jour.'),
                          ),
                        );
                        await _reloadOverview();
                      } on KeseCloudException catch (cloudError) {
                        setLocal(() => error = cloudError.message);
                      }
                    },
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    licenseCodeController.dispose();
    planController.dispose();
    maxDevicesController.dispose();
    maxUsersController.dispose();
    cloudBaseUrlController.dispose();
  }

  Future<void> _openTenantCloudEditor(
    KeseCloudCreatorTenantOverview item,
  ) async {
    final controller = TextEditingController(
      text: item.tenant.cloudBaseUrl ?? '',
    );
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier l’adresse cloud',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.tenant.companyName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AppField(
                    label: 'Adresse cloud de cette entreprise',
                    controller: controller,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "La prochaine synchronisation devra utiliser cette adresse pour rattacher ou poursuivre les échanges cloud de cette entreprise.",
                    style: TextStyle(
                      color: _mutedTextColor(context),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: 'Mise à jour impossible',
                      subtitle: error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await widget.onUpdateLicense(
                          licenseId: item.license.id,
                          cloudBaseUrl: controller.text.trim(),
                        );
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Adresse cloud mise à jour.'),
                          ),
                        );
                        await _reloadOverview();
                      } on KeseCloudException catch (cloudError) {
                        setLocal(() => error = cloudError.message);
                      }
                    },
                    icon: const Icon(Icons.cloud_sync_rounded),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _resetLicense(KeseCloudCreatorTenantOverview item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Réinitialiser cette licence ?'),
        content: Text(
          'La licence ${item.license.licenseCode} sera remise en attente. Les appareils rattachés seront désactivés et les sessions cloud existantes seront fermées. Les comptes utilisateurs restent conservés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.onResetLicense(licenseId: item.license.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Licence réinitialisée.')),
      );
      await _reloadOverview();
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _deleteLicense(KeseCloudCreatorTenantOverview item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette licence ?'),
        content: Text(
          'La licence ${item.license.licenseCode} de ${item.tenant.companyName} sera supprimée définitivement, même si elle a déjà été utilisée. Cette action efface aussi les appareils, sessions et données cloud de cette entreprise.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.onDeleteLicense(licenseId: item.license.id);
      if (!mounted) return;
      setState(() {
        _overviewItems = _overviewItems
            .where((entry) => entry.license.id != item.license.id)
            .toList(growable: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Licence supprimée.')),
      );
      await _reloadOverview();
    } on KeseCloudException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final creatorSession = widget.creatorSession;
    return _EntryScreenFrame(
      darkMode: widget.darkMode,
      toggleTheme: widget.toggleTheme,
      desktopFormMaxWidth: 880,
      desktopShellMaxWidth: 1460,
      formFirst: true,
      heroBadge: 'Espace créateur',
      heroTitle: 'Créez une entreprise et sa licence',
      heroSubtitle:
          'Préparez une nouvelle entreprise, son administrateur principal et son code licence sans sortir de KESE.',
      heroPoints: const [
        'Crée l’entreprise cloud avec sa clé technique.',
        'Génère immédiatement la licence d’activation.',
        'Prépare ensuite le premier appareil avec les bons identifiants.',
      ],
      formTitle: 'Nouvelle entreprise',
      formSubtitle:
          'Renseignez les informations de base, puis générez la licence et le compte administrateur initial.',
      logoAsset: _keseLogoAsset,
      heroAccent: const Color(0xFF0B7285),
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Retour'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (creatorSession != null)
            _EntryContextCard(
              icon: Icons.cloud_done_rounded,
              title: 'Connexion créateur active',
              subtitle:
                  'Serveur cloud : ${creatorSession.baseUrl}\nCompte : ${creatorSession.username}',
              accent: const Color(0xFF0B7285),
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _softPanelColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Administration créateur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Les accès du compte créateur se gèrent séparément, avant les opérations sur les entreprises et les licences.',
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _creatorProfileBusy
                      ? null
                      : _openCreatorProfileEditor,
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  label: const Text('Modifier les accès créateur'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openCreatorCloudAddressEditor,
                  icon: const Icon(Icons.cloud_sync_rounded),
                  label: const Text('Modifier l’adresse cloud'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 960;
              final mobileLayout = constraints.maxWidth < 760;
              final compactFields = constraints.maxWidth < 720;
              final supervisionCard = Container(
                padding: EdgeInsets.all(mobileLayout ? 14 : 16),
                decoration: BoxDecoration(
                  color: _softPanelColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _panelBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Supervision des entreprises',
                            style: (mobileLayout
                                    ? Theme.of(context).textTheme.titleMedium
                                    : Theme.of(context).textTheme.titleLarge)
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser',
                          onPressed: _overviewBusy ? null : _reloadOverview,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mobileLayout
                          ? 'Suivez ici les entreprises créées, l’état des licences et les appareils déjà rattachés.'
                          : 'Vue rapide des entreprises créées, de l’état des licences et du nombre d’appareils déjà rattachés.',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        height: 1.42,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_overviewBusy)
                      const LinearProgressIndicator(minHeight: 4)
                    else if (_overviewError != null)
                      _InfoBanner(
                        icon: Icons.cloud_off_rounded,
                        title: 'Supervision indisponible',
                        subtitle: _overviewError!,
                      )
                    else if (_overviewItems.isEmpty)
                      const _InfoBanner(
                        icon: Icons.domain_disabled_rounded,
                        title: 'Aucune entreprise créée',
                        subtitle:
                            'La liste se remplira automatiquement après la première création.',
                      )
                    else
                      Column(
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _CreatorMiniStat(
                                label: 'Entreprises',
                                value: '${_overviewItems.length}',
                              ),
                              _CreatorMiniStat(
                                label: 'Licences actives',
                                value:
                                    '${_overviewItems.where((item) => item.license.status == 'active').length}',
                              ),
                              _CreatorMiniStat(
                                label: 'Suspendues / bloquées',
                                value:
                                    '${_overviewItems.where((item) => item.license.status != 'active').length}',
                              ),
                              _CreatorMiniStat(
                                label: 'Appareils actifs',
                                value:
                                    '${_overviewItems.fold<int>(0, (sum, item) => sum + item.activeDevicesCount)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._overviewItems.map(
                            (item) => _CreatorTenantOverviewCard(
                              item: item,
                              onEditCloud: () => _openTenantCloudEditor(item),
                              onSuspend: item.license.status == 'active'
                                  ? () => _changeLicenseStatus(
                                        item,
                                        'suspended',
                                      )
                                  : null,
                              onReactivate: item.license.status != 'active'
                                  ? () => _changeLicenseStatus(item, 'active')
                                  : null,
                              onRevoke: item.license.status != 'revoked'
                                  ? () => _changeLicenseStatus(item, 'revoked')
                                  : null,
                              onEdit: () => _openLicenseEditor(item),
                              onReset: () => _resetLicense(item),
                              onDelete: () => _deleteLicense(item),
                            ),
                          ),
                        ],
                    ),
                  ],
                ),
              );
              final creationCard = Container(
                padding: EdgeInsets.all(twoColumns ? 20 : 14),
                decoration: BoxDecoration(
                  color: _softPanelColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _panelBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Identification de l’entreprise',
                      style: (mobileLayout
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mobileLayout
                          ? 'Renseignez l’entreprise, le site principal et le compte administrateur avant de lancer la création.'
                          : 'Renseignez d’abord l’entreprise, son site principal et le compte administrateur initial.',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: mobileLayout ? 12 : 16),
                    Container(
                      padding: EdgeInsets.all(mobileLayout ? 12 : 14),
                      decoration: BoxDecoration(
                        color: _panelColor(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _panelBorderColor(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Entreprise et site principal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _AppField(
                            label: 'Nom de l’entreprise',
                            controller: _companyName,
                          ),
                          const SizedBox(height: 10),
                          _AppField(
                            label: 'Responsable',
                            controller: _ownerName,
                          ),
                          const SizedBox(height: 10),
                          _AppField(label: 'Téléphone', controller: _phone),
                          const SizedBox(height: 10),
                          _AppField(label: 'Email', controller: _email),
                          const SizedBox(height: 10),
                          _AppField(
                            label: 'Adresse / ville',
                            controller: _address,
                          ),
                          const SizedBox(height: 10),
                          _AppField(
                            label: 'Nom du site principal',
                            controller: _branchName,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: mobileLayout ? 12 : 14),
                    Container(
                      padding: EdgeInsets.all(mobileLayout ? 12 : 14),
                      decoration: BoxDecoration(
                        color: _panelColor(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _panelBorderColor(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Administrateur et licence',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AppField(
                            label: 'Nom complet de l’administrateur',
                            controller: _adminFullName,
                          ),
                          const SizedBox(height: 10),
                          _AppField(
                            label: 'Identifiant administrateur',
                            controller: _adminUsername,
                          ),
                          const SizedBox(height: 10),
                          _AppField(
                            label: 'Code PIN administrateur',
                            controller: _adminPin,
                            number: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Durée de licence',
                            style: TextStyle(
                              color: _mutedTextColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ('trial-24h', 'Essai 24 h'),
                              ('1y', '1 an'),
                              ('2y', '2 ans'),
                              ('5y', '5 ans'),
                              ('indefinite', 'Illimitée'),
                            ].map((entry) {
                              final code = entry.$1;
                              final label = mobileLayout
                                  ? switch (code) {
                                      'trial-24h' => '24 h',
                                      'indefinite' => 'Sans limite',
                                      _ => entry.$2,
                                    }
                                  : entry.$2;
                              final selected = _licenseDuration == code;
                              return ChoiceChip(
                                label: Text(label),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _licenseDuration = code),
                                visualDensity: mobileLayout
                                    ? VisualDensity.compact
                                    : VisualDensity.standard,
                                materialTapTargetSize: mobileLayout
                                    ? MaterialTapTargetSize.shrinkWrap
                                    : MaterialTapTargetSize.padded,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          if (compactFields)
                            Column(
                              children: [
                                _AppField(
                                  label: 'Code plan',
                                  controller: _planCode,
                                ),
                                const SizedBox(height: 10),
                                _AppField(
                                  label: 'Appareils max',
                                  controller: _maxDevices,
                                  number: true,
                                ),
                                const SizedBox(height: 10),
                                _AppField(
                                  label: 'Utilisateurs max',
                                  controller: _maxUsers,
                                  number: true,
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _AppField(
                                    label: 'Code plan',
                                    controller: _planCode,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AppField(
                                    label: 'Appareils max',
                                    controller: _maxDevices,
                                    number: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AppField(
                                    label: 'Utilisateurs max',
                                    controller: _maxUsers,
                                    number: true,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              final actionCard = Container(
                padding: EdgeInsets.all(twoColumns ? 20 : 14),
                decoration: BoxDecoration(
                  color: _softPanelColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _panelBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Création et activation',
                      style: (mobileLayout
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mobileLayout
                          ? 'Créez ensuite la licence et récupérez immédiatement les informations à remettre au client.'
                          : 'Vérifiez les informations de l’entreprise, puis générez la licence. Les identifiants à remettre au client apparaîtront ici juste après la création.',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: mobileLayout ? 12 : 14),
                    FilledButton.icon(
                      onPressed: _busy ? null : _submit,
                      icon: const Icon(Icons.domain_add_rounded),
                      label: Text(
                        _busy
                            ? 'Création en cours...'
                            : mobileLayout
                                ? 'Créer entreprise + licence'
                                : 'Créer l’entreprise et la licence',
                      ),
                    ),
                    SizedBox(height: mobileLayout ? 10 : 14),
                    _InfoBanner(
                      icon: Icons.info_outline_rounded,
                      title: 'Génération automatique',
                      subtitle:
                          'La clé entreprise et le code licence sont générés automatiquement. Vous pourrez ensuite les copier, les télécharger et préparer le premier appareil.',
                    ),
                    if (_error != null) ...[
                      SizedBox(height: mobileLayout ? 10 : 12),
                      _InfoBanner(
                        icon: Icons.error_outline_rounded,
                        title: 'Création impossible',
                        subtitle: _error!,
                      ),
                    ],
                    if (result != null) ...[
                      SizedBox(height: mobileLayout ? 14 : 18),
                      Container(
                        padding: EdgeInsets.all(mobileLayout ? 14 : 18),
                        decoration: BoxDecoration(
                          color: _panelColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _panelBorderColor(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Entreprise créée',
                              style: (mobileLayout
                                      ? Theme.of(context).textTheme.titleMedium
                                      : Theme.of(context).textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: mobileLayout ? 12 : 14),
                            Container(
                              padding: EdgeInsets.all(mobileLayout ? 12 : 14),
                              decoration: BoxDecoration(
                                color: _warningSurface(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _panelBorderColor(context),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informations à transmettre à l’entreprise',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Conserve et communique au client la clé entreprise, le code licence et les identifiants administrateur. Ce sont les données nécessaires pour activer le premier appareil puis rattacher les autres.',
                                    style: TextStyle(
                                      color: _mutedTextColor(context),
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _CreatorResultRow(
                              label: 'Entreprise',
                              value: result.tenant.companyName,
                            ),
                            _CreatorResultRow(
                              label: 'Clé entreprise',
                              value: result.tenant.tenantKey,
                              onCopy: () => _copyText(
                                result.tenant.tenantKey,
                                'Clé entreprise',
                              ),
                            ),
                            _CreatorResultRow(
                              label: 'Code licence',
                              value: result.license.licenseCode,
                              onCopy: () => _copyText(
                                result.license.licenseCode,
                                'Code licence',
                              ),
                            ),
                            _CreatorResultRow(
                              label: 'Validité',
                              value: _licenseDurationLabel(result.license.planCode),
                            ),
                            _CreatorResultRow(
                              label: 'Expiration',
                              value: _formatLicenseExpiry(result.license.expiresAt),
                            ),
                            _CreatorResultRow(
                              label: 'Plan',
                              value: _extractCommercialPlan(result.license.planCode),
                            ),
                            _CreatorResultRow(
                              label: 'Admin',
                              value: result.adminUser.username,
                              onCopy: () => _copyText(
                                result.adminUser.username,
                                'Identifiant admin',
                              ),
                            ),
                            _CreatorResultRow(
                              label: 'PIN admin',
                              value: _adminPin.text.trim(),
                              onCopy: () =>
                                  _copyText(_adminPin.text.trim(), 'PIN admin'),
                            ),
                            _CreatorResultRow(
                              label: 'Site principal',
                              value: result.branch.branchCode,
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: _downloadActivationSheet,
                              icon: const Icon(Icons.download_rounded),
                              label: Text(
                                mobileLayout
                                    ? 'Télécharger la fiche'
                                    : 'Télécharger la fiche d’activation',
                              ),
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () => widget.onOpenActivationFromResult(
                                baseUrl:
                                    result.tenant.cloudBaseUrl ??
                                    creatorSession?.baseUrl ??
                                    _defaultCloudBaseUrl,
                                response: result,
                                adminPin: _adminPin.text.trim(),
                              ),
                              icon: const Icon(Icons.rocket_launch_rounded),
                              label: Text(
                                mobileLayout
                                    ? 'Préparer le 1er appareil'
                                    : 'Préparer l’activation du premier appareil',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
              if (twoColumns) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 12, child: creationCard),
                        const SizedBox(width: 14),
                        Expanded(flex: 9, child: actionCard),
                      ],
                    ),
                    const SizedBox(height: 14),
                    supervisionCard,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  creationCard,
                  const SizedBox(height: 12),
                  actionCard,
                  const SizedBox(height: 12),
                  supervisionCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreatorResultRow extends StatelessWidget {
  const _CreatorResultRow({
    required this.label,
    required this.value,
    this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobileLayout = constraints.maxWidth < 420;
        if (mobileLayout) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (onCopy != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Copier',
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 118,
                child: Text(
                  label,
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Copier',
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CreatorTenantOverviewCard extends StatelessWidget {
  const _CreatorTenantOverviewCard({
    required this.item,
    required this.onEdit,
    this.onEditCloud,
    this.onSuspend,
    this.onReactivate,
    this.onRevoke,
    this.onReset,
    this.onDelete,
  });

  final KeseCloudCreatorTenantOverview item;
  final VoidCallback onEdit;
  final VoidCallback? onEditCloud;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;
  final VoidCallback? onRevoke;
  final VoidCallback? onReset;
  final VoidCallback? onDelete;

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Aucune activité';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }

  String _statusLabel(String value) {
    return switch (value.trim().toLowerCase()) {
      'active' => 'Active',
      'suspended' => 'Suspendue',
      'revoked' => 'Bloquée',
      _ => value,
    };
  }

  Color _statusSurface(BuildContext context, String value) {
    return switch (value.trim().toLowerCase()) {
      'active' => _softAccentStrong(context),
      'suspended' => _warningSurface(context),
      'revoked' => _dangerSurface(context),
      _ => _softPanelColor(context),
    };
  }

  Color _statusText(BuildContext context, String value) {
    if (_isDark(context)) return _strongTextColor(context);
    return switch (value.trim().toLowerCase()) {
      'active' => _greenDark,
      'suspended' => _ink,
      'revoked' => _danger,
      _ => _ink,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(item.license.status);
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobileLayout = constraints.maxWidth < 680;
        final statWidth = mobileLayout
            ? (constraints.maxWidth - 10) / 2
            : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(mobileLayout ? 12 : 14),
          decoration: BoxDecoration(
            color: _panelColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _panelBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mobileLayout)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tenant.companyName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusSurface(context, item.license.status),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _panelBorderColor(context)),
                      ),
                      child: Text(
                        item.firstActivationDone
                            ? '$statusLabel · liée'
                            : '$statusLabel · en attente',
                        style: TextStyle(
                          color: _statusText(context, item.license.status),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      'Clé : ${item.tenant.tenantKey}',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      'Licence : ${item.license.licenseCode}',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tenant.companyName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Clé entreprise : ${item.tenant.tenantKey}',
                            style: TextStyle(
                              color: _mutedTextColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Code licence : ${item.license.licenseCode}',
                            style: TextStyle(
                              color: _mutedTextColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusSurface(context, item.license.status),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _panelBorderColor(context)),
                      ),
                      child: Text(
                        item.firstActivationDone
                            ? '$statusLabel · liée'
                            : '$statusLabel · en attente',
                        style: TextStyle(
                          color: _statusText(context, item.license.status),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: statWidth,
                    child: _CreatorMiniStat(
                      label: 'Validité',
                      value: _licenseDurationLabel(item.license.planCode),
                      compact: mobileLayout,
                    ),
                  ),
                  SizedBox(
                    width: statWidth,
                    child: _CreatorMiniStat(
                      label: 'Plan',
                      value: _extractCommercialPlan(item.license.planCode),
                      compact: mobileLayout,
                    ),
                  ),
                  SizedBox(
                    width: statWidth,
                    child: _CreatorMiniStat(
                      label: 'Appareils',
                      value: '${item.activeDevicesCount}/${item.license.maxDevices}',
                      compact: mobileLayout,
                    ),
                  ),
                  SizedBox(
                    width: statWidth,
                    child: _CreatorMiniStat(
                      label: 'Utilisateurs',
                      value: '${item.usersCount}/${item.license.maxUsers}',
                      compact: mobileLayout,
                    ),
                  ),
                  SizedBox(
                    width: statWidth,
                    child: _CreatorMiniStat(
                      label: 'Site',
                      value: item.branch.branchCode,
                      compact: mobileLayout,
                    ),
                  ),
                  SizedBox(
                    width: mobileLayout ? constraints.maxWidth : null,
                    child: _CreatorMiniStat(
                      label: 'Cloud',
                      value: item.tenant.cloudBaseUrl ?? 'Non défini',
                      compact: mobileLayout,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(mobileLayout ? 10 : 12),
                decoration: BoxDecoration(
                  color: _softPanelColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _panelBorderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Contrôle de licence',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (mobileLayout)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CreatorIconActionButton(
                            icon: Icons.edit_rounded,
                            tooltip: 'Modifier',
                            onPressed: onEdit,
                          ),
                          if (onEditCloud != null)
                            _CreatorIconActionButton(
                              icon: Icons.cloud_sync_rounded,
                              tooltip: 'Modifier l’adresse cloud',
                              onPressed: onEditCloud!,
                            ),
                          if (onSuspend != null)
                            _CreatorIconActionButton(
                              icon: Icons.pause_circle_rounded,
                              tooltip: 'Suspendre',
                              onPressed: onSuspend!,
                            ),
                          if (onReactivate != null)
                            _CreatorIconActionButton(
                              icon: Icons.play_circle_rounded,
                              tooltip: 'Réactiver',
                              onPressed: onReactivate!,
                            ),
                          if (onRevoke != null)
                            _CreatorIconActionButton(
                              icon: Icons.block_rounded,
                              tooltip: 'Bloquer',
                              onPressed: onRevoke!,
                            ),
                          if (onReset != null)
                            _CreatorIconActionButton(
                              icon: Icons.restart_alt_rounded,
                              tooltip: 'Réinitialiser',
                              onPressed: onReset!,
                            ),
                          if (onDelete != null)
                            _CreatorIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'Supprimer',
                              onPressed: onDelete!,
                              destructive: true,
                            ),
                        ],
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Modifier'),
                          ),
                          if (onEditCloud != null)
                            FilledButton.tonalIcon(
                              onPressed: onEditCloud,
                              icon: const Icon(Icons.cloud_sync_rounded),
                              label: const Text('Adresse cloud'),
                            ),
                          if (onSuspend != null)
                            OutlinedButton.icon(
                              onPressed: onSuspend,
                              icon: const Icon(Icons.pause_circle_rounded),
                              label: const Text('Suspendre'),
                            ),
                          if (onReactivate != null)
                            FilledButton.tonalIcon(
                              onPressed: onReactivate,
                              icon: const Icon(Icons.play_circle_rounded),
                              label: const Text('Réactiver'),
                            ),
                          if (onRevoke != null)
                            OutlinedButton.icon(
                              onPressed: onRevoke,
                              icon: const Icon(Icons.block_rounded),
                              label: const Text('Bloquer'),
                            ),
                          if (onReset != null)
                            OutlinedButton.icon(
                              onPressed: onReset,
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('Réinitialiser'),
                            ),
                          if (onDelete != null)
                            TextButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Supprimer'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mobileLayout
                    ? 'Expiration : ${_formatLicenseExpiry(item.license.expiresAt)}\nActivité : ${_formatDateTime(item.lastActivityAt)}'
                    : 'Expiration : ${_formatLicenseExpiry(item.license.expiresAt)}\nDernière activité : ${_formatDateTime(item.lastActivityAt)}',
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CreatorMiniStat extends StatelessWidget {
  const _CreatorMiniStat({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: compact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorIconActionButton extends StatelessWidget {
  const _CreatorIconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? (_isDark(context) ? Colors.red.shade200 : _danger)
        : _strongTextColor(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: destructive ? _dangerSurface(context) : _panelColor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _panelBorderColor(context)),
          ),
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
  }
}

class _CreatorAccessHint extends StatelessWidget {
  const _CreatorAccessHint({required this.onLongPress});

  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'Version $_appVersionLabel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedTextColor(context).withAlpha(170),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class CreatorAccessLoginPage extends StatefulWidget {
  const CreatorAccessLoginPage({
    super.key,
    required this.darkMode,
    required this.toggleTheme,
    required this.onAuthenticate,
    required this.onAuthenticated,
    required this.onBack,
  });

  final bool darkMode;
  final VoidCallback toggleTheme;
  final CreatorAccessCallback onAuthenticate;
  final VoidCallback onAuthenticated;
  final VoidCallback onBack;

  @override
  State<CreatorAccessLoginPage> createState() => _CreatorAccessLoginPageState();
}

class _CreatorAccessLoginPageState extends State<CreatorAccessLoginPage> {
  late final TextEditingController _cloudBaseUrl =
      TextEditingController(text: _defaultCloudBaseUrl);
  late final TextEditingController _username = TextEditingController();
  late final TextEditingController _pin = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _cloudBaseUrl.dispose();
    _username.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().length < 3 || _pin.text.trim().length < 4) {
      setState(() => _error = 'Renseigne les accès créateur complets.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.onAuthenticate(
      baseUrl: _cloudBaseUrl.text.trim(),
      username: _username.text.trim(),
      pin: _pin.text.trim(),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _busy = false;
        _error = result;
      });
      return;
    }
    setState(() => _busy = false);
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return _EntryScreenFrame(
      darkMode: widget.darkMode,
      toggleTheme: widget.toggleTheme,
      desktopFormMaxWidth: 620,
      formFirst: true,
      heroBadge: 'Accès protégé',
      heroTitle: 'Espace créateur KESE',
      heroSubtitle:
          'Cet accès est séparé du parcours client normal et réservé à la création des entreprises et des licences.',
      heroPoints: const [
        'Création d’entreprises et de licences.',
        'Préparation du premier appareil d’activation.',
        'Accès réservé au créateur / propriétaire.',
      ],
      formTitle: 'Authentification créateur',
      formSubtitle:
          'Renseignez les identifiants créateur pour ouvrir l’espace de gestion.',
      logoAsset: _keseLogoAsset,
      heroAccent: const Color(0xFF0B7285),
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Retour'),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _softPanelColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wideFields = constraints.maxWidth >= 520;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AppField(
                      label: 'Adresse cloud créateur',
                      controller: _cloudBaseUrl,
                    ),
                    const SizedBox(height: 10),
                    if (wideFields)
                      Row(
                        children: [
                          Expanded(
                            child: _AppField(
                              label: 'Identifiant créateur',
                              controller: _username,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                        child: _AppField(
                          label: 'Code secret créateur',
                          controller: _pin,
                        ),
                      ),
                        ],
                      )
                    else ...[
                      _AppField(
                        label: 'Identifiant créateur',
                        controller: _username,
                      ),
                      const SizedBox(height: 10),
                      _AppField(
                        label: 'Code secret créateur',
                        controller: _pin,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.lock_outline_rounded,
              title: 'Accès refusé',
              subtitle: _error!,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: const Icon(Icons.admin_panel_settings_rounded),
            label: Text(
              _busy
                  ? 'Connexion créateur...'
                  : 'Ouvrir l’espace créateur',
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.store,
    required this.darkMode,
    required this.toggleTheme,
    required this.onLogin,
    required this.onCloudLogin,
    required this.onOpenCreatorAccess,
    required this.onForgotPasswordRequest,
  });

  final AppStore store;
  final bool darkMode;
  final VoidCallback toggleTheme;
  final ValueChanged<AppUser> onLogin;
  final CloudLoginCallback onCloudLogin;
  final VoidCallback onOpenCreatorAccess;
  final Future<String?> Function(AppUser requester) onForgotPasswordRequest;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _username =
      TextEditingController(
        text: widget.store.cloudSession?.username ?? widget.store.activeUser.username,
      );
  late final TextEditingController _pin =
      TextEditingController(text: widget.store.activeUser.pin);
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    final username = _username.text.trim().toLowerCase();
    final pin = _pin.text.trim();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = widget.store.users.where((entry) {
        return entry.username.trim().toLowerCase() == username;
      }).firstOrNull;
      if (user == null) {
        setState(() => _error = 'Identifiant introuvable.');
        return;
      }
      if (user.isBlocked) {
        setState(
          () => _error = 'Ce compte est bloqué. Contacte l’administrateur.',
        );
        return;
      }
      if (user.pin != pin) {
        setState(() => _error = 'Code secret incorrect.');
        return;
      }
      widget.onLogin(user);
      final cloudSession = widget.store.cloudSession;
      if (cloudSession != null && currentNetworkOnline()) {
        unawaited(
          widget.onCloudLogin(
            baseUrl: cloudSession.baseUrl,
            tenantKey: cloudSession.tenantKey,
            username: _username.text.trim(),
            pin: pin,
            deviceLabel: cloudSession.deviceLabel,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _openForgotPassword() async {
    final username = _username.text.trim().toLowerCase();
    final user = widget.store.users.where((entry) {
      return entry.username.trim().toLowerCase() == username;
    }).firstOrNull;
    if (user == null) {
      setState(
        () => _error = 'Saisis d’abord un identifiant valide pour signaler l’oubli.',
      );
      return;
    }
    if (user.isAdmin) {
      final subject = Uri.encodeComponent(
        'Demande de réinitialisation du mot de passe administrateur KESE',
      );
      final body = Uri.encodeComponent(
        'Bonjour,\n\nJe souhaite réinitialiser le mot de passe du compte administrateur @${user.username} de l’entreprise ${widget.store.settings.companyName}.\n\nMerci.',
      );
      openExternalUrl('mailto:$_creatorEmail?subject=$subject&body=$body');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une demande e-mail de réinitialisation administrateur a été préparée pour les créateurs.',
          ),
        ),
      );
      return;
    }
    final result = await widget.onForgotPasswordRequest(user);
    if (!mounted) return;
    if (result != null) {
      setState(() => _error = result);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Message envoyé à l’administrateur pour réinitialiser ce compte.',
        ),
      ),
    );
  }

  Future<void> _openChangePassword() async {
    final username = TextEditingController(text: _username.text.trim());
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier le mot de passe',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  _AppField(label: 'Identifiant', controller: username),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Code secret actuel',
                    controller: current,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Nouveau code secret',
                    controller: next,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Confirmer le nouveau code',
                    controller: confirm,
                    number: true,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: 'Modification impossible',
                      subtitle: error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      if (next.text.trim().length < 6) {
                        setLocal(
                          () => error =
                              'Le nouveau mot de passe doit contenir au moins 6 caractères.',
                        );
                        return;
                      }
                      if (next.text.trim() != confirm.text.trim()) {
                        setLocal(() => error = 'La confirmation ne correspond pas.');
                        return;
                      }
                      final updated = widget.store.updateUserPin(
                        username: username.text.trim(),
                        currentPin: current.text.trim(),
                        nextPin: next.text.trim(),
                      );
                      if (!updated) {
                        setLocal(
                          () => error =
                              'Identifiant ou mot de passe actuel incorrect.',
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe mis à jour avec succes.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_reset_rounded),
                    label: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredRoles = widget.store.users
        .map((user) => user.role)
        .toSet()
        .toList();
    final cloudSession = widget.store.cloudSession;
    final companyName = widget.store.settings.companyName.trim().isEmpty
        ? 'Votre entreprise'
        : widget.store.settings.companyName.trim();
    return _EntryScreenFrame(
      darkMode: widget.darkMode,
      toggleTheme: widget.toggleTheme,
      desktopFormMaxWidth: 640,
      formFirst: true,
      showFormLogo: false,
      showHeroLogo: false,
      showHighlightsLogo: true,
      heroBadge: cloudSession == null
          ? 'Espace local sécurisé'
          : 'Session sécurisée',
      heroTitle: 'Ouvrez votre session KESE',
      heroSubtitle: cloudSession == null
          ? 'Retrouvez votre caisse, vos messages et vos opérations sur un espace de travail simple, net et prêt à démarrer.'
          : 'L’entreprise $companyName est déjà liée à ce poste. Connectez-vous pour retrouver votre espace et reprendre immédiatement le travail.',
      heroPoints: [
        'Le rôle connecté ouvre directement son propre espace de travail, sans ambiguïté.',
        'Les messages, notifications et activités se remettent à jour automatiquement quand internet est disponible.',
        'Chaque poste reste rattaché à votre entreprise avec une connexion pensée pour la caisse comme pour la supervision.',
      ],
      formTitle: 'Connexion',
      formSubtitle: cloudSession == null
          ? 'Identifiez-vous pour ouvrir la session de ce poste.'
          : 'Utilisez vos accès pour ouvrir votre espace de travail.',
      formKicker: cloudSession == null
          ? 'Poste prêt à connecter'
          : 'Entreprise déjà liée à ce poste',
      formHighlights: cloudSession == null
          ? const [
              'Connexion rapide',
              'Travail local',
              'Reprise cloud ensuite',
            ]
          : const [
              'Session sécurisée',
              'Synchronisation disponible',
              'Accès par rôle',
            ],
      logoAsset: _keseLogoAsset,
      heroAccent: const Color(0xFF0B7285),
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (featuredRoles.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: featuredRoles
                  .map((role) => _AuthRolePill(label: role))
                  .toList(),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _softPanelColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AppField(label: 'Identifiant', controller: _username),
                const SizedBox(height: 12),
                _AppField(
                  label: 'Code secret',
                  controller: _pin,
                  number: true,
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.error_outline_rounded,
              title: 'Connexion impossible',
              subtitle: _error!,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: Icon(
              _submitting ? Icons.hourglass_top_rounded : Icons.lock_open_rounded,
            ),
            label: Text(_submitting ? 'Connexion...' : 'Ouvrir la session'),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 0,
            children: [
              TextButton(
                onPressed: _openForgotPassword,
                child: const Text('Mot de passe oublié ?'),
              ),
              TextButton(
                onPressed: _openChangePassword,
                child: const Text('Modifier le mot de passe'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Le compte connecté ouvre son propre espace de travail et reprend automatiquement les échanges, ventes et notifications disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (cloudSession != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _softPanelColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _panelBorderColor(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _softAccentStrong(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_done_rounded,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Connexion cloud prête sur ${cloudSession.deviceLabel}',
                          style: TextStyle(
                            color: _mutedTextColor(context),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Built with DSquare Technologies by Musagara Daniel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Copyright 2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _CreatorAccessHint(onLongPress: widget.onOpenCreatorAccess),
        ],
      ),
    );
  }
}

class _AuthRolePill extends StatelessWidget {
  const _AuthRolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _softAccentStrong(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 15,
            color: _isDark(context) ? const Color(0xFFD8F4FA) : _greenDark,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: _isDark(context) ? const Color(0xFFD8F4FA) : _greenDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class MajiskifHome extends StatefulWidget {
  const MajiskifHome({
    super.key,
    required this.store,
    required this.darkMode,
    required this.toggleTheme,
    required this.onSynchronizePendingActivation,
    required this.onLogout,
  });

  final AppStore store;
  final bool darkMode;
  final VoidCallback toggleTheme;
  final Future<String?> Function() onSynchronizePendingActivation;
  final VoidCallback onLogout;

  @override
  State<MajiskifHome> createState() => _MajiskifHomeState();
}

class _MajiskifHomeState extends State<MajiskifHome> {
  AppStore get store => widget.store;
  final KeseCloudService _cloudService = KeseCloudService();
  final RealtimeSyncService _realtimeSyncService = createRealtimeSyncService();
  final AttentionFeedbackService _attentionFeedbackService =
      createAttentionFeedbackService();
  int tab = 0;
  int moreModule = -1;
  bool showMessages = false;
  bool showNotifications = false;
  bool showInfo = false;
  bool _messageThreadOpen = false;
  bool syncInProgress = false;
  bool _syncIndicatorVisible = false;
  bool isOnline = true;
  bool _autoSyncQueued = false;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _offlineReminderTimer;
  Timer? _cloudRefreshTimer;
  final List<CartLine> cart = [];
  bool _didFinishInitialCloudRefresh = false;
  int _lastUnreadMessages = 0;
  int _lastUnreadAlerts = 0;

  void _selectMainTab(int value, {int? module}) {
    setState(() {
      showMessages = false;
      showNotifications = false;
      showInfo = false;
      _messageThreadOpen = false;
      tab = value;
      if (value == 4) {
        moreModule = module ?? -1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isOnline = currentNetworkOnline();
    _lastUnreadMessages = store.unreadMessages;
    _lastUnreadAlerts = store.unreadAlerts;
    _networkSubscription = networkStatusStream().listen((online) {
      if (!mounted) return;
      final previous = isOnline;
      setState(() => isOnline = online);
      if (online != previous) {
        _handleConnectivityChange(online);
      }
      if (online) {
        _queueAutoSyncIfNeeded();
        unawaited(_runSync(manual: false));
        unawaited(_connectRealtimeIfNeeded());
      }
    });
    if (!isOnline) {
      _handleConnectivityChange(false);
    }
    _queueAutoSyncIfNeeded();
    if (isOnline &&
        (store.cloudSession != null || store.pendingCloudActivation != null)) {
      unawaited(_runSync(manual: false));
    }
    unawaited(_connectRealtimeIfNeeded());
    _startCloudRefreshTimer();
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _offlineReminderTimer?.cancel();
    _cloudRefreshTimer?.cancel();
    unawaited(_realtimeSyncService.disconnect());
    super.dispose();
  }

  Future<void> _connectRealtimeIfNeeded() async {
    if (!isOnline) return;
    final session = store.cloudSession;
    if (session == null) return;
    await _realtimeSyncService.connect(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      onSignal: () {
        if (!mounted || syncInProgress) return;
        unawaited(_runSync(manual: false));
      },
    );
  }

  void _startCloudRefreshTimer() {
    _cloudRefreshTimer?.cancel();
    _cloudRefreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted || !isOnline || syncInProgress) {
        return;
      }
      if (store.cloudSession == null ||
          (!store.hasPendingSync && store.pendingCloudActivation == null)) {
        return;
      }
      unawaited(_runSync(manual: false));
    });
  }

  void _notifyIncomingCloudEvents({
    required int beforeMessages,
    required int beforeAlerts,
    required bool manual,
  }) {
    final afterMessages = store.unreadMessages;
    final afterAlerts = store.unreadAlerts;
    final newMessages = (afterMessages - beforeMessages).clamp(0, 9999);
    final newAlerts = (afterAlerts - beforeAlerts).clamp(0, 9999);

    _lastUnreadMessages = afterMessages;
    _lastUnreadAlerts = afterAlerts;

    if (!_didFinishInitialCloudRefresh) {
      _didFinishInitialCloudRefresh = true;
      return;
    }
    if (newMessages == 0 && newAlerts == 0) return;

    _attentionFeedbackService.notifyIncoming();
    if (!mounted || manual) return;
    final parts = <String>[];
    if (newMessages > 0) {
      parts.add(
        newMessages == 1 ? '1 nouveau message' : '$newMessages nouveaux messages',
      );
    }
    if (newAlerts > 0) {
      parts.add(
        newAlerts == 1
            ? '1 nouvelle notification'
            : '$newAlerts nouvelles notifications',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(parts.join(' - '))),
    );
  }

  void _handleConnectivityChange(bool online) {
    _offlineReminderTimer?.cancel();
    if (online) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              store.hasPendingSync
                  ? 'Connexion rétablie. Les données en attente vont être synchronisées.'
                  : 'Connexion rétablie. Vous pouvez continuer à travailler normalement.',
            ),
          ),
        );
      }
      return;
    }
    unawaited(_realtimeSyncService.disconnect());
    _showOfflineReminder();
    _offlineReminderTimer = Timer.periodic(const Duration(seconds: 90), (_) {
      if (!mounted || isOnline) return;
      _showOfflineReminder();
    });
  }

  void _showOfflineReminder() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 6),
        content: Text(
          'Vous travaillez hors ligne. Veuillez entrer dans Plus puis utiliser Synchroniser quand la connexion reviendra.',
        ),
      ),
    );
  }

  Future<void> _runManualSync() async => _runSync(manual: true);

  Future<bool> _ensurePendingActivationCloudAddress() async {
    final pending = store.pendingCloudActivation;
    if (pending == null || pending.baseUrl.trim().isNotEmpty) return true;
    if (!mounted) return false;
    final controller = TextEditingController();
    String? error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Adresse cloud requise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cette activation a démarré en local. Saisissez maintenant l'adresse cloud fournie par le créateur pour finaliser la liaison et synchroniser les données.",
              ),
              const SizedBox(height: 12),
              _AppField(
                label: 'Adresse cloud',
                controller: controller,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(
                    color: _danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final raw = controller.text.trim();
                if (raw.isEmpty) {
                  setLocal(() => error = 'Saisis une adresse cloud valide.');
                  return;
                }
                final normalized = KeseCloudService.normalizeBaseUrl(raw);
                store.pendingCloudActivation =
                    pending.copyWith(baseUrl: normalized);
                store.onChanged?.call();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return confirmed == true;
  }

  Future<void> _editStoredCloudAddress() async {
    final initialValue =
        store.pendingCloudActivation?.baseUrl ??
        store.cloudSession?.baseUrl ??
        _defaultCloudBaseUrl;
    final controller = TextEditingController(text: initialValue);
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Modifier l’adresse cloud'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Utilise cette option quand le créateur t'a fourni une nouvelle adresse cloud pour cette entreprise avant la prochaine synchronisation.",
              ),
              const SizedBox(height: 12),
              _AppField(
                label: 'Adresse cloud',
                controller: controller,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(
                    color: _danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final raw = controller.text.trim();
                if (raw.isEmpty) {
                  setLocal(() => error = 'Saisis une adresse cloud valide.');
                  return;
                }
                final normalized = KeseCloudService.normalizeBaseUrl(raw);
                setState(() {
                  if (store.pendingCloudActivation != null) {
                    store.pendingCloudActivation = store.pendingCloudActivation!
                        .copyWith(baseUrl: normalized);
                  }
                      if (store.cloudSession != null) {
                    store.cloudSession =
                        store.cloudSession!.copyWith(baseUrl: normalized);
                  }
                });
                store.onChanged?.call();
                Navigator.pop(dialogContext);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _runSync({required bool manual}) async {
    if (syncInProgress) return;
    if (!isOnline) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mode hors ligne actif. Les données seront synchronisées dès que la connexion reviendra.',
            ),
          ),
        );
      }
      return;
    }
    var cloudSession = store.cloudSession;
    if (cloudSession == null && store.pendingCloudActivation != null) {
      if (manual) {
        final ready = await _ensurePendingActivationCloudAddress();
        if (!ready) return;
      } else if (store.pendingCloudActivation?.baseUrl.trim().isEmpty == true) {
        return;
      }
      setState(() {
        syncInProgress = true;
        _syncIndicatorVisible = manual;
      });
      final activationResult = await widget.onSynchronizePendingActivation();
      if (!mounted) return;
      cloudSession = store.cloudSession;
      if (cloudSession == null) {
        setState(() {
          syncInProgress = false;
          _syncIndicatorVisible = false;
          _autoSyncQueued = false;
        });
        if (manual) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                activationResult ??
                    'La liaison cloud n’a pas pu être finalisée pour le moment.',
              ),
            ),
          );
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La liaison cloud a été finalisée. La synchronisation complète démarre maintenant.',
          ),
        ),
      );
      setState(() {
        syncInProgress = false;
        _syncIndicatorVisible = false;
      });
    }
    if (cloudSession == null) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connexion cloud non configurée. Active d’abord cet appareil depuis la page de connexion.',
            ),
          ),
        );
      }
      return;
    }
    final hadPendingChanges = store.pendingSyncChanges > 0;
    final beforeUnreadMessages = store.unreadMessages;
    final beforeUnreadAlerts = store.unreadAlerts;
    setState(() {
      syncInProgress = true;
      _syncIndicatorVisible = manual;
    });
    try {
      final pendingEntries = store.pendingSyncEntries;
      final pushResponse = await _cloudService.push(
        session: cloudSession,
        operations: pendingEntries
            .map(
              (entry) => {
                'operation_uid': entry.id,
                'entity_name': entry.entityName,
                'entity_id': entry.entityId,
                'operation_name': entry.operationName,
                'payload_json': entry.payloadJson,
                'payload_hash': entry.payloadHash,
                'created_at': entry.createdAt.toIso8601String(),
              },
            )
            .toList(),
      );
      _applyPushSyncResponseToStore(store, pendingEntries, pushResponse);
      final pullResponse = await _cloudService.pull(
        session: cloudSession,
        afterId: cloudSession.lastPulledOperationId,
      );
      store.applyCloudOperations(pullResponse.operations);
      store.cloudSession = cloudSession.copyWith(
        lastPulledOperationId: pullResponse.cursor,
      );
      store.onChanged?.call();
      _notifyIncomingCloudEvents(
        beforeMessages: beforeUnreadMessages,
        beforeAlerts: beforeUnreadAlerts,
        manual: manual,
      );
      if (mounted) {
        setState(() {
          syncInProgress = false;
          _syncIndicatorVisible = false;
          _autoSyncQueued = false;
        });
      }
      if (!mounted) return;
      if (manual) {
        final hasConflicts = pushResponse.conflicts > 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasConflicts
                  ? 'Synchronisation partielle terminee. Certains elements demandent une resolution de conflit.'
                  : hadPendingChanges
                      ? 'Synchronisation terminée. Les données locales ont été envoyées vers votre espace cloud.'
                      : 'Synchronisation terminee. Aucune nouvelle modification en attente.',
            ),
          ),
        );
      }
    } on KeseCloudException catch (error) {
      final failedIds = store.pendingSyncEntries.map((entry) => entry.id).toSet();
      store.updateSyncQueueStatus(
        entryIds: failedIds,
        status: SyncOperationStatus.failed,
        lastError: error.message,
      );
      if (!mounted) return;
      setState(() {
        syncInProgress = false;
        _syncIndicatorVisible = false;
        _autoSyncQueued = false;
      });
      if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      final failedIds = store.pendingSyncEntries.map((entry) => entry.id).toSet();
      store.updateSyncQueueStatus(
        entryIds: failedIds,
        status: SyncOperationStatus.failed,
        lastError: 'La synchronisation cloud a echoue.',
      );
      if (!mounted) return;
      setState(() {
        syncInProgress = false;
        _syncIndicatorVisible = false;
        _autoSyncQueued = false;
      });
      if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La synchronisation cloud a échoué. Vérifie l’accès réseau et la configuration du serveur.',
            ),
          ),
        );
      }
    }
  }

  void _queueAutoSyncIfNeeded() {
    final hasSyncWork =
        store.hasPendingSync || store.pendingCloudActivation != null;
    if (!isOnline || syncInProgress || !hasSyncWork || _autoSyncQueued) {
      return;
    }
    _autoSyncQueued = true;
    Future<void>.microtask(() async {
      if (!mounted) return;
      await _runSync(manual: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final activeUser = store.activeUser;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final desktopShell = screenWidth >= 1180;
    _queueAutoSyncIfNeeded();
    final pages = [
      DashboardPage(
        store: store,
        goToPos: () => _selectMainTab(1),
        openCredits: () => _selectMainTab(4, module: 11),
        openProduct: activeUser.canManageCatalog
            ? _openProductSheet
            : () => _showHeaderMessage(
                  'Catalogue',
                  'La gestion des produits est réservée au gestionnaire ou a l’administrateur.',
                ),
      ),
      PosPage(
        store: store,
        cart: cart,
        onChanged: () => setState(() {}),
        checkout: _openCheckoutSheet,
        openSale: _showSaleDetails,
        cancelDraft: () => setState(cart.clear),
      ),
      CatalogPage(
        store: store,
        canManage: activeUser.canManageCatalog,
        openProduct: _openProductSheet,
        openStockMove: _openStockMoveSheet,
        addCategory: _addCategoryInline,
        previewProduct: _showProductPreview,
        deleteProduct: _deleteProduct,
      ),
      CashPage(
        store: store,
        openExpense: _openExpenseSheet,
        openSale: _showSaleDetails,
      ),
      MorePage(
        store: store,
        selectedModule: moreModule,
        onModule: (value) => setState(() => moreModule = value),
        closeModule: () => setState(() => moreModule = -1),
        openTab: _selectMainTab,
        onChanged: () => setState(store.markDirty),
        openCustomer: _openCustomerSheet,
        openSupplier: _openSupplierSheet,
        openPurchase: _openPurchaseSheet,
        openSettings: _openSettingsSheet,
        openUser: _openUserSheet,
        openReceipt: _showReceipt,
        onAlertTap: (alert) => setState(() => store.markAlertRead(alert)),
        onReadAllAlerts: () => setState(store.markAllAlertsRead),
        onSync: _runManualSync,
        syncing: _syncIndicatorVisible,
      ),
    ];
    final body = showMessages
        ? MessagesPage(
            store: store,
            onChanged: () => setState(() {}),
            onThreadStateChanged: (opened) =>
                setState(() => _messageThreadOpen = opened),
          )
        : showNotifications
        ? NotificationPage(
            store: store,
            onAlertTap: (alert) => setState(() => store.markAlertRead(alert)),
            onReadAllAlerts: () => setState(store.markAllAlertsRead),
            onChanged: () => setState(() {}),
          )
        : showInfo
        ? InfoPage(store: store, onLogout: widget.onLogout)
        : pages[tab];
    final currentPageLabel = showMessages
        ? 'Messages'
        : showNotifications
        ? 'Notifications'
        : showInfo
        ? 'Informations'
        : switch (tab) {
            0 => 'Tableau de bord',
            1 => 'Vendre',
            2 => 'Produits',
            3 => 'Caisse',
            _ => 'Gestion',
          };

    final hidePrimaryHud = showMessages && _messageThreadOpen;

    return Scaffold(
      appBar: hidePrimaryHud
          ? null
          : AppBar(
        toolbarHeight: 78,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        titleSpacing: 14,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(.10),
          ),
        ),
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.darkMode
                  ? const [
                      Color(0xFF061C28),
                      Color(0xFF083A49),
                      Color(0xFF0C5D6D),
                    ]
                  : const [
                      Color(0xFF073744),
                      Color(0xFF0A4C5D),
                      Color(0xFF0F6F82),
                    ],
            ),
          ),
        ),
        leading: showMessages || showNotifications || showInfo
            ? IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  hoverColor: Colors.white12,
                  highlightColor: Colors.white10,
                ),
                onPressed: () => setState(() {
                  showMessages = false;
                  showNotifications = false;
                  showInfo = false;
                  _messageThreadOpen = false;
                }),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: Row(
          children: [
            CompanyLogoBadge(settings: store.settings),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'KESE',
                        style: TextStyle(
                          fontSize: 13.6,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD8F26E),
                          letterSpacing: 0.35,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _HeaderBrandSwitcher(
                          darkMode: widget.darkMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store.settings.companyName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      height: 1.18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            _HeaderCircleButton(
              icon: Icons.mail_outline_rounded,
              tooltip: 'Messages',
              badgeCount: store.unreadMessages,
              selected: showMessages,
              onTap: () => setState(() {
                showNotifications = false;
                showInfo = false;
                showMessages = true;
                _messageThreadOpen = false;
              }),
            ),
            const SizedBox(width: 6),
            _HeaderBadgeButton(
              count: store.unreadAlerts,
              selected: showNotifications,
              onTap: () {
                setState(() {
                  showMessages = false;
                  showInfo = false;
                  showNotifications = true;
                  _messageThreadOpen = false;
                });
              },
            ),
            const SizedBox(width: 6),
            _HeaderCircleButton(
              icon: widget.darkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              tooltip: widget.darkMode ? 'Mode clair' : 'Mode sombre',
              onTap: widget.toggleTheme,
            ),
            const SizedBox(width: 6),
            _HeaderCircleButton(
              onTap: () => setState(() {
                showMessages = false;
                showNotifications = false;
                showInfo = true;
                _messageThreadOpen = false;
              }),
              icon: Icons.account_circle_outlined,
              tooltip: 'Profil',
              selected: showInfo,
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.darkMode
                ? const [
                    Color(0xFF08131A),
                    Color(0xFF0A1B23),
                    Color(0xFF0D2732),
                  ]
                : const [
                    Color(0xFFF4FAFB),
                    Color(0xFFF7FBFC),
                    Color(0xFFEFF8FB),
                  ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: desktopShell
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DesktopPrimaryRail(
                        darkMode: widget.darkMode,
                        companyName: store.settings.companyName,
                        activeUserName: store.activeUser.name,
                        selectedTab: tab,
                        canManageCatalog: activeUser.canManageCatalog,
                        onTabSelected: _selectMainTab,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1380),
                            child: Column(
                              children: [
                                if (!hidePrimaryHud)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _PageContextStrip(
                                      label: currentPageLabel,
                                      accountName: store.activeUser.name,
                                    ),
                                  ),
                                Expanded(child: body),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      children: [
                        if (!hidePrimaryHud)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                            child: _PageContextStrip(
                              label: currentPageLabel,
                              accountName: store.activeUser.name,
                            ),
                          ),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: desktopShell
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.darkMode
                        ? const Color(0xFF15313C)
                        : const Color(0xFFCEE1E7),
                    width: .8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.darkMode ? .20 : .06,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: _selectMainTab,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.dashboard_rounded),
                    label: 'Accueil',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.point_of_sale_rounded),
                    label: 'Vendre',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_rounded),
                    label: activeUser.canManageCatalog
                        ? 'Produits'
                        : 'Catalogue',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Caisse',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.apps_rounded),
                    label: 'Plus',
                  ),
                ],
              ),
            ),
    );
  }

  void _openProductSheet([Product? product]) {
    final editing = product != null;
    final name = TextEditingController(text: product?.name ?? '');
    final cost = TextEditingController(text: '${product?.cost ?? 0}');
    final price = TextEditingController(text: '${product?.price ?? 0}');
    final qty = TextEditingController(text: '${product?.quantity ?? 0}');
    final min = TextEditingController(text: '${product?.minQuantity ?? 3}');
    final image = TextEditingController(text: product?.imageUrl ?? '');
    final newCategory = TextEditingController();
    String selectedCategory = product?.category ?? store.categories.first;
    String selectedUnit = product?.unit ?? store.units.first;

    _showFormSheet(
      title: editing ? 'Modifier produit' : 'Nouveau produit',
      children: [
        _InfoBanner(
          icon: Icons.qr_code_2_rounded,
          title: editing ? product.sku : 'SKU et code-barres automatiques',
          subtitle: editing
              ? 'Code-barres: ${product.barcode}'
              : 'Le commerçant ne les saisit pas.',
        ),
        StatefulBuilder(
          builder: (context, setLocal) => Column(
            children: [
              ProductMediaPicker(
                imageUrl: image.text,
                label: name.text.trim().isEmpty ? 'Image produit' : name.text,
                onPick: () async {
                  final picked = await pickImageDataUrl();
                  if (picked == null) return;
                  setLocal(() => image.text = picked);
                },
                onClear: image.text.isEmpty
                    ? null
                    : () => setLocal(() => image.text = ''),
              ),
              const SizedBox(height: 12),
              _AppField(label: 'Nom du produit', controller: name),
              const SizedBox(height: 12),
              _TwoColumns(
                left: DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: store.categories
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry,
                          child: Text(entry),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setLocal(
                    () => selectedCategory = value ?? selectedCategory,
                  ),
                ),
                right: DropdownButtonFormField<String>(
                  initialValue: selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unite'),
                  items: store.units
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry,
                          child: Text(entry),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setLocal(() => selectedUnit = value ?? selectedUnit),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AppField(
                      label: 'Nouvelle categorie',
                      controller: newCategory,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () {
                      final value = newCategory.text.trim();
                      if (value.isEmpty) return;
                      setState(() => store.addCategory(value));
                      setLocal(() => selectedCategory = value);
                      newCategory.clear();
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TwoColumns(
                left: _AppField(
                  label: 'Prix d’achat',
                  controller: cost,
                  number: true,
                ),
                right: _AppField(
                  label: 'Prix vente',
                  controller: price,
                  number: true,
                ),
              ),
              const SizedBox(height: 12),
              _TwoColumns(
                left: _AppField(
                  label: 'Quantité initiale',
                  controller: qty,
                  number: true,
                ),
                right: _AppField(
                  label: 'Quantité d alerte',
                  controller: min,
                  number: true,
                ),
              ),
              const SizedBox(height: 12),
              _AppField(
                label: 'Image produit (lien web, optionnel)',
                controller: image,
              ),
            ],
          ),
        ),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return;
        setState(() {
          store.addCategory(selectedCategory);
          if (editing) {
            product
              ..name = name.text.trim()
              ..category = selectedCategory
              ..unit = selectedUnit
              ..cost = _num(cost.text)
              ..price = _num(price.text)
              ..quantity = _num(qty.text)
              ..minQuantity = _num(min.text)
              ..imageUrl = image.text.trim();
            store.enqueueSyncOperation(
              entityName: 'product',
              entityId: product.code,
              operationName: 'update',
              payload: store.productSyncPayload(product),
            );
          } else {
            final created = store.createProduct(
              name: name.text.trim(),
              category: selectedCategory,
              unit: selectedUnit,
              cost: _num(cost.text),
              price: _num(price.text),
              quantity: _num(qty.text),
              minQuantity: _num(min.text),
              imageUrl: image.text.trim(),
            );
            store.products.add(created);
            store.enqueueSyncOperation(
              entityName: 'product',
              entityId: created.code,
              operationName: 'create',
              payload: store.productSyncPayload(created),
            );
          }
          store.markDirty();
        });
        Navigator.pop(context);
      },
    );
  }

  void _openStockMoveSheet(Product product) {
    final qty = TextEditingController(text: '1');
    String type = 'IN';
    _showFormSheet(
      title: 'Mouvement stock',
      children: [
        _InfoBanner(
          icon: Icons.inventory_rounded,
          title: product.name,
          subtitle: 'Disponible: ${product.quantityText}',
        ),
        StatefulBuilder(
          builder: (context, setLocal) => SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'IN',
                label: Text('Entrée'),
                icon: Icon(Icons.add_rounded),
              ),
              ButtonSegment(
                value: 'OUT',
                label: Text('Sortie'),
                icon: Icon(Icons.remove_rounded),
              ),
              ButtonSegment(
                value: 'ADJUST',
                label: Text('Ajuster'),
                icon: Icon(Icons.tune_rounded),
              ),
            ],
            selected: {type},
            onSelectionChanged: (value) => setLocal(() => type = value.first),
          ),
        ),
        _AppField(label: 'Quantité', controller: qty, number: true),
      ],
      onSave: () {
        setState(() => store.applyStockMove(product, type, _num(qty.text)));
        Navigator.pop(context);
      },
    );
  }

  void _openCheckoutSheet() {
    if (cart.isEmpty) return;
    final paid = TextEditingController(text: '$cartTotal');
    final discount = TextEditingController(text: '0');
    Customer customer = store.customers.first;
    String method = 'Cash';
    DateTime creditDueDate = DateTime.now().add(const Duration(days: 7));
    final dueDateController = TextEditingController(
      text: _formatDate(creditDueDate),
    );

    _showFormSheet(
      title: 'Encaisser',
      children: [
        ...cart.map((line) => _CartLineTile(line: line, money: store.money)),
        StatefulBuilder(
          builder: (context, setLocal) => Column(
            children: [
              if (method == 'Credit')
                _InfoBanner(
                  icon: Icons.credit_score_rounded,
                  title: 'Vente à crédit activée',
                  subtitle:
                      'Le montant non paye sera ajoute a la dette du client selectionne.',
                ),
              if (method == 'Credit') const SizedBox(height: 12),
              DropdownButtonFormField<Customer>(
                initialValue: customer,
                decoration: const InputDecoration(labelText: 'Client'),
                items: store.customers
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (value) =>
                    setLocal(() => customer = value ?? customer),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Paiement'),
                items:
                    const ['Cash', 'Mobile money', 'Carte', 'Credit', 'Mixte']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                onChanged: (value) => setLocal(() {
                  method = value ?? method;
                  if (method == 'Credit') {
                    paid.text = '0';
                  } else if (_num(paid.text) <= 0) {
                    paid.text = '$cartTotal';
                  }
                }),
              ),
              if (method == 'Credit') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Echeance du paiement',
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: creditDueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      helpText: 'Choisir l’échéance',
                      cancelText: 'Annuler',
                      confirmText: 'Valider',
                    );
                    if (picked == null) return;
                    setLocal(() {
                      creditDueDate = picked;
                      dueDateController.text = _formatDate(creditDueDate);
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        _TwoColumns(
          left: _AppField(label: 'Remise', controller: discount, number: true),
          right: _AppField(label: 'Payé', controller: paid, number: true),
        ),
        _TotalBox(label: 'Total panier', value: store.money(cartTotal)),
      ],
      onSave: () {
        setState(() {
          final sale = store.completeSale(
            cart: cart,
            customer: customer,
            method: method,
            paid: _num(paid.text),
            discount: _num(discount.text),
            cashier: store.activeUser,
            dueDate: method == 'Credit' ? creditDueDate : null,
          );
          cart.clear();
          Navigator.pop(context);
          _showReceipt(sale);
        });
      },
    );
  }

  void _openCustomerSheet() => _openPartySheet(isSupplier: false);

  void _openSupplierSheet() => _openPartySheet(isSupplier: true);

  void _openPartySheet({required bool isSupplier}) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    _showFormSheet(
      title: isSupplier ? 'Nouveau fournisseur' : 'Nouveau client',
      children: [
        _AppField(label: 'Nom', controller: name),
        _AppField(label: 'Numero WhatsApp', controller: phone),
        _AppField(label: 'Adresse', controller: address),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return;
        setState(() {
          if (isSupplier) {
            final supplier = store.createSupplier(name.text, phone.text, address.text);
            store.suppliers.add(supplier);
            store.enqueueSyncOperation(
              entityName: 'supplier',
              entityId: supplier.code,
              operationName: 'create',
              payload: store.supplierSyncPayload(supplier),
            );
          } else {
            final customer = store.createCustomer(name.text, phone.text, address.text);
            store.customers.add(customer);
            store.enqueueSyncOperation(
              entityName: 'customer',
              entityId: customer.code,
              operationName: 'create',
              payload: store.customerSyncPayload(customer),
            );
          }
          store.markDirty();
        });
        Navigator.pop(context);
      },
    );
  }

  void _openPurchaseSheet() {
    Product product = store.products.first;
    Supplier supplier = store.suppliers.first;
    final qty = TextEditingController(text: '1');
    final cost = TextEditingController(text: '${product.cost}');
    final paid = TextEditingController(text: '0');
    _showFormSheet(
      title: 'Achat fournisseur',
      children: [
        StatefulBuilder(
          builder: (context, setLocal) => Column(
            children: [
              DropdownButtonFormField<Supplier>(
                initialValue: supplier,
                decoration: const InputDecoration(labelText: 'Fournisseur'),
                items: store.suppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (value) =>
                    setLocal(() => supplier = value ?? supplier),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Product>(
                initialValue: product,
                decoration: const InputDecoration(labelText: 'Produit'),
                items: store.products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (value) => setLocal(() {
                  product = value ?? product;
                  cost.text = '${product.cost}';
                }),
              ),
            ],
          ),
        ),
        _TwoColumns(
          left: _AppField(label: 'Quantité', controller: qty, number: true),
          right: _AppField(
            label: 'Cout unitaire',
            controller: cost,
            number: true,
          ),
        ),
        _AppField(label: 'Montant paye', controller: paid, number: true),
      ],
      onSave: () {
        setState(
          () => store.addPurchase(
            product,
            supplier,
            _num(qty.text),
            _num(cost.text),
            _num(paid.text),
            store.activeUser,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  void _openExpenseSheet() {
    final label = TextEditingController(text: 'Operations');
    final amount = TextEditingController();
    _showFormSheet(
      title: 'Nouvelle dépense',
      children: [
        _AppField(label: 'Categorie', controller: label),
        _AppField(label: 'Montant', controller: amount, number: true),
      ],
      onSave: () {
        setState(() => store.addExpense(label.text, _num(amount.text), store.activeUser));
        Navigator.pop(context);
      },
    );
  }

  void _openSettingsSheet() {
    final s = store.settings;
    final cloudSession = store.cloudSession;
    final company = TextEditingController(text: s.companyName);
    final phone = TextEditingController(text: s.phone);
    final email = TextEditingController(text: s.email);
    final rccm = TextEditingController(text: s.rccm);
    final idNat = TextEditingController(text: s.idNat);
    final nif = TextEditingController(text: s.nif);
    final efo = TextEditingController(text: s.efo);
    final address = TextEditingController(text: s.address);
    var logoValue = s.logoUrl;
    _showFormSheet(
      title: 'Paramètres entreprise',
      children: [
        StatefulBuilder(
          builder: (context, setLocal) => Column(
            children: [
              if (cloudSession != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _softPanelColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _panelBorderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cle entreprise',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _greenDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        cloudSession.tenantKey,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: cloudSession.tenantKey),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Clé entreprise copiée.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copier la clé'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ProductMediaPicker(
                imageUrl: logoValue,
                label: 'Logo entreprise',
                pickLabel: 'Choisir le logo',
                onPick: () async {
                  final picked = await pickImageDataUrl();
                  if (picked == null) return;
                  setLocal(() => logoValue = picked);
                },
                onClear: logoValue.isEmpty
                    ? null
                    : () => setLocal(() => logoValue = ''),
              ),
              const SizedBox(height: 12),
              _AppField(label: 'Entreprise', controller: company),
              const SizedBox(height: 12),
              _TwoColumns(
                left: _AppField(label: 'Telephone', controller: phone),
                right: _AppField(label: 'Email', controller: email),
              ),
              const SizedBox(height: 12),
              _AppField(label: 'Adresse', controller: address),
              const SizedBox(height: 12),
              _TwoColumns(
                left: _AppField(label: 'RCCM', controller: rccm),
                right: _AppField(label: 'ID NAT', controller: idNat),
              ),
              const SizedBox(height: 12),
              _TwoColumns(
                left: _AppField(label: 'NIF / Impot', controller: nif),
                right: _AppField(label: 'N EFO', controller: efo),
              ),
            ],
          ),
        ),
      ],
      onSave: () {
        setState(() {
          s
            ..companyName = company.text
            ..phone = phone.text
            ..email = email.text
            ..address = address.text
            ..rccm = rccm.text
            ..idNat = idNat.text
            ..nif = nif.text
            ..efo = efo.text
            ..logoUrl = logoValue;
          store.enqueueSyncOperation(
            entityName: 'settings',
            entityId: store.tenantId,
            operationName: 'update',
            payload: store.settingsSyncPayload(),
          );
          store.markDirty();
        });
        Navigator.pop(context);
      },
    );
  }

  void _openUserSheet() {
    final name = TextEditingController();
    final username = TextEditingController();
    final pin = TextEditingController();
    _showFormSheet(
      title: 'Utilisateur',
      children: [
        _AppField(label: 'Nom', controller: name),
        _AppField(label: 'Identifiant', controller: username),
        _AppField(label: 'Code secret', controller: pin, number: true),
      ],
      onSave: () {
        final user = AppUser(
          code: store.codes.nextUser(),
          name: name.text,
          username: username.text,
          role: 'Caissier',
          pin: pin.text,
        );
        setState(() {
          store.users.add(user);
          store.enqueueSyncOperation(
            entityName: 'user',
            entityId: user.code,
            operationName: 'create',
            payload: store.userSyncPayload(user),
          );
          store.markDirty();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showReceipt(Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: DocumentPreviewSheet(
            store: store,
            sale: sale,
            onClose: () => Navigator.pop(context),
            onPrintTicket: () => printPdfBytes(
              'Ticket ${sale.ticketNo}',
              _buildTicketPdfBytes(sale),
            ),
            onPrintInvoice: () async => printPdfBytes(
              'Facture ${sale.invoiceNo}',
              await _buildInvoicePdfBytes(sale),
            ),
            onExportInvoicePdf: () async => downloadBytes(
              '${sale.invoiceNo}.pdf',
              await _buildInvoicePdfBytes(sale),
              'application/pdf',
            ),
            onSettleCredit: !store.activeUser.isCashier && sale.isCredit
                ? () {
                    Navigator.pop(context);
                    _openCreditSettlementSheet(sale);
                  }
                : null,
          ),
        ),
      ),
    );
  }

  void _showSaleDetails(Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: 'Detail vente',
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                Text(
                  sale.invoiceNo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${sale.customer.name} - ${sale.method} - ${sale.status} - ${sale.cashierName}',
                  style: TextStyle(color: _mutedTextColor(context)),
                ),
                const SizedBox(height: 14),
                ...sale.lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SaleLineInsightTile(
                      line: line,
                      product: store.findProduct(line.product),
                      money: store.money,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _TotalBox(label: 'Sous-total', value: store.money(sale.subtotal)),
                const SizedBox(height: 8),
                _TotalBox(label: 'Remise', value: store.money(sale.discount)),
                const SizedBox(height: 8),
                _TotalBox(label: 'Total', value: store.money(sale.total)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductPreview(Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: product.name,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 220,
                    child: ProductMedia(product: product),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openStockMoveSheet(product);
                        },
                        icon: const Icon(Icons.sync_alt_rounded),
                        label: const Text('Mouvement stock'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteProduct(product);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        side: const BorderSide(color: _danger),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    ProductInfoRow(
                      icon: Icons.category_rounded,
                      label: 'Categorie',
                      value: product.category,
                    ),
                    ProductInfoRow(
                      icon: Icons.inventory_2_rounded,
                      label: 'Stock',
                      value: product.quantityText,
                    ),
                    ProductInfoRow(
                      icon: Icons.warning_amber_rounded,
                      label: 'Alerte',
                      value: '${product.minQuantity.round()} ${product.unit}',
                    ),
                    ProductInfoRow(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Prix d’achat',
                      value: store.money(product.cost),
                    ),
                    ProductInfoRow(
                      icon: Icons.sell_rounded,
                      label: 'Prix vente',
                      value: store.money(product.price),
                    ),
                    ProductInfoRow(
                      icon: Icons.qr_code_rounded,
                      label: 'Code',
                      value: product.sku,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer produit'),
        content: Text('Supprimer ${product.name} du catalogue ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      store.enqueueSyncOperation(
        entityName: 'product',
        entityId: product.code,
        operationName: 'delete',
        payload: store.productSyncPayload(product),
      );
      store.products.removeWhere((entry) => entry.code == product.code);
      store.stockMoves.removeWhere(
        (move) =>
            move.product == product.name &&
            (move.reference == product.sku || move.type == 'OPENING'),
      );
      store.markDirty();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} a ete supprime du catalogue.'),
      ),
    );
  }

  void _showInvoicePreview(BuildContext context, Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: DocumentPreviewSheet(
            store: store,
            sale: sale,
            initialMode: DocumentPreviewMode.invoice,
            onClose: () => Navigator.pop(sheetContext),
            onPrintTicket: () => printPdfBytes(
              'Ticket ${sale.ticketNo}',
              _buildTicketPdfBytes(sale),
            ),
            onPrintInvoice: () async => printPdfBytes(
              'Facture ${sale.invoiceNo}',
              await _buildInvoicePdfBytes(sale),
            ),
            onExportInvoicePdf: () async => downloadBytes(
              '${sale.invoiceNo}.pdf',
              await _buildInvoicePdfBytes(sale),
              'application/pdf',
            ),
            onSettleCredit: !store.activeUser.isCashier && sale.isCredit
                ? () {
                    Navigator.pop(sheetContext);
                    _openCreditSettlementSheet(sale);
                  }
                : null,
          ),
        ),
      ),
    );
  }

  void _openCreditSettlementSheet(Sale sale) {
    final amount = TextEditingController(text: '${sale.due.round()}');
    _showFormSheet(
      title: 'Règlement du crédit',
      children: [
        _InfoBanner(
          icon: Icons.receipt_long_rounded,
          title: sale.invoiceNo,
          subtitle:
              '${sale.customer.name} - Reste ${store.money(sale.due)} a encaisser.',
        ),
        _AppField(label: 'Montant regle', controller: amount, number: true),
      ],
      onSave: () {
        final settled = store.settleSaleCredit(
          sale,
          amount: _num(amount.text),
          actor: store.activeUser,
        );
        if (settled <= 0) return;
        setState(() {});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paiement enregistre: ${store.money(settled)} pour ${sale.invoiceNo}.',
            ),
          ),
        );
      },
    );
  }

  String _invoiceHtml(Sale sale) {
    return _buildModernInvoiceHtml(store, sale);
  }

  String _ticketHtml(Sale sale) {
    return _buildThermalTicketHtml(store, sale);
  }

  String _documentQrPayload(Sale sale, String kind) =>
      '$kind|${sale.invoiceNo}|${sale.ticketNo}|${sale.customer.code}|${sale.cashierCode}|${sale.createdAt.toIso8601String()}|${sale.total.round()}';

  Future<Uint8List> _buildInvoicePdfBytes(Sale sale) async {
    return _buildModernInvoicePdfBytes(store, sale);
  }

  Uint8List _buildTicketPdfBytes(Sale sale) {
    return _buildThermalTicketPdfBytes(store, sale);
  }

  void _showHeaderMessage(String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - $body'),
      ),
    );
  }

  void _addCategoryInline() {
    final controller = TextEditingController();
    _showFormSheet(
      title: 'Nouvelle categorie',
      children: [_AppField(label: 'Nom de la categorie', controller: controller)],
      onSave: () {
        final value = controller.text.trim();
        if (value.isEmpty) return;
        setState(() => store.addCategory(value));
        Navigator.pop(context);
      },
    );
  }

  void _showFormSheet({
    required String title,
    required List<Widget> children,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...children.expand(
                    (child) => [child, const SizedBox(height: 12)],
                  ),
                  FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  num get cartTotal =>
      cart.fold<num>(0, (sum, line) => sum + line.qty * line.product.price);
}

class _DesktopPrimaryRail extends StatelessWidget {
  const _DesktopPrimaryRail({
    required this.darkMode,
    required this.companyName,
    required this.activeUserName,
    required this.selectedTab,
    required this.canManageCatalog,
    required this.onTabSelected,
  });

  final bool darkMode;
  final String companyName;
  final String activeUserName;
  final int selectedTab;
  final bool canManageCatalog;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(darkMode ? 24 : 10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: darkMode
                    ? const [
                        Color(0xFF082736),
                        Color(0xFF0A4C5D),
                        Color(0xFF0F6F82),
                      ]
                    : const [
                        Color(0xFF0A4C5D),
                        Color(0xFF0F6F82),
                        Color(0xFF18A8BD),
                      ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset(
                        _keseLogoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.point_of_sale_rounded,
                          color: _green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'KESE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  companyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activeUserName,
                  style: TextStyle(
                    color: Colors.white.withAlpha(214),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DesktopRailButton(
            selected: selectedTab == 0,
            icon: Icons.dashboard_rounded,
            label: 'Accueil',
            onTap: () => onTabSelected(0),
          ),
          const SizedBox(height: 8),
          _DesktopRailButton(
            selected: selectedTab == 1,
            icon: Icons.point_of_sale_rounded,
            label: 'Vendre',
            onTap: () => onTabSelected(1),
          ),
          const SizedBox(height: 8),
          _DesktopRailButton(
            selected: selectedTab == 2,
            icon: Icons.inventory_2_rounded,
            label: canManageCatalog ? 'Produits' : 'Catalogue',
            onTap: () => onTabSelected(2),
          ),
          const SizedBox(height: 8),
          _DesktopRailButton(
            selected: selectedTab == 3,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Caisse',
            onTap: () => onTabSelected(3),
          ),
          const SizedBox(height: 8),
          _DesktopRailButton(
            selected: selectedTab == 4,
            icon: Icons.apps_rounded,
            label: 'Gestion',
            onTap: () => onTabSelected(4),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _softPanelColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _panelBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espace desktop',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Navigation stable, vue large et accès rapide aux modules principaux.',
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopRailButton extends StatelessWidget {
  const _DesktopRailButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF143A63) : _softPanelColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF143A63)
                  : _panelBorderColor(context),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : _greenDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.goToPos,
    required this.openProduct,
    required this.openCredits,
  });

  final AppStore store;
  final VoidCallback goToPos;
  final VoidCallback openProduct;
  final VoidCallback openCredits;

  @override
  Widget build(BuildContext context) {
    final metrics = store.todayMetrics;
    final cashierView = store.activeUser.isCashier;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final desktop = screenWidth >= 1100;
    String moneyValue(num value) => store.money(value);
    final heroLabelStyle = _whiteLabel.copyWith(fontSize: desktop ? 14 : 13);
    final heroSubtitleStyle = _whiteLabel.copyWith(
      fontSize: desktop ? 14 : 13,
      fontWeight: FontWeight.w700,
      color: Colors.white.withAlpha(232),
    );
    final hero = Container(
      height: screenWidth < 520
          ? 378
          : desktop
              ? 324
              : 300,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widgetColorSet(context),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A4C5D),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxWidth < 520;
          final amountStyle = compact
              ? _heroAmount.copyWith(fontSize: 38)
              : _heroAmount.copyWith(fontSize: desktop ? 50 : 46);
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!compact) ...[
                _DashboardMiniTrendCard(
                  metrics: metrics,
                  cashierView: cashierView,
                  money: moneyValue,
                ),
                const SizedBox(height: 12),
              ],
              Text('Revenu du jour', style: heroLabelStyle),
              SizedBox(height: compact ? 6 : 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  moneyValue(metrics.revenue),
                  key: ValueKey(metrics.revenue),
                  style: amountStyle,
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                cashierView
                    ? '${metrics.salesCount} vente(s) - caisse ${moneyValue(metrics.cash)}'
                    : '${metrics.salesCount} vente(s) - bénéfice ${moneyValue(metrics.profit)}',
                style: heroSubtitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 110, child: copy),
                const SizedBox(height: 4),
                SizedBox(
                  height: 214,
                  child: ProductShowcase(products: store.products),
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: desktop ? 4 : 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: copy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: desktop ? 6 : 5,
                child: ProductShowcase(products: store.products),
              ),
            ],
          );
        },
      ),
    );
    final actions = Row(
      children: [
        Expanded(
          child: _BigActionButton(
            icon: Icons.add_shopping_cart_rounded,
            label: 'Vendre',
            onTap: goToPos,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BigActionButton(
            icon: Icons.inventory_2_rounded,
            label: 'Produits',
            onTap: openProduct,
          ),
        ),
      ],
    );
    final kpis = _ResponsiveGrid(
      children: [
        KpiTile(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Caisse',
          value: moneyValue(metrics.cash),
        ),
        KpiTile(
          icon: cashierView ? Icons.sell_rounded : Icons.trending_up_rounded,
          label: cashierView ? 'Ventes du jour' : 'Bénéfice',
          value: cashierView ? '${metrics.salesCount}' : moneyValue(metrics.profit),
        ),
        KpiTile(
          icon: Icons.credit_score_rounded,
          label: 'Crédits',
          value: moneyValue(store.customerDebt),
        ),
        KpiTile(
          icon: cashierView ? Icons.receipt_rounded : Icons.warning_rounded,
          label: cashierView ? 'Dépenses' : 'Stock bas',
          value: cashierView
              ? moneyValue(metrics.expenses)
              : '${store.lowStock.length}',
        ),
      ],
    );
    final recent = SectionCard(
      title: 'Activité récente',
      icon: Icons.history_rounded,
      child: RecentActivitiesPager(activities: store.recentActivities),
    );
    final watch = SectionCard(
      title: 'À surveiller',
      icon: Icons.visibility_rounded,
      child: Column(
        children: [
          StatusInsightTile(
            icon: cashierView
                ? Icons.account_balance_wallet_rounded
                : Icons.warning_amber_rounded,
            title: cashierView ? 'Ma caisse du jour' : 'Produits en stock bas',
            subtitle: cashierView
                ? '${moneyValue(metrics.cash)} après ${moneyValue(metrics.expenses)} de dépenses.'
                : store.lowStock.isEmpty
                    ? 'Aucun produit en rupture proche pour le moment.'
                    : store.lowStock
                        .take(3)
                        .map((product) => '${product.name} (${product.quantityText})')
                        .join(', '),
            tone: cashierView
                ? InsightTone.good
                : store.lowStock.isEmpty
                    ? InsightTone.good
                    : InsightTone.warning,
          ),
          const SizedBox(height: 8),
          StatusInsightTile(
            icon: Icons.credit_score_rounded,
            title: 'Crédits clients',
            subtitle: store.customerDebt <= 0
                ? 'Aucun crédit client en attente.'
                : '${store.money(store.customerDebt)} restent à récupérer.',
            tone: store.customerDebt <= 0
                ? InsightTone.good
                : InsightTone.warning,
            onTap: store.customerDebt <= 0 ? null : openCredits,
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1080;
        if (!desktop) {
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              hero,
              const SizedBox(height: 12),
              actions,
              const SizedBox(height: 12),
              kpis,
              const SizedBox(height: 14),
              recent,
              const SizedBox(height: 12),
              watch,
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            hero,
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    children: [
                      actions,
                      const SizedBox(height: 14),
                      kpis,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      recent,
                      const SizedBox(height: 14),
                      watch,
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

List<Color> widgetColorSet(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const [Color(0xFF0B2A38), Color(0xFF13758A), Color(0xFF37D2F4)]
    : const [Color(0xFF0A4C5D), Color(0xFF0F6F82), Color(0xFF1490A2)];

class _DashboardMiniTrendCard extends StatelessWidget {
  const _DashboardMiniTrendCard({
    required this.metrics,
    required this.cashierView,
    required this.money,
  });

  final TodayMetrics metrics;
  final bool cashierView;
  final String Function(num value) money;

  @override
  Widget build(BuildContext context) {
    final values = <num>[
      metrics.revenue <= 0 ? 1 : metrics.revenue,
      metrics.cash <= 0 ? 1 : metrics.cash,
      cashierView ? metrics.expenses : metrics.profit.abs(),
      metrics.salesCount <= 0 ? 1 : metrics.salesCount,
    ];
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final bars = <({
      String label,
      num value,
      List<Color> colors,
    })>[
      (
        label: 'Ventes',
        value: metrics.revenue <= 0 ? 1 : metrics.revenue,
        colors: const [Color(0xFF74E1F1), Color(0xFF28C0D7)],
      ),
      (
        label: 'Caisse',
        value: metrics.cash <= 0 ? 1 : metrics.cash,
        colors: const [Color(0xFF7AF0C0), Color(0xFF22B57F)],
      ),
      (
        label: cashierView ? 'Sorties' : 'Bénéfice',
        value: (cashierView ? metrics.expenses : metrics.profit.abs()) <= 0
            ? 1
            : (cashierView ? metrics.expenses : metrics.profit.abs()),
        colors: cashierView
            ? const [Color(0xFFFFD894), Color(0xFFE3A83F)]
            : const [Color(0xFFAAB7FF), Color(0xFF6977F5)],
      ),
      (
        label: 'Volume',
        value: metrics.salesCount <= 0 ? 1 : metrics.salesCount,
        colors: const [Color(0xFFFFAFCB), Color(0xFFE16096)],
      ),
    ];

    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((bar) {
                final heightFactor = ((bar.value.toDouble() / maxValue) * 0.78).clamp(0.22, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: bar.colors,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: bar.colors.last.withAlpha(90),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 28,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(110),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bar.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tendance du jour',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cashierView ? 'Vue caisse en temps réel' : 'Vue synthèse de performance',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Caisse ${money(metrics.cash)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PosPage extends StatefulWidget {
  const PosPage({
    super.key,
    required this.store,
    required this.cart,
    required this.onChanged,
    required this.checkout,
    required this.openSale,
    required this.cancelDraft,
  });

  final AppStore store;
  final List<CartLine> cart;
  final VoidCallback onChanged;
  final VoidCallback checkout;
  final void Function(Sale sale) openSale;
  final VoidCallback cancelDraft;

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  String productQuery = '';
  String salesQuery = '';
  int productPage = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final cart = widget.cart;
    final checkout = widget.checkout;
    final cancelDraft = widget.cancelDraft;
    final openSale = widget.openSale;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    final filteredProducts = store.products.where((product) {
      final haystack =
          '${product.name} ${product.category} ${product.sku} ${product.barcode}';
      return _matchesSearchText(haystack, productQuery);
    }).toList();
    const productPageSize = 4;
    final totalProductPages =
        ((filteredProducts.length + productPageSize - 1) ~/ productPageSize).clamp(1, 9999);
    final safeProductPage = productPage.clamp(0, totalProductPages - 1);
    if (safeProductPage != productPage) {
      productPage = safeProductPage;
    }
    final visibleProducts = filteredProducts
        .skip(safeProductPage * productPageSize)
        .take(productPageSize)
        .toList();
    final filteredSales = store.visibleSales.reversed.where((sale) {
      final haystack =
          '${sale.invoiceNo} ${sale.customer.name} ${sale.lines.map((line) => line.product).join(' ')}';
      return _matchesSearchText(haystack, salesQuery);
    }).toList();
    final salesInsights = salesQuery.trim().isEmpty
        ? const <ProductSalesInsight>[]
        : store.productSalesInsights(salesQuery);
    final total = cart.fold<num>(
      0,
      (sum, line) => sum + line.qty * line.product.price,
    );
    final pageHeader = _PageHeader(
      title: 'Vendre',
      subtitle:
          'Choisissez un ou plusieurs produits selon la commande du client, encaissez puis validez la commande. Chaque appui ajoute une quantité supplémentaire.',
      icon: Icons.point_of_sale_rounded,
    );
    final productSearchField = TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Rechercher un produit',
      ),
      onChanged: (value) => setState(() {
        productQuery = value;
        productPage = 0;
      }),
    );
    final productsGrid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleProducts.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: desktop ? 240 : 210,
        mainAxisExtent: 224,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final product = visibleProducts[index];
        return ProductCard(
          product: product,
          money: store.money,
          onTap: product.quantity <= 0
              ? null
              : () {
                  final existing = cart
                      .where((line) => line.product == product)
                      .firstOrNull;
                  if (existing == null) {
                    cart.add(CartLine(product: product));
                  } else if (existing.qty < product.quantity) {
                    existing.qty += 1;
                  }
                  widget.onChanged();
                },
        );
      },
    );
    final journalSection = SectionCard(
      title: 'Journal des ventes',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.tune_rounded),
              hintText: 'Filtrer par facture, client ou produit',
            ),
            onChanged: (value) => setState(() => salesQuery = value),
          ),
          if (salesQuery.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            if (salesInsights.isNotEmpty)
              ...salesInsights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductSalesInsightCard(
                    insight: insight,
                    money: store.money,
                  ),
                ),
              )
            else
              const _EmptyStateTile(
                icon: Icons.search_off_rounded,
                title: 'Aucun produit trouve',
                subtitle:
                    'Essaie un autre nom, une facture ou le nom du client.',
              ),
          ],
          const SizedBox(height: 12),
          if (filteredSales.isEmpty)
            const _EmptyStateTile(
              icon: Icons.receipt_long_rounded,
              title: 'Aucune vente correspondante',
              subtitle:
                  'Les ventes filtrees apparaîtront ici des qu elles correspondent a la recherche.',
            )
          else
            ...filteredSales.take(8).map((sale) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SaleJournalCard(
                  sale: sale,
                  store: store,
                  onTap: () => openSale(sale),
                ),
              );
            }),
        ],
      ),
    );
    final cartSummary = Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.isEmpty ? 'Aucune commande en cours' : 'Commande en cours',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cart.isEmpty ? store.money(0) : store.money(total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        cart.isEmpty
                            ? 'Ajoute des produits pour commencer.'
                            : '${cart.fold<num>(0, (s, e) => s + e.qty)} article(s)',
                        style: TextStyle(color: _mutedTextColor(context)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cart.isEmpty
                        ? _softPanelColor(context)
                        : _softAccentStrong(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _panelBorderColor(context)),
                  ),
                  child: Text(
                    cart.isEmpty ? 'Panier vide' : 'Panier actif',
                    style: TextStyle(
                      color: cart.isEmpty ? _ink : _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cart.isEmpty)
              const _InfoBanner(
                icon: Icons.shopping_cart_outlined,
                title: 'Commence par choisir un produit',
                subtitle:
                    'Le récapitulatif de vente s’affichera ici dès le premier ajout au panier.',
              )
            else
              ...cart.take(4).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CartLineTile(
                    line: line,
                    money: store.money,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: cart.isEmpty ? null : cancelDraft,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: cart.isEmpty ? null : checkout,
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('Encaisser'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (desktop) {
      const sidebarWidth = 470.0;
      final leftPanel = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          productSearchField,
          const SizedBox(height: 12),
          SectionCard(
            title: 'Produits disponibles',
            icon: Icons.inventory_2_rounded,
            child: Column(
              children: [
                productsGrid,
                if (totalProductPages > 1) ...[
                  const SizedBox(height: 10),
                  _PagerControls(
                    page: safeProductPage,
                    totalPages: totalProductPages,
                    onPrevious: safeProductPage == 0
                        ? null
                        : () => setState(() => productPage -= 1),
                    onNext: safeProductPage >= totalProductPages - 1
                        ? null
                        : () => setState(() => productPage += 1),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
      return ListView(
        padding: const EdgeInsets.all(18),
        children: [
          pageHeader,
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ViewportStickyRail(
                width: sidebarWidth,
                child: leftPanel,
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 10,
                child: Column(
                  children: [
                    cartSummary,
                    const SizedBox(height: 14),
                    journalSection,
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(
            14,
            cart.isEmpty ? 14 : 126,
            14,
            24,
          ),
          children: [
            if (cart.isEmpty) ...[
              pageHeader,
              const SizedBox(height: 12),
            ],
            productSearchField,
            const SizedBox(height: 12),
            productsGrid,
            if (totalProductPages > 1) ...[
              const SizedBox(height: 10),
              _PagerControls(
                page: safeProductPage,
                totalPages: totalProductPages,
                onPrevious: safeProductPage == 0
                    ? null
                    : () => setState(() => productPage -= 1),
                onNext: safeProductPage >= totalProductPages - 1
                    ? null
                    : () => setState(() => productPage += 1),
              ),
            ],
            const SizedBox(height: 14),
            journalSection,
          ],
        ),
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: IgnorePointer(
            ignoring: cart.isEmpty,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: cart.isEmpty ? const Offset(0, -0.25) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: cart.isEmpty ? 0 : 1,
                child: cart.isEmpty
                    ? const SizedBox.shrink()
                    : Material(
                        color: Colors.transparent,
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Commande en cours',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            store.money(total),
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            '${cart.fold<num>(0, (s, e) => s + e.qty)} article(s)',
                                            style: TextStyle(
                                              color: _mutedTextColor(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _softAccentStrong(context),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: _panelBorderColor(context),
                                        ),
                                      ),
                                      child: const Text(
                                        'Panier actif',
                                        style: TextStyle(
                                          color: _green,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: cancelDraft,
                                        icon: const Icon(Icons.close_rounded),
                                        label: const Text('Annuler'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: checkout,
                                        icon: const Icon(
                                          Icons.receipt_long_rounded,
                                        ),
                                        label: const Text('Encaisser'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.store,
    required this.canManage,
    required this.openProduct,
    required this.openStockMove,
    required this.addCategory,
    required this.previewProduct,
    required this.deleteProduct,
  });

  final AppStore store;
  final bool canManage;
  final void Function(Product? product) openProduct;
  final void Function(Product product) openStockMove;
  final VoidCallback addCategory;
  final void Function(Product product) previewProduct;
  final void Function(Product product) deleteProduct;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String productQuery = '';
  String productFilter = 'Tous';

  Widget _buildDesktopCatalogShell(
    BuildContext context, {
    required Widget search,
    required Widget filter,
    required List<Product> filteredProducts,
    required Widget statsPanel,
    required Widget categoriesPanel,
    required AppStore store,
  }) {
    final rightRail = Column(
      children: [
        if (widget.canManage) ...[
          SectionCard(
            title: 'Actions produit',
            icon: Icons.add_box_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.addCategory,
                        icon: const Icon(Icons.category_rounded),
                        label: const Text('Categorie'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => widget.openProduct(null),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Produit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _InfoBanner(
                  icon: Icons.inventory_2_rounded,
                  title: 'Gestion du catalogue',
                  subtitle:
                      'Ajoute, modifie ou ajuste rapidement les articles et leurs catégories.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        SectionCard(
          title: 'Vue d’ensemble',
          icon: Icons.grid_view_rounded,
          child: statsPanel,
        ),
        const SizedBox(height: 14),
        categoriesPanel,
      ],
    );

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _PageHeader(
          title: 'Produits & Stock',
          subtitle: widget.canManage
              ? 'Catalogue, categories et mouvements des stocks.'
              : 'Catalogue produit en lecture seule pour la caisse.',
          icon: Icons.inventory_2_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: search),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: filter),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Produits disponibles',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            '${filteredProducts.length} résultat(s)',
                            style: TextStyle(
                              color: _mutedTextColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filteredProducts.isEmpty)
                        const _EmptyStateTile(
                          icon: Icons.inventory_2_rounded,
                          title: 'Aucun produit visible',
                          subtitle:
                              'Essaie une autre recherche ou change le filtre pour afficher plus de produits.',
                        )
                      else
                        ...filteredProducts.map((product) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ProductStockTile(
                              product: product,
                              money: store.money,
                              edit: widget.canManage
                                  ? () => widget.openProduct(product)
                                  : null,
                              move: widget.canManage
                                  ? () => widget.openStockMove(product)
                                  : null,
                              preview: () => widget.previewProduct(product),
                              delete: widget.canManage
                                  ? () => widget.deleteProduct(product)
                                  : null,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _ViewportStickyRail(
              width: 360,
              child: rightRail,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    final filteredProducts = store.products.where((product) {
      final matchesQuery = _matchesSearchText(
        '${product.name} ${product.category} ${product.sku} ${product.barcode}',
        productQuery,
      );
      final matchesFilter = switch (productFilter) {
        'Stock bas' => product.quantity <= product.minQuantity,
        'En stock' => product.quantity > 0,
        'Tous' => true,
        _ => product.category == productFilter,
      };
      return matchesQuery && matchesFilter;
    }).toList();
    final filterOptions = <String>[
      'Tous',
      'En stock',
      'Stock bas',
      ...store.categories,
    ];
    final search = TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Rechercher un produit',
      ),
      onChanged: (value) => setState(() => productQuery = value),
    );
    final filter = DropdownButtonFormField<String>(
      initialValue: productFilter,
      decoration: const InputDecoration(labelText: 'Filtrer'),
      items: filterOptions
          .map(
            (entry) => DropdownMenuItem(
              value: entry,
              child: Text(entry),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => productFilter = value ?? 'Tous'),
    );
    final productList = filteredProducts.isEmpty
        ? const _EmptyStateTile(
            icon: Icons.inventory_2_rounded,
            title: 'Aucun produit visible',
            subtitle:
                'Essaie une autre recherche ou change le filtre pour afficher plus de produits.',
          )
        : PagedWidgetList(
            pageSize: desktop ? 6 : 5,
            items: filteredProducts
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProductStockTile(
                      product: product,
                      money: store.money,
                      edit: widget.canManage ? () => widget.openProduct(product) : null,
                      move: widget.canManage ? () => widget.openStockMove(product) : null,
                      preview: () => widget.previewProduct(product),
                      delete: widget.canManage ? () => widget.deleteProduct(product) : null,
                    ),
                  ),
                )
                .toList(),
          );
    final statsPanel = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CompactKpiTile(
                icon: Icons.sell_rounded,
                label: 'Produits',
                value: '${store.products.length}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CompactKpiTile(
                icon: Icons.warning_rounded,
                label: 'Alertes stock',
                value: '${store.lowStock.length}',
              ),
            ),
          ],
        ),
        if (store.activeUser.canSeeGlobalStockInsights) ...[
          const SizedBox(height: 8),
          CompactKpiTile(
            icon: Icons.warehouse_rounded,
            label: 'Valeur stock',
            value: store.money(store.stockValue),
          ),
        ],
      ],
    );
    final categoriesPanel = SectionCard(
      title: 'Categories',
      icon: Icons.category_rounded,
      child: AutoCategoryStrip(categories: store.categories),
    );

    if (!desktop) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _PageHeader(
            title: 'Produits & Stock',
            subtitle: widget.canManage
                ? 'Catalogue, categories et mouvements des stocks.'
                : 'Catalogue produit en lecture seule pour la caisse.',
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 12),
          if (widget.canManage) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.addCategory,
                    icon: const Icon(Icons.category_rounded),
                    label: const Text('Categorie'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.openProduct(null),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Produit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 620;
              if (stacked) {
                return Column(
                  children: [
                    search,
                    const SizedBox(height: 10),
                    filter,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: search),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: filter),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Produits disponibles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          productList,
          const SizedBox(height: 12),
          statsPanel,
          const SizedBox(height: 12),
          categoriesPanel,
        ],
      );
    }

    return _buildDesktopCatalogShell(
      context,
      search: search,
      filter: filter,
      filteredProducts: filteredProducts,
      statsPanel: statsPanel,
      categoriesPanel: categoriesPanel,
      store: store,
    );
  }
}

class CashPage extends StatelessWidget {
  const CashPage({
    super.key,
    required this.store,
    required this.openExpense,
    required this.openSale,
  });

  final AppStore store;
  final VoidCallback openExpense;
  final void Function(Sale sale) openSale;
  static final ValueNotifier<String> searchNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final metrics = store.todayMetrics;
    final cashierView = store.activeUser.isCashier;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    String moneyValue(num value) => store.money(value);
    final sales = store.visibleSales;
    final expenses = store.visibleExpenses;
    final purchases = store.visiblePurchases;
    final rows = [
      ...sales.map(
        (s) => LedgerRow(
          'Vente',
          s.invoiceNo,
          s.lines.map((line) => '${line.product} x${line.qty}').join(', '),
          s.customer.name,
          s.paid,
          s.createdAt,
        ),
      ),
      ...expenses.map(
        (e) => LedgerRow('Depense', e.label, e.label, '-', -e.amount, e.createdAt),
      ),
      ...purchases.map(
        (p) => LedgerRow(
          'Achat',
          p.reference,
          p.product,
          p.supplier,
          -p.paid,
          p.createdAt,
        ),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final header = _PageHeader(
      title: 'Caisse',
      subtitle: cashierView
          ? 'Ta caisse, tes ventes du jour, tes dépenses et ton journal personnel.'
          : 'Trésorerie, dépenses, bénéfice et journal detaille.',
      icon: Icons.account_balance_wallet_rounded,
      action: FilledButton.icon(
        onPressed: openExpense,
        icon: const Icon(Icons.remove_circle_outline_rounded),
        label: const Text('Depense'),
      ),
    );
    final metricsGrid = _CashMetricsGrid(
      children: [
        CompactKpiTile(
          icon: Icons.point_of_sale_rounded,
          label: 'Ventes',
          value: moneyValue(metrics.revenue),
        ),
        CompactKpiTile(
          icon: cashierView ? Icons.receipt_long_rounded : Icons.trending_up_rounded,
          label: cashierView ? 'Tickets jour' : 'Bénéfice',
          value: cashierView ? '${metrics.salesCount}' : moneyValue(metrics.profit),
        ),
        CompactKpiTile(
          icon: Icons.payments_rounded,
          label: 'Caisse',
          value: moneyValue(metrics.cash),
        ),
        CompactKpiTile(
          icon: Icons.receipt_rounded,
          label: 'Dépenses',
          value: moneyValue(metrics.expenses),
        ),
      ],
    );
    final searchField = TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Rechercher un produit ou une facture',
      ),
      onChanged: (value) => searchNotifier.value = value,
    );
    final journal = SectionCard(
      title: 'Journal',
      icon: Icons.list_alt_rounded,
      action: const _TapHintBadge(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _softAccentStrong(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: searchNotifier,
          builder: (context, query, _) => CashJournalPanel(
            store: store,
            rows: rows,
            sales: sales,
            money: store.money,
            openSale: openSale,
            query: query,
          ),
        ),
      ),
    );
    if (!desktop) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          header,
          const SizedBox(height: 12),
          metricsGrid,
          const SizedBox(height: 14),
          searchField,
          const SizedBox(height: 12),
          journal,
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        header,
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  metricsGrid,
                  const SizedBox(height: 14),
                  SectionCard(
                    title: 'Recherche rapide',
                    icon: Icons.manage_search_rounded,
                    child: searchField,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 12,
              child: journal,
            ),
          ],
        ),
      ],
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.store,
    required this.selectedModule,
    required this.onModule,
    required this.closeModule,
    required this.openTab,
    required this.onChanged,
    required this.openCustomer,
    required this.openSupplier,
    required this.openPurchase,
    required this.openSettings,
    required this.openUser,
    required this.openReceipt,
    required this.onAlertTap,
    required this.onReadAllAlerts,
    required this.onSync,
    required this.syncing,
  });

  final AppStore store;
  final int selectedModule;
  final ValueChanged<int> onModule;
  final VoidCallback closeModule;
  final ValueChanged<int> openTab;
  final VoidCallback onChanged;
  final VoidCallback openCustomer;
  final VoidCallback openSupplier;
  final VoidCallback openPurchase;
  final VoidCallback openSettings;
  final VoidCallback openUser;
  final void Function(Sale sale) openReceipt;
  final ValueChanged<AppAlert> onAlertTap;
  final VoidCallback onReadAllAlerts;
  final Future<void> Function() onSync;
  final bool syncing;

  List<ModuleSpec> get _modules => const [
    ModuleSpec('Vente', 'Ouvrir la caisse de vente', Icons.point_of_sale_rounded),
    ModuleSpec('Factures', 'Liste, ticket et PDF', Icons.description_rounded),
    ModuleSpec('Clients', 'Ajouter, modifier, supprimer', Icons.people_alt_rounded),
    ModuleSpec(
      'Fournisseurs',
      'Achats et contacts',
      Icons.local_shipping_rounded,
    ),
    ModuleSpec('Achats', 'Approvisionnement et paiements', Icons.move_to_inbox_rounded),
    ModuleSpec(
      'Notifications',
      'Alertes stock et suivi administratif',
      Icons.notifications_active_rounded,
    ),
    ModuleSpec('Rapports', 'Courbe et details complets', Icons.bar_chart_rounded),
    ModuleSpec('Comptabilite', 'Grand livre et synthese', Icons.account_balance_rounded),
    ModuleSpec('Paramètres', 'Entreprise, fiscal et légal', Icons.settings_rounded),
    ModuleSpec(
      'Utilisateurs',
      'Rôles et accès',
      Icons.admin_panel_settings_rounded,
    ),
    ModuleSpec('Journal', 'Flux ventes, achats et stock', Icons.menu_book_rounded),
    ModuleSpec(
      'Crédits',
      'Dettes clients et validations',
      Icons.credit_score_rounded,
    ),
  ];

  bool _canAccessModule(int index) {
    final user = store.activeUser;
    return switch (index) {
      0 => true,
      1 => true,
      2 => user.canAccessCustomers,
      3 => user.canAccessSuppliers,
      4 => user.canAccessPurchases,
      5 => user.canSeeNotifications,
      6 => user.canAccessReports,
      7 => user.canAccessAccounting,
      8 => user.canManageSettings,
      9 => user.canAccessUsersModule,
      10 => true,
      11 => user.canAccessCredits,
      _ => false,
    };
  }

  List<int> get _visibleModuleIndexes =>
      List<int>.generate(_modules.length, (index) => index);

  @override
  Widget build(BuildContext context) {
    if (selectedModule >= 0 &&
        selectedModule < _modules.length &&
        _canAccessModule(selectedModule)) {
      return _buildModulePage(context, selectedModule);
    }
    return _buildOverview(context);
  }

  Widget _buildOverview(BuildContext context) {
    final visibleSales = store.visibleSales;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    final modulesGrid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _visibleModuleIndexes.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: desktop ? 260 : 220,
        mainAxisExtent: desktop ? 118 : 108,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => ModuleCard(
        spec: _modules[_visibleModuleIndexes[index]],
        selected: false,
        onTap: () => _openModule(context, _visibleModuleIndexes[index]),
      ),
    );
    final quickAccess = SectionCard(
      title: 'Acces rapide',
      icon: Icons.flash_on_rounded,
      child: Column(
        children: [
          _OverviewQuickTile(
            icon: Icons.point_of_sale_rounded,
            title: 'Vendre maintenant',
            subtitle: 'Ouvre directement la page de vente.',
            onTap: () => openTab(1),
          ),
          const SizedBox(height: 10),
          _OverviewQuickTile(
            icon: Icons.description_rounded,
            title: 'Derniere facture',
            subtitle: visibleSales.isEmpty
                ? 'Aucune facture pour le moment.'
                : '${visibleSales.last.invoiceNo} - ${store.money(visibleSales.last.total)}',
            onTap: visibleSales.isEmpty
                ? null
                : () => _showInvoicePreview(context, visibleSales.last),
          ),
          const SizedBox(height: 10),
          _OverviewQuickTile(
            icon: store.activeUser.canSeeNotifications
                ? Icons.notifications_active_rounded
                : Icons.menu_book_rounded,
            title: store.activeUser.canSeeNotifications
                ? 'Notifications en attente'
                : 'Mon journal',
            subtitle: store.activeUser.canSeeNotifications
                ? '${store.unreadAlerts} notification(s) a lire'
                : 'Voir mes ventes, tickets et mouvements recents.',
            onTap: () => onModule(store.activeUser.canSeeNotifications ? 5 : 10),
          ),
        ],
      ),
    );
    if (!desktop) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const _PageHeader(
            title: 'Gestion complete',
            subtitle: 'Chaque module ouvre maintenant sa propre page de travail.',
            icon: Icons.apps_rounded,
          ),
          const SizedBox(height: 12),
          modulesGrid,
          const SizedBox(height: 14),
          _SyncActionCard(
            syncing: syncing,
            pendingChanges: store.pendingSyncChanges,
            lastSyncAt: store.lastSyncAt,
            pendingActivation: store.pendingCloudActivation != null,
            onTap: onSync,
          ),
          const SizedBox(height: 14),
          quickAccess,
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _PageHeader(
          title: 'Gestion complete',
          subtitle: 'Chaque module ouvre maintenant sa propre page de travail.',
          icon: Icons.apps_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 12,
              child: SectionCard(
                title: 'Modules',
                icon: Icons.widgets_rounded,
                child: modulesGrid,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  _SyncActionCard(
                    syncing: syncing,
                    pendingChanges: store.pendingSyncChanges,
                    lastSyncAt: store.lastSyncAt,
                    pendingActivation: store.pendingCloudActivation != null,
                    onTap: onSync,
                  ),
                  const SizedBox(height: 14),
                  quickAccess,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openModule(BuildContext context, int index) {
    if (!_canAccessModule(index)) {
      _showInfo(
        context,
        'Acces refuse',
        'Vous n etes pas autorise a acceder a cette fonction avec ce compte.',
      );
      return;
    }
    if (index == 0) {
      openTab(1);
      return;
    }
    onModule(index);
  }

  Widget _buildModulePage(BuildContext context, int index) {
    final spec = _modules[index];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        ManagementModuleHeader(
          title: spec.title,
          subtitle: spec.subtitle,
          icon: spec.icon,
          action: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_moduleAction(context, index) case final action?) action,
              OutlinedButton.icon(
                onPressed: closeModule,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _moduleContent(context, index),
      ],
    );
  }

  Widget? _moduleAction(BuildContext context, int index) {
    if (index == 2) {
      return FilledButton.icon(
        onPressed: () => _openCustomerEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Client'),
      );
    }
    if (index == 3) {
      return FilledButton.icon(
        onPressed: () => _openSupplierEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Fournisseur'),
      );
    }
    if (index == 4) {
      return FilledButton.icon(
        onPressed: openPurchase,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Achat'),
      );
    }
    if (index == 5) {
      return FilledButton.tonalIcon(
        onPressed: onReadAllAlerts,
        icon: const Icon(Icons.done_all_rounded),
        label: const Text('Tout lire'),
      );
    }
    if (index == 8) {
      return FilledButton.tonalIcon(
        onPressed: openSettings,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Modifier'),
      );
    }
    if (index == 9) {
      if (!store.activeUser.canManageUsers) return null;
      return FilledButton.icon(
        onPressed: () => _openUserEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Utilisateur'),
      );
    }
    return null;
  }

  Widget _moduleContent(BuildContext context, int index) {
    switch (index) {
      case 1:
        return _buildInvoicesPage(context);
      case 2:
        return _buildCustomersPage(context);
      case 3:
        return _buildSuppliersPage(context);
      case 4:
        return _buildPurchasesPage(context);
      case 5:
        return _buildAlertsPage();
      case 6:
        return _buildReportsPage(context);
      case 7:
        return _buildAccountingPage(context);
      case 8:
        return _buildSettingsPage(context);
      case 9:
        return _buildUsersPage(context);
      case 10:
        return _buildJournalPage(context);
      case 11:
        return _buildCreditsPage(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInvoicesPage(BuildContext context) {
    final sales = store.visibleSales;
    final paidCount = sales.where((sale) => sale.due <= 0).length;
    final creditCount = sales.where((sale) => sale.due > 0).length;
    final totalRevenue = sales.fold<num>(0, (sum, sale) => sum + sale.total);
    return Column(
      children: [
        _CashMetricsGrid(
          children: [
            CompactKpiTile(
              icon: Icons.receipt_long_rounded,
              label: 'Facture',
              value: '${sales.length}',
            ),
            CompactKpiTile(
              icon: Icons.verified_rounded,
              label: 'Payée',
              value: '$paidCount',
            ),
            CompactKpiTile(
              icon: Icons.credit_score_rounded,
              label: 'Credit',
              value: '$creditCount',
            ),
            CompactKpiTile(
              icon: Icons.payments_rounded,
              label: 'Montant',
              value: store.money(totalRevenue),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Liste des factures',
          icon: Icons.description_rounded,
          child: sales.isEmpty
              ? const _EmptyStateTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Aucune facture',
                  subtitle: 'Les factures apparaîtront ici après les ventes.',
                )
              : PagedWidgetList(
                  items: sales
                      .map(
                        (sale) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InvoiceTile(
                            sale: sale,
                            money: store.money,
                            onTap: () => _showInvoicePreview(context, sale),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCustomersPage(BuildContext context) {
    return SectionCard(
      title: 'Liste des clients',
      icon: Icons.people_alt_rounded,
          child: Column(
            children: [
              _CashMetricsGrid(
                children: [
                  CompactKpiTile(
                    icon: Icons.people_alt_rounded,
                    label: 'Clients',
                    value: '${store.customers.length}',
                  ),
                  CompactKpiTile(
                    icon: Icons.credit_card_rounded,
                    label: 'Crédits',
                    value: store.money(store.customerDebt),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          PagedWidgetList(
            items: store.customers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ManagePartyTile(
                  icon: Icons.person_rounded,
                  name: entry.value.name,
                  code: entry.value.code,
                  subtitle: _customerSubtitle(entry.value),
                  whatsappNumber: entry.value.phone,
                  onWhatsApp: entry.value.phone.trim().isEmpty
                      ? null
                      : () => openExternalUrl(_whatsAppUrl(entry.value.phone)),
                  onEdit: store.canEditCustomer(entry.value)
                      ? () => _openCustomerEditor(
                            context,
                            customer: entry.value,
                            index: entry.key,
                          )
                      : null,
                  onDelete: store.canDeleteCustomer(entry.value)
                      ? () => _deleteCustomer(context, entry.key, entry.value)
                      : null,
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersPage(BuildContext context) {
    final purchases = store.visiblePurchases;
    return SectionCard(
      title: 'Liste des fournisseurs',
      icon: Icons.local_shipping_rounded,
          child: Column(
        children: [
          _CashMetricsGrid(
            children: [
              CompactKpiTile(
                icon: Icons.local_shipping_rounded,
                label: 'Fournisseurs',
                value: '${store.suppliers.length}',
              ),
              CompactKpiTile(
                icon: Icons.shopping_bag_rounded,
                label: 'Achats',
                value: '${purchases.length}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          PagedWidgetList(
            items: store.suppliers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ManagePartyTile(
                  icon: Icons.local_shipping_rounded,
                  name: entry.value.name,
                  code: entry.value.code,
                  subtitle: entry.value.phone.isEmpty
                      ? entry.value.address
                      : '${entry.value.phone} - ${entry.value.address}',
                  whatsappNumber: entry.value.phone,
                  onWhatsApp: entry.value.phone.trim().isEmpty
                      ? null
                      : () => openExternalUrl(_whatsAppUrl(entry.value.phone)),
                  onEdit: () => _openSupplierEditor(
                    context,
                    supplier: entry.value,
                    index: entry.key,
                  ),
                  onDelete: () => _deleteSupplier(context, entry.key, entry.value),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesPage(BuildContext context) {
    final purchases = store.visiblePurchases;
    final paid = purchases.fold<num>(0, (sum, purchase) => sum + purchase.paid);
    final total = purchases.fold<num>(0, (sum, purchase) => sum + purchase.total);
    return Column(
      children: [
        _CashMetricsGrid(
          children: [
            CompactKpiTile(
              icon: Icons.move_to_inbox_rounded,
              label: 'Achats',
              value: '${purchases.length}',
            ),
            CompactKpiTile(
              icon: Icons.payments_rounded,
              label: 'Montant total',
              value: store.money(total),
            ),
            CompactKpiTile(
              icon: Icons.done_rounded,
              label: 'Montant paye',
              value: store.money(paid),
            ),
            CompactKpiTile(
              icon: Icons.schedule_rounded,
              label: 'Reste a payer',
              value: store.money((total - paid).clamp(0, double.infinity)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Journal des achats',
          icon: Icons.inventory_2_rounded,
          child: purchases.isEmpty
              ? const _EmptyStateTile(
                  icon: Icons.move_to_inbox_rounded,
                  title: 'Aucun achat',
                  subtitle: 'Ajoute un achat pour suivre les approvisionnements.',
                )
              : PagedWidgetList(
                  items: purchases
                      .map(
                        (purchase) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PurchaseTile(
                            purchase: purchase,
                            money: store.money,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildAlertsPage() {
    final alerts = store.smartAlerts;
    return Column(
      children: [
        AlertStatusStrip(
          unreadCount: store.unreadAlerts,
          lowStockCount: store.activeUser.canSeeGlobalStockInsights
              ? store.lowStock.length
              : 0,
          creditAmount: store.money(store.customerDebt),
          alertCount: alerts.length,
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Notifications',
          icon: Icons.notifications_rounded,
          child: PagedWidgetList(
            items: alerts
                .map(
                  (alert) => AlertTile(
                    alert: alert,
                    onTap: () {
                      onAlertTap(alert);
                      onChanged();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsPage(BuildContext context) {
    final metrics = store.todayMetrics;
    final sales = store.visibleSales;
    final cashierView = store.activeUser.isCashier;
    final bestSeller = store.products.fold<Product?>(
      null,
      (best, product) {
        final sold = sales
            .expand((sale) => sale.lines)
            .where((line) => line.product == product.name)
            .fold<num>(0, (sum, line) => sum + line.qty);
        if (best == null) return product;
        final bestSold = sales
            .expand((sale) => sale.lines)
            .where((line) => line.product == best.name)
            .fold<num>(0, (sum, line) => sum + line.qty);
        return sold > bestSold ? product : best;
      },
    );

    return Column(
      children: [
        TradingChartCard(store: store),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Rapports complets',
          icon: Icons.analytics_rounded,
          child: Column(
            children: [
              _ReportDetailTile(
                title: 'Performance du jour',
                subtitle:
                    '${metrics.salesCount} vente(s), ${store.money(metrics.revenue)} encaisses.',
                onTap: () => _showReportDetail(
                  context,
                  title: 'Performance du jour',
                  lines: cashierView
                      ? [
                          'Revenu du jour: ${store.money(metrics.revenue)}',
                          'Caisse de là journée: ${store.money(metrics.cash)}',
                          'Dépenses de là journée: ${store.money(metrics.expenses)}',
                          'Ventes de là journée: ${metrics.salesCount}',
                        ]
                      : [
                          'Revenu du jour: ${store.money(metrics.revenue)}',
                          'Bénéfice estime: ${store.money(metrics.profit)}',
                          'Caisse nette: ${store.money(metrics.cash)}',
                          'Dépenses du jour: ${store.money(metrics.expenses)}',
                        ],
                ),
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                title: 'Meilleur produit',
                subtitle: bestSeller == null
                    ? 'Aucun produit vendu pour le moment.'
                    : '${bestSeller.name} - ${store.money(bestSeller.price)}',
                onTap: () => _showReportDetail(
                  context,
                  title: 'Produit le plus vendu',
                  lines: bestSeller == null
                      ? const ['Aucune vente encore enregistree.']
                      : [
                          'Produit: ${bestSeller.name}',
                          'Categorie: ${bestSeller.category}',
                          'Prix vente: ${store.money(bestSeller.price)}',
                          'Stock actuel: ${bestSeller.quantityText}',
                        ],
                ),
              ),
              const SizedBox(height: 8),
              _ReportDetailTile(
                title: 'Crédits clients',
                subtitle: 'Montant en attente: ${store.money(store.customerDebt)}',
                onTap: () => _showReportDetail(
                  context,
                  title: 'Crédits clients',
                  lines: sales.where((sale) => sale.due > 0).isEmpty
                      ? const ['Aucun crédit client en attente.']
                      : sales
                          .where((sale) => sale.due > 0)
                          .map(
                            (sale) =>
                                '${sale.customer.name} - ${sale.invoiceNo} - ${store.money(sale.due)}',
                          )
                          .toList(),
                ),
              ),
              if (!cashierView) ...[
                const SizedBox(height: 8),
                _ReportDetailTile(
                  title: 'Valeur du stock',
                  subtitle: 'Valeur actuelle: ${store.money(store.stockValue)}',
                  onTap: () => _showReportDetail(
                    context,
                    title: 'Valeur du stock',
                    lines: store.products
                        .map(
                          (product) =>
                              '${product.name}: ${product.quantity.round()} x ${store.money(product.cost)}',
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountingPage(BuildContext context) {
    final cashierView = store.activeUser.isCashier;
    final ledgerRows = _ledgerRows();
    final totalEntries = ledgerRows
        .where((row) => row.amount > 0)
        .fold<num>(0, (sum, row) => sum + row.amount);
    final totalExits = ledgerRows
        .where((row) => row.amount < 0)
        .fold<num>(0, (sum, row) => sum + row.amount.abs());
    final net = totalEntries - totalExits;
    final visibleGrossProfit = store.visibleSales.fold<num>(
      0,
      (sum, sale) =>
          sum +
          sale.lines.fold<num>(
            0,
            (inner, line) => inner + (line.price - line.cost) * line.qty,
          ),
    );

    return Column(
      children: [
        _ResponsiveGrid(
          children: [
            KpiTile(
              icon: Icons.arrow_downward_rounded,
              label: 'Entrées',
              value: store.money(totalEntries),
            ),
            KpiTile(
              icon: Icons.arrow_upward_rounded,
              label: 'Sorties',
              value: store.money(totalExits),
            ),
            KpiTile(
              icon: cashierView
                  ? Icons.account_balance_wallet_rounded
                  : Icons.calculate_rounded,
              label: cashierView ? 'Solde caisse' : 'Resultat net',
              value: store.money(net),
            ),
            KpiTile(
              icon: cashierView
                  ? Icons.credit_score_rounded
                  : Icons.trending_up_rounded,
              label: cashierView ? 'Crédits' : 'Marge brute',
              value: store.money(
                cashierView ? store.customerDebt : visibleGrossProfit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TradingChartCard(store: store),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Synthese comptable',
          icon: Icons.account_balance_wallet_rounded,
          child: Column(
            children: [
              _AccountingLine(
                label: 'Ventes encaissees',
                value: store.money(
                  store.visibleSales.fold<num>(0, (sum, sale) => sum + sale.paid),
                ),
              ),
              _AccountingLine(
                label: 'Crédits clients',
                value: store.money(store.customerDebt),
              ),
              if (!cashierView)
                _AccountingLine(
                  label: 'Dettes fournisseurs',
                  value: store.money(store.supplierDebt),
                ),
              _AccountingLine(
                label: 'Achats payes',
                value: store.money(
                  store.visiblePurchases.fold<num>(
                    0,
                    (sum, purchase) => sum + purchase.paid,
                  ),
                ),
              ),
              _AccountingLine(
                label: 'Dépenses',
                value: store.money(
                  store.visibleExpenses.fold<num>(
                    0,
                    (sum, expense) => sum + expense.amount,
                  ),
                ),
              ),
              if (!cashierView)
                _AccountingLine(
                  label: 'Valeur actuelle du stock',
                  value: store.money(store.stockValue),
                  emphasize: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Grand livre simplifié',
          icon: Icons.table_rows_rounded,
          child: JournalLedgerTable(
            rows: ledgerRows,
            money: store.money,
            showFilter: true,
            showSwipeHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    final s = store.settings;
    final cloudSession = store.cloudSession;
    return Column(
      children: [
        SectionCard(
          title: 'Identite entreprise',
          icon: Icons.store_rounded,
          child: Column(
            children: [
              ListTile(
                leading: CompanyLogoBadge(settings: s),
                title: Text(
                  s.companyName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(s.ownerName),
              ),
              const Divider(height: 18),
              ListTile(
                leading: const Icon(Icons.phone_rounded, color: _green),
                title: const Text('Contacts'),
                subtitle: Text(
                  '${s.phone}\n${s.email.isEmpty ? '-' : s.email}\n${s.address}',
                ),
                isThreeLine: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Legal et fiscal',
          icon: Icons.badge_rounded,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.approval_rounded, color: _green),
                title: const Text('RCCM'),
                subtitle: Text(s.rccm.isEmpty ? '-' : s.rccm),
              ),
              ListTile(
                leading: const Icon(Icons.perm_identity_rounded, color: _green),
                title: const Text('ID NAT'),
                subtitle: Text(s.idNat.isEmpty ? '-' : s.idNat),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_rounded, color: _green),
                title: const Text('NIF / Impot'),
                subtitle: Text(s.nif.isEmpty ? '-' : s.nif),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_rounded, color: _green),
                title: const Text('EFO'),
                subtitle: Text(s.efo.isEmpty ? '-' : s.efo),
              ),
              ListTile(
                leading: const Icon(Icons.payments_rounded, color: _green),
                title: const Text('Devise et taxe'),
                subtitle: Text('${s.currency} - Taxe ${s.taxRate}%'),
              ),
            ],
          ),
        ),
        if (cloudSession != null) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: 'Connexion cloud',
            icon: Icons.cloud_done_rounded,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.key_rounded, color: _green),
                  title: const Text('Clé entreprise'),
                  subtitle: Text(cloudSession.tenantKey),
                  trailing: IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: cloudSession.tenantKey),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clé entreprise copiée.')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'Copier la clé',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.devices_rounded, color: _green),
                  title: const Text('Appareil relié'),
                  subtitle: Text(cloudSession.deviceLabel),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUsersPage(BuildContext context) {
    final adminCount = store.users.where((user) => user.role == 'Admin').length;
    final canManageUsers = store.activeUser.canManageUsers;
    return Column(
      children: [
        _ResponsiveGrid(
          children: [
            KpiTile(
              icon: Icons.group_rounded,
              label: 'Utilisateurs',
              value: '${store.users.length}',
            ),
            KpiTile(
              icon: Icons.admin_panel_settings_rounded,
              label: 'Admins',
              value: '$adminCount',
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Acces et roles',
          icon: Icons.manage_accounts_rounded,
          child: PagedWidgetList(
            items: store.users.asMap().entries.map((entry) {
              final user = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: UserManagementTile(
                  user: user,
                  onInspect: () => _showUserActivityOverview(context, user),
                  onEdit: canManageUsers
                      ? () => _openUserEditor(
                            context,
                            user: user,
                            index: entry.key,
                          )
                      : null,
                  onToggleBlock: canManageUsers
                      ? () {
                          if (user.code == store.activeUser.code) {
                            _showInfo(
                              context,
                              'Compte actif',
                              'Tu ne peux pas bloquer le compte actuellement connecté.',
                            );
                            return;
                          }
                          if (user.isAdmin &&
                              !user.isBlocked &&
                              adminCount <= 1) {
                            _showInfo(
                              context,
                              'Dernier administrateur',
                              'Garde au moins un administrateur actif pour administrer les accès.',
                            );
                            return;
                          }
                          store.users[entry.key].isBlocked =
                              !store.users[entry.key].isBlocked;
                          store.enqueueSyncOperation(
                            entityName: 'user',
                            entityId: store.users[entry.key].code,
                            operationName: 'update',
                            payload: store.userSyncPayload(store.users[entry.key]),
                          );
                          onChanged();
                        }
                      : null,
                  onDelete: canManageUsers
                      ? () => _deleteUser(context, entry.key, user)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJournalPage(BuildContext context) {
    final rows = _ledgerRows();

    return Column(
      children: [
        _ResponsiveGrid(
          children: [
            KpiTile(
              icon: Icons.menu_book_rounded,
              label: 'Ecritures',
              value: '${rows.length}',
            ),
            KpiTile(
              icon: Icons.sync_alt_rounded,
              label: 'Mouvements stock',
              value: '${store.visibleStockMoves.length}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Journal detaille',
          icon: Icons.receipt_long_rounded,
          child: rows.isEmpty
              ? const _EmptyStateTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Journal vide',
                  subtitle: 'Les ventes, achats et dépenses apparaîtront ici.',
                )
              : JournalLedgerTable(
                  rows: rows,
                  money: store.money,
                  onRowTap: (row) => _showJournalDetail(context, row),
                  showFilter: true,
                  showSwipeHint: true,
                ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Historique des stocks',
          icon: Icons.inventory_rounded,
          child: PagedWidgetList(
            items: store.visibleStockMoves.reversed.take(50).map(
              (move) {
                final positive = move.quantity >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: _softPanelColor(context),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _panelColor(context),
                        child: Icon(
                          positive
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: positive ? _green : _danger,
                        ),
                      ),
                      title: Text(
                        '${move.product} - ${move.type}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${move.reference} - ${_formatDate(move.createdAt)}'),
                      trailing: Text(
                        '${move.quantity > 0 ? '+' : ''}${move.quantity.round()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: positive ? _green : _danger,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsPage(BuildContext context) {
    final creditSales = store.visibleSales
        .where((sale) => sale.due > 0)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return Column(
      children: [
        _ResponsiveGrid(
          children: [
            KpiTile(
              icon: Icons.credit_score_rounded,
              label: 'Dettes en cours',
              value: '${creditSales.length}',
            ),
            KpiTile(
              icon: Icons.payments_rounded,
              label: 'Montant a recuperer',
              value: store.money(
                creditSales.fold<num>(0, (sum, sale) => sum + sale.due),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Crédits clients (Dettes)',
          icon: Icons.credit_score_rounded,
          child: creditSales.isEmpty
              ? const _EmptyStateTile(
                  icon: Icons.verified_rounded,
                  title: 'Aucune dette en attente',
                  subtitle: 'Les ventes à crédit apparaîtront ici jusqu’à leur règlement.',
                )
              : PagedWidgetList(
                  items: creditSales
                      .map(
                        (sale) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CreditSaleTile(
                            sale: sale,
                            money: store.money,
                            canSettle:
                                store.activeUser.isAdmin || store.activeUser.isManager,
                            onTap: () => _showInvoicePreview(context, sale),
                            onSettle: () => _confirmSettleCredit(context, sale),
                            onWhatsApp: sale.customer.phone.trim().isEmpty
                                ? null
                                : () => openExternalUrl(
                                    _whatsAppUrl(
                                      sale.customer.phone,
                                      text: store.creditReminderMessage(sale),
                                    ),
                                  ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  List<Sale> _salesForUser(AppUser user) => store.sales
      .where((sale) => sale.cashierCode == user.code)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Purchase> _purchasesForUser(AppUser user) => store.purchases
      .where((purchase) => purchase.authorCode == user.code)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Expense> _expensesForUser(AppUser user) => store.expenses
      .where((expense) => expense.authorCode == user.code)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<StockMove> _stockMovesForUser(AppUser user) {
    final saleRefs = _salesForUser(user).map((sale) => sale.invoiceNo).toSet();
    final purchaseRefs = _purchasesForUser(user)
        .map((purchase) => purchase.reference)
        .toSet();
    return store.stockMoves
        .where(
          (move) =>
              saleRefs.contains(move.reference) ||
              purchaseRefs.contains(move.reference),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TodayMetrics _metricsForUser(AppUser user) {
    final now = DateTime.now();
    bool sameDay(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    final sales = _salesForUser(user).where((sale) => sameDay(sale.createdAt)).toList();
    final expenses = _expensesForUser(user)
        .where((expense) => sameDay(expense.createdAt))
        .fold<num>(0, (sum, expense) => sum + expense.amount);
    final revenue = sales.fold<num>(0, (sum, sale) => sum + sale.total);
    final paid = sales.fold<num>(0, (sum, sale) => sum + sale.paid);
    final cost = sales.fold<num>(
      0,
      (sum, sale) =>
          sum +
          sale.lines.fold<num>(0, (inner, line) => inner + line.cost * line.qty),
    );
    return TodayMetrics(
      salesCount: sales.length,
      revenue: revenue,
      profit: revenue - cost - expenses,
      cash: paid - expenses,
      expenses: expenses,
    );
  }

  List<LedgerRow> _ledgerRowsForUser(AppUser user) {
    return [
      ..._salesForUser(user).map(
        (sale) => LedgerRow(
          'Vente',
          sale.invoiceNo,
          sale.lines.map((line) => '${line.product} x${line.qty}').join(', '),
          sale.customer.name,
          sale.paid,
          sale.createdAt,
        ),
      ),
      ..._expensesForUser(user).map(
        (expense) => LedgerRow(
          'Depense',
          expense.label,
          expense.label,
          '-',
          -expense.amount,
          expense.createdAt,
        ),
      ),
      ..._purchasesForUser(user).map(
        (purchase) => LedgerRow(
          'Achat',
          purchase.reference,
          purchase.product,
          purchase.supplier,
          -purchase.paid,
          purchase.createdAt,
        ),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ProductSalesInsight> _productInsightsForUser(AppUser user) {
    final sales = _salesForUser(user);
    final insights = store.products.map((product) {
      num soldQty = 0;
      num soldAmount = 0;
      num soldProfit = 0;
      for (final sale in sales) {
        for (final line in sale.lines.where((line) => line.product == product.name)) {
          soldQty += line.qty;
          soldAmount += line.qty * line.price;
          soldProfit += line.qty * (line.price - line.cost);
        }
      }
      return ProductSalesInsight(
        product: product,
        soldQty: soldQty,
        soldAmount: soldAmount,
        soldProfit: soldProfit,
        stockAmount: product.quantity * product.price,
        remainingProfit: product.quantity * (product.price - product.cost),
        totalPotential: (soldQty + product.quantity) * product.price,
        totalProfitPotential:
            (soldQty + product.quantity) * (product.price - product.cost),
      );
    }).where((insight) => insight.soldQty > 0).toList()
      ..sort((a, b) => b.soldAmount.compareTo(a.soldAmount));
    return insights;
  }

  void _showUserActivityOverview(BuildContext context, AppUser user) {
    final metrics = _metricsForUser(user);
    final sales = _salesForUser(user);
    final purchases = _purchasesForUser(user);
    final expenses = _expensesForUser(user);
    final stockMoves = _stockMovesForUser(user);
    final ledgerRows = _ledgerRowsForUser(user);
    final productInsights = _productInsightsForUser(user);
    final creditSales = sales.where((sale) => sale.due > 0).toList()
      ..sort((a, b) => b.due.compareTo(a.due));
    final creditTotal = sales.fold<num>(0, (sum, sale) => sum + sale.due);
    final totalGenerated = sales.fold<num>(0, (sum, sale) => sum + sale.total);
    final totalCollected = sales.fold<num>(0, (sum, sale) => sum + sale.paid);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: 'Activite de ${user.name}',
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Profil du compte',
                  icon: Icons.badge_rounded,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _softAccentColor(context),
                      child: Icon(
                        user.isAdmin
                            ? Icons.workspace_premium_rounded
                            : user.isManager
                            ? Icons.manage_accounts_rounded
                            : Icons.point_of_sale_rounded,
                        color: _green,
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('@${user.username} - ${user.role} - ${user.code}'),
                  ),
                ),
                const SizedBox(height: 12),
                _ResponsiveGrid(
                  children: [
                    KpiTile(
                      icon: Icons.sell_rounded,
                      label: 'Montant génère',
                      value: store.money(totalGenerated),
                    ),
                    KpiTile(
                      icon: Icons.payments_rounded,
                      label: 'Montant encaisse',
                      value: store.money(totalCollected),
                    ),
                    KpiTile(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Caisse du jour',
                      value: store.money(metrics.cash),
                    ),
                    KpiTile(
                      icon: Icons.credit_score_rounded,
                      label: 'Crédits',
                      value: store.money(creditTotal),
                    ),
                    KpiTile(
                      icon: Icons.receipt_long_rounded,
                      label: 'Ventes',
                      value: '${sales.length}',
                    ),
                    KpiTile(
                      icon: Icons.sync_alt_rounded,
                      label: 'Operations',
                      value: '${ledgerRows.length + stockMoves.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Dernieres ventes',
                  icon: Icons.point_of_sale_rounded,
                  child: sales.isEmpty
                      ? const _EmptyStateTile(
                          icon: Icons.receipt_long_rounded,
                          title: 'Aucune vente',
                          subtitle: 'Les ventes de ce compte apparaîtront ici.',
                        )
                      : PagedWidgetList(
                          items: sales.take(20).map(
                            (sale) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InvoiceTile(
                                sale: sale,
                                money: store.money,
                                onTap: () => _showInvoicePreview(context, sale),
                              ),
                            ),
                          ).toList(),
                        ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Journal de ce compte',
                  icon: Icons.menu_book_rounded,
                  child: ledgerRows.isEmpty
                      ? const _EmptyStateTile(
                          icon: Icons.menu_book_rounded,
                          title: 'Aucune operation',
                          subtitle: 'Les achats, ventes et dépenses de ce compte apparaîtront ici.',
                        )
                      : JournalLedgerTable(
                          rows: ledgerRows,
                          money: store.money,
                          showFilter: true,
                          showSwipeHint: true,
                          onRowTap: (row) => _showJournalDetail(context, row),
                        ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Produits lies a ce compte',
                  icon: Icons.inventory_2_rounded,
                  child: productInsights.isEmpty
                      ? const _EmptyStateTile(
                          icon: Icons.inventory_2_rounded,
                          title: 'Aucun produit',
                          subtitle: 'Les produits vendus par ce compte apparaîtront ici.',
                        )
                      : Column(
                          children: productInsights.take(8).map(
                            (insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ProductSalesInsightCard(
                                insight: insight,
                                money: store.money,
                              ),
                            ),
                          ).toList(),
                        ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Crédits de ce compte',
                  icon: Icons.credit_score_rounded,
                  child: creditSales.isEmpty
                      ? const _EmptyStateTile(
                          icon: Icons.verified_rounded,
                          title: 'Aucun crédit',
                          subtitle: 'Les ventes à crédit de ce compte apparaîtront ici.',
                        )
                      : PagedWidgetList(
                          items: creditSales.take(20).map(
                            (sale) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: CreditSaleTile(
                                sale: sale,
                                money: store.money,
                                canSettle: store.activeUser.isAdmin || store.activeUser.isManager,
                                onTap: () => _showInvoicePreview(context, sale),
                                onSettle: () => _confirmSettleCredit(context, sale),
                              ),
                            ),
                          ).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSettleCredit(BuildContext context, Sale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Valider le paiement'),
        content: Text(
          'Es-tu sur que la dette ${sale.invoiceNo} de ${sale.customer.name} a ete payee ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final settled = store.settleSaleCredit(
      sale,
      actor: store.activeUser,
    );
    if (settled <= 0) return;
    onChanged();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dette reglee pour ${sale.customer.name} - ${store.money(settled)} encaisses.',
        ),
      ),
    );
  }

  List<LedgerRow> _ledgerRows() {
    return [
      ...store.visibleSales.map(
        (sale) => LedgerRow(
          'Vente',
          sale.invoiceNo,
          sale.lines.map((line) => '${line.product} x${line.qty}').join(', '),
          sale.customer.name,
          sale.paid,
          sale.createdAt,
        ),
      ),
      ...store.visibleExpenses.map(
        (expense) => LedgerRow(
          'Depense',
          expense.label,
          expense.label,
          '-',
          -expense.amount,
          expense.createdAt,
        ),
      ),
      ...store.visiblePurchases.map(
        (purchase) => LedgerRow(
          'Achat',
          purchase.reference,
          purchase.product,
          purchase.supplier,
          -purchase.paid,
          purchase.createdAt,
        ),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _showInvoicePreview(BuildContext context, Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: DocumentPreviewSheet(
            store: store,
            sale: sale,
            initialMode: DocumentPreviewMode.invoice,
            onClose: () => Navigator.pop(sheetContext),
            onPrintTicket: () => printPdfBytes(
              'Ticket ${sale.ticketNo}',
              _buildTicketPdfBytes(sale),
            ),
            onPrintInvoice: () async => printPdfBytes(
              'Facture ${sale.invoiceNo}',
              await _buildInvoicePdfBytes(sale),
            ),
            onExportInvoicePdf: () async => downloadBytes(
              '${sale.invoiceNo}.pdf',
              await _buildInvoicePdfBytes(sale),
              'application/pdf',
            ),
            onSettleCredit:
                (store.activeUser.isAdmin || store.activeUser.isManager) && sale.isCredit
                ? () => _confirmSettleCredit(sheetContext, sale)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _openCustomerEditor(
    BuildContext context, {
    Customer? customer,
    int? index,
  }) async {
    if (customer != null && !store.canEditCustomer(customer)) {
      _showInfo(
        context,
        'Client protégé',
        'Ce client a été créé ou modifié par un autre compte autorisé. Le caissier ne peut modifier que ses propres clients.',
      );
      return;
    }
    final name = TextEditingController(text: customer?.name ?? '');
    final phone = TextEditingController(text: customer?.phone ?? '');
    final address = TextEditingController(text: customer?.address ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: customer == null ? 'Nouveau client' : 'Modifier client',
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 12),
                _AppField(label: 'Nom', controller: name),
                const SizedBox(height: 10),
                _AppField(label: 'Numero WhatsApp', controller: phone),
                const SizedBox(height: 10),
                _AppField(label: 'Adresse', controller: address),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    if (name.text.trim().isEmpty) return;
                    final next = Customer(
                      code: customer?.code ?? store.codes.nextCustomer(),
                      name: name.text.trim(),
                      phone: phone.text.trim(),
                      address: address.text.trim(),
                      lastEditedByCode: store.activeUser.code,
                      lastEditedByName: store.activeUser.name,
                    );
                    if (index == null) {
                      store.customers.add(next);
                    } else {
                      store.customers[index] = next;
                    }
                    store.enqueueSyncOperation(
                      entityName: 'customer',
                      entityId: next.code,
                      operationName: index == null ? 'create' : 'update',
                      payload: store.customerSyncPayload(next),
                    );
                    onChanged();
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSupplierEditor(
    BuildContext context, {
    Supplier? supplier,
    int? index,
  }) async {
    final name = TextEditingController(text: supplier?.name ?? '');
    final phone = TextEditingController(text: supplier?.phone ?? '');
    final address = TextEditingController(text: supplier?.address ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: supplier == null
                      ? 'Nouveau fournisseur'
                      : 'Modifier fournisseur',
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 12),
                _AppField(label: 'Nom', controller: name),
                const SizedBox(height: 10),
                _AppField(label: 'Numero WhatsApp', controller: phone),
                const SizedBox(height: 10),
                _AppField(label: 'Adresse', controller: address),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    if (name.text.trim().isEmpty) return;
                    final next = Supplier(
                      code: supplier?.code ?? store.codes.nextSupplier(),
                      name: name.text.trim(),
                      phone: phone.text.trim(),
                      address: address.text.trim(),
                    );
                    if (index == null) {
                      store.suppliers.add(next);
                    } else {
                      store.suppliers[index] = next;
                    }
                    store.enqueueSyncOperation(
                      entityName: 'supplier',
                      entityId: next.code,
                      operationName: index == null ? 'create' : 'update',
                      payload: store.supplierSyncPayload(next),
                    );
                    onChanged();
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUserEditor(
    BuildContext context, {
    AppUser? user,
    int? index,
  }) async {
    final name = TextEditingController(text: user?.name ?? '');
    final username = TextEditingController(text: user?.username ?? '');
    final pin = TextEditingController(text: user?.pin ?? '');
    var role = user?.role ?? 'Caissier';
    var blocked = user?.isBlocked ?? false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: user == null ? 'Nouvel utilisateur' : 'Modifier utilisateur',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  _AppField(label: 'Nom', controller: name),
                  const SizedBox(height: 10),
                  _AppField(label: 'Identifiant', controller: username),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'Caissier', child: Text('Caissier')),
                      DropdownMenuItem(
                        value: 'Gestionnaire',
                        child: Text('Gestionnaire'),
                      ),
                    ],
                    onChanged: (value) => setLocal(() => role = value ?? role),
                  ),
                  const SizedBox(height: 10),
                  _AppField(label: 'Code secret', controller: pin, number: true),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: blocked,
                    onChanged: (value) => setLocal(() => blocked = value),
                    title: const Text('Compte bloqué'),
                    subtitle: const Text(
                      'Un compte bloqué ne peut pas se connecter.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      if (name.text.trim().isEmpty || username.text.trim().isEmpty) {
                        return;
                      }
                      final previousPin = user?.pin;
                      final next = AppUser(
                        code: user?.code ?? store.codes.nextUser(),
                        name: name.text.trim(),
                        username: username.text.trim(),
                        role: role,
                        pin: pin.text.trim(),
                        isBlocked: blocked,
                      );
                      if (index == null) {
                        store.users.add(next);
                      } else {
                        store.users[index] = next;
                      }
                      store.enqueueSyncOperation(
                        entityName: 'user',
                        entityId: next.code,
                        operationName: index == null ? 'create' : 'update',
                        payload: store.userSyncPayload(next),
                      );
                      if (user != null &&
                          previousPin != null &&
                          previousPin != next.pin &&
                          store.activeUser.code != next.code) {
                        final resetNotice = AppMessage.system(
                          title: 'Code secret reinitialise',
                          body:
                              'Votre code secret a ete reinitialise par l’administrateur. Utilisez le nouveau code qui vous a ete communique pour vous reconnecter.',
                          id:
                              'reset-${DateTime.now().millisecondsSinceEpoch}-${next.code}',
                          createdAt: DateTime.now(),
                          recipientCode: next.code,
                          recipientName: next.name,
                        );
                        store.messages.add(resetNotice);
                        store.enqueueSyncOperation(
                          entityName: 'message',
                          entityId: resetNotice.id,
                          operationName: 'create',
                          payload: store.messageSyncPayload(resetNotice),
                        );
                      }
                      onChanged();
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, int index, Customer customer) async {
    if (!store.canDeleteCustomer(customer)) {
      _showInfo(
        context,
        'Suppression refusée',
        'Ce client est géré par un autre compte autorisé. Le caissier ne peut supprimer que ses propres clients.',
      );
      return;
    }
    final confirm = await _confirmDelete(
      context,
      title: 'Supprimer client',
      body: 'Supprimer ${customer.name} de la liste clients ?',
    );
    if (confirm != true) return;
    store.enqueueSyncOperation(
      entityName: 'customer',
      entityId: customer.code,
      operationName: 'delete',
      payload: store.customerSyncPayload(customer),
    );
    store.customers.removeAt(index);
    onChanged();
  }

  Future<void> _deleteSupplier(BuildContext context, int index, Supplier supplier) async {
    final confirm = await _confirmDelete(
      context,
      title: 'Supprimer fournisseur',
      body: 'Supprimer ${supplier.name} de la liste fournisseurs ?',
    );
    if (confirm != true) return;
    store.enqueueSyncOperation(
      entityName: 'supplier',
      entityId: supplier.code,
      operationName: 'delete',
      payload: store.supplierSyncPayload(supplier),
    );
    store.suppliers.removeAt(index);
    onChanged();
  }

  Future<void> _deleteUser(BuildContext context, int index, AppUser user) async {
    if (user.code == store.activeUser.code) {
      _showInfo(
        context,
        'Utilisateur actif',
        'Deconnecté ce compte avant de le supprimer.',
      );
      return;
    }
    if (user.isAdmin &&
        store.users.where((entry) => entry.role == 'Admin').length <= 1) {
      _showInfo(
        context,
        'Dernier administrateur',
        'Ajoute un autre administrateur avant de supprimer ce compte.',
      );
      return;
    }
    final confirm = await _confirmDelete(
      context,
      title: 'Supprimer utilisateur',
      body: 'Supprimer ${user.name} et son accès ?',
    );
    if (confirm != true) return;
    store.enqueueSyncOperation(
      entityName: 'user',
      entityId: user.code,
      operationName: 'delete',
      payload: store.userSyncPayload(user),
    );
    store.users.removeAt(index);
    onChanged();
  }

  Future<bool?> _confirmDelete(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showReportDetail(
    BuildContext context, {
    required String title,
    required List<String> lines,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: title,
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _softPanelColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _panelBorderColor(context)),
                  ),
                  child: Column(
                    children: lines
                        .map(
                          (line) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _panelColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _panelBorderColor(context),
                              ),
                            ),
                            child: Text(
                              line,
                              style: TextStyle(
                                color: _strongTextColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJournalDetail(BuildContext context, LedgerRow row) {
    final matchingSale = store.visibleSales
        .where((sale) => sale.invoiceNo == row.reference)
        .firstOrNull;
    final matchingPurchase = store.visiblePurchases
        .where((purchase) => purchase.reference == row.reference)
        .firstOrNull;
    _showReportDetail(
      context,
      title: 'Detail journal',
      lines: matchingSale != null
          ? [
              'Type: Vente',
              'Facture: ${matchingSale.invoiceNo}',
              'Ticket: ${matchingSale.ticketNo}',
              'Client: ${matchingSale.customer.name}',
              'Libelle: ${row.label}',
              'Caissier: ${matchingSale.cashierName}',
              'Paiement: ${matchingSale.method}',
              'Total: ${store.money(matchingSale.total)}',
              'Payé: ${store.money(matchingSale.paid)}',
              'Reste: ${store.money(matchingSale.due)}',
              'Date: ${_formatDate(matchingSale.createdAt)}',
            ]
          : matchingPurchase != null
          ? [
              'Type: Achat',
              'Référence: ${matchingPurchase.reference}',
              'Libelle: ${row.label}',
              'Tiers: ${row.party}',
              'Fournisseur: ${matchingPurchase.supplier}',
              'Produit: ${matchingPurchase.product}',
              'Quantité: ${matchingPurchase.quantity.round()}',
              'Total: ${store.money(matchingPurchase.total)}',
              'Payé: ${store.money(matchingPurchase.paid)}',
              'Reste: ${store.money(matchingPurchase.due)}',
              'Date: ${_formatDate(matchingPurchase.createdAt)}',
            ]
          : [
              'Type: ${row.kind}',
              'Référence: ${row.reference}',
              'Libelle: ${row.label}',
              if (row.party.trim().isNotEmpty && row.party.trim() != '-') 'Client: ${row.party}',
              'Montant: ${store.money(row.amount)}',
              'Date: ${_formatDate(row.createdAt)}',
            ],
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - $body'),
      ),
    );
  }

  String _customerSubtitle(Customer customer) {
    final debt = store.debtForCustomer(customer);
    final contact = customer.phone.isEmpty ? customer.address : customer.phone;
    if (debt <= 0) return contact;
    return '$contact - Dette ${store.money(debt)}';
  }

  String _whatsAppUrl(String phone, {String? text}) {
    final rawDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = rawDigits.startsWith('243')
        ? rawDigits
        : rawDigits.startsWith('0')
        ? '243${rawDigits.substring(1)}'
        : '243$rawDigits';
    if (text == null || text.trim().isEmpty) {
      return 'https://wa.me/$normalized';
    }
    return 'https://wa.me/$normalized?text=${Uri.encodeComponent(text)}';
  }

  String _invoiceHtml(Sale sale) {
    return _buildModernInvoiceHtml(store, sale);
  }

  String _ticketHtml(Sale sale) {
    return _buildThermalTicketHtml(store, sale);
  }

  String _documentQrPayload(Sale sale, String kind) =>
      '$kind|${sale.invoiceNo}|${sale.ticketNo}|${sale.customer.code}|${sale.cashierCode}|${sale.createdAt.toIso8601String()}|${sale.total.round()}';

  Future<Uint8List> _buildInvoicePdfBytes(Sale sale) async {
    return _buildModernInvoicePdfBytes(store, sale);
  }

  Uint8List _buildTicketPdfBytes(Sale sale) {
    return _buildThermalTicketPdfBytes(store, sale);
  }
}

class AppStore {
  AppStore({
    required this.tenantId,
    required this.branchId,
    required this.deviceId,
    required this.settings,
    required this.codes,
    required this.categories,
    required this.products,
    required this.customers,
    required this.suppliers,
    required this.users,
    required this.sales,
    required this.purchases,
    required this.expenses,
    required this.stockMoves,
    required this.alerts,
    required this.messages,
    required this.syncQueue,
    required this.syncConflicts,
    required this.activeUser,
    Set<String>? readAlertIds,
    Set<String>? readMessageIds,
    Set<String>? hiddenMessageKeys,
    this.changeCounter = 0,
    this.lastSyncedCounter = 0,
    this.lastSyncAt,
    this.cloudAccessConfigured = false,
    this.cloudSession,
    this.pendingCloudActivation,
    this.onChanged,
  }) : readAlertIds = readAlertIds ?? <String>{},
       readMessageIds = readMessageIds ?? <String>{},
       hiddenMessageKeys = hiddenMessageKeys ?? <String>{};

  String tenantId;
  String branchId;
  String deviceId;
  final CompanySettings settings;
  final CodeGenerator codes;
  final List<String> categories;
  final List<Product> products;
  final List<Customer> customers;
  final List<Supplier> suppliers;
  final List<AppUser> users;
  final List<Sale> sales;
  final List<Purchase> purchases;
  final List<Expense> expenses;
  final List<StockMove> stockMoves;
  final List<AppAlert> alerts;
  final List<AppMessage> messages;
  final List<SyncQueueEntry> syncQueue;
  final List<SyncConflictEntry> syncConflicts;
  AppUser activeUser;
  final Set<String> readAlertIds;
  final Set<String> readMessageIds;
  final Set<String> hiddenMessageKeys;
  int changeCounter;
  int lastSyncedCounter;
  DateTime? lastSyncAt;
  bool cloudAccessConfigured;
  KeseCloudSession? cloudSession;
  PendingCloudActivation? pendingCloudActivation;
  VoidCallback? onChanged;

  int get pendingSyncChanges {
    final queuePending = syncQueue
        .where((entry) => entry.status != SyncOperationStatus.synced)
        .length;
    final legacyPending = (changeCounter - lastSyncedCounter).clamp(0, 1 << 30);
    return syncQueue.isNotEmpty ? queuePending : legacyPending;
  }
  bool get hasPendingSync => pendingSyncChanges > 0;
  List<SyncQueueEntry> get pendingSyncEntries => syncQueue
      .where((entry) => entry.status != SyncOperationStatus.synced)
      .toList();

  void markDirty() {
    changeCounter += 1;
    onChanged?.call();
  }

  void reconcileCodeCounters() {
    codes.product = math.max(
      codes.product,
      _nextCodeValue(products.map((entry) => entry.code), 'PRD-'),
    );
    codes.customer = math.max(
      codes.customer,
      _nextCodeValue(customers.map((entry) => entry.code), 'CLI-'),
    );
    codes.supplier = math.max(
      codes.supplier,
      _nextCodeValue(suppliers.map((entry) => entry.code), 'FRN-'),
    );
    codes.user = math.max(
      codes.user,
      _nextCodeValue(users.map((entry) => entry.code), 'USR-'),
    );
    final currentYear = DateTime.now().year;
    codes.invoice = math.max(
      codes.invoice,
      _nextCodeValue(sales.map((entry) => entry.invoiceNo), 'FAC-$currentYear-'),
    );
    codes.ticket = math.max(
      codes.ticket,
      _nextCodeValue(sales.map((entry) => entry.ticketNo), 'TCK-$currentYear-'),
    );
    codes.order = math.max(
      codes.order,
      _nextCodeValue(sales.map((entry) => entry.orderNo), 'CMD-$currentYear-'),
    );
    codes.purchase = math.max(
      codes.purchase,
      _nextCodeValue(
        purchases.map((entry) => entry.reference),
        'ACH-$currentYear-',
      ),
    );
  }

  void markSynchronized() {
    final now = DateTime.now();
    for (var index = 0; index < syncQueue.length; index++) {
      final entry = syncQueue[index];
      if (entry.status == SyncOperationStatus.pending ||
          entry.status == SyncOperationStatus.failed) {
        syncQueue[index] = entry.copyWith(
          status: SyncOperationStatus.synced,
          updatedAt: now,
          lastError: null,
        );
      }
    }
    lastSyncedCounter = changeCounter;
    lastSyncAt = now;
    onChanged?.call();
  }

  void updateSyncQueueStatus({
    required Set<String> entryIds,
    required SyncOperationStatus status,
    String? lastError,
  }) {
    if (entryIds.isEmpty) return;
    final now = DateTime.now();
    for (var index = 0; index < syncQueue.length; index++) {
      final entry = syncQueue[index];
      if (!entryIds.contains(entry.id)) continue;
      syncQueue[index] = entry.copyWith(
        status: status,
        updatedAt: now,
        lastError: lastError,
        retryCount: status == SyncOperationStatus.failed
            ? entry.retryCount + 1
            : entry.retryCount,
      );
    }
    if (status == SyncOperationStatus.synced) {
      lastSyncedCounter = changeCounter;
      lastSyncAt = now;
    }
    onChanged?.call();
  }

  factory AppStore.demo() {
    final codes = CodeGenerator();
    final supplier = Supplier(
      code: codes.nextSupplier(),
      name: 'Fournisseur general',
      phone: '+243 000 000',
      address: 'Kinshasa',
    );
    final customer = Customer(
      code: codes.nextCustomer(),
      name: 'Client de passage',
      phone: '+243 999 000 111',
      address: 'Kinshasa',
      lastEditedByCode: '',
      lastEditedByName: '',
    );
    final products = [
      Product.demo(
        codes.nextProduct(),
        'Pain',
        'Aliment',
        300,
        500,
        24,
        Icons.bakery_dining_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=80',
      ),
      Product.demo(
        codes.nextProduct(),
        'Coca',
        'Boisson',
        700,
        1000,
        14,
        Icons.local_drink_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1622484212850-eb596d769edc?auto=format&fit=crop&w=900&q=80',
      ),
      Product.demo(
        codes.nextProduct(),
        'Savon',
        'Maison',
        1000,
        1500,
        10,
        Icons.soap_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1584305574647-acf8069a8f3d?auto=format&fit=crop&w=900&q=80',
      ),
      Product.demo(
        codes.nextProduct(),
        'Riz 1kg',
        'Aliment',
        1800,
        2400,
        18,
        Icons.rice_bowl_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=900&q=80',
      ),
      Product.demo(
        codes.nextProduct(),
        'Meche 12 pouces',
        'Beaute',
        4200,
        6500,
        8,
        Icons.face_3_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=900&q=80',
      ),
    ];
    final admin = AppUser(
      code: codes.nextUser(),
      name: 'Administrateur',
      username: 'Admin',
      role: 'Admin',
      pin: 'Admin@2026',
    );
    final manager = AppUser(
      code: codes.nextUser(),
      name: 'Gestionnaire',
      username: 'Gestionnaire',
      role: 'Gestionnaire',
      pin: 'Gerant@2026',
    );
    final cashier = AppUser(
      code: codes.nextUser(),
      name: 'Caissier',
      username: 'Caissier',
      role: 'Caissier',
      pin: 'Caisse@2026',
    );
    return AppStore(
      tenantId: 'tenant-demo-kese',
      branchId: 'branch-main',
      deviceId: 'device-local-demo',
      settings: CompanySettings(),
      codes: codes,
      categories: ['Aliment', 'Beaute', 'Boisson', 'Maison', 'Divers'],
      products: products,
      customers: [customer],
      suppliers: [supplier],
      users: [admin, manager, cashier],
      sales: [],
      purchases: [],
      expenses: [],
      stockMoves: products
          .map(
            (p) => StockMove(
              type: 'OPENING',
              product: p.name,
              quantity: p.quantity,
              reference: 'Ouverture',
              createdAt: DateTime.now(),
            ),
          )
          .toList(),
      alerts: [
        AppAlert.info(
          'Bienvenue',
          'DSquare Technologies vous souhaite la bienvenue dans KESE, votre assistante commerciale.',
          id: 'welcome',
        ),
      ],
      messages: [
        AppMessage.chat(
          id: 'chat-welcome-admin-manager',
          senderCode: admin.code,
          senderName: admin.name,
          recipientCode: manager.code,
          recipientName: manager.name,
          body: 'Bienvenue dans KESE. Utilise cette messagerie pour les suivis de caisse, les relances clients et la coordination interne.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
      ],
      syncQueue: [],
      syncConflicts: [],
      activeUser: admin,
    );
  }

  Map<String, dynamic> get _syncContext => {
        'tenantId': tenantId,
        'branchId': branchId,
        'deviceId': deviceId,
      };

  Map<String, dynamic> productSyncPayload(Product product) => {
        ..._syncContext,
        'code': product.code,
        'sku': product.sku,
        'barcode': product.barcode,
        'name': product.name,
        'category': product.category,
        'unit': product.unit,
        'cost': product.cost,
        'price': product.price,
        'quantity': product.quantity,
        'minQuantity': product.minQuantity,
        'location': product.location,
        'imageUrl': product.imageUrl,
      };

  Map<String, dynamic> customerSyncPayload(Customer customer) => {
        ..._syncContext,
        'code': customer.code,
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
        'lastEditedByCode': customer.lastEditedByCode,
        'lastEditedByName': customer.lastEditedByName,
      };

  Map<String, dynamic> supplierSyncPayload(Supplier supplier) => {
        ..._syncContext,
        'code': supplier.code,
        'name': supplier.name,
        'phone': supplier.phone,
        'address': supplier.address,
      };

  Map<String, dynamic> userSyncPayload(AppUser user) => {
        ..._syncContext,
        'code': user.code,
        'name': user.name,
        'username': user.username,
        'role': user.role,
        'pin': user.pin,
        'isBlocked': user.isBlocked,
      };

  Map<String, dynamic> settingsSyncPayload() => {
        ..._syncContext,
        'companyName': settings.companyName,
        'ownerName': settings.ownerName,
        'logoUrl': settings.logoUrl,
        'phone': settings.phone,
        'email': settings.email,
        'address': settings.address,
        'rccm': settings.rccm,
        'idNat': settings.idNat,
        'nif': settings.nif,
        'efo': settings.efo,
        'currency': settings.currency,
        'taxRate': settings.taxRate,
      };

  Map<String, dynamic> saleSyncPayload(Sale sale) => {
        ..._syncContext,
        'orderNo': sale.orderNo,
        'invoiceNo': sale.invoiceNo,
        'ticketNo': sale.ticketNo,
        'customerCode': sale.customer.code,
        'customerName': sale.customer.name,
        'cashierCode': sale.cashierCode,
        'cashierName': sale.cashierName,
        'subtotal': sale.subtotal,
        'discount': sale.discount,
        'total': sale.total,
        'paid': sale.paid,
        'due': sale.due,
        'method': sale.method,
        'createdAt': sale.createdAt.toIso8601String(),
        'dueDate': sale.dueDate.toIso8601String(),
        'lines': sale.lines
            .map(
              (line) => {
                'product': line.product,
                'qty': line.qty,
                'price': line.price,
                'cost': line.cost,
                'lineTotal': line.qty * line.price,
              },
            )
            .toList(),
      };

  Map<String, dynamic> purchaseSyncPayload(Purchase purchase) => {
        ..._syncContext,
        'reference': purchase.reference,
        'product': purchase.product,
        'supplier': purchase.supplier,
        'authorCode': purchase.authorCode,
        'authorName': purchase.authorName,
        'quantity': purchase.quantity,
        'total': purchase.total,
        'paid': purchase.paid,
        'due': purchase.due,
        'createdAt': purchase.createdAt.toIso8601String(),
      };

  Map<String, dynamic> expenseSyncPayload(Expense expense) => {
        ..._syncContext,
        'label': expense.label,
        'authorCode': expense.authorCode,
        'authorName': expense.authorName,
        'amount': expense.amount,
        'createdAt': expense.createdAt.toIso8601String(),
      };

  Map<String, dynamic> stockMoveSyncPayload(StockMove move) => {
        ..._syncContext,
        'type': move.type,
        'product': move.product,
        'quantity': move.quantity,
        'reference': move.reference,
        'createdAt': move.createdAt.toIso8601String(),
      };

  Map<String, dynamic> messageSyncPayload(AppMessage message) => {
        ..._syncContext,
        'id': message.id,
        'title': message.title,
        'body': message.body,
        'type': message.type,
        'contentType': message.contentType,
        'attachmentName': message.attachmentName,
        'attachmentMimeType': message.attachmentMimeType,
        'attachmentDataUrl': message.attachmentDataUrl,
        'createdAt': message.createdAt.toIso8601String(),
        'expiresAt': message.expiresAt?.toIso8601String(),
        'editedAt': message.editedAt?.toIso8601String(),
        'senderCode': message.senderCode,
        'senderName': message.senderName,
        'recipientCode': message.recipientCode,
        'recipientName': message.recipientName,
        'recipientReadAt': message.recipientReadAt?.toIso8601String(),
        'deletedForEveryoneAt': message.deletedForEveryoneAt?.toIso8601String(),
      };

  void applyCloudOperations(List<KeseCloudSyncOperation> operations) {
    var changed = false;
    for (final operation in operations) {
      if (operation.syncStatus == 'conflict') {
        continue;
      }
      changed = _applyCloudOperation(operation) || changed;
    }
    if (changed) {
      reconcileCodeCounters();
    }
    if (changed) {
      onChanged?.call();
    }
  }

  bool _applyCloudOperation(KeseCloudSyncOperation operation) {
    Map<String, dynamic> payload;
    try {
      payload = _asMap(jsonDecode(operation.payloadJson));
    } catch (_) {
      return false;
    }
    return switch (operation.entityName) {
      'category' => _applyCategoryOperation(operation, payload),
      'settings' => _applySettingsOperation(payload),
      'customer' => _applyCustomerOperation(operation, payload),
      'supplier' => _applySupplierOperation(operation, payload),
      'user' => _applyUserOperation(operation, payload),
      'product' => _applyProductOperation(operation, payload),
      'stock_move' => _applyStockMoveOperation(operation, payload),
      'sale' => _applySaleOperation(operation, payload),
      'purchase' => _applyPurchaseOperation(operation, payload),
      'expense' => _applyExpenseOperation(operation, payload),
      'message' => _applyMessageOperation(operation, payload),
      _ => false,
    };
  }

  bool _applyCategoryOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final name = _asString(payload['name']).trim();
    if (name.isEmpty) return false;
    if (operation.operationName == 'delete') {
      return categories.remove(name);
    }
    if (categories.contains(name)) return false;
    categories.add(name);
    categories.sort();
    return true;
  }

  bool _applySettingsOperation(Map<String, dynamic> payload) {
    settings
      ..companyName = _asString(payload['companyName'], settings.companyName)
      ..ownerName = _asString(payload['ownerName'], settings.ownerName)
      ..logoUrl = _asString(payload['logoUrl'], settings.logoUrl)
      ..phone = _asString(payload['phone'], settings.phone)
      ..email = _asString(payload['email'], settings.email)
      ..address = _asString(payload['address'], settings.address)
      ..rccm = _asString(payload['rccm'], settings.rccm)
      ..idNat = _asString(payload['idNat'], settings.idNat)
      ..nif = _asString(payload['nif'], settings.nif)
      ..efo = _asString(payload['efo'], settings.efo)
      ..currency = _asString(payload['currency'], settings.currency)
      ..taxRate = _asNum(payload['taxRate'], settings.taxRate);
    return true;
  }

  bool _applyCustomerOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final code = _asString(payload['code'], operation.entityId);
    final index = customers.indexWhere((entry) => entry.code == code);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      customers.removeAt(index);
      return true;
    }
    final customer = Customer(
      code: code,
      name: _asString(payload['name']),
      phone: _asString(payload['phone']),
      address: _asString(payload['address']),
      lastEditedByCode: _asString(payload['lastEditedByCode']),
      lastEditedByName: _asString(payload['lastEditedByName']),
    );
    if (index == -1) {
      customers.add(customer);
      return true;
    }
    customers[index] = customer;
    return true;
  }

  bool _applySupplierOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final code = _asString(payload['code'], operation.entityId);
    final index = suppliers.indexWhere((entry) => entry.code == code);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      suppliers.removeAt(index);
      return true;
    }
    final supplier = Supplier(
      code: code,
      name: _asString(payload['name']),
      phone: _asString(payload['phone']),
      address: _asString(payload['address']),
    );
    if (index == -1) {
      suppliers.add(supplier);
      return true;
    }
    suppliers[index] = supplier;
    return true;
  }

  bool _applyUserOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final code = _asString(payload['code'], operation.entityId);
    final username = _asString(payload['username']).trim();
    final normalizedUsername = username.toLowerCase();
    final index = users.indexWhere(
      (entry) =>
          entry.code == code ||
          entry.username.trim().toLowerCase() == normalizedUsername,
    );
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      final removed = users.removeAt(index);
      if (activeUser.code == removed.code) {
        activeUser = users.firstOrNull ?? activeUser;
      }
      return true;
    }
    final user = AppUser(
      code: code,
      name: _asString(payload['name'], username),
      username: username,
      role: _asString(payload['role'], 'Caissier'),
      pin: _asString(payload['pin'], 'Kese@2026'),
      isBlocked: _asBool(payload['isBlocked']),
    );
    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
    }
    if (activeUser.code == code ||
        activeUser.username.trim().toLowerCase() == normalizedUsername) {
      activeUser = user;
    }
    return true;
  }

  bool _applyProductOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final code = _asString(payload['code'], operation.entityId);
    final index = products.indexWhere((entry) => entry.code == code);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      products.removeAt(index);
      return true;
    }
    final product = Product(
      code: code,
      sku: _asString(payload['sku']),
      barcode: _asString(payload['barcode']),
      name: _asString(payload['name']),
      category: _asString(payload['category']),
      unit: _asString(payload['unit'], 'piece'),
      cost: _asNum(payload['cost']),
      price: _asNum(payload['price']),
      quantity: _asNum(payload['quantity']),
      minQuantity: _asNum(payload['minQuantity']),
      location: _asString(payload['location']),
      icon: Icons.inventory_2_rounded,
      imageUrl: _asString(payload['imageUrl']),
    );
    if (index == -1) {
      products.add(product);
    } else {
      products[index]
        ..sku = product.sku
        ..barcode = product.barcode
        ..name = product.name
        ..category = product.category
        ..unit = product.unit
        ..cost = product.cost
        ..price = product.price
        ..quantity = product.quantity
        ..minQuantity = product.minQuantity
        ..location = product.location
        ..imageUrl = product.imageUrl;
    }
    codes.product = math.max(
      codes.product,
      _nextCodeValue(products.map((entry) => entry.code), 'PRD-'),
    );
    final category = product.category.trim();
    if (category.isNotEmpty && !categories.contains(category)) {
      categories.add(category);
      categories.sort();
    }
    return true;
  }

  bool _applyStockMoveOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final createdAt = _asDate(payload['createdAt']) ?? DateTime.now();
    final reference = _asString(payload['reference']);
    final product = _asString(payload['product']);
    final exists = stockMoves.any(
      (entry) =>
          entry.reference == reference &&
          entry.product == product &&
          entry.createdAt.toIso8601String() == createdAt.toIso8601String(),
    );
    if (operation.operationName == 'delete') {
      final index = stockMoves.indexWhere(
        (entry) =>
            entry.reference == reference &&
            entry.product == product &&
            entry.createdAt.toIso8601String() == createdAt.toIso8601String(),
      );
      if (index == -1) return false;
      stockMoves.removeAt(index);
      return true;
    }
    if (exists) return false;
    stockMoves.add(
      StockMove(
        type: _asString(payload['type']),
        product: product,
        quantity: _asNum(payload['quantity']),
        reference: reference,
        createdAt: createdAt,
      ),
    );
    return true;
  }

  bool _applySaleOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final invoiceNo = _asString(payload['invoiceNo'], operation.entityId);
    final index = sales.indexWhere((entry) => entry.invoiceNo == invoiceNo);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      sales.removeAt(index);
      return true;
    }
    final customerCode = _asString(payload['customerCode'], 'client-cloud');
    final existingCustomer = customers.where((entry) => entry.code == customerCode).firstOrNull;
    final customer = existingCustomer ??
        Customer(
          code: customerCode,
          name: _asString(payload['customerName'], 'Client'),
          phone: '',
          address: '',
        );
    if (existingCustomer == null) {
      customers.add(customer);
    }
    final sale = Sale(
      orderNo: _asString(payload['orderNo']),
      invoiceNo: invoiceNo,
      ticketNo: _asString(payload['ticketNo']),
      customer: customer,
      cashierName: _asString(payload['cashierName']),
      cashierCode: _asString(payload['cashierCode']),
      lines: _asDynamicList(payload['lines'])
          .whereType<Map>()
          .map(
            (raw) => raw.map((key, value) => MapEntry('$key', value)),
          )
          .map(
            (line) => SaleLine(
              product: _asString(line['product']),
              qty: _asNum(line['qty']),
              price: _asNum(line['price']),
              cost: _asNum(line['cost']),
            ),
          )
          .toList(),
      subtotal: _asNum(payload['subtotal']),
      discount: _asNum(payload['discount']),
      total: _asNum(payload['total']),
      paid: _asNum(payload['paid']),
      method: _asString(payload['method']),
      createdAt: _asDate(payload['createdAt']) ?? DateTime.now(),
      dueDate: _asDate(payload['dueDate']) ?? DateTime.now(),
    );
    if (index == -1) {
      sales.add(sale);
    } else {
      sales[index] = sale;
    }
    return true;
  }

  bool _applyPurchaseOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final reference = _asString(payload['reference'], operation.entityId);
    final index = purchases.indexWhere((entry) => entry.reference == reference);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      purchases.removeAt(index);
      return true;
    }
    final purchase = Purchase(
      reference: reference,
      product: _asString(payload['product']),
      supplier: _asString(payload['supplier']),
      authorCode: _asString(payload['authorCode']),
      authorName: _asString(payload['authorName']),
      quantity: _asNum(payload['quantity']),
      total: _asNum(payload['total']),
      paid: _asNum(payload['paid']),
      createdAt: _asDate(payload['createdAt']) ?? DateTime.now(),
    );
    if (index == -1) {
      purchases.add(purchase);
    } else {
      purchases[index] = purchase;
    }
    return true;
  }

  bool _applyExpenseOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final createdAt = _asDate(payload['createdAt']) ?? DateTime.now();
    final label = _asString(payload['label'], operation.entityId);
    final index = expenses.indexWhere(
      (entry) =>
          entry.label == label &&
          entry.createdAt.toIso8601String() == createdAt.toIso8601String(),
    );
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      expenses.removeAt(index);
      return true;
    }
    final expense = Expense(
      label: label,
      authorCode: _asString(payload['authorCode']),
      authorName: _asString(payload['authorName']),
      amount: _asNum(payload['amount']),
      createdAt: createdAt,
    );
    if (index == -1) {
      expenses.add(expense);
    } else {
      expenses[index] = expense;
    }
    return true;
  }

  bool _applyMessageOperation(
    KeseCloudSyncOperation operation,
    Map<String, dynamic> payload,
  ) {
    final id = _asString(payload['id'], operation.entityId);
    final index = messages.indexWhere((entry) => entry.id == id);
    if (operation.operationName == 'delete') {
      if (index == -1) return false;
      messages.removeAt(index);
      return true;
    }
    final message = AppMessage(
      id: id,
      title: _asString(payload['title']),
      body: _asString(payload['body']),
      type: _asString(payload['type'], 'system'),
      contentType: _asString(payload['contentType'], 'text'),
      createdAt: _asDate(payload['createdAt']) ?? DateTime.now(),
      senderCode: _nullableString(payload['senderCode']),
      senderName: _nullableString(payload['senderName']),
      recipientCode: _nullableString(payload['recipientCode']),
      recipientName: _nullableString(payload['recipientName']),
      attachmentName: _nullableString(payload['attachmentName']),
      attachmentMimeType: _nullableString(payload['attachmentMimeType']),
      attachmentDataUrl: _nullableString(payload['attachmentDataUrl']),
      expiresAt: _asDate(payload['expiresAt']),
      editedAt: _asDate(payload['editedAt']),
      recipientReadAt: _asDate(payload['recipientReadAt']),
      deletedForEveryoneAt: _asDate(payload['deletedForEveryoneAt']),
    );
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    return true;
  }

  void enqueueSyncOperation({
    required String entityName,
    required String entityId,
    required String operationName,
    required Map<String, dynamic> payload,
    SyncOperationStatus status = SyncOperationStatus.pending,
    int retryCount = 0,
    String? lastError,
  }) {
    final now = DateTime.now();
    final payloadJson = jsonEncode(payload);
    syncQueue.add(
      SyncQueueEntry(
        id: '$entityName-$entityId-${now.microsecondsSinceEpoch}',
        tenantId: tenantId,
        branchId: branchId,
        deviceId: deviceId,
        entityName: entityName,
        entityId: entityId,
        operationName: operationName,
        payloadJson: payloadJson,
        payloadHash: _stableHash(payloadJson),
        status: status,
        retryCount: retryCount,
        lastError: lastError,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  void registerSyncConflict({
    required String entityName,
    required String localEntityId,
    String? serverEntityId,
    required String conflictType,
    required Map<String, dynamic> localPayload,
    Map<String, dynamic>? serverPayload,
  }) {
    syncConflicts.add(
      SyncConflictEntry(
        id: '$entityName-$localEntityId-${DateTime.now().microsecondsSinceEpoch}',
        tenantId: tenantId,
        branchId: branchId,
        deviceId: deviceId,
        entityName: entityName,
        localEntityId: localEntityId,
        serverEntityId: serverEntityId,
        conflictType: conflictType,
        localPayloadJson: jsonEncode(localPayload),
        serverPayloadJson: serverPayload == null ? null : jsonEncode(serverPayload),
        resolutionStatus: 'open',
        createdAt: DateTime.now(),
      ),
    );
  }

  Product createProduct({
    required String name,
    required String category,
    required String unit,
    required num cost,
    required num price,
    required num quantity,
    required num minQuantity,
    String imageUrl = '',
  }) {
    String uniqueProductCode() {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final suffix = math.Random().nextInt(1 << 20).toRadixString(36);
      return 'PRD-$stamp-$suffix';
    }

    String uniqueSku() {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final suffix = math.Random().nextInt(1 << 20).toRadixString(36);
      return 'SKU-$stamp-$suffix';
    }

    String uniqueBarcode() {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final suffix = math.Random().nextInt(1000).toString().padLeft(3, '0');
      return '2$stamp$suffix';
    }

    return Product(
      code: uniqueProductCode(),
      sku: uniqueSku(),
      barcode: uniqueBarcode(),
      name: name,
      category: category,
      unit: unit,
      cost: cost,
      price: price,
      quantity: quantity,
      minQuantity: minQuantity,
      location: '',
      icon: Icons.inventory_2_rounded,
      imageUrl: imageUrl,
    );
  }

  List<String> get units => const [
    'piece',
    'boite',
    'paquet',
    'carton',
    'sac',
    'bouteille',
    'metre',
    'm2',
    'kg',
    'litre',
  ];

  void addCategory(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    if (!categories.contains(normalized)) {
      categories.add(normalized);
      categories.sort();
      enqueueSyncOperation(
        entityName: 'category',
        entityId: '$tenantId::$normalized',
        operationName: 'upsert',
        payload: {
          ..._syncContext,
          'name': normalized,
        },
      );
      markDirty();
    }
  }

  Customer createCustomer(String name, String phone, String address) {
    return Customer(
      code: codes.nextCustomer(),
      name: name,
      phone: phone,
      address: address,
      lastEditedByCode: activeUser.code,
      lastEditedByName: activeUser.name,
    );
  }

  Supplier createSupplier(String name, String phone, String address) {
    return Supplier(
      code: codes.nextSupplier(),
      name: name,
      phone: phone,
      address: address,
    );
  }

  bool canEditCustomer(Customer customer) {
    if (activeUser.isAdmin || activeUser.isManager) return true;
    return customer.lastEditedByCode == activeUser.code;
  }

  bool canDeleteCustomer(Customer customer) {
    if (activeUser.isAdmin || activeUser.isManager) return true;
    return customer.lastEditedByCode == activeUser.code;
  }

  void applyStockMove(Product product, String type, num value) {
    final before = product.quantity;
    if (type == 'IN') {
      product.quantity += value;
    }
    if (type == 'OUT') {
      product.quantity = (product.quantity - value).clamp(0, double.infinity);
    }
    if (type == 'ADJUST') {
      product.quantity = value;
    }
    final move = StockMove(
      type: type,
      product: product.name,
      quantity: product.quantity - before,
      reference: product.sku,
      createdAt: DateTime.now(),
    );
    stockMoves.add(move);
    alerts.add(
      AppAlert.info(
        'Stock mis à jour',
        '${product.name}: $before -> ${product.quantity}',
        id: 'stock-${product.code}-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    enqueueSyncOperation(
      entityName: 'stock_move',
      entityId:
          '${move.reference}-${move.createdAt.microsecondsSinceEpoch}-${move.product}',
      operationName: 'create',
      payload: stockMoveSyncPayload(move),
    );
    enqueueSyncOperation(
      entityName: 'product',
      entityId: product.code,
      operationName: 'update',
      payload: productSyncPayload(product),
    );
    markDirty();
  }

  Sale completeSale({
    required List<CartLine> cart,
    required Customer customer,
    required String method,
    required num paid,
    required num discount,
    required AppUser cashier,
    DateTime? dueDate,
  }) {
    if (cart.isEmpty) {
      throw StateError('Impossible de valider une vente vide.');
    }
    final subtotal = cart.fold<num>(
      0,
      (sum, line) => sum + line.qty * line.product.price,
    );
    final total = (subtotal - discount).clamp(0, double.infinity);
    final normalizedPaid = method == 'Credit'
        ? 0
        : paid.clamp(0, total);
    final now = DateTime.now();
    final effectiveDueDate = method == 'Credit'
        ? (dueDate ?? now.add(const Duration(days: 7)))
        : now;
    final sale = Sale(
      orderNo: codes.nextOrder(),
      invoiceNo: codes.nextInvoice(),
      ticketNo: codes.nextTicket(),
      customer: customer,
      cashierName: cashier.name,
      cashierCode: cashier.code,
      lines: cart
          .map(
            (line) => SaleLine(
              product: line.product.name,
              qty: line.qty,
              price: line.product.price,
              cost: line.product.cost,
            ),
          )
          .toList(),
      subtotal: subtotal,
      discount: discount,
      total: total,
      paid: normalizedPaid,
      method: method,
      createdAt: now,
      dueDate: effectiveDueDate,
    );
    final saleMoves = <StockMove>[];
    for (final line in cart) {
      line.product.quantity = (line.product.quantity - line.qty).clamp(
        0,
        double.infinity,
      );
      final move = StockMove(
        type: 'SALE',
        product: line.product.name,
        quantity: -line.qty,
        reference: sale.invoiceNo,
        createdAt: now,
      );
      stockMoves.add(move);
      saleMoves.add(move);
    }
    sales.add(sale);
    if (sale.due > 0) {
      final creditMessage = AppMessage.system(
        title: 'Nouveau crédit client',
        body:
            '${customer.name} doit ${money(sale.due)} sur ${sale.invoiceNo}. Echeance: ${_formatDate(sale.dueDate)}.',
        id: 'credit-${sale.invoiceNo}',
        createdAt: now,
        recipientCode: cashier.code,
        recipientName: cashier.name,
      );
      messages.add(creditMessage);
      enqueueSyncOperation(
        entityName: 'message',
        entityId: creditMessage.id,
        operationName: 'create',
        payload: messageSyncPayload(creditMessage),
      );
      _notifyCreditSaleStakeholders(
        sale: sale,
        actor: cashier,
        createdAt: now,
      );
    }
    alerts.add(
      AppAlert.info(
        'Vente enregistree',
        '${sale.ticketNo} - ${money(sale.total)} par ${sale.cashierName}.',
        id: 'sale-${sale.ticketNo}',
      ),
    );
    enqueueSyncOperation(
      entityName: 'sale',
      entityId: sale.invoiceNo,
      operationName: 'create',
      payload: saleSyncPayload(sale),
    );
    for (var index = 0; index < cart.length; index++) {
      final line = cart[index];
      final move = saleMoves[index];
      enqueueSyncOperation(
        entityName: 'stock_move',
        entityId:
            '${move.reference}-${move.createdAt.microsecondsSinceEpoch}-${move.product}',
        operationName: 'create',
        payload: stockMoveSyncPayload(move),
      );
      enqueueSyncOperation(
        entityName: 'product',
        entityId: line.product.code,
        operationName: 'update',
        payload: productSyncPayload(line.product),
      );
    }
    markDirty();
    return sale;
  }

  void addPurchase(
    Product product,
    Supplier supplier,
    num qty,
    num cost,
    num paid,
    AppUser actor,
  ) {
    product.quantity += qty;
    product.cost = cost;
    final purchase = Purchase(
      reference: codes.nextPurchase(),
      product: product.name,
      supplier: supplier.name,
      authorCode: actor.code,
      authorName: actor.name,
      quantity: qty,
      total: qty * cost,
      paid: paid,
      createdAt: DateTime.now(),
    );
    purchases.add(purchase);
    final move = StockMove(
      type: 'IN',
      product: product.name,
      quantity: qty,
      reference: purchase.reference,
      createdAt: DateTime.now(),
    );
    stockMoves.add(move);
    enqueueSyncOperation(
      entityName: 'purchase',
      entityId: purchase.reference,
      operationName: 'create',
      payload: purchaseSyncPayload(purchase),
    );
    enqueueSyncOperation(
      entityName: 'stock_move',
      entityId:
          '${move.reference}-${move.createdAt.microsecondsSinceEpoch}-${move.product}',
      operationName: 'create',
      payload: stockMoveSyncPayload(move),
    );
    enqueueSyncOperation(
      entityName: 'product',
      entityId: product.code,
      operationName: 'update',
      payload: productSyncPayload(product),
    );
    markDirty();
  }

  void addExpense(String label, num amount, AppUser actor) {
    if (amount <= 0) return;
    final expense = Expense(
      label: label.isEmpty ? 'Operations' : label,
      authorCode: actor.code,
      authorName: actor.name,
      amount: amount,
      createdAt: DateTime.now(),
    );
    expenses.add(expense);
    enqueueSyncOperation(
      entityName: 'expense',
      entityId:
          '${expense.label}-${expense.createdAt.microsecondsSinceEpoch}',
      operationName: 'create',
      payload: expenseSyncPayload(expense),
    );
    markDirty();
  }

  void _appendSystemMessageForUser({
    required AppUser recipient,
    required String title,
    required String body,
    required String id,
    required DateTime createdAt,
  }) {
    final message = AppMessage.system(
      title: title,
      body: body,
      id: id,
      createdAt: createdAt,
      recipientCode: recipient.code,
      recipientName: recipient.name,
    );
    messages.add(message);
    enqueueSyncOperation(
      entityName: 'message',
      entityId: message.id,
      operationName: 'create',
      payload: messageSyncPayload(message),
    );
  }

  void _notifyCreditSaleStakeholders({
    required Sale sale,
    required AppUser actor,
    required DateTime createdAt,
  }) {
    final recipients = switch (actor.role) {
      'Caissier' => users.where((user) => user.isAdmin || user.isManager).toList(),
      'Gestionnaire' || 'Manager' => users.where((user) => user.isAdmin).toList(),
      _ => const <AppUser>[],
    };
    if (recipients.isEmpty) return;
    final contractedDate = _formatDate(sale.createdAt);
    final dueLabel = _formatDate(sale.dueDate);
    final summary = _saleProductSummary(sale);
    for (final recipient in recipients) {
      _appendSystemMessageForUser(
        recipient: recipient,
        title: 'Vente a credit enregistree',
        body:
            '${actor.name} a enregistre une vente a credit pour ${sale.customer.name} le $contractedDate. '
            'Facture ${sale.invoiceNo}, reste ${money(sale.due)}, echeance $dueLabel, produits: $summary.',
        id:
            'credit-notify-${sale.invoiceNo}-${recipient.code}-${createdAt.microsecondsSinceEpoch}',
        createdAt: createdAt,
      );
    }
  }

  void _notifyDebtSettlementAdmins({
    required Sale sale,
    required num settledAmount,
    required AppUser actor,
    required DateTime createdAt,
  }) {
    final admins = users.where((user) => user.isAdmin).toList();
    if (admins.isEmpty) return;
    final contractedDate = _formatDate(sale.createdAt);
    for (final admin in admins) {
      _appendSystemMessageForUser(
        recipient: admin,
        title: 'Dette payee',
        body:
            'La dette de ${sale.customer.name}, contractee le $contractedDate sous ${sale.invoiceNo}, '
            'a ete reglee a hauteur de ${money(settledAmount)} par ${actor.name}.',
        id:
            'settled-notify-${sale.invoiceNo}-${admin.code}-${createdAt.microsecondsSinceEpoch}',
        createdAt: createdAt,
      );
    }
  }

  bool updateActiveUserPin({
    required String currentPin,
    required String nextPin,
  }) {
    if (activeUser.pin != currentPin) return false;
    activeUser.pin = nextPin;
    enqueueSyncOperation(
      entityName: 'user',
      entityId: activeUser.code,
      operationName: 'update',
      payload: userSyncPayload(activeUser),
    );
    markDirty();
    return true;
  }

  bool updateActiveUserAccess({
    required String currentPin,
    required String nextPin,
    required String username,
  }) {
    if (activeUser.pin != currentPin) return false;
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) return false;
    final alreadyUsed = users.any(
      (user) =>
          user.code != activeUser.code &&
          user.username.trim().toLowerCase() == normalizedUsername.toLowerCase(),
    );
    if (alreadyUsed) return false;
    activeUser.username = normalizedUsername;
    activeUser.pin = nextPin;
    enqueueSyncOperation(
      entityName: 'user',
      entityId: activeUser.code,
      operationName: 'update',
      payload: userSyncPayload(activeUser),
    );
    markDirty();
    return true;
  }

  bool updateUserPin({
    required String username,
    required String currentPin,
    required String nextPin,
  }) {
    final user = users.where((entry) {
      return entry.username.trim().toLowerCase() == username.trim().toLowerCase();
    }).firstOrNull;
    if (user == null) return false;
    if (user.pin != currentPin) return false;
    user.pin = nextPin;
    enqueueSyncOperation(
      entityName: 'user',
      entityId: user.code,
      operationName: 'update',
      payload: userSyncPayload(user),
    );
    markDirty();
    return true;
  }

  num settleSaleCredit(Sale sale, {num? amount, AppUser? actor}) {
    final due = sale.due;
    if (due <= 0) return 0;
    final settled = (amount ?? due).clamp(0, due);
    if (settled <= 0) return 0;
    sale.paid += settled;
    final now = DateTime.now();
    final effectiveActor = actor ?? activeUser;
    final message = AppMessage.system(
      title: 'Dette reglee',
      body:
          '${sale.customer.name} a regle ${money(settled)} sur ${sale.invoiceNo}.',
      id: 'settle-${sale.invoiceNo}-${now.millisecondsSinceEpoch}',
      createdAt: now,
      recipientCode: effectiveActor.code,
      recipientName: effectiveActor.name,
    );
    messages.add(message);
    enqueueSyncOperation(
      entityName: 'sale',
      entityId: sale.invoiceNo,
      operationName: 'settle_credit',
      payload: {
        ...saleSyncPayload(sale),
        'settledAmount': settled,
      },
    );
    enqueueSyncOperation(
      entityName: 'message',
      entityId: message.id,
      operationName: 'create',
      payload: messageSyncPayload(message),
    );
    _notifyDebtSettlementAdmins(
      sale: sale,
      settledAmount: settled,
      actor: effectiveActor,
      createdAt: now,
    );
    markDirty();
    return settled;
  }

  List<Sale> get visibleSales => activeUser.isCashier
      ? sales.where((sale) => sale.cashierCode == activeUser.code).toList()
      : List<Sale>.from(sales);

  List<Purchase> get visiblePurchases {
    if (!activeUser.canAccessPurchases) return const [];
    if (!activeUser.isCashier) return List<Purchase>.from(purchases);
    return purchases.where((purchase) => purchase.authorCode == activeUser.code).toList();
  }

  List<Expense> get visibleExpenses {
    if (!activeUser.isCashier) return List<Expense>.from(expenses);
    return expenses.where((expense) => expense.authorCode == activeUser.code).toList();
  }

  List<StockMove> get visibleStockMoves {
    if (!activeUser.isCashier) return List<StockMove>.from(stockMoves);
    final saleRefs = visibleSales.map((sale) => sale.invoiceNo).toSet();
    final purchaseRefs = visiblePurchases.map((purchase) => purchase.reference).toSet();
    return stockMoves
        .where(
          (move) =>
              (move.type == 'SALE' && saleRefs.contains(move.reference)) ||
              (move.type == 'IN' && purchaseRefs.contains(move.reference)),
        )
        .toList();
  }

  TodayMetrics get todayMetrics {
    final now = DateTime.now();
    bool sameDay(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    final todaySales = visibleSales.where((s) => sameDay(s.createdAt)).toList();
    final todayExpenses = visibleExpenses
        .where((e) => sameDay(e.createdAt))
        .fold<num>(0, (sum, e) => sum + e.amount);
    final revenue = todaySales.fold<num>(0, (sum, s) => sum + s.total);
    final paid = todaySales.fold<num>(0, (sum, s) => sum + s.paid);
    final cost = todaySales.fold<num>(
      0,
      (sum, s) =>
          sum +
          s.lines.fold<num>(0, (inner, line) => inner + line.cost * line.qty),
    );
    return TodayMetrics(
      salesCount: todaySales.length,
      revenue: revenue,
      profit: revenue - cost - todayExpenses,
      cash: paid - todayExpenses,
      expenses: todayExpenses,
    );
  }

  List<Product> get lowStock =>
      products.where((p) => p.quantity <= p.minQuantity).toList();
  num get stockValue =>
      products.fold<num>(0, (sum, p) => sum + p.quantity * p.cost);
  num get customerDebt => visibleSales.fold<num>(0, (sum, s) => sum + s.due);
  num get supplierDebt =>
      visiblePurchases.fold<num>(0, (sum, purchase) => sum + purchase.due);
  int get unreadAlerts => smartAlerts.where((alert) => !alert.isRead).length;
  int get unreadMessages =>
      messageInbox.where(_isUnreadMessageForActiveUser).length;
  List<AppAlert> get smartAlerts {
    final scopedAlerts = <AppAlert>[];
    if (activeUser.canSeeCompanyWideNotifications) {
      scopedAlerts.addAll(alerts.map(_withReadState));
      scopedAlerts.addAll(
        lowStock.map(
          (p) => _withReadState(
            AppAlert.warning(
              'Stock bas',
              '${p.name}: reste ${p.quantityText}.',
              id: 'low-${p.code}-${p.quantity.round()}',
            ),
          ),
        ),
      );
    }
    scopedAlerts.addAll(
      systemMessagesForActiveUser.map(
        (message) => _withReadState(
          AppAlert.info(
            message.title,
            message.body,
            id: 'alert-${message.id}',
            createdAt: message.createdAt,
          ),
        ),
      ),
    );
    scopedAlerts.addAll(
      creditReminderMessages.map(
        (message) => _withReadState(
          AppAlert.warning(
            message.title,
            message.body,
            id: 'credit-alert-${message.id}',
            createdAt: message.createdAt,
          ),
        ),
      ),
    );
    final byId = <String, AppAlert>{};
    for (final alert in scopedAlerts) {
      byId[alert.id] = alert;
    }
    return byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<AppMessage> get creditReminderMessages {
    final today = _dateOnly(DateTime.now());
    final reminders = <AppMessage>[];
    for (final sale in visibleSales.where((sale) => sale.due > 0)) {
      final due = _dateOnly(sale.dueDate);
      final diff = due.difference(today).inDays;
      final products = _saleProductSummary(sale);
      final reminderDayKey =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      if (diff == 1) {
        reminders.add(
          AppMessage.system(
            title: 'Rappel 24 h avant échéance',
            body:
                '${sale.customer.name} doit regler ${money(sale.due)} demain pour $products.',
            id: 'credit-reminder-${sale.invoiceNo}-before-$reminderDayKey',
            createdAt: DateTime.now(),
          ),
        );
      }
      if (diff == 0) {
        reminders.add(
          AppMessage.system(
            title: 'Echeance aujourd hui',
            body:
                'Aujourd hui ${sale.customer.name} doit payer ${money(sale.due)} pour $products.',
            id: 'credit-reminder-${sale.invoiceNo}-today-$reminderDayKey',
            createdAt: DateTime.now(),
          ),
        );
      }
      if (diff < 0) {
        reminders.add(
          AppMessage.system(
            title: 'Dette en retard',
            body:
                '${sale.customer.name} a une dette echue de ${money(sale.due)} pour $products.',
            id: 'credit-reminder-${sale.invoiceNo}-overdue-$reminderDayKey',
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    return reminders;
  }

  List<AppMessage> get internalMessagesForActiveUser => messages
      .where(
        (message) =>
            message.isChat &&
            (message.senderCode == activeUser.code ||
                message.recipientCode == activeUser.code) &&
            _isVisibleMessageForActiveUser(message),
      )
      .map(_withMessageReadState)
      .toList();

  List<AppMessage> get systemMessagesForActiveUser => messages
      .where(
        (message) =>
            message.isSystem &&
            _isVisibleMessageForActiveUser(message) &&
            (activeUser.canSeeCompanyWideNotifications
                ? (message.recipientCode == null ||
                    message.recipientCode == activeUser.code)
                : message.recipientCode == activeUser.code),
      )
      .map(_withMessageReadState)
      .toList();

  List<AppMessage> get messageInbox => [
        ...systemMessagesForActiveUser,
        ...creditReminderMessages.map(_withMessageReadState),
        ...internalMessagesForActiveUser,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String _saleProductSummary(Sale sale) {
    final labels = sale.lines
        .map((line) => '${line.product} x${line.qty}')
        .take(3)
        .toList();
    final suffix = sale.lines.length > 3 ? ' et autres produits' : '';
    return labels.join(', ') + suffix;
  }

  String creditReminderMessage(Sale sale) {
    final dueLabel = _formatDate(sale.dueDate);
    return 'Bonjour ${sale.customer.name}, rappel de paiement de la dette ${sale.invoiceNo}. '
        'Montant restant: ${money(sale.due)}. Produits concernes: ${_saleProductSummary(sale)}. '
        'Echeance: $dueLabel. Merci de regulariser aujourd hui.';
  }

  String? _alertBackedMessageId(String alertId) {
    if (alertId.startsWith('alert-')) {
      return alertId.substring('alert-'.length);
    }
    if (alertId.startsWith('credit-alert-')) {
      return alertId.substring('credit-alert-'.length);
    }
    return null;
  }

  AppAlert _withReadState(AppAlert alert) {
    final linkedMessageId = _alertBackedMessageId(alert.id);
    final readFromMessage =
        linkedMessageId != null && readMessageIds.contains(linkedMessageId);
    final isRead = readAlertIds.contains(alert.id) || readFromMessage;
    return alert.copyWith(
      readAt: isRead ? (alert.readAt ?? DateTime.now()) : null,
    );
  }

  AppMessage _withMessageReadState(AppMessage message) {
    final alreadyReadLocally = readMessageIds.contains(message.id);
    final isOwnChatMessage =
        message.isChat && message.senderCode == activeUser.code;
    final wasReadByRecipient =
        message.isChat &&
        message.recipientCode == activeUser.code &&
        message.recipientReadAt != null;
    final readAt =
        message.readAt ??
        (alreadyReadLocally
            ? DateTime.now()
            : isOwnChatMessage
            ? message.createdAt
            : wasReadByRecipient
            ? message.recipientReadAt
            : null);
    return message.copyWith(readAt: readAt);
  }

  bool _isUnreadMessageForActiveUser(AppMessage message) {
    if (!_isVisibleMessageForActiveUser(message)) return false;
    if (message.isDeletedForEveryone) return false;
    if (message.isChat) {
      return message.recipientCode == activeUser.code &&
          message.senderCode != activeUser.code &&
          message.recipientReadAt == null &&
          !readMessageIds.contains(message.id);
    }
    return !readMessageIds.contains(message.id);
  }

  void markAlertRead(AppAlert alert) {
    readAlertIds.add(alert.id);
    if (alert.id.startsWith('alert-')) {
      readMessageIds.add(alert.id.substring('alert-'.length));
    } else if (alert.id.startsWith('credit-alert-')) {
      readMessageIds.add(alert.id.substring('credit-alert-'.length));
    }
    onChanged?.call();
  }

  void markMessageRead(AppMessage message) {
    if (message.recipientCode == activeUser.code &&
        message.recipientReadAt == null &&
        message.isChat) {
      final index = messages.indexWhere((entry) => entry.id == message.id);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          recipientReadAt: DateTime.now(),
        );
        enqueueSyncOperation(
          entityName: 'message',
          entityId: messages[index].id,
          operationName: 'update',
          payload: messageSyncPayload(messages[index]),
        );
      }
    }
    readMessageIds.add(message.id);
    readAlertIds.add('alert-${message.id}');
    readAlertIds.add('credit-alert-${message.id}');
    markDirty();
  }

  void markAllAlertsRead() {
    readAlertIds.addAll(smartAlerts.map((alert) => alert.id));
    readMessageIds.addAll(
      smartAlerts.map((alert) {
        if (alert.id.startsWith('alert-')) {
          return alert.id.substring('alert-'.length);
        }
        if (alert.id.startsWith('credit-alert-')) {
          return alert.id.substring('credit-alert-'.length);
        }
        return '';
      }).where((id) => id.isNotEmpty),
    );
    onChanged?.call();
  }

  void markAllMessagesRead() {
    for (final message in messageInbox) {
      markMessageRead(message);
    }
    onChanged?.call();
  }

  bool markMessagesFromPeerAsRead(AppUser peer) {
    var markedAny = false;
    for (final message in conversationWith(peer).where(
      (entry) => entry.recipientCode == activeUser.code && !entry.isRead,
    )) {
      markMessageRead(message);
      markedAny = true;
    }
    return markedAny;
  }

  String _hiddenMessageKey(String userCode, String messageId) =>
      '$userCode::$messageId';

  bool _isHiddenForActiveUser(AppMessage message) =>
      hiddenMessageKeys.contains(_hiddenMessageKey(activeUser.code, message.id));

  bool _isVisibleMessageForActiveUser(AppMessage message) {
    if (_isHiddenForActiveUser(message)) return false;
    if (message.isDeletedForEveryone) return true;
    if (message.isSystem) {
      if (activeUser.canSeeCompanyWideNotifications) {
        return message.recipientCode == null ||
            message.recipientCode == activeUser.code;
      }
      return message.recipientCode == activeUser.code;
    }
    final isSender = message.senderCode == activeUser.code;
    final isRecipient = message.recipientCode == activeUser.code;
    return isSender || isRecipient;
  }

  List<AppUser> get messagePeers =>
      users.where((user) => user.code != activeUser.code).toList();

  List<AppMessage> conversationWith(AppUser peer) {
    final thread = messages.where((message) {
      final pairA =
          message.senderCode == activeUser.code && message.recipientCode == peer.code;
      final pairB =
          message.senderCode == peer.code && message.recipientCode == activeUser.code;
      return (pairA || pairB) && !_isHiddenForActiveUser(message);
    }).map(_withMessageReadState).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return thread;
  }

  void sendInternalMessage({
    required AppUser recipient,
    required String body,
    String contentType = 'text',
    String? attachmentName,
    String? attachmentMimeType,
    String? attachmentDataUrl,
  }) {
    final text = body.trim();
    if (text.isEmpty && (attachmentDataUrl == null || attachmentDataUrl.isEmpty)) {
      return;
    }
    final now = DateTime.now();
    final message = AppMessage.chat(
      id: 'chat-${now.millisecondsSinceEpoch}-${activeUser.code}-${recipient.code}',
      senderCode: activeUser.code,
      senderName: activeUser.name,
      recipientCode: recipient.code,
      recipientName: recipient.name,
      body: text,
      createdAt: now,
      contentType: contentType,
      attachmentName: attachmentName,
      attachmentMimeType: attachmentMimeType,
      attachmentDataUrl: attachmentDataUrl,
      expiresAt: contentType == 'text'
          ? null
          : now.add(const Duration(days: 7)),
    );
    messages.add(message);
    enqueueSyncOperation(
      entityName: 'message',
      entityId: message.id,
      operationName: 'create',
      payload: messageSyncPayload(message),
    );
    markDirty();
  }

  bool canEditMessage(AppMessage message) {
    if (!message.isChat) return false;
    if (message.senderCode != activeUser.code) return false;
    if (message.isDeletedForEveryone) return false;
    return message.recipientReadAt == null;
  }

  bool editInternalMessage({
    required AppMessage message,
    required String body,
    String? attachmentName,
    String? attachmentMimeType,
    String? attachmentDataUrl,
    String? contentType,
  }) {
    if (!canEditMessage(message)) return false;
    final index = messages.indexWhere((entry) => entry.id == message.id);
    if (index == -1) return false;
    messages[index] = messages[index].copyWith(
      body: body.trim(),
      contentType: contentType ?? message.contentType,
      attachmentName: attachmentName ?? message.attachmentName,
      attachmentMimeType: attachmentMimeType ?? message.attachmentMimeType,
      attachmentDataUrl: attachmentDataUrl ?? message.attachmentDataUrl,
      editedAt: DateTime.now(),
      expiresAt: (contentType ?? message.contentType) == 'text'
          ? null
          : DateTime.now().add(const Duration(days: 7)),
    );
    enqueueSyncOperation(
      entityName: 'message',
      entityId: messages[index].id,
      operationName: 'update',
      payload: messageSyncPayload(messages[index]),
    );
    markDirty();
    return true;
  }

  void deleteMessageForEveryone(AppMessage message) {
    if (message.senderCode != activeUser.code) return;
    final index = messages.indexWhere((entry) => entry.id == message.id);
    if (index == -1) return;
    messages[index] = messages[index].copyWith(
      body: 'Message supprime',
      attachmentDataUrl: null,
      attachmentMimeType: null,
      attachmentName: null,
      deletedForEveryoneAt: DateTime.now(),
      editedAt: DateTime.now(),
    );
    enqueueSyncOperation(
      entityName: 'message',
      entityId: messages[index].id,
      operationName: 'update',
      payload: messageSyncPayload(messages[index]),
    );
    markDirty();
  }

  void deleteMessageForCurrentUser(AppMessage message) {
    hiddenMessageKeys.add(_hiddenMessageKey(activeUser.code, message.id));
    markDirty();
  }

  void sendForgotPasswordRequest(AppUser requester) {
    final admin = users.where((user) => user.isAdmin).firstOrNull;
    if (admin == null) return;
    final request = AppMessage.chat(
      id: 'forgot-${DateTime.now().millisecondsSinceEpoch}-${requester.code}-${admin.code}',
      senderCode: requester.code,
      senderName: requester.name,
      recipientCode: admin.code,
      recipientName: admin.name,
      body:
          'Bonjour, j ai oublie le mot de passe du compte ${requester.username}. Merci de m aider a le reinitialiser.',
      createdAt: DateTime.now(),
    );
    messages.add(request);
    enqueueSyncOperation(
      entityName: 'message',
      entityId: request.id,
      operationName: 'create',
      payload: messageSyncPayload(request),
    );
    final ack = AppMessage.system(
      title: 'Demande envoyee',
      body:
          'La demande de reinitialisation du compte ${requester.username} a ete transmise a l’administrateur.',
      id: 'forgot-ack-${DateTime.now().millisecondsSinceEpoch}-${requester.code}',
      createdAt: DateTime.now(),
      recipientCode: requester.code,
      recipientName: requester.name,
    );
    messages.add(ack);
    enqueueSyncOperation(
      entityName: 'message',
      entityId: ack.id,
      operationName: 'create',
      payload: messageSyncPayload(ack),
    );
    markDirty();
  }

  Product? findProduct(String name) => products.where((p) => p.name == name).firstOrNull;

  num debtForCustomer(Customer customer) => sales
      .where((sale) => sale.customer.code == customer.code)
      .fold<num>(0, (sum, sale) => sum + sale.due);

  List<Sale> creditSalesForCustomer(Customer customer) => sales
      .where((sale) => sale.customer.code == customer.code && sale.due > 0)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<RecentActivity> get recentActivities {
    final activities = <RecentActivity>[
      ...visibleSales.map(
        (sale) => RecentActivity(
          icon: Icons.point_of_sale_rounded,
          title: 'Vente ${sale.invoiceNo}',
          subtitle:
              '${sale.customer.name} - ${sale.cashierName} - ${sale.lines.fold<num>(0, (sum, line) => sum + line.qty).round()} article(s)',
          trailing: money(sale.total),
          createdAt: sale.createdAt,
        ),
      ),
      ...visiblePurchases.map(
        (purchase) => RecentActivity(
          icon: Icons.move_to_inbox_rounded,
          title: 'Approvisionnement ${purchase.reference}',
          subtitle: '${purchase.product} via ${purchase.supplier}',
          trailing: money(purchase.total),
          createdAt: purchase.createdAt,
        ),
      ),
      ...visibleExpenses.map(
        (expense) => RecentActivity(
          icon: Icons.remove_circle_outline_rounded,
          title: 'Depense ${expense.label}',
          subtitle: 'Sortie de caisse enregistree',
          trailing: money(expense.amount),
          createdAt: expense.createdAt,
        ),
      ),
      ...visibleStockMoves
          .where((move) => move.type != 'OPENING')
          .map(
            (move) => RecentActivity(
              icon: Icons.sync_alt_rounded,
              title: 'Mouvement ${move.type}',
              subtitle: '${move.product} - ref ${move.reference}',
              trailing: '${move.quantity > 0 ? '+' : ''}${move.quantity.round()}',
              createdAt: move.createdAt,
            ),
          ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (activities.isEmpty) {
      return [
        RecentActivity(
          icon: Icons.waving_hand_rounded,
          title: 'Bienvenue dans KESE',
          subtitle: 'Les nouvelles ventes et mouvements apparaîtront ici.',
          trailing: 'Maintenant',
          createdAt: DateTime.now(),
        ),
      ];
    }
    return activities;
  }

  List<ProductSalesInsight> productSalesInsights(String query) {
    if (query.trim().isEmpty) return const [];
    return products.where((product) {
      return _matchesSearchText(
        '${product.name} ${product.category} ${product.sku} ${product.barcode}',
        query,
      );
    }).map((product) {
      num soldQty = 0;
      num soldAmount = 0;
      num soldProfit = 0;
      for (final sale in visibleSales) {
        for (final line in sale.lines.where((line) => line.product == product.name)) {
          soldQty += line.qty;
          soldAmount += line.qty * line.price;
          soldProfit += line.qty * (line.price - line.cost);
        }
      }
      final stockAmount = product.quantity * product.price;
      final remainingProfit = product.quantity * (product.price - product.cost);
      final totalPotential = (soldQty + product.quantity) * product.price;
      final totalProfitPotential =
          (soldQty + product.quantity) * (product.price - product.cost);
      return ProductSalesInsight(
        product: product,
        soldQty: soldQty,
        soldAmount: soldAmount,
        soldProfit: soldProfit,
        stockAmount: stockAmount,
        remainingProfit: remainingProfit,
        totalPotential: totalPotential,
        totalProfitPotential: totalProfitPotential,
      );
    }).toList();
  }

  String money(num value) => '${value.round()} ${settings.currency}';
}

class CodeGenerator {
  CodeGenerator({
    this.product = 1,
    this.customer = 1,
    this.supplier = 1,
    this.user = 1,
    this.invoice = 1,
    this.ticket = 1,
    this.order = 1,
    this.purchase = 1,
  });

  int product = 1;
  int customer = 1;
  int supplier = 1;
  int user = 1;
  int invoice = 1;
  int ticket = 1;
  int order = 1;
  int purchase = 1;

  String nextProduct() => 'PRD-${_six(product++)}';
  String nextSku() => 'SKU-${_six(product + 210)}';
  String nextBarcode() =>
      '2${DateTime.now().millisecondsSinceEpoch.toString().substring(3, 12)}';
  String nextCustomer() => 'CLI-${_six(customer++)}';
  String nextSupplier() => 'FRN-${_six(supplier++)}';
  String nextUser() => 'USR-${_six(user++)}';
  String nextInvoice() => 'FAC-${DateTime.now().year}-${_six(invoice++)}';
  String nextTicket() => 'TCK-${DateTime.now().year}-${_six(ticket++)}';
  String nextOrder() => 'CMD-${DateTime.now().year}-${_six(order++)}';
  String nextPurchase() => 'ACH-${DateTime.now().year}-${_six(purchase++)}';
  String _six(int value) => value.toString().padLeft(6, '0');
}

Map<String, dynamic> _storeToJson(AppStore store) => {
      'tenantId': store.tenantId,
      'branchId': store.branchId,
      'deviceId': store.deviceId,
      'activeUserCode': store.activeUser.code,
      'changeCounter': store.changeCounter,
      'lastSyncedCounter': store.lastSyncedCounter,
      'lastSyncAt': store.lastSyncAt?.toIso8601String(),
      'cloudAccessConfigured': store.cloudAccessConfigured,
      'cloudSession': store.cloudSession?.toJson(),
      'pendingCloudActivation': store.pendingCloudActivation?.toJson(),
      'readAlertIds': store.readAlertIds.toList(),
      'readMessageIds': store.readMessageIds.toList(),
      'hiddenMessageKeys': store.hiddenMessageKeys.toList(),
      'codes': {
        'product': store.codes.product,
        'customer': store.codes.customer,
        'supplier': store.codes.supplier,
        'user': store.codes.user,
        'invoice': store.codes.invoice,
        'ticket': store.codes.ticket,
        'order': store.codes.order,
        'purchase': store.codes.purchase,
      },
      'settings': {
        'companyName': store.settings.companyName,
        'ownerName': store.settings.ownerName,
        'logoUrl': store.settings.logoUrl,
        'phone': store.settings.phone,
        'email': store.settings.email,
        'address': store.settings.address,
        'rccm': store.settings.rccm,
        'idNat': store.settings.idNat,
        'nif': store.settings.nif,
        'efo': store.settings.efo,
        'currency': store.settings.currency,
        'taxRate': store.settings.taxRate,
      },
      'categories': store.categories,
      'products': store.products
          .map(
            (product) => {
              'code': product.code,
              'sku': product.sku,
              'barcode': product.barcode,
              'name': product.name,
              'category': product.category,
              'unit': product.unit,
              'cost': product.cost,
              'price': product.price,
              'quantity': product.quantity,
              'minQuantity': product.minQuantity,
              'location': product.location,
              'imageUrl': product.imageUrl,
            },
          )
          .toList(),
      'customers': store.customers
          .map(
            (customer) => {
              'code': customer.code,
              'name': customer.name,
              'phone': customer.phone,
              'address': customer.address,
              'lastEditedByCode': customer.lastEditedByCode,
              'lastEditedByName': customer.lastEditedByName,
            },
          )
          .toList(),
      'suppliers': store.suppliers
          .map(
            (supplier) => {
              'code': supplier.code,
              'name': supplier.name,
              'phone': supplier.phone,
              'address': supplier.address,
            },
          )
          .toList(),
      'users': store.users
          .map(
            (user) => {
              'code': user.code,
              'name': user.name,
              'username': user.username,
              'role': user.role,
              'pin': user.pin,
              'isBlocked': user.isBlocked,
            },
          )
          .toList(),
      'sales': store.sales
          .map(
            (sale) => {
              'orderNo': sale.orderNo,
              'invoiceNo': sale.invoiceNo,
              'ticketNo': sale.ticketNo,
              'customerCode': sale.customer.code,
              'cashierName': sale.cashierName,
              'cashierCode': sale.cashierCode,
              'subtotal': sale.subtotal,
              'discount': sale.discount,
              'total': sale.total,
              'paid': sale.paid,
              'method': sale.method,
              'createdAt': sale.createdAt.toIso8601String(),
              'dueDate': sale.dueDate.toIso8601String(),
              'lines': sale.lines
                  .map(
                    (line) => {
                      'product': line.product,
                      'qty': line.qty,
                      'price': line.price,
                      'cost': line.cost,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'purchases': store.purchases
          .map(
            (purchase) => {
              'reference': purchase.reference,
              'product': purchase.product,
              'supplier': purchase.supplier,
              'authorCode': purchase.authorCode,
              'authorName': purchase.authorName,
              'quantity': purchase.quantity,
              'total': purchase.total,
              'paid': purchase.paid,
              'createdAt': purchase.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'expenses': store.expenses
          .map(
            (expense) => {
              'label': expense.label,
              'authorCode': expense.authorCode,
              'authorName': expense.authorName,
              'amount': expense.amount,
              'createdAt': expense.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'stockMoves': store.stockMoves
          .map(
            (move) => {
              'type': move.type,
              'product': move.product,
              'quantity': move.quantity,
              'reference': move.reference,
              'createdAt': move.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'alerts': store.alerts
          .map(
            (alert) => {
              'id': alert.id,
              'title': alert.title,
              'body': alert.body,
              'level': alert.level.name,
              'createdAt': alert.createdAt.toIso8601String(),
              'readAt': alert.readAt?.toIso8601String(),
            },
          )
          .toList(),
      'messages': store.messages
          .map(
            (message) => {
              'id': message.id,
              'title': message.title,
              'body': message.body,
              'type': message.type,
              'contentType': message.contentType,
              'createdAt': message.createdAt.toIso8601String(),
              'attachmentName': message.attachmentName,
              'attachmentMimeType': message.attachmentMimeType,
              'attachmentDataUrl': message.attachmentDataUrl,
              'expiresAt': message.expiresAt?.toIso8601String(),
              'editedAt': message.editedAt?.toIso8601String(),
              'senderCode': message.senderCode,
              'senderName': message.senderName,
              'recipientCode': message.recipientCode,
              'recipientName': message.recipientName,
              'recipientReadAt': message.recipientReadAt?.toIso8601String(),
              'deletedForEveryoneAt': message.deletedForEveryoneAt?.toIso8601String(),
              'readAt': message.readAt?.toIso8601String(),
            },
          )
          .toList(),
      'syncQueue': store.syncQueue
          .map(
            (entry) => {
              'id': entry.id,
              'tenantId': entry.tenantId,
              'branchId': entry.branchId,
              'deviceId': entry.deviceId,
              'entityName': entry.entityName,
              'entityId': entry.entityId,
              'operationName': entry.operationName,
              'payloadJson': entry.payloadJson,
              'payloadHash': entry.payloadHash,
              'status': entry.status.name,
              'retryCount': entry.retryCount,
              'lastError': entry.lastError,
              'createdAt': entry.createdAt.toIso8601String(),
              'updatedAt': entry.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'syncConflicts': store.syncConflicts
          .map(
            (entry) => {
              'id': entry.id,
              'tenantId': entry.tenantId,
              'branchId': entry.branchId,
              'deviceId': entry.deviceId,
              'entityName': entry.entityName,
              'localEntityId': entry.localEntityId,
              'serverEntityId': entry.serverEntityId,
              'conflictType': entry.conflictType,
              'localPayloadJson': entry.localPayloadJson,
              'serverPayloadJson': entry.serverPayloadJson,
              'resolutionStatus': entry.resolutionStatus,
              'createdAt': entry.createdAt.toIso8601String(),
              'resolvedAt': entry.resolvedAt?.toIso8601String(),
            },
          )
          .toList(),
    };

int _nextCodeValue(Iterable<String> values, String prefix) {
  var maxValue = 0;
  for (final value in values) {
    if (!value.startsWith(prefix)) continue;
    final parsed = int.tryParse(value.substring(prefix.length));
    if (parsed != null && parsed > maxValue) {
      maxValue = parsed;
    }
  }
  return maxValue + 1;
}

AppStore _storeFromJson(Map<String, dynamic> json) {
  final settingsJson = _asMap(json['settings']);
  final codesJson = _asMap(json['codes']);

  final settings = CompanySettings()
    ..companyName = _asString(settingsJson['companyName'], 'Votre entreprise')
    ..ownerName = _asString(settingsJson['ownerName'], 'Responsable')
    ..logoUrl = _asString(settingsJson['logoUrl'])
    ..phone = _asString(settingsJson['phone'], '+243 000 000 000')
    ..email = _asString(settingsJson['email'])
    ..address = _asString(settingsJson['address'], 'Kinshasa')
    ..rccm = _asString(settingsJson['rccm'])
    ..idNat = _asString(settingsJson['idNat'])
    ..nif = _asString(settingsJson['nif'])
    ..efo = _asString(settingsJson['efo'])
    ..currency = _asString(settingsJson['currency'], 'FC')
    ..taxRate = _asNum(settingsJson['taxRate']);

  final customers = _asList(json['customers'])
      .map(
        (raw) => Customer(
          code: _asString(raw['code']),
          name: _asString(raw['name']),
          phone: _asString(raw['phone']),
          address: _asString(raw['address']),
          lastEditedByCode: _asString(raw['lastEditedByCode']),
          lastEditedByName: _asString(raw['lastEditedByName']),
        ),
      )
      .toList();

  final suppliers = _asList(json['suppliers'])
      .map(
        (raw) => Supplier(
          code: _asString(raw['code']),
          name: _asString(raw['name']),
          phone: _asString(raw['phone']),
          address: _asString(raw['address']),
        ),
      )
      .toList();

  final users = _asList(json['users'])
      .map(
        (raw) => AppUser(
          code: _asString(raw['code']),
          name: _asString(raw['name']),
          username: _asString(raw['username']),
          role: _asString(raw['role']),
          pin: _asString(raw['pin']),
          isBlocked: _asBool(raw['isBlocked']),
        ),
      )
      .toList();

  final products = _asList(json['products'])
      .map(
        (raw) => Product(
          code: _asString(raw['code']),
          sku: _asString(raw['sku']),
          barcode: _asString(raw['barcode']),
          name: _asString(raw['name']),
          category: _asString(raw['category']),
          unit: _asString(raw['unit'], 'piece'),
          cost: _asNum(raw['cost']),
          price: _asNum(raw['price']),
          quantity: _asNum(raw['quantity']),
          minQuantity: _asNum(raw['minQuantity'], 3),
          location: _asString(raw['location'], 'Rayon principal'),
          icon: Icons.inventory_2_rounded,
          imageUrl: _asString(raw['imageUrl']),
        ),
      )
      .toList();

  Customer customerByCode(String code) =>
      customers.where((customer) => customer.code == code).firstOrNull ??
      Customer(
        code: code,
        name: 'Client',
        phone: '',
        address: '',
      );

  final sales = _asList(json['sales'])
      .map(
        (raw) => Sale(
          orderNo: _asString(raw['orderNo']),
          invoiceNo: _asString(raw['invoiceNo']),
          ticketNo: _asString(raw['ticketNo']),
          customer: customerByCode(_asString(raw['customerCode'])),
          cashierName: _asString(raw['cashierName']),
          cashierCode: _asString(raw['cashierCode']),
          lines: _asList(raw['lines'])
              .map(
                (line) => SaleLine(
                  product: _asString(line['product']),
                  qty: _asNum(line['qty'], 1),
                  price: _asNum(line['price']),
                  cost: _asNum(line['cost']),
                ),
              )
              .toList(),
          subtotal: _asNum(raw['subtotal']),
          discount: _asNum(raw['discount']),
          total: _asNum(raw['total']),
          paid: _asNum(raw['paid']),
          method: _asString(raw['method']),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
          dueDate: _asDate(raw['dueDate']) ?? DateTime.now(),
        ),
      )
      .toList();

  final purchases = _asList(json['purchases'])
      .map(
        (raw) => Purchase(
          reference: _asString(raw['reference']),
          product: _asString(raw['product']),
          supplier: _asString(raw['supplier']),
          authorCode: _asString(raw['authorCode']),
          authorName: _asString(raw['authorName']),
          quantity: _asNum(raw['quantity']),
          total: _asNum(raw['total']),
          paid: _asNum(raw['paid']),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
        ),
      )
      .toList();

  final expenses = _asList(json['expenses'])
      .map(
        (raw) => Expense(
          label: _asString(raw['label']),
          authorCode: _asString(raw['authorCode']),
          authorName: _asString(raw['authorName']),
          amount: _asNum(raw['amount']),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
        ),
      )
      .toList();

  final stockMoves = _asList(json['stockMoves'])
      .map(
        (raw) => StockMove(
          type: _asString(raw['type']),
          product: _asString(raw['product']),
          quantity: _asNum(raw['quantity']),
          reference: _asString(raw['reference']),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
        ),
      )
      .toList();

  final alerts = _asList(json['alerts'])
      .map(
        (raw) => AppAlert(
          id: _asString(raw['id']),
          title: _asString(raw['title']),
          body: _asString(raw['body']),
          level: _alertLevelFromString(_asString(raw['level'], 'info')),
          createdAt: _asDate(raw['createdAt']),
          readAt: _asDate(raw['readAt']),
        ),
      )
      .toList();

  final messages = _asList(json['messages'])
      .map(
        (raw) => AppMessage(
          id: _asString(raw['id']),
          title: _asString(raw['title']),
          body: _asString(raw['body']),
          type: _asString(raw['type'], 'system'),
          contentType: _asString(raw['contentType'], 'text'),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
          attachmentName: _nullableString(raw['attachmentName']),
          attachmentMimeType: _nullableString(raw['attachmentMimeType']),
          attachmentDataUrl: _nullableString(raw['attachmentDataUrl']),
          expiresAt: _asDate(raw['expiresAt']),
          editedAt: _asDate(raw['editedAt']),
          senderCode: _nullableString(raw['senderCode']),
          senderName: _nullableString(raw['senderName']),
          recipientCode: _nullableString(raw['recipientCode']),
          recipientName: _nullableString(raw['recipientName']),
          recipientReadAt: _asDate(raw['recipientReadAt']),
          deletedForEveryoneAt: _asDate(raw['deletedForEveryoneAt']),
          readAt: _asDate(raw['readAt']),
        ),
      )
      .toList();

  final syncQueue = _asList(json['syncQueue'])
      .map(
        (raw) => SyncQueueEntry(
          id: _asString(raw['id']),
          tenantId: _asString(raw['tenantId'], _asString(json['tenantId'])),
          branchId: _asString(raw['branchId'], _asString(json['branchId'])),
          deviceId: _asString(raw['deviceId'], _asString(json['deviceId'])),
          entityName: _asString(raw['entityName']),
          entityId: _asString(raw['entityId']),
          operationName: _asString(raw['operationName']),
          payloadJson: _asString(raw['payloadJson'], '{}'),
          payloadHash: _asString(raw['payloadHash']),
          status: _syncOperationStatusFromString(
            _asString(raw['status'], 'pending'),
          ),
          retryCount: _asInt(raw['retryCount'], 0),
          lastError: _nullableString(raw['lastError']),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
          updatedAt: _asDate(raw['updatedAt']) ?? DateTime.now(),
        ),
      )
      .toList();

  final syncConflicts = _asList(json['syncConflicts'])
      .map(
        (raw) => SyncConflictEntry(
          id: _asString(raw['id']),
          tenantId: _asString(raw['tenantId'], _asString(json['tenantId'])),
          branchId: _asString(raw['branchId'], _asString(json['branchId'])),
          deviceId: _asString(raw['deviceId'], _asString(json['deviceId'])),
          entityName: _asString(raw['entityName']),
          localEntityId: _asString(raw['localEntityId']),
          serverEntityId: _nullableString(raw['serverEntityId']),
          conflictType: _asString(raw['conflictType']),
          localPayloadJson: _asString(raw['localPayloadJson'], '{}'),
          serverPayloadJson: _nullableString(raw['serverPayloadJson']),
          resolutionStatus: _asString(raw['resolutionStatus'], 'open'),
          createdAt: _asDate(raw['createdAt']) ?? DateTime.now(),
          resolvedAt: _asDate(raw['resolvedAt']),
        ),
      )
      .toList();

  final cloudSessionJson = _asMap(json['cloudSession']);
  final cloudSession = cloudSessionJson.isEmpty
      ? null
      : KeseCloudSession.fromJson(cloudSessionJson);
  final pendingActivationJson = _asMap(json['pendingCloudActivation']);
  final pendingCloudActivation = pendingActivationJson.isEmpty
      ? null
      : PendingCloudActivation.fromJson(pendingActivationJson);
  final cloudAccessConfigured = _asBool(json['cloudAccessConfigured']);

  final codes = CodeGenerator(
    product: _asInt(codesJson['product'], 1),
    customer: _asInt(codesJson['customer'], 1),
    supplier: _asInt(codesJson['supplier'], 1),
    user: _asInt(codesJson['user'], 1),
    invoice: _asInt(codesJson['invoice'], 1),
    ticket: _asInt(codesJson['ticket'], 1),
    order: _asInt(codesJson['order'], 1),
    purchase: _asInt(codesJson['purchase'], 1),
  );

  final activeUserCode = _asString(json['activeUserCode']);
  final activeUser = users.where((user) => user.code == activeUserCode).firstOrNull ??
      (users.isNotEmpty
          ? users.first
          : AppUser(
              code: codes.nextUser(),
              name: 'Administrateur',
              username: 'Admin',
              role: 'Admin',
              pin: 'Admin@2026',
            ));
  if (users.isEmpty) {
    users.add(activeUser);
  }

  final store = AppStore(
    tenantId: _asString(json['tenantId'], 'tenant-demo-kese'),
    branchId: _asString(json['branchId'], 'branch-main'),
    deviceId: _asString(json['deviceId'], 'device-local-demo'),
    settings: settings,
    codes: codes,
    categories: _asDynamicList(json['categories'])
        .map((entry) => _asString(entry))
        .where((entry) => entry.isNotEmpty)
        .toList(),
    products: products,
    customers: customers,
    suppliers: suppliers,
    users: users,
    sales: sales,
    purchases: purchases,
    expenses: expenses,
    stockMoves: stockMoves,
    alerts: alerts,
    messages: messages,
    syncQueue: syncQueue,
    syncConflicts: syncConflicts,
    activeUser: activeUser,
    cloudAccessConfigured: cloudAccessConfigured || cloudSession != null,
    cloudSession: cloudSession,
    pendingCloudActivation: pendingCloudActivation,
    readAlertIds: _asList(json['readAlertIds']).map((entry) => _asString(entry)).toSet(),
    readMessageIds: _asList(json['readMessageIds'])
        .map((entry) => _asString(entry))
        .toSet(),
    hiddenMessageKeys: _asList(json['hiddenMessageKeys'])
        .map((entry) => _asString(entry))
        .toSet(),
    changeCounter: _asInt(json['changeCounter'], 0),
    lastSyncedCounter: _asInt(json['lastSyncedCounter'], 0),
    lastSyncAt: _asDate(json['lastSyncAt']),
  );
  store.reconcileCodeCounters();
  return store;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry('$key', val));
  }
  return <String, dynamic>{};
}

List<dynamic> _asDynamicList(dynamic value) => value is List ? value : const [];

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((entry) => entry.map((key, val) => MapEntry('$key', val)))
        .toList();
  }
  return const <Map<String, dynamic>>[];
}

String _asString(dynamic value, [String fallback = '']) =>
    value == null ? fallback : '$value';

String? _nullableString(dynamic value) {
  final normalized = _asString(value);
  return normalized.isEmpty ? null : normalized;
}

num _asNum(dynamic value, [num fallback = 0]) {
  if (value is num) return value;
  return num.tryParse('${value ?? ''}') ?? fallback;
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse('${value ?? ''}') ?? fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  final text = _asString(value).toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

DateTime? _asDate(dynamic value) {
  final text = _nullableString(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}

SyncOperationStatus _syncOperationStatusFromString(String value) => switch (value) {
      'synced' => SyncOperationStatus.synced,
      'failed' => SyncOperationStatus.failed,
      'conflict' => SyncOperationStatus.conflict,
      _ => SyncOperationStatus.pending,
    };

AlertLevel _alertLevelFromString(String value) => switch (value) {
      'warning' => AlertLevel.warning,
      'danger' => AlertLevel.danger,
      _ => AlertLevel.info,
    };

String _stableHash(String input) {
  var hash = 0x811C9DC5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toUnsigned(32).toRadixString(16).padLeft(8, '0');
}

class CompanySettings {
  String companyName = 'Votre entreprise';
  String ownerName = 'Responsable';
  String logoUrl = '';
  String phone = '+243 000 000 000';
  String email = '';
  String address = 'Kinshasa';
  String rccm = '';
  String idNat = '';
  String nif = '';
  String efo = '';
  String currency = 'FC';
  num taxRate = 0;
}

class Product {
  Product({
    required this.code,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.category,
    required this.unit,
    required this.cost,
    required this.price,
    required this.quantity,
    required this.minQuantity,
    required this.location,
    required this.icon,
    required this.imageUrl,
  });

  factory Product.demo(
    String code,
    String name,
    String category,
    num cost,
    num price,
    num qty,
    IconData icon,
    {String imageUrl = ''}
  ) {
    return Product(
      code: code,
      sku: 'SKU-${code.substring(4)}',
      barcode:
          '2${DateTime.now().millisecondsSinceEpoch.toString().substring(3, 12)}',
      name: name,
      category: category,
      unit: 'piece',
      cost: cost,
      price: price,
      quantity: qty,
      minQuantity: 3,
      location: 'Rayon principal',
      icon: icon,
      imageUrl: imageUrl,
    );
  }

  final String code;
  String sku;
  String barcode;
  String name;
  String category;
  String unit;
  num cost;
  num price;
  num quantity;
  num minQuantity;
  String location;
  IconData icon;
  String imageUrl;

  String get quantityText => '${quantity.round()} $unit';
}

class Customer {
  Customer({
    required this.code,
    required this.name,
    required this.phone,
    required this.address,
    this.lastEditedByCode = '',
    this.lastEditedByName = '',
  });
  final String code;
  final String name;
  final String phone;
  final String address;
  final String lastEditedByCode;
  final String lastEditedByName;
}

class Supplier {
  Supplier({
    required this.code,
    required this.name,
    required this.phone,
    required this.address,
  });
  final String code;
  final String name;
  final String phone;
  final String address;
}

class AppUser {
  AppUser({
    required this.code,
    required this.name,
    required this.username,
    required this.role,
    required this.pin,
    this.isBlocked = false,
  });
  final String code;
  final String name;
  String username;
  final String role;
  String pin;
  bool isBlocked;

  bool get isAdmin => role == 'Admin';
  bool get isManager => role == 'Gestionnaire' || role == 'Manager';
  bool get isCashier => role == 'Caissier';
  bool get canSeeNotifications => true;
  bool get canManageUsers => isAdmin;
  bool get canManageSettings => isAdmin || isManager;
  bool get canManageCatalog => isAdmin || isManager;
  bool get canAccessAccounting => isAdmin || isManager;
  bool get canAccessReports => isAdmin || isManager;
  bool get canAccessPurchases => isAdmin || isManager;
  bool get canAccessPeople => true;
  bool get canAccessCustomers => true;
  bool get canAccessSuppliers => isAdmin || isManager;
  bool get canAccessCredits => isAdmin || isManager;
  bool get canSeeFinancials => true;
  bool get canSeeProfit => !isCashier;
  bool get canSeeCompanyWideNotifications => isAdmin || isManager;
  bool get canSeeGlobalStockInsights => isAdmin || isManager;
  bool get canAccessUsersModule => isAdmin;
}

class CartLine {
  CartLine({required this.product});
  final Product product;
  num qty = 1;
}

class SaleLine {
  SaleLine({
    required this.product,
    required this.qty,
    required this.price,
    required this.cost,
  });
  final String product;
  final num qty;
  final num price;
  final num cost;
}

class Sale {
  Sale({
    required this.orderNo,
    required this.invoiceNo,
    required this.ticketNo,
    required this.customer,
    required this.cashierName,
    required this.cashierCode,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paid,
    required this.method,
    required this.createdAt,
    required this.dueDate,
  });
  final String orderNo;
  final String invoiceNo;
  final String ticketNo;
  final Customer customer;
  final String cashierName;
  final String cashierCode;
  final List<SaleLine> lines;
  final num subtotal;
  final num discount;
  final num total;
  num paid;
  final String method;
  final DateTime createdAt;
  final DateTime dueDate;
  num get due => (total - paid).clamp(0, double.infinity);
  String get status => due <= 0 ? 'Payée' : 'Crédit';
  bool get isCredit => due > 0;
}

class Purchase {
  Purchase({
    required this.reference,
    required this.product,
    required this.supplier,
    required this.authorCode,
    required this.authorName,
    required this.quantity,
    required this.total,
    required this.paid,
    required this.createdAt,
  });
  final String reference;
  final String product;
  final String supplier;
  final String authorCode;
  final String authorName;
  final num quantity;
  final num total;
  final num paid;
  final DateTime createdAt;
  num get due => (total - paid).clamp(0, double.infinity);
}

class Expense {
  Expense({
    required this.label,
    required this.authorCode,
    required this.authorName,
    required this.amount,
    required this.createdAt,
  });
  final String label;
  final String authorCode;
  final String authorName;
  final num amount;
  final DateTime createdAt;
}

class StockMove {
  StockMove({
    required this.type,
    required this.product,
    required this.quantity,
    required this.reference,
    required this.createdAt,
  });
  final String type;
  final String product;
  final num quantity;
  final String reference;
  final DateTime createdAt;
}

class AppAlert {
  AppAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.level,
    DateTime? createdAt,
    this.readAt,
  }) : createdAt = createdAt ?? DateTime.now();
  factory AppAlert.info(
    String title,
    String body, {
    String? id,
    DateTime? createdAt,
  }) => AppAlert(
    id: id ?? 'info-${DateTime.now().millisecondsSinceEpoch}',
    title: title,
    body: body,
    level: AlertLevel.info,
    createdAt: createdAt,
  );
  factory AppAlert.warning(
    String title,
    String body, {
    String? id,
    DateTime? createdAt,
  }) => AppAlert(
    id: id ?? 'warning-${DateTime.now().millisecondsSinceEpoch}',
    title: title,
    body: body,
    level: AlertLevel.warning,
    createdAt: createdAt,
  );
  factory AppAlert.danger(
    String title,
    String body, {
    String? id,
    DateTime? createdAt,
  }) => AppAlert(
    id: id ?? 'danger-${DateTime.now().millisecondsSinceEpoch}',
    title: title,
    body: body,
    level: AlertLevel.danger,
    createdAt: createdAt,
  );
  final String id;
  final String title;
  final String body;
  final AlertLevel level;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  AppAlert copyWith({DateTime? readAt}) => AppAlert(
    id: id,
    title: title,
    body: body,
    level: level,
    createdAt: createdAt,
    readAt: readAt,
  );
}

class AppMessage {
  AppMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.senderCode,
    this.senderName,
    this.recipientCode,
    this.recipientName,
    this.contentType = 'text',
    this.attachmentName,
    this.attachmentMimeType,
    this.attachmentDataUrl,
    this.expiresAt,
    this.editedAt,
    this.recipientReadAt,
    this.deletedForEveryoneAt,
    this.readAt,
  });

  factory AppMessage.system({
    required String title,
    required String body,
    required String id,
    required DateTime createdAt,
    String? recipientCode,
    String? recipientName,
  }) => AppMessage(
    id: id,
    title: title,
    body: body,
    type: 'system',
    createdAt: createdAt,
    recipientCode: recipientCode,
    recipientName: recipientName,
  );

  factory AppMessage.chat({
    required String id,
    required String senderCode,
    required String senderName,
    required String recipientCode,
    required String recipientName,
    required String body,
    required DateTime createdAt,
    String contentType = 'text',
    String? attachmentName,
    String? attachmentMimeType,
    String? attachmentDataUrl,
    DateTime? expiresAt,
    DateTime? editedAt,
    DateTime? recipientReadAt,
    DateTime? deletedForEveryoneAt,
  }) => AppMessage(
    id: id,
    title: senderName,
    body: body,
    type: 'chat',
    createdAt: createdAt,
    senderCode: senderCode,
    senderName: senderName,
    recipientCode: recipientCode,
    recipientName: recipientName,
    contentType: contentType,
    attachmentName: attachmentName,
    attachmentMimeType: attachmentMimeType,
    attachmentDataUrl: attachmentDataUrl,
    expiresAt: expiresAt,
    editedAt: editedAt,
    recipientReadAt: recipientReadAt,
    deletedForEveryoneAt: deletedForEveryoneAt,
  );

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final String? senderCode;
  final String? senderName;
  final String? recipientCode;
  final String? recipientName;
  final String contentType;
  final String? attachmentName;
  final String? attachmentMimeType;
  final String? attachmentDataUrl;
  final DateTime? expiresAt;
  final DateTime? editedAt;
  final DateTime? recipientReadAt;
  final DateTime? deletedForEveryoneAt;
  final DateTime? readAt;

  bool get isChat => type == 'chat';
  bool get isSystem => type == 'system';
  bool get isRead => readAt != null;
  bool get isDeletedForEveryone => deletedForEveryoneAt != null;
  bool get hasAttachment => attachmentDataUrl != null && attachmentDataUrl!.isNotEmpty;
  bool get isMediaMessage => contentType != 'text';
  bool get isMediaExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get canDisplayAttachment =>
      hasAttachment && !isDeletedForEveryone && !isMediaExpired;

  AppMessage copyWith({
    DateTime? readAt,
    String? title,
    String? body,
    String? type,
    String? contentType,
    String? attachmentName,
    String? attachmentMimeType,
    String? attachmentDataUrl,
    DateTime? expiresAt,
    DateTime? editedAt,
    DateTime? recipientReadAt,
    DateTime? deletedForEveryoneAt,
  }) => AppMessage(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    createdAt: createdAt,
    senderCode: senderCode,
    senderName: senderName,
    recipientCode: recipientCode,
    recipientName: recipientName,
    contentType: contentType ?? this.contentType,
    attachmentName: attachmentName ?? this.attachmentName,
    attachmentMimeType: attachmentMimeType ?? this.attachmentMimeType,
    attachmentDataUrl: attachmentDataUrl ?? this.attachmentDataUrl,
    expiresAt: expiresAt ?? this.expiresAt,
    editedAt: editedAt ?? this.editedAt,
    recipientReadAt: recipientReadAt ?? this.recipientReadAt,
    deletedForEveryoneAt: deletedForEveryoneAt ?? this.deletedForEveryoneAt,
    readAt: readAt,
  );
}

enum SyncOperationStatus { pending, synced, failed, conflict }

class SyncQueueEntry {
  const SyncQueueEntry({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.deviceId,
    required this.entityName,
    required this.entityId,
    required this.operationName,
    required this.payloadJson,
    required this.payloadHash,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String branchId;
  final String deviceId;
  final String entityName;
  final String entityId;
  final String operationName;
  final String payloadJson;
  final String payloadHash;
  final SyncOperationStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncQueueEntry copyWith({
    SyncOperationStatus? status,
    int? retryCount,
    String? lastError,
    DateTime? updatedAt,
  }) => SyncQueueEntry(
    id: id,
    tenantId: tenantId,
    branchId: branchId,
    deviceId: deviceId,
    entityName: entityName,
    entityId: entityId,
    operationName: operationName,
    payloadJson: payloadJson,
    payloadHash: payloadHash,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class SyncConflictEntry {
  const SyncConflictEntry({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.deviceId,
    required this.entityName,
    required this.localEntityId,
    this.serverEntityId,
    required this.conflictType,
    required this.localPayloadJson,
    this.serverPayloadJson,
    required this.resolutionStatus,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String tenantId;
  final String branchId;
  final String deviceId;
  final String entityName;
  final String localEntityId;
  final String? serverEntityId;
  final String conflictType;
  final String localPayloadJson;
  final String? serverPayloadJson;
  final String resolutionStatus;
  final DateTime createdAt;
  final DateTime? resolvedAt;
}

enum AlertLevel { info, warning, danger }

class TodayMetrics {
  TodayMetrics({
    required this.salesCount,
    required this.revenue,
    required this.profit,
    required this.cash,
    required this.expenses,
  });
  final int salesCount;
  final num revenue;
  final num profit;
  final num cash;
  final num expenses;
}

class LedgerRow {
  LedgerRow(
    this.kind,
    this.reference,
    this.label,
    this.party,
    this.amount,
    this.createdAt,
  );
  final String kind;
  final String reference;
  final String label;
  final String party;
  final num amount;
  final DateTime createdAt;
}

class RecentActivity {
  RecentActivity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.createdAt,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final DateTime createdAt;
}

class ProductSalesInsight {
  const ProductSalesInsight({
    required this.product,
    required this.soldQty,
    required this.soldAmount,
    required this.soldProfit,
    required this.stockAmount,
    required this.remainingProfit,
    required this.totalPotential,
    required this.totalProfitPotential,
  });

  final Product product;
  final num soldQty;
  final num soldAmount;
  final num soldProfit;
  final num stockAmount;
  final num remainingProfit;
  final num totalPotential;
  final num totalProfitPotential;
}

class ModuleSpec {
  const ModuleSpec(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class ProductShowcase extends StatefulWidget {
  const ProductShowcase({super.key, required this.products});
  final List<Product> products;

  @override
  State<ProductShowcase> createState() => _ProductShowcaseState();
}

class _ProductShowcaseState extends State<ProductShowcase> {
  late final PageController _controller;
  Timer? _timer;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.products.length < 2) return;
      index = (index + 1) % widget.products.length;
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(
        child: Text(
          'Ajoute un produit pour voir le slide.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  Colors.white.withAlpha(6),
                  const Color(0xFF0E4E60).withAlpha(130),
                ]
              : [
                  Colors.white.withAlpha(26),
                  const Color(0xFFBCE7EF).withAlpha(110),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(24)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.products.length,
              onPageChanged: (value) => setState(() => index = value),
              itemBuilder: (context, pageIndex) =>
                  DashboardProductSlide(product: widget.products[pageIndex]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: List.generate(
                widget.products.length,
                (dot) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: dot == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dot == index ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.money,
    required this.onTap,
  });
  final Product product;
  final String Function(num value) money;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: onTap == null ? _softPanelColor(context) : _panelColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProductMedia(product: product),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                money(product.price),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _green,
                ),
              ),
              Text(
                '${product.category} - reste ${product.quantityText}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductStockTile extends StatelessWidget {
  const ProductStockTile({
    super.key,
    required this.product,
    required this.money,
    this.edit,
    this.move,
    required this.preview,
    this.delete,
  });
  final Product product;
  final String Function(num value) money;
  final VoidCallback? edit;
  final VoidCallback? move;
  final VoidCallback preview;
  final VoidCallback? delete;

  @override
  Widget build(BuildContext context) {
    final low = product.quantity <= product.minQuantity;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(desktop ? 14 : 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: preview,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: desktop ? 84 : 70,
                      height: desktop ? 84 : 70,
                      child: ProductMedia(product: product),
                    ),
                  ),
                ),
                SizedBox(width: desktop ? 14 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: desktop ? 16 : 14,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.category} - ${product.quantityText}',
                        style: TextStyle(
                          color: _mutedTextColor(context),
                          fontSize: desktop ? 13 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${money(product.price)} - ${product.sku}',
                        style: TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w800,
                          fontSize: desktop ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: desktop ? 12 : 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: desktop ? 210 : null,
                  child: OutlinedButton.icon(
                    onPressed: preview,
                    icon: Icon(
                      low ? Icons.visibility_rounded : Icons.inventory_2_rounded,
                      color: low ? _danger : _green,
                    ),
                    label: Text(move == null ? 'Voir la fiche' : 'Mouvement stock'),
                  ),
                ),
                if (move != null || edit != null || delete != null) ...[
                  if (move != null)
                    IconButton(
                      onPressed: move,
                      icon: Icon(
                        low ? Icons.warning_rounded : Icons.sync_alt_rounded,
                        color: low ? _danger : _green,
                      ),
                      tooltip: 'Mouvement de stock',
                    ),
                  if (edit != null)
                    IconButton(
                      onPressed: edit,
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: 'Modifier',
                    ),
                  if (delete != null)
                    IconButton(
                      onPressed: delete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: _danger,
                      tooltip: 'Supprimer',
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductMedia extends StatelessWidget {
  const ProductMedia({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });
  final Product product;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final source = product.imageUrl.trim();
    if (source.startsWith('data:image')) {
      final data = UriData.parse(source);
      return Image.memory(
        data.contentAsBytes(),
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            _ProductFallback(product: product),
      );
    }
    if (source.isNotEmpty) {
      return Image.network(
        source,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            _ProductFallback(product: product),
      );
    }
    return _ProductFallback(product: product);
  }
}

class _ProductFallback extends StatelessWidget {
  const _ProductFallback({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDark(context)
              ? const [Color(0xFF10212A), Color(0xFF143240), Color(0xFF163C4B)]
              : const [Color(0xFFE7F5F8), Colors.white, _surface],
        ),
      ),
      child: Center(child: Icon(product.icon, size: 44, color: _green)),
    );
  }
}

class _ViewportStickyRail extends StatefulWidget {
  const _ViewportStickyRail({
    required this.child,
    this.width,
    this.topSpacing = 0,
    this.bottomSpacing = 18,
  });

  final Widget child;
  final double? width;
  final double topSpacing;
  final double bottomSpacing;

  @override
  State<_ViewportStickyRail> createState() => _ViewportStickyRailState();
}

class _ViewportStickyRailState extends State<_ViewportStickyRail> {
  final GlobalKey _slotKey = GlobalKey();
  final GlobalKey _childKey = GlobalKey();

  double _snapOffset(double value) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (devicePixelRatio <= 0) {
      return value.roundToDouble();
    }
    return (value * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant _ViewportStickyRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  double _computeOffset() {
    final slotContext = _slotKey.currentContext;
    final childContext = _childKey.currentContext;
    if (slotContext == null || childContext == null) return 0;
    final slotBox = slotContext.findRenderObject();
    final childBox = childContext.findRenderObject();
    if (slotBox is! RenderBox || childBox is! RenderBox) return 0;

    final slotTop = slotBox.localToGlobal(Offset.zero).dy;
    final childHeight = childBox.size.height;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final topPinnedTop = widget.topSpacing;
    final availableHeight = math.max(
      120.0,
      viewportHeight - topPinnedTop - widget.bottomSpacing,
    );
    final travel = math.max(0.0, topPinnedTop - slotTop);

    if (childHeight <= availableHeight) {
      return _snapOffset(travel);
    }

    final bottomPinnedTop = viewportHeight - widget.bottomSpacing - childHeight;
    final maxTravel = math.max(0.0, childHeight - availableHeight);
    final releaseStart = bottomPinnedTop;
    final bottomStickThreshold = (2 * bottomPinnedTop) - topPinnedTop;

    final desiredTop = switch (slotTop) {
      final v when v >= topPinnedTop => slotTop,
      final v when v >= releaseStart => topPinnedTop,
      final v when v >= bottomStickThreshold => slotTop + maxTravel,
      _ => bottomPinnedTop,
    };

    return _snapOffset(desiredTop - slotTop);
  }

  Widget _buildRail() {
    return SizedBox(
      key: _slotKey,
      width: widget.width,
      child: Transform.translate(
        offset: Offset(0, _computeOffset()),
        child: KeyedSubtree(
          key: _childKey,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      return _buildRail();
    }
    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, child) => _buildRail(),
    );
  }
}

class DashboardProductSlide extends StatelessWidget {
  const DashboardProductSlide({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductMedia(product: product, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF062838).withAlpha(72),
                  Colors.transparent,
                  const Color(0xFF041821).withAlpha(182),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withAlpha(18)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _HeroChip(label: 'Stock ${product.quantity.round()}'),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _HeroChip(label: product.category),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF041821).withAlpha(96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withAlpha(18)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${product.price.round()} FC',
                              style: const TextStyle(
                                color: Color(0xFFA6F7FF),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Stock ${product.quantity.round()} • ${product.unit}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(214),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ProductMediaPicker extends StatelessWidget {
  const ProductMediaPicker({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onPick,
    this.onClear,
    this.pickLabel = 'Choisir image',
  });
  final String imageUrl;
  final String label;
  final Future<void> Function() onPick;
  final VoidCallback? onClear;
  final String pickLabel;

  @override
  Widget build(BuildContext context) {
    final previewProduct = Product.demo(
      'PRD-000000',
      label,
      'Divers',
      0,
      0,
      0,
      Icons.inventory_2_rounded,
      imageUrl: imageUrl,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductMedia(product: previewProduct),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => onPick(),
                  icon: const Icon(Icons.image_rounded),
                  label: Text(pickLabel),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class SaleLineTile extends StatelessWidget {
  const SaleLineTile({
    super.key,
    required this.line,
    required this.product,
    required this.money,
  });
  final SaleLine line;
  final Product? product;
  final String Function(num value) money;

  @override
  Widget build(BuildContext context) {
    final visualProduct =
        product ??
        Product.demo(
          'PRD-999999',
          line.product,
          'Divers',
          line.cost,
          line.price,
          line.qty,
          Icons.inventory_2_rounded,
          imageUrl: '',
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 52,
                height: 52,
                child: ProductMedia(product: visualProduct),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${line.qty.round()} x ${money(line.price)}',
                    style: TextStyle(color: _mutedTextColor(context)),
                  ),
                ],
              ),
            ),
            Text(
              money(line.qty * line.price),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class SaleLineInsightTile extends StatelessWidget {
  const SaleLineInsightTile({
    super.key,
    required this.line,
    required this.product,
    required this.money,
  });

  final SaleLine line;
  final Product? product;
  final String Function(num value) money;

  @override
  Widget build(BuildContext context) {
    final visualProduct =
        product ??
        Product.demo(
          'PRD-999999',
          line.product,
          'Divers',
          line.cost,
          line.price,
          line.qty,
          Icons.inventory_2_rounded,
        );
    final soldAmount = line.qty * line.price;
    final stockLeft = product?.quantity ?? 0;
    final stockLeftAmount = stockLeft * line.price;
    final fullPotential = (stockLeft + line.qty) * line.price;
    final soldProfit = line.qty * (line.price - line.cost);
    final remainingProfit =
        stockLeft * ((product?.price ?? line.price) - (product?.cost ?? line.cost));
    final totalProfitPotential =
        (stockLeft + line.qty) * ((product?.price ?? line.price) - line.cost);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: ProductMedia(product: visualProduct),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.product,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${line.qty.round()} vendu(s) - ${stockLeft.round()} en stock',
                        style: TextStyle(
                          color: _mutedTextColor(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${money(line.price)} / unite',
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _MetricRowPair(
              leftLabel: 'Montant vendu',
              leftValue: money(soldAmount),
              rightLabel: 'Bénéfice recolte',
              rightValue: money(soldProfit),
            ),
            const SizedBox(height: 8),
            _MetricRowPair(
              leftLabel: 'Reste a recolter',
              leftValue: money(stockLeftAmount),
              rightLabel: 'Bénéfice restant',
              rightValue: money(remainingProfit),
            ),
            const SizedBox(height: 8),
            _MetricRowPair(
              leftLabel: 'Potentiel total',
              leftValue: money(fullPotential),
              rightLabel: 'Bénéfice potentiel',
              rightValue: money(totalProfitPotential),
            ),
          ],
        ),
      ),
    );
  }
}

class SaleJournalCard extends StatelessWidget {
  const SaleJournalCard({
    super.key,
    required this.sale,
    required this.store,
    required this.onTap,
  });
  final Sale sale;
  final AppStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstLine = sale.lines.firstOrNull;
    final product = firstLine == null ? null : store.findProduct(firstLine.product);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: ProductMedia(
                        product:
                            product ??
                            Product.demo(
                              'PRD-999998',
                              firstLine?.product ?? 'Vente',
                              'Divers',
                              0,
                              0,
                              0,
                              Icons.receipt_long_rounded,
                              imageUrl: '',
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.invoiceNo,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${sale.customer.name} - ${sale.ticketNo} - ${_formatDate(sale.createdAt)}',
                          style: TextStyle(
                            color: _mutedTextColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    store.money(sale.total),
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...sale.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.product,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${line.qty.round()}'),
                      const SizedBox(width: 12),
                      Text(store.money(line.price)),
                      const SizedBox(width: 12),
                      Text(
                        store.money(line.qty * line.price),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CashJournalPanel extends StatefulWidget {
  const CashJournalPanel({
    super.key,
    required this.store,
    required this.rows,
    required this.sales,
    required this.money,
    required this.openSale,
    this.query = '',
  });
  final AppStore store;
  final List<LedgerRow> rows;
  final List<Sale> sales;
  final String Function(num value) money;
  final void Function(Sale sale) openSale;
  final String query;

  @override
  State<CashJournalPanel> createState() => _CashJournalPanelState();
}

class _CashJournalPanelState extends State<CashJournalPanel> {
  String operationFilter = 'Tout';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = widget.query.trim();
    final productInsights = normalizedQuery.isEmpty
        ? const <ProductSalesInsight>[]
        : widget.store.productSalesInsights(normalizedQuery);
    final filtered = widget.rows.where((row) {
      final matchesOperation = switch (operationFilter) {
        'Ventes' => row.kind == 'Vente',
        'Dépenses' => row.kind == 'Depense',
        'Achats' => row.kind == 'Achat',
        _ => true,
      };
      final normalized = _normalizeSearchText(normalizedQuery);
      final matchesQuery = normalized.isEmpty || _rowMatchesQuery(row, normalized);
      return matchesOperation && matchesQuery;
    }).toList();
    return Column(
      children: [
        _JournalFilterTabs(
          value: operationFilter,
          onChanged: (value) => setState(() => operationFilter = value),
        ),
        const SizedBox(height: 12),
        if (normalizedQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          if (productInsights.isNotEmpty)
            ...productInsights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProductSalesInsightCard(
                  insight: insight,
                  money: widget.money,
                ),
              ),
            ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _softPanelColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _panelBorderColor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Operation',
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Montant',
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const _EmptyStateTile(
            icon: Icons.list_alt_rounded,
            title: 'Aucun journal correspondant',
            subtitle:
                'Ajuste la recherche ou le filtre pour retrouver une vente, un achat ou une dépense.',
          )
        else
          ...filtered.take(20).map((row) {
            final sale = widget.sales
                .where((entry) => entry.invoiceNo == row.reference)
                .firstOrNull;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: JournalRowCard(
                row: row,
                money: widget.money,
                onTap: sale == null ? null : () => widget.openSale(sale),
              ),
            );
          }),
      ],
    );
  }

  bool _rowMatchesQuery(LedgerRow row, String query) {
    final base = _normalizeSearchText(
      '${row.kind} ${row.reference} ${row.label} ${row.party} ${_formatDate(row.createdAt)}',
    );
    if (base.contains(query)) return true;
    if (row.kind == 'Vente') {
      final sale = widget.sales
          .where((entry) => entry.invoiceNo == row.reference)
          .firstOrNull;
      if (sale == null) return false;
      final haystack = _normalizeSearchText(
        '${sale.invoiceNo} ${sale.customer.name} ${sale.lines.map((line) => line.product).join(' ')}',
      );
      return haystack.contains(query);
    }
    return false;
  }
}

enum InsightTone { good, warning }

class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({super.key, required this.activity});
  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _softAccentColor(context),
        child: Icon(activity.icon, color: _green),
      ),
      title: Text(
        activity.title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${activity.subtitle}\n${_formatDate(activity.createdAt)}'),
      isThreeLine: true,
      trailing: Text(
        activity.trailing,
        style: const TextStyle(fontWeight: FontWeight.w800, color: _green),
      ),
    );
  }
}

class RecentActivitiesPager extends StatefulWidget {
  const RecentActivitiesPager({super.key, required this.activities});
  final List<RecentActivity> activities;

  @override
  State<RecentActivitiesPager> createState() => _RecentActivitiesPagerState();
}

class _RecentActivitiesPagerState extends State<RecentActivitiesPager> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final totalPages = ((widget.activities.length + 2) ~/ 3).clamp(1, 999);
    final safePage = page.clamp(0, totalPages - 1);
    if (safePage != page) {
      page = safePage;
    }
    final visible = widget.activities.skip(page * 3).take(3).toList();
    return Column(
      children: [
        ...visible.map((activity) => RecentActivityTile(activity: activity)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: page <= 0 ? null : () => setState(() => page -= 1),
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Retour'),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _softPanelColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _panelBorderColor(context)),
              ),
              child: Text(
                '${page + 1}/$totalPages',
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: page >= totalPages - 1
                    ? null
                    : () => setState(() => page += 1),
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Suite'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatusInsightTile extends StatelessWidget {
  const StatusInsightTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final InsightTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = tone == InsightTone.good
        ? _softAccentStrong(context)
        : _warningSurface(context);
    final color = tone == InsightTone.good ? _green : Colors.orange.shade800;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _panelColor(context),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: _strongTextColor(context)),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class JournalRowCard extends StatelessWidget {
  const JournalRowCard({
    super.key,
    required this.row,
    required this.money,
    this.onTap,
  });

  final LedgerRow row;
  final String Function(num value) money;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final positive = row.amount >= 0;
    final positiveBg = _isDark(context)
        ? const Color(0xFF112A33)
        : const Color(0xFFF7FCF9);
    final negativeBg = _isDark(context)
        ? const Color(0xFF33261F)
        : const Color(0xFFFFFAF1);
    final positiveBorder = _isDark(context)
        ? const Color(0xFF295268)
        : const Color(0xFFD1E6EC);
    final negativeBorder = _isDark(context)
        ? const Color(0xFF654838)
        : const Color(0xFFF0DFC0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: positive ? positiveBg : negativeBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: positive ? positiveBorder : negativeBorder,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: positive
                  ? _softAccentStrong(context)
                  : _warningSurface(context),
              child: Icon(
                positive
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: positive ? _green : Colors.orange.shade800,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.kind,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _greenDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _mutedTextColor(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(row.createdAt),
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              money(row.amount),
              style: TextStyle(
                color: positive ? _green : _danger,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const _TapHintChevron(),
            ],
          ],
        ),
      ),
    );
  }
}

class _TapHintBadge extends StatelessWidget {
  const _TapHintBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Details',
            style: TextStyle(
              color: _mutedTextColor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          const _TapHintChevron(),
        ],
      ),
    );
  }
}

class _JournalFilterTabs extends StatelessWidget {
  const _JournalFilterTabs({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = const [
      ('Tout', 'Tout'),
      ('Ventes', 'Vente'),
      ('Dépenses', 'Dépenses'),
      ('Achats', 'Achat'),
    ];
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _JournalFilterTab(
                  label: option.$2,
                  selected: value == option.$1,
                  onTap: () => onChanged(option.$1),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LedgerFilterField extends StatelessWidget {
  const _LedgerFilterField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hint,
        isDense: true,
      ),
    );
  }
}

class _LedgerCompactPicker extends StatelessWidget {
  const _LedgerCompactPicker({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _panelColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _greenDark),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _mutedTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: hasValue
                          ? _strongTextColor(context)
                          : _mutedTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (hasValue && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _softAccentColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 14),
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LedgerOptionPickerSheet extends StatefulWidget {
  const _LedgerOptionPickerSheet({
    required this.title,
    required this.initialValue,
    required this.options,
  });

  final String title;
  final String initialValue;
  final List<String> options;

  @override
  State<_LedgerOptionPickerSheet> createState() => _LedgerOptionPickerSheetState();
}

class _LedgerOptionPickerSheetState extends State<_LedgerOptionPickerSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  late String query = widget.initialValue;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((option) => _matchesSearchText(option, query))
        .toList();
    return Container(
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        18 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choisir ${widget.title.toLowerCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Saisir ou chercher',
              isDense: true,
              suffixIcon: query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() => query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Aucun resultat. Tu peux valider la saisie manuelle.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _mutedTextColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = filtered[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(''),
                  child: const Text('Effacer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalFilterTab extends StatelessWidget {
  const _JournalFilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = _panelColor(context);
    final border = _panelBorderColor(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _green : base,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _green : border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : _green,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _TapHintChevron extends StatefulWidget {
  const _TapHintChevron();

  @override
  State<_TapHintChevron> createState() => _TapHintChevronState();
}

class _TapHintChevronState extends State<_TapHintChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(2 * _controller.value, 0),
        child: child,
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        color: _green,
        size: 18,
      ),
    );
  }
}

class _MetricRowPair extends StatelessWidget {
  const _MetricRowPair({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InlineMetric(label: leftLabel, value: leftValue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InlineMetric(label: rightLabel, value: rightValue),
        ),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSalesInsightCard extends StatelessWidget {
  const ProductSalesInsightCard({
    super.key,
    required this.insight,
    required this.money,
  });

  final ProductSalesInsight insight;
  final String Function(num value) money;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: ProductMedia(product: insight.product),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${insight.product.category} - ${insight.product.quantityText} disponibles',
                        style: TextStyle(color: _mutedTextColor(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InsightStatsGrid(
              children: [
                MiniStatTile(
                  icon: Icons.shopping_cart_checkout_rounded,
                  label: 'Quantité vendue',
                  value: '${insight.soldQty.round()}',
                ),
                MiniStatTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'Stock restant',
                  value: '${insight.product.quantity.round()}',
                ),
                MiniStatTile(
                  icon: Icons.sell_rounded,
                  label: 'Montant recolte',
                  value: money(insight.soldAmount),
                ),
                MiniStatTile(
                  icon: Icons.trending_up_rounded,
                  label: 'Bénéfice recolte',
                  value: money(insight.soldProfit),
                ),
                MiniStatTile(
                  icon: Icons.payments_rounded,
                  label: 'Reste a recolter',
                  value: money(insight.stockAmount),
                ),
                MiniStatTile(
                  icon: Icons.savings_rounded,
                  label: 'Bénéfice restant',
                  value: money(insight.remainingProfit),
                ),
                MiniStatTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Potentiel total',
                  value: money(insight.totalPotential),
                ),
                MiniStatTile(
                  icon: Icons.insights_rounded,
                  label: 'Bénéfice potentiel',
                  value: money(insight.totalProfitPotential),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateTile extends StatelessWidget {
  const _EmptyStateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _panelColor(context),
            child: Icon(icon, color: _green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: _mutedTextColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.store,
    required this.onAlertTap,
    required this.onReadAllAlerts,
    required this.onChanged,
  });

  final AppStore store;
  final ValueChanged<AppAlert> onAlertTap;
  final VoidCallback onReadAllAlerts;
  final VoidCallback onChanged;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final systemMessages =
        store.messageInbox.where((message) => message.isSystem).toList();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _PageHeader(
          title: 'Notifications',
          subtitle: 'Alertes stock, operations et suivi administratif hors messagerie.',
          icon: Icons.notifications_active_rounded,
          action: TextButton.icon(
            onPressed: () {
              widget.onReadAllAlerts();
              store.markAllMessagesRead();
              setState(() {});
              widget.onChanged();
            },
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Tout lire'),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Dernieres notifications',
          icon: Icons.mark_email_read_rounded,
          child: PagedWidgetList(
            items: store.smartAlerts
                .map((alert) => AlertTile(
                      alert: alert,
                      onTap: () {
                        widget.onAlertTap(alert);
                        setState(() {});
                      },
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Messages système liés',
          icon: Icons.forum_rounded,
          child: systemMessages.isEmpty
              ? const _EmptyStateTile(
                  icon: Icons.mark_email_read_rounded,
                  title: 'Aucun message système',
                  subtitle: 'Les confirmations, rappels et informations internes s’afficheront ici.',
                )
              : PagedWidgetList(
                  items: systemMessages
                      .map(
                        (message) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _InboxMessageTile(
                            message: message,
                            onTap: () {
                              store.markMessageRead(message);
                              setState(() {});
                              widget.onChanged();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    required this.store,
    required this.onChanged,
    this.onThreadStateChanged,
  });

  final AppStore store;
  final VoidCallback onChanged;
  final ValueChanged<bool>? onThreadStateChanged;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String section = 'Discussions';
  AppUser? _openedPeer;
  final TextEditingController _composer = TextEditingController();
  PickedMediaAttachment? _draftAttachment;
  String _draftAttachmentKind = 'text';
  static const List<String> _quickEmojis = [
    '😀',
    '😂',
    '😉',
    '😍',
    '👍',
    '🙏',
    '🔥',
    '🎉',
    '✅',
    '📦',
    '💰',
    '📣',
    '⚠️',
    '❤️',
    '😎',
    '🤝',
    '🙂',
    '😊',
    '😁',
    '😇',
    '🥰',
    '😘',
    '😜',
    '🤗',
    '👏',
    '🙌',
    '👌',
    '💪',
    '🙈',
    '🎯',
    '📞',
    '🛒',
    '📄',
    '📷',
    '🎁',
    '⭐',
    '🌟',
    '💡',
    '🚀',
    '🧾',
    '🏪',
    '🏷️',
    '💳',
    '💵',
    '📌',
    '⌛',
    '🕒',
    '❗',
    '❓',
    '✅',
    '☑️',
    '🔔',
    '🔒',
    '🫶',
    '😌',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _closeThread() {
    setState(() {
      _openedPeer = null;
      _composer.clear();
      _draftAttachment = null;
      _draftAttachmentKind = 'text';
    });
    widget.onThreadStateChanged?.call(false);
  }

  Future<void> _appendEmoji(TextEditingController controller) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModalHeader(
                title: 'Choisir un emoji',
                onClose: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickEmojis
                    .map(
                      (emoji) => InkWell(
                        onTap: () => Navigator.pop(sheetContext, emoji),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _softPanelColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _panelBorderColor(context)),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
    if (emoji == null || emoji.isEmpty) return;
    controller.text = '${controller.text}$emoji';
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  Future<PickedMediaAttachment?> _pickAttachment(String kind) {
    return switch (kind) {
      'image' => pickMediaAttachment(accept: 'image/*'),
      _ => pickMediaAttachment(
          accept: '*/*',
        ),
    };
  }

  ({Uint8List bytes, String mimeType})? _decodeAttachmentDataUrl(String dataUrl) {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex <= 0) return null;
    final metadata = dataUrl.substring(0, commaIndex);
    final encoded = dataUrl.substring(commaIndex + 1);
    final mimeMatch = RegExp(r'^data:([^;]+)').firstMatch(metadata);
    final mimeType = mimeMatch?.group(1) ?? 'application/octet-stream';
    return (
      bytes: Uint8List.fromList(base64Decode(encoded)),
      mimeType: mimeType,
    );
  }

  Future<void> _downloadAttachment(AppMessage message) async {
    final dataUrl = message.attachmentDataUrl;
    if (dataUrl == null || dataUrl.isEmpty) return;
    final decoded = _decodeAttachmentDataUrl(dataUrl);
    if (decoded == null) return;
    final filename =
        message.attachmentName ??
        'piece-jointe-${message.createdAt.millisecondsSinceEpoch}';
    await downloadBytes(filename, decoded.bytes, decoded.mimeType);
  }

  Future<void> _openAttachmentActions(AppMessage message) async {
    if (!message.canDisplayAttachment || message.attachmentDataUrl == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModalHeader(
                title: message.attachmentName ?? 'Pièce jointe',
                onClose: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  final decoded = _decodeAttachmentDataUrl(message.attachmentDataUrl!);
                  if (decoded == null) return;
                  openBytesInNewTab(decoded.bytes, decoded.mimeType);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Ouvrir'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await _downloadAttachment(message);
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Télécharger'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _threadDayLabel(DateTime date) {
    final now = DateTime.now();
    if (_sameCalendarDay(date, now)) return "Aujourd'hui";
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameCalendarDay(date, yesterday)) return 'Hier';
    return _formatDate(date);
  }

  String _formatClock(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<Widget> _buildThreadWidgets({
    required List<AppMessage> thread,
    required AppStore store,
    required StateSetter setLocal,
  }) {
    if (thread.isEmpty) {
      return const [
        _EmptyStateTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Aucun message',
          subtitle: 'Commence la discussion interne ici.',
        ),
      ];
    }

    final widgets = <Widget>[];
    DateTime? previousDate;
    for (final message in thread) {
      if (previousDate == null || !_sameCalendarDay(previousDate, message.createdAt)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _ChatDateChip(label: _threadDayLabel(message.createdAt)),
          ),
        );
        previousDate = message.createdAt;
      }
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            left: message.senderCode == store.activeUser.code ? 58 : 6,
            right: message.senderCode == store.activeUser.code ? 6 : 58,
            bottom: 4,
          ),
          child: Row(
            mainAxisAlignment: message.senderCode == store.activeUser.code
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.senderCode != store.activeUser.code) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    color: _softAccentColor(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (() {
                      final raw = (message.senderName ?? '?').trim();
                      return raw.isEmpty ? '?' : raw.substring(0, 1).toUpperCase();
                    })(),
                    style: const TextStyle(
                      color: _greenDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: _ChatMessageBubble(
                  message: message,
                  isCurrentUser: message.senderCode == store.activeUser.code,
                  canEdit: store.canEditMessage(message),
                  onOpenActions: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (sheetContext) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ModalHeader(
                                title: 'Options du message',
                                onClose: () => Navigator.pop(sheetContext),
                              ),
                              const SizedBox(height: 12),
                              if (store.canEditMessage(message))
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    final editController = TextEditingController(
                                      text: message.body,
                                    );
                                    showModalBottomSheet<bool>(
                                      context: context,
                                      isScrollControlled: true,
                                      showDragHandle: true,
                                      builder: (editContext) => SafeArea(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            16,
                                            6,
                                            16,
                                            18 +
                                                MediaQuery.viewInsetsOf(
                                                  editContext,
                                                ).bottom,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _ModalHeader(
                                                title: 'Modifier le message',
                                                onClose: () => Navigator.pop(
                                                  editContext,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: editController,
                                                minLines: 1,
                                                maxLines: 4,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'Modifier le message',
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                  editContext,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Enregistrer',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).then((confirmed) {
                                      if (confirmed != true) return;
                                      final updated =
                                          store.editInternalMessage(
                                        message: message,
                                        body: editController.text,
                                      );
                                      if (!updated) return;
                                      setState(() {});
                                      setLocal(() {});
                                      widget.onChanged();
                                    });
                                  },
                                  icon: const Icon(Icons.edit_rounded),
                                  label: const Text('Modifier'),
                                ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  store.deleteMessageForCurrentUser(message);
                                  setState(() {});
                                  setLocal(() {});
                                  widget.onChanged();
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Supprimer pour moi'),
                              ),
                              if (message.senderCode ==
                                  store.activeUser.code) ...[
                                const SizedBox(height: 10),
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    store.deleteMessageForEveryone(message);
                                    setState(() {});
                                    setLocal(() {});
                                    widget.onChanged();
                                  },
                                  icon: const Icon(
                                    Icons.delete_forever_rounded,
                                  ),
                                  label: const Text(
                                    'Supprimer pour tout le monde',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onEdit: () async {
                final editController = TextEditingController(text: message.body);
                final confirmed = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (editContext) => SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        6,
                        16,
                        18 + MediaQuery.viewInsetsOf(editContext).bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModalHeader(
                            title: 'Modifier le message',
                            onClose: () => Navigator.pop(editContext),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: editController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Modifier le message',
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => Navigator.pop(editContext, true),
                            child: const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirmed != true) return;
                final updated = store.editInternalMessage(
                  message: message,
                  body: editController.text,
                );
                if (!updated) return;
                setState(() {});
                setLocal(() {});
                widget.onChanged();
                  },
                  onDeleteForMe: () {
                store.deleteMessageForCurrentUser(message);
                setState(() {});
                setLocal(() {});
                widget.onChanged();
                  },
                  onDeleteForEveryone:
                      message.senderCode == store.activeUser.code
                      ? () {
                      store.deleteMessageForEveryone(message);
                      setState(() {});
                      setLocal(() {});
                      widget.onChanged();
                      }
                      : null,
                  onOpenAttachment: message.canDisplayAttachment
                      ? () => _openAttachmentActions(message)
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  String _formatVoiceDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<PickedMediaAttachment?> _recordVoiceNote({
    VoiceNoteRecorder? recorder,
    bool startBeforeSheet = false,
  }) async {
    final activeRecorder = recorder ?? createVoiceNoteRecorder();
    final preview = ValueNotifier<PickedMediaAttachment?>(null);
    if (startBeforeSheet) {
      final started = await activeRecorder.start();
      if (!started) {
        await activeRecorder.close();
        activeRecorder.dispose();
        preview.dispose();
        if (mounted && activeRecorder.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(activeRecorder.errorMessage!)),
          );
        }
        return null;
      }
    } else {
      unawaited(activeRecorder.start());
    }
    final attachment = await showModalBottomSheet<PickedMediaAttachment>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: AnimatedBuilder(
            animation: Listenable.merge([activeRecorder, preview]),
            builder: (context, _) {
              final draft = preview.value;
              final canRetry =
                  !activeRecorder.isRecording &&
                  !activeRecorder.isPreparing &&
                  draft == null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Note vocale',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _softPanelColor(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _panelBorderColor(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: activeRecorder.isRecording
                                    ? _softAccentStrong(context)
                                    : _panelColor(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _panelBorderColor(context)),
                              ),
                              child: Icon(
                                activeRecorder.isRecording
                                    ? Icons.graphic_eq_rounded
                                    : Icons.mic_rounded,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeRecorder.isPreparing
                                        ? 'Préparation du microphone...'
                                        : activeRecorder.isRecording
                                        ? 'Enregistrement en cours'
                                        : draft != null
                                        ? 'Préécoute avant envoi'
                                        : 'Prête à enregistrer',
                                    style: TextStyle(
                                      color: _strongTextColor(context),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeRecorder.isRecording
                                        ? _formatVoiceDuration(activeRecorder.elapsed)
                                        : draft != null
                                        ? 'Lis la note vocale puis envoie-la.'
                                        : (activeRecorder.errorMessage ??
                                            'Tout se fait ici, sans quitter la discussion.'),
                                    style: TextStyle(
                                      color: _mutedTextColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (draft != null) ...[
                          const SizedBox(height: 14),
                          AudioAttachmentPlayer(
                            dataUrl: draft.dataUrl,
                            compact: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (activeRecorder.isRecording)
                        FilledButton.icon(
                          onPressed: () async {
                            final recorded = await activeRecorder.stop();
                            if (recorded == null) return;
                            preview.value = recorded;
                          },
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Arrêter'),
                        ),
                      if (activeRecorder.isRecording)
                        OutlinedButton.icon(
                          onPressed: () async {
                            await activeRecorder.cancel();
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Annuler'),
                        ),
                      if (canRetry)
                        FilledButton.tonalIcon(
                          onPressed: () {
                            preview.value = null;
                            unawaited(activeRecorder.start());
                          },
                          icon: const Icon(Icons.mic_rounded),
                          label: Text(
                            activeRecorder.errorMessage == null
                                ? 'Commencer'
                                : 'Réessayer',
                          ),
                        ),
                      if (draft != null)
                        FilledButton.icon(
                          onPressed: () => Navigator.pop(sheetContext, draft),
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Utiliser cette note'),
                        ),
                      if (draft != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            preview.value = null;
                            unawaited(activeRecorder.start());
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Refaire'),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await activeRecorder.close();
    activeRecorder.dispose();
    preview.dispose();
    return attachment;
  }

  Future<PickedMediaAttachment?> _requestVoiceNoteAttachment() async {
    final recorder = createVoiceNoteRecorder();
    final blockedReason = recorder.unavailableReason;
    if (blockedReason != null) {
      if (!mounted) {
        recorder.dispose();
        return null;
      }
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: 'Microphone indisponible',
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 12),
                Text(
                  blockedReason,
                  style: TextStyle(
                    color: _strongTextColor(context),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Compris'),
                ),
              ],
            ),
          ),
        ),
      );
      recorder.dispose();
      return null;
    }
    return _recordVoiceNote(recorder: recorder, startBeforeSheet: true);
  }

  Future<void> _pickThreadAttachment(String kind) async {
    final picked = kind == 'audio'
        ? await _requestVoiceNoteAttachment()
        : await _pickAttachment(kind);
    if (picked == null) return;
    setState(() {
      _draftAttachment = picked;
      _draftAttachmentKind = kind;
    });
  }

  void _sendThreadMessage(AppUser peer) {
    if (_composer.text.trim().isEmpty && _draftAttachment == null) return;
    widget.store.sendInternalMessage(
      recipient: peer,
      body: _composer.text,
      contentType: _draftAttachmentKind,
      attachmentName: _draftAttachment?.fileName,
      attachmentMimeType: _draftAttachment?.mimeType,
      attachmentDataUrl: _draftAttachment?.dataUrl,
    );
    setState(() {
      _composer.clear();
      _draftAttachment = null;
      _draftAttachmentKind = 'text';
    });
    widget.onChanged();
  }

  Widget _buildThreadPage(AppUser peer) {
    final store = widget.store;
    final thread = store.conversationWith(peer);
    final dark = _isDark(context);
    final pageColor = dark ? const Color(0xFF121B22) : Colors.white;
    final threadColor = dark ? const Color(0xFF121B22) : Colors.white;
    final composerShellColor = dark ? const Color(0xFF121B22) : Colors.white;
    final inputColor = dark ? const Color(0xFF1D2931) : const Color(0xFFF1F3F6);
    final iconColor = dark ? Colors.white70 : _green;
    final titleColor = dark ? Colors.white : _strongTextColor(context);
    final subtitleColor = dark ? Colors.white54 : const Color(0xFF8A8F98);
    return ColoredBox(
      color: pageColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            decoration: BoxDecoration(
              color: pageColor,
              border: Border(
                bottom: BorderSide(
                  color: dark ? Colors.white12 : const Color(0xFFE8EBEF),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    hoverColor: dark ? Colors.white10 : const Color(0x140C5D6D),
                    highlightColor: Colors.transparent,
                  ),
                  onPressed: _closeThread,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: titleColor,
                    size: 22,
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: dark
                      ? const Color(0xFF26343D)
                      : const Color(0xFFE5F1F3),
                  child: Text(
                    peer.name.trim().isEmpty
                        ? '?'
                        : peer.name.trim().substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: dark ? Colors.white : _greenDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vous pouvez échanger des messages, des fichiers et des notes vocales entre comptes internes.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings_rounded,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: threadColor,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                children: [
                  ..._buildThreadWidgets(
                    thread: thread,
                    store: store,
                    setLocal: (fn) => setState(fn),
                  ),
                ],
              ),
            ),
          ),
          if (_draftAttachment != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: _MessageAttachmentDraftTile(
                kind: _draftAttachmentKind,
                fileName: _draftAttachment!.fileName,
                dataUrl: _draftAttachment!.dataUrl,
                onClear: () => setState(() {
                  _draftAttachment = null;
                  _draftAttachmentKind = 'text';
                }),
              ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            decoration: BoxDecoration(
              color: composerShellColor,
              border: Border(
                top: BorderSide(
                  color: dark ? Colors.white10 : const Color(0xFFE8EBEF),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _appendEmoji(_composer),
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: dark ? Colors.white60 : _green,
                          ),
                          tooltip: 'Emoji',
                        ),
                        Expanded(
                          child: TextField(
                            controller: _composer,
                            minLines: 1,
                            maxLines: 4,
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: subtitleColor),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (sheetContext) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _ModalHeader(
                                        title: 'Joindre un fichier',
                                        onClose: () => Navigator.pop(sheetContext),
                                      ),
                                      const SizedBox(height: 12),
                                      FilledButton.icon(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          _pickThreadAttachment('image');
                                        },
                                        icon: const Icon(Icons.image_outlined),
                                        label: const Text('Importer une image'),
                                      ),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          _pickThreadAttachment('audio');
                                        },
                                        icon: const Icon(Icons.audio_file_outlined),
                                        label: const Text('Importer un audio'),
                                      ),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          _pickThreadAttachment('file');
                                        },
                                        icon: const Icon(Icons.attach_file_rounded),
                                        label: const Text('Importer un document'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: dark ? Colors.white60 : _green,
                          ),
                          tooltip: 'Pièces jointes',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _composer,
                  builder: (context, value, _) {
                    final hasDraft =
                        value.text.trim().isNotEmpty || _draftAttachment != null;
                    return _PartyActionButton(
                      onPressed: () {
                        if (hasDraft) {
                          _sendThreadMessage(peer);
                          return;
                        }
                        _pickThreadAttachment('audio');
                      },
                      tooltip: hasDraft ? 'Envoyer' : 'Enregistrer',
                      background: _green,
                      size: 54,
                      child: Icon(
                        hasDraft ? Icons.send_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _messagePreview(AppMessage? message) {
    if (message == null) return 'Aucune discussion pour le moment.';
    if (message.isDeletedForEveryone) return 'Message supprime';
    if (message.isMediaExpired) return 'Media expire';
    return switch (message.contentType) {
      'image' => 'Image${message.body.trim().isEmpty ? '' : ' - ${message.body}'}',
      'audio' => 'Note vocale${message.body.trim().isEmpty ? '' : ' - ${message.body}'}',
      'file' => 'Document${message.attachmentName == null ? '' : ' - ${message.attachmentName}'}',
      _ => message.body,
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final systemMessages =
        store.messageInbox.where((message) => message.isSystem).toList();
    final peers = store.messagePeers;
    final openedPeer = _openedPeer;
    if (section == 'Discussions' && openedPeer != null) {
      return _buildThreadPage(openedPeer);
    }
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _PageHeader(
          title: 'Messages',
          subtitle: 'Relances de paiement et discussions entre administrateur, gestionnaire et caisse.',
          icon: Icons.chat_bubble_outline_rounded,
          action: TextButton.icon(
            onPressed: () {
              store.markAllMessagesRead();
              setState(() {});
              widget.onChanged();
            },
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Tout lire'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _MessageSectionChip(
              label: 'Relances',
              count: systemMessages.where((message) => !message.isRead).length,
              selected: section == 'Relances',
              onTap: () => setState(() {
                section = 'Relances';
                _openedPeer = null;
              }),
            ),
            const SizedBox(width: 10),
            _MessageSectionChip(
              label: 'Discussions',
              count: store.unreadMessages,
              selected: section == 'Discussions',
              onTap: () => setState(() {
                section = 'Discussions';
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (section == 'Relances')
          SectionCard(
            title: 'Relances et messages systeme',
            icon: Icons.schedule_send_rounded,
            child: systemMessages.isEmpty
                ? const _EmptyStateTile(
                    icon: Icons.mark_email_read_rounded,
                    title: 'Aucune relance',
                    subtitle: 'Les échéances de paiement et les messages systeme apparaîtront ici.',
                  )
                : PagedWidgetList(
                    items: systemMessages
                        .map(
                          (message) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _InboxMessageTile(
                              message: message,
                              onTap: () {
                                store.markMessageRead(message);
                                setState(() {});
                                widget.onChanged();
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
          )
        else
          SectionCard(
            title: 'Discussions internes',
            icon: Icons.forum_rounded,
            child: peers.isEmpty
                ? const _EmptyStateTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Aucun autre compte',
                    subtitle: 'Ajoute des utilisateurs pour commencer les discussions internes.',
                  )
                : PagedWidgetList(
                    items: peers
                        .map(
                          (peer) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ChatThreadTile(
                              peer: peer,
                              messages: store.conversationWith(peer),
                              currentUserCode: store.activeUser.code,
                              onTap: () => _openThread(peer),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
      ],
    );
  }

  void _openThread(AppUser peer) {
    final store = widget.store;
    final markedAny = store.markMessagesFromPeerAsRead(peer);
    setState(() => _openedPeer = peer);
    widget.onThreadStateChanged?.call(true);
    if (markedAny) {
      widget.onChanged();
    }
  }
}

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.store, required this.onLogout});

  final AppStore store;
  final VoidCallback onLogout;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String section = 'Aide';

  Future<void> _openAccountCenter(BuildContext context) async {
    final user = widget.store.activeUser;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModalHeader(
                title: 'Mon compte',
                onClose: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Acces utilisateur',
                icon: Icons.badge_rounded,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x140C5D6D),
                        child: Icon(Icons.person_rounded, color: _green),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${user.username} - ${user.role}'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _openAccountAccessSheet(context),
                      icon: const Icon(Icons.manage_accounts_rounded),
                      label: const Text('Modifier mes accès'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAccountAccessSheet(BuildContext context) async {
    final username = TextEditingController(text: widget.store.activeUser.username);
    final current = TextEditingController();
    final next = TextEditingController(text: widget.store.activeUser.pin);
    final confirm = TextEditingController(text: widget.store.activeUser.pin);
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier mon compte',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  _AppField(label: 'Nom d utilisateur', controller: username),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Code secret actuel',
                    controller: current,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Nouveau code secret',
                    controller: next,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Confirmer le nouveau code',
                    controller: confirm,
                    number: true,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: 'Modification impossible',
                      subtitle: error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      if (username.text.trim().isEmpty) {
                        setLocal(() => error = 'Le nom d utilisateur est obligatoire.');
                        return;
                      }
                      if (next.text.trim().length < 6) {
                        setLocal(
                          () => error = 'Le nouveau code doit avoir au moins 6 caractères.',
                        );
                        return;
                      }
                      if (next.text.trim() != confirm.text.trim()) {
                        setLocal(() => error = 'La confirmation ne correspond pas.');
                        return;
                      }
                      final updated = widget.store.updateActiveUserAccess(
                        currentPin: current.text.trim(),
                        nextPin: next.text.trim(),
                        username: username.text.trim(),
                      );
                      if (!updated) {
                        setLocal(
                          () => error =
                              'Le code actuel est incorrect ou le nom d’utilisateur existe déjà.',
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Les accès du compte ont été mis à jour.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openHelpMedia({
    required String title,
    required String imageAsset,
    required List<String> lines,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalHeader(
                  title: title,
                  onClose: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF073744), Color(0xFF0F6F82)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: _strongTextColor(context),
                        height: 1.45,
                        fontWeight: line == lines.first ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final lines = [
      '1. Connecte-toi avec le role approprié: administrateur pour l administration générale, gestionnaire pour la supervision commerciale et caissier pour l encaissement quotidien.',
      '2. Commence toujours par vérifier les paramètres de l’entreprise: nom commercial, contacts, adresse, mentions fiscales et logo d exploitation.',
      '3. Ouvre Produits pour enregistrer les catégories, ajouter les articles, les images, les prix d’achat, les prix de vente, les unités et les seuils d’alerte.',
      '4. Utilise les mouvements de stock pour corriger les entrées, sorties, ajustements et stock initial avant de commencer les ventes réelles.',
      '5. Dans Vendre, recherche ou fais défiler les produits, touche un produit pour augmenter la quantité puis vérifie le panier avant validation.',
      '6. Choisis le client, applique une remise si nécessaire, indique le montant payé et choisis le mode de paiement approprié.',
      '7. Si la vente est à crédit, saisis obligatoirement l’échéance de paiement afin que la dette soit suivie, relancée et soldable plus tard.',
      '8. Après validation, KESE génère automatiquement le ticket et la facture; utilise ensuite la prévisualisation pour imprimer ou exporter en PDF selon le besoin.',
      '9. Consulte Caisse pour le suivi des ventes, bénéfices, dépenses et journaux de caisse; consulte Plus pour les factures, clients, fournisseurs, achats, crédits et comptabilité.',
      '10. Utilise Messages pour lire les relances de paiements, recevoir les signalements internes et communiquer entre administrateur, gestionnaire et caissier.',
      '11. En cas de travail hors ligne, continue à enregistrer les opérations puis rends-toi dans Plus et clique sur Synchroniser dès que la connexion revient.',
      '12. Avant toute clôture de journée, vérifie les factures, les tickets, les dettes clients, les achats, les dépenses, les alertes stock et les rapports.',
    ];
    return SectionCard(
      title: 'Instructions',
      icon: Icons.menu_book_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  line,
                  style: TextStyle(
                    color: _strongTextColor(context),
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildConditionsSection(BuildContext context) {
    final lines = [
      'L’utilisation de KESE est réservée aux personnes autorisées par l’entreprise cliente.',
      'L’utilisateur doit saisir des données exactes et vérifier les ventes, paiements, achats, crédits et mouvements avant validation.',
      'Il est interdit de reproduire, copier, distribuer, revendre, louer, modifier ou reconditionner l’application sans autorisation préalable écrite du fabricant.',
      'Les logos, interfaces, documents générés, codes et visuels restent protégés par les droits du fabricant.',
      'Toute utilisation frauduleuse, tentative de détournement ou de suppression des protections de l’application engage la responsabilité de l’utilisateur.',
      'L’entreprise utilisatrice reste responsable du contrôle interne de ses utilisateurs, de ses accès et de ses données commerciales.',
      'Aucun utilisateur ne peut céder, dupliquer ou exploiter commercialement cette application pour le compte d’un tiers sans contrat valide avec le fabricant.',
      'Les comptes, codes secrets, droits et journaux d’activité doivent être gérés avec confidentialité et dans le respect de la hiérarchie définie par l’administrateur.',
      'Le fabricant peut recommander des mises à jour, contrôles de licence, vérifications techniques ou opérations de maintenance lorsque cela est nécessaire à la stabilité de la solution.',
      'Les données exportées, imprimées ou synchronisées doivent être vérifiées par l’entreprise cliente avant toute utilisation comptable, fiscale ou contractuelle.',
      'Toute tentative de désactivation des protections, de contournement des accès, de falsification des journaux ou de modification non autorisée de l’architecture est strictement interdite.',
      'Le client utilisateur reconnaît que les services de support, de personnalisation, de maintenance ou de réactivation sont régis par les conditions commerciales du fabricant.',
    ];
    return SectionCard(
      title: 'Conditions d’utilisation',
      icon: Icons.gavel_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  line,
                  style: TextStyle(
                    color: _strongTextColor(context),
                    height: 1.52,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Column(
      children: [
        const _InfoSupportHero(),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Présentation de l’Entreprise — D-Square Technologies',
          icon: Icons.support_agent_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openHelpMedia(
                  title: 'DSquare Technologies',
                  imageAsset: _dtechLogoAsset,
                  lines: const [
                    'Présentation de l’Entreprise — D-Square Technologies',
                    ..._companyPresentationParagraphs,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                child: const _BrandBanner(),
              ),
              const SizedBox(height: 12),
              const _HelpParagraphs(_companyPresentationParagraphs),
              const SizedBox(height: 8),
              const _HelpBulletList(_companyDomains),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Présentation du Fondateur — Musagara Daniel',
          icon: Icons.person_search_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openHelpMedia(
                  title: 'Musagara Daniel',
                  imageAsset: _architectAsset,
                  lines: const [
                    'Présentation du Fondateur — Musagara Daniel',
                    ..._founderPresentationParagraphs,
                    'Email: danielmusagara@gmail.com',
                    'Telephone / WhatsApp: +243 971 238 634',
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                child: const CreatorProfileCard(),
              ),
              const SizedBox(height: 12),
              const _HelpParagraphs(_founderPresentationParagraphs),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.alternate_email_rounded, color: _green),
                title: const Text('Email'),
                subtitle: const Text('danielmusagara@gmail.com'),
                onTap: () => openExternalUrl('mailto:danielmusagara@gmail.com'),
              ),
              ListTile(
                leading: const Icon(Icons.phone_rounded, color: _green),
                title: const Text('Telephone'),
                subtitle: const Text('+243 971 238 634'),
                onTap: () => openExternalUrl('tel:+243971238634'),
              ),
              ListTile(
                leading: Image.asset(
                  _whatsAppAsset,
                  width: 22,
                  height: 22,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                ),
                title: const Text('WhatsApp'),
                subtitle: const Text('+243 971 238 634'),
                onTap: () => openExternalUrl('https://wa.me/243971238634'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Présentation de l’Application — KESE',
          icon: Icons.storefront_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openHelpMedia(
                  title: 'KESE',
                  imageAsset: _keseLogoAsset,
                  lines: const [
                    'Présentation de l’Application — KESE',
                    ..._kesePresentationParagraphs,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                child: const _KeseBrandBanner(),
              ),
              const SizedBox(height: 12),
              const _HelpParagraphs(_kesePresentationParagraphs),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Fonctionnalités principales de KESE',
          icon: Icons.checklist_rounded,
          child: const _HelpBulletList(_keseFeatures),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Une solution disponible partout',
          icon: Icons.devices_rounded,
          child: const _HelpBulletList(_kesePlatforms),
        ),
      ],
    );
  }

  Future<void> _openPasswordSheet(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            18 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setLocal) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: 'Modifier mon code secret',
                    onClose: () => Navigator.pop(sheetContext),
                  ),
                  const SizedBox(height: 12),
                  _AppField(
                    label: 'Code secret actuel',
                    controller: current,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Nouveau code secret',
                    controller: next,
                    number: true,
                  ),
                  const SizedBox(height: 10),
                  _AppField(
                    label: 'Confirmer le nouveau code',
                    controller: confirm,
                    number: true,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      title: 'Modification impossible',
                      subtitle: error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      if (next.text.trim().length < 6) {
                        setLocal(
                          () => error = 'Le nouveau code doit avoir au moins 6 caractères.',
                        );
                        return;
                      }
                      if (next.text.trim() != confirm.text.trim()) {
                        setLocal(() => error = 'La confirmation ne correspond pas.');
                        return;
                      }
                      final updated = widget.store.updateActiveUserPin(
                        currentPin: current.text.trim(),
                        nextPin: next.text.trim(),
                      );
                      if (!updated) {
                        setLocal(
                          () => error = 'Le code secret actuel est incorrect.',
                        );
                        return;
                      }
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code secret mis à jour avec succes.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_reset_rounded),
                    label: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const _PageHeader(
          title: 'Informations',
          subtitle: 'Instructions, conditions d utilisation et aide technique.',
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 12),
        const _InfoLandingCard(),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => _openAccountCenter(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0C5D6D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.manage_accounts_rounded),
            label: const Text('Acceder a mon compte'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTabButton(
                label: 'Aide',
                selected: section == 'Aide',
                onTap: () => setState(() => section = 'Aide'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoTabButton(
                label: 'Instructions',
                selected: section == 'Instructions',
                onTap: () => setState(() => section = 'Instructions'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoTabButton(
                label: 'Conditions',
                selected: section == 'Conditions',
                onTap: () => setState(() => section = 'Conditions'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        switch (section) {
          'Conditions' => _buildConditionsSection(context),
          'Aide' => _buildHelpSection(context),
          _ => _buildInstructionsSection(context),
        },
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Changer de compte'),
        ),
      ],
    );
  }
}

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final muted = _mutedTextColor(context);
    final width = MediaQuery.sizeOf(context).width;
    final roomy = width >= 900;
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 7 : (roomy ? 8 : 9),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 18 : (roomy ? 22 : 20),
              backgroundColor: _softPanelColor(context),
              child: Icon(
                icon,
                color: _green,
                size: compact ? 20 : (roomy ? 24 : 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 12.5 : (roomy ? 14 : 13),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 20 : (roomy ? 24 : 22),
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTabButton extends StatelessWidget {
  const _InfoTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = _panelColor(context);
    final border = _panelBorderColor(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _green : base,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _green : border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _green,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BrandBanner extends StatelessWidget {
  const _BrandBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D687A), Color(0xFF1692A2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0x22000000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Image.asset(
                _dtechLogoAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DSquare Technologies',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Built with DSquare Technologies by Musagara Daniel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLandingCard extends StatelessWidget {
  const _InfoLandingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF063744), Color(0xFF0C5D6D), Color(0xFF1590A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Image.asset(
                  _keseLogoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centre d information KESE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Support, fabricant, aide technique et bonnes pratiques dans une interface plus claire.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _InfoHeroChip(
                icon: Icons.support_agent_rounded,
                label: 'Support',
              ),
              _InfoHeroChip(
                icon: Icons.shield_outlined,
                label: 'Conditions',
              ),
              _InfoHeroChip(
                icon: Icons.menu_book_rounded,
                label: 'Guides',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoHeroChip extends StatelessWidget {
  const _InfoHeroChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSupportHero extends StatelessWidget {
  const _InfoSupportHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _softAccentStrong(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.live_help_rounded, color: _green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aide en premier',
                      style: TextStyle(
                        color: _strongTextColor(context),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cette page s ouvre maintenant sur l aide pour donner plus vite acces au support, au fabricant et aux contacts utiles.',
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _InfoSupportMiniTile(
                icon: Icons.business_center_rounded,
                title: 'Fabricant',
                subtitle: 'DSquare Technologies',
              ),
              _InfoSupportMiniTile(
                icon: Icons.storefront_rounded,
                title: 'Produit',
                subtitle: 'KESE',
              ),
              _InfoSupportMiniTile(
                icon: Icons.person_search_rounded,
                title: 'Architecte',
                subtitle: 'Musagara Daniel',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSupportMiniTile extends StatelessWidget {
  const _InfoSupportMiniTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _panelColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: _green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _mutedTextColor(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _strongTextColor(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeseBrandBanner extends StatelessWidget {
  const _KeseBrandBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF073744), Color(0xFF0C5D6D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  _keseLogoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KESE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Votre assistante commerciale',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreatorProfileCard extends StatelessWidget {
  const CreatorProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: _softAccentColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              _architectAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Text(
                'MD',
                style: TextStyle(
                  color: _greenDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Musagara Daniel',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Architecte de l’application et point de contact technique principal.',
                  style: TextStyle(color: _mutedTextColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStatTile extends StatelessWidget {
  const MiniStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = _mutedTextColor(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: _softPanelColor(context),
              child: Icon(icon, size: 12, color: _green),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactKpiTile extends StatelessWidget {
  const CompactKpiTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = _mutedTextColor(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: _softPanelColor(context),
              child: Icon(icon, size: 15, color: _green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductInfoRow extends StatelessWidget {
  const ProductInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _panelColor(context),
            child: Icon(icon, size: 15, color: _green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _mutedTextColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _strongTextColor(context),
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.onTap});
  final AppAlert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final warning = alert.level == AlertLevel.warning;
    final infoSurface = _softPanelColor(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: alert.isRead ? 0.62 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: alert.isRead
              ? _panelColor(context)
              : (warning ? _warningSurface(context) : infoSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            warning ? Icons.warning_rounded : Icons.info_rounded,
            color: warning ? Colors.orange.shade800 : _green,
          ),
          title: Text(
            alert.title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(alert.body),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: alert.isRead
                ? const Icon(
                    Icons.done_rounded,
                    key: ValueKey('read'),
                    color: _green,
                  )
                : const Icon(
                    Icons.circle_notifications_rounded,
                    key: ValueKey('unread'),
                    color: _green,
                  ),
          ),
        ),
      ),
    );
  }
}

class _InboxMessageTile extends StatelessWidget {
  const _InboxMessageTile({
    required this.message,
    this.onTap,
  });

  final AppMessage message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !message.isRead;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: unread ? 1 : 0.68,
      child: Container(
        decoration: BoxDecoration(
          color: unread ? _softAccentStrong(context) : _panelColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: unread
                ? const Color(0x140C5D6D)
                : _softPanelColor(context),
            child: Icon(
              message.title.toLowerCase().contains('retard')
                  ? Icons.warning_amber_rounded
                  : Icons.schedule_send_rounded,
              color: message.title.toLowerCase().contains('retard')
                  ? _danger
                  : _green,
            ),
          ),
          title: Text(
            message.title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: _strongTextColor(context),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _mutedTextColor(context),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(message.createdAt),
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                unread ? Icons.mark_email_unread_rounded : Icons.done_all_rounded,
                size: 18,
                color: unread ? _green : _mutedTextColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageAttachmentDraftTile extends StatelessWidget {
  const _MessageAttachmentDraftTile({
    required this.kind,
    required this.fileName,
    required this.onClear,
    this.dataUrl,
  });

  final String kind;
  final String fileName;
  final VoidCallback onClear;
  final String? dataUrl;

  @override
  Widget build(BuildContext context) {
    final icon = switch (kind) {
      'image' => Icons.image_outlined,
      'audio' => Icons.mic_none_rounded,
      _ => Icons.attach_file_rounded,
    };
    final label = switch (kind) {
      'image' => 'Image jointe',
      'audio' => 'Note vocale jointe',
      _ => 'Document joint',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (kind == 'audio' && dataUrl != null) ...[
            const SizedBox(height: 10),
            AudioAttachmentPlayer(
              dataUrl: dataUrl!,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.canEdit,
    required this.onDeleteForMe,
    this.onOpenActions,
    this.onEdit,
    this.onDeleteForEveryone,
    this.onOpenAttachment,
  });

  final AppMessage message;
  final bool isCurrentUser;
  final bool canEdit;
  final VoidCallback onDeleteForMe;
  final VoidCallback? onOpenActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDeleteForEveryone;
  final VoidCallback? onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final surface = isCurrentUser
        ? (dark ? const Color(0xFF0C5D6D) : _green)
        : (dark ? const Color(0xFF202C33) : const Color(0xFFF1F3F6));
    final borderColor = isCurrentUser
        ? (dark ? const Color(0xFF127489) : const Color(0xFF16758A))
        : (dark ? const Color(0xFF2C3A43) : const Color(0xFFE6EAF0));
    final bubbleTextColor =
        dark || isCurrentUser ? Colors.white : const Color(0xFF182229);
    final info = <String>[
      if (message.editedAt != null) 'modifie',
      if (message.recipientReadAt != null && isCurrentUser) 'lu',
      if (message.expiresAt != null && !message.isMediaExpired) '7 jours',
    ].join(' - ');
    final contentLabel = switch (message.contentType) {
      'image' => 'Image',
      'audio' => 'Note vocale',
      'file' => 'Document',
      _ => '',
    };
    final maxWidth =
        MediaQuery.sizeOf(context).width * (isCurrentUser ? 0.66 : 0.72);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(160.0, 420.0)),
      child: GestureDetector(
        onLongPress: onOpenActions,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 7),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isCurrentUser ? 18 : 6),
                    bottomRight: Radius.circular(isCurrentUser ? 6 : 18),
                  ),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(dark ? 12 : 8),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isDeletedForEveryone)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          'Message supprime',
                          style: TextStyle(
                            color: dark
                                ? Colors.white60
                                : const Color(0xFF667781),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else ...[
                      if (message.canDisplayAttachment) ...[
                        if (message.contentType == 'image')
                          InkWell(
                            onTap: onOpenAttachment,
                            borderRadius: BorderRadius.circular(14),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 220,
                                ),
                                child: Image.network(
                                  message.attachmentDataUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else if (message.contentType == 'audio')
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.white.withAlpha(8)
                                  : const Color(0xFFF4F7F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: dark
                                    ? Colors.white10
                                    : const Color(0xFFE4E9EC),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: _softAccentStrong(context),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.mic_rounded,
                                        color: _green,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        message.attachmentName ??
                                            contentLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: bubbleTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AudioAttachmentPlayer(
                                  dataUrl: message.attachmentDataUrl!,
                                  compact: true,
                                ),
                              ],
                            ),
                          )
                        else
                          InkWell(
                            onTap: onOpenAttachment,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: dark
                                    ? Colors.white.withAlpha(7)
                                    : const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: dark
                                      ? Colors.white10
                                      : const Color(0xFFE4E9EC),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: _softAccentStrong(context),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: _green,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message.attachmentName ??
                                                  contentLabel,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: bubbleTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Touchez pour ouvrir',
                                              style: TextStyle(
                                                color: dark
                                                    ? Colors.white54
                                                    : const Color(
                                                        0xFF667781,
                                                      ),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.download_rounded,
                                        size: 18,
                                        color: dark
                                            ? Colors.white60
                                            : const Color(0xFF667781),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: onOpenAttachment,
                                      style: TextButton.styleFrom(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize
                                                .shrinkWrap,
                                      ),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 15,
                                      ),
                                      label: const Text(
                                        'Ouvrir / telecharger',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (message.body.trim().isNotEmpty)
                          const SizedBox(height: 8),
                      ],
                      if (message.isMediaExpired)
                        Text(
                          'Ce média a expiré après 7 jours.',
                          style: TextStyle(
                            color: dark
                                ? Colors.white60
                                : const Color(0xFF667781),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else if (message.body.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            message.body,
                            style: TextStyle(
                              color: bubbleTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.26,
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: dark
                                  ? Colors.white54
                                  : const Color(0xFF667781),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (info.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Text(
                              info,
                              style: TextStyle(
                                color: dark
                                    ? Colors.white54
                                    : const Color(0xFF667781),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 5),
                            Icon(
                              message.recipientReadAt != null
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 15,
                              color: message.recipientReadAt != null
                                  ? const Color(0xFF53BDEB)
                                  : (dark
                                      ? Colors.white54
                                      : const Color(0xFF667781)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatDateChip extends StatelessWidget {
  const _ChatDateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF182229) : const Color(0xFFE9EDEF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: dark ? Colors.white70 : const Color(0xFF54656F),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ChatThreadTile extends StatelessWidget {
  const _ChatThreadTile({
    required this.peer,
    required this.messages,
    required this.currentUserCode,
    this.onTap,
  });

  final AppUser peer;
  final List<AppMessage> messages;
  final String currentUserCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final lastMessage = messages.isEmpty ? null : messages.last;
    final unreadCount = messages
        .where(
          (message) =>
              message.recipientCode == currentUserCode &&
              message.senderCode == peer.code &&
              !message.isRead,
        )
        .length;
    final preview = lastMessage == null
        ? 'Aucune discussion pour le moment.'
        : lastMessage.isDeletedForEveryone
        ? 'Message supprime'
        : lastMessage.isMediaExpired
        ? 'Media expire'
        : switch (lastMessage.contentType) {
            'image' => 'Image',
            'audio' => 'Note vocale',
            'file' => lastMessage.attachmentName ?? 'Document',
            _ => lastMessage.body,
          };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: unreadCount > 0
                ? _softPanelColor(context)
                : _panelColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unreadCount > 0
                  ? _softAccentStrong(context)
                  : _panelBorderColor(context),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _softAccentColor(context),
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  peer.name.trim().isEmpty
                      ? '?'
                      : peer.name.trim().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: _greenDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            peer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _strongTextColor(context),
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            '${lastMessage.createdAt.hour.toString().padLeft(2, '0')}:${lastMessage.createdAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: unreadCount > 0
                                  ? _greenDark
                                  : _mutedTextColor(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${peer.role} · @${peer.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dark
                            ? Colors.white54
                            : const Color(0xFF667781),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _mutedTextColor(context),
                              height: 1.25,
                              fontWeight:
                                  unreadCount > 0
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                height: 1,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _mutedTextColor(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.spec,
    required this.selected,
    required this.onTap,
  });
  final ModuleSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        _isDark(context) ? const Color(0xFF153543) : const Color(0xFFE7F5F8);
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: selected ? selectedColor : _panelColor(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 15 : 14,
            vertical: desktop ? 12 : 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0x550F6F82)
                  : _panelBorderColor(context),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x26073B48),
                blurRadius: selected ? 24 : 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(_isDark(context) ? 0 : .26),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(spec.icon, color: _green, size: desktop ? 24 : 22),
              const SizedBox(height: 7),
              Text(
                spec.title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: desktop ? 15.5 : 15,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                spec.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _mutedTextColor(context),
                  fontSize: desktop ? 12.8 : 12.4,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManagementModuleHeader extends StatelessWidget {
  const ManagementModuleHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7084), Color(0xFF15A0B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A4C5D),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withAlpha(36),
                child: Icon(icon, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(32),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Gestion complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PagedWidgetList extends StatefulWidget {
  const PagedWidgetList({
    super.key,
    required this.items,
    this.pageSize = 5,
  });

  final List<Widget> items;
  final int pageSize;

  @override
  State<PagedWidgetList> createState() => _PagedWidgetListState();
}

class _PagedWidgetListState extends State<PagedWidgetList> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final totalPages = ((widget.items.length + widget.pageSize - 1) ~/ widget.pageSize)
        .clamp(1, 9999);
    final safePage = page.clamp(0, totalPages - 1);
    if (safePage != page) page = safePage;
    final visible = widget.items
        .skip(safePage * widget.pageSize)
        .take(widget.pageSize)
        .toList();

    return Column(
      children: [
        ...visible,
        if (totalPages > 1) ...[
          const SizedBox(height: 10),
          _PagerControls(
            page: safePage,
            totalPages: totalPages,
            onPrevious: safePage == 0 ? null : () => setState(() => page -= 1),
            onNext: safePage >= totalPages - 1
                ? null
                : () => setState(() => page += 1),
          ),
        ],
      ],
    );
  }
}

class _SyncActionCard extends StatelessWidget {
  const _SyncActionCard({
    required this.syncing,
    required this.pendingChanges,
    required this.lastSyncAt,
    required this.pendingActivation,
    required this.onTap,
  });

  final bool syncing;
  final int pendingChanges;
  final DateTime? lastSyncAt;
  final bool pendingActivation;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = syncing
        ? 'Synchronisation en cours entre la base locale et la base en ligne...'
        : pendingActivation
        ? 'Une activation locale attend encore sa liaison cloud. Lance la synchronisation dès que la connexion est disponible.'
        : pendingChanges > 0
        ? '$pendingChanges changement(s) en attente de remontee vers la base en ligne.'
        : lastSyncAt == null
        ? 'Aucune synchronisation lancee pour le moment.'
        : 'Derniere synchronisation: ${_formatDate(lastSyncAt!)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PressableScale(
          onTap: () {
            if (syncing) return;
            onTap();
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A4C5D), Color(0xFF0F6F82), Color(0xFF14A1B3)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x220A4C5D),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(.24)),
                  ),
                  child: syncing
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.sync_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Synchroniser',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(.22)),
                  ),
                  child: Text(
                    syncing ? 'Sync...' : 'Lancer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewQuickTile extends StatelessWidget {
  const _OverviewQuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: _softPanelColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _panelColor(context),
                child: Icon(icon, color: _green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: _mutedTextColor(context)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _green),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagerControls extends StatelessWidget {
  const _PagerControls({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('Retour'),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _softPanelColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _panelBorderColor(context)),
          ),
          child: Text(
            '${page + 1}/$totalPages',
            style: TextStyle(
              color: _mutedTextColor(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Suivant'),
          ),
        ),
      ],
    );
  }
}

class ManagePartyTile extends StatelessWidget {
  const ManagePartyTile({
    super.key,
    required this.icon,
    required this.name,
    required this.code,
    required this.subtitle,
    this.whatsappNumber,
    this.onWhatsApp,
    this.onEdit,
    this.onDelete,
  });

  final IconData icon;
  final String name;
  final String code;
  final String subtitle;
  final String? whatsappNumber;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: _softAccentColor(context),
              child: Icon(icon, color: _green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    code,
                    style: const TextStyle(
                      color: _greenDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _mutedTextColor(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (whatsappNumber != null && whatsappNumber!.trim().isNotEmpty)
                  _PartyActionButton(
                    onPressed: onWhatsApp,
                    tooltip: 'WhatsApp',
                    background: Colors.transparent,
                    size: 28,
                    showShadow: false,
                    child: Image.asset(
                      _whatsAppAsset,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.chat_rounded,
                        size: 20,
                        color: Color(0xFF25D366),
                      ),
                    ),
                  ),
                const SizedBox(width: 2),
                if (onEdit != null)
                  IconButton(
                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                    padding: EdgeInsets.zero,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    tooltip: 'Modifier',
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 2),
                  IconButton(
                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: _danger,
                    tooltip: 'Supprimer',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyActionButton extends StatelessWidget {
  const _PartyActionButton({
    required this.onPressed,
    required this.tooltip,
    required this.child,
    this.background = Colors.white,
    this.borderColor,
    this.size = 36,
    this.showShadow = true,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final Widget child;
  final Color background;
  final Color? borderColor;
  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: borderColor == null
                ? null
                : Border.all(
                    color: borderColor!,
                  ),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class AlertStatusStrip extends StatelessWidget {
  const AlertStatusStrip({
    super.key,
    required this.unreadCount,
    required this.lowStockCount,
    required this.creditAmount,
    required this.alertCount,
  });

  final int unreadCount;
  final int lowStockCount;
  final String creditAmount;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AlertStatusIcon(
            icon: Icons.notifications_active_rounded,
            label: '$alertCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AlertStatusIcon(
            icon: Icons.mark_email_unread_rounded,
            label: '$unreadCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AlertStatusIcon(
            icon: Icons.warning_amber_rounded,
            label: '$lowStockCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AlertStatusIcon(
            icon: Icons.credit_score_rounded,
            label: creditAmount,
          ),
        ),
      ],
    );
  }
}

class _AlertStatusIcon extends StatelessWidget {
  const _AlertStatusIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _softAccentStrong(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _green),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _AccountingLine extends StatelessWidget {
  const _AccountingLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: emphasize ? _softAccentStrong(context) : _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _strongTextColor(context),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: emphasize ? 18 : 16,
              color: emphasize ? _greenDark : _strongTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class UserManagementTile extends StatelessWidget {
  const UserManagementTile({
    super.key,
    required this.user,
    this.onInspect,
    this.onEdit,
    this.onToggleBlock,
    this.onDelete,
  });

  final AppUser user;
  final VoidCallback? onInspect;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleBlock;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final blocked = user.isBlocked;
    final badgeColor = blocked ? _dangerSurface(context) : _softAccentColor(context);
    final badgeTextColor = blocked ? _danger : _greenDark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _softAccentColor(context),
                  child: Icon(
                    user.isAdmin
                        ? Icons.workspace_premium_rounded
                        : user.isManager
                        ? Icons.manage_accounts_rounded
                        : Icons.point_of_sale_rounded,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: _greenDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.code,
                        style: TextStyle(
                          color: _mutedTextColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    blocked ? '${user.role} - Bloque' : user.role,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onInspect != null)
                  OutlinedButton.icon(
                    onPressed: onInspect,
                    icon: const Icon(Icons.insights_rounded),
                    label: const Text('Activites'),
                  ),
                if (onEdit != null)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Modifier'),
                  ),
                if (onToggleBlock != null)
                  OutlinedButton.icon(
                    onPressed: onToggleBlock,
                    icon: Icon(
                      blocked
                          ? Icons.lock_open_rounded
                          : Icons.block_rounded,
                    ),
                    label: Text(blocked ? 'Débloquer' : 'Bloquer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: blocked ? _greenDark : _danger,
                    ),
                  ),
                if (onDelete != null)
                  FilledButton.tonalIcon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Supprimer'),
                    style: FilledButton.styleFrom(
                      foregroundColor: _danger,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportDetailTile extends StatelessWidget {
  const _ReportDetailTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: _softPanelColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _panelColor(context),
                child: const Icon(Icons.assessment_rounded, color: _green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: _mutedTextColor(context)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _softAccentColor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir',
                      style: TextStyle(
                        color: _greenDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: _greenDark, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TradingChartCard extends StatelessWidget {
  const TradingChartCard({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final points = _buildTradingPoints();
    final gradient = _isDark(context)
        ? const [Color(0xFF0A4C5D), Color(0xFF0F6F82), Color(0xFF17A2B7)]
        : const [Color(0xFF0B5A6C), Color(0xFF0F6F82), Color(0xFF19A9BC)];
    return SectionCard(
      title: 'Courbe de tendance',
      icon: Icons.show_chart_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flux des ventes',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              store.money(store.todayMetrics.revenue),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _TradingChartPainter(points),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _buildTradingPoints() {
    final sales = store.visibleSales;
    if (sales.isEmpty) {
      return const [12, 18, 15, 22, 20, 28, 24];
    }
    final grouped = <double>[];
    for (var i = 0; i < sales.length; i++) {
      grouped.add(sales[i].total.toDouble());
    }
    while (grouped.length < 7) {
      grouped.insert(0, grouped.isEmpty ? 12 : grouped.first * 0.9);
    }
    return grouped.take(7).toList();
  }
}

class _TradingChartPainter extends CustomPainter {
  _TradingChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 1 ? 1.0 : maxValue - minValue;

    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(28)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xAAFFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / range) * (size.height - 12) - 6;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = Colors.white;
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / range) * (size.height - 12) - 6;
      canvas.drawCircle(Offset(x, y), 4.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TradingChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class JournalLedgerTable extends StatefulWidget {
  const JournalLedgerTable({
    super.key,
    required this.rows,
    required this.money,
    this.onRowTap,
    this.showFilter = false,
    this.showSwipeHint = false,
  });

  final List<LedgerRow> rows;
  final String Function(num value) money;
  final ValueChanged<LedgerRow>? onRowTap;
  final bool showFilter;
  final bool showSwipeHint;

  @override
  State<JournalLedgerTable> createState() => _JournalLedgerTableState();
}

class _JournalLedgerTableState extends State<JournalLedgerTable> {
  int page = 0;
  String filter = 'Tout';
  String dateQuery = '';
  String productQuery = '';
  String clientQuery = '';
  late final TextEditingController _dateController;
  late final TextEditingController _productController;
  late final TextEditingController _clientController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _productController = TextEditingController();
    _clientController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _productController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = widget.showFilter
        ? widget.rows.where(_matchesLedgerFilter).toList()
        : widget.rows;
    final totalPages = ((filteredRows.length + 4) ~/ 5).clamp(1, 9999);
    final safePage = page.clamp(0, totalPages - 1);
    if (safePage != page) page = safePage;
    final start = safePage * 5;
    final visible = filteredRows.skip(start).take(5).toList();
    num runningBalance = 0;
    final orderedForBalance = filteredRows.reversed.toList();
    final balances = <String, num>{};
    for (final row in orderedForBalance) {
      runningBalance += row.amount;
      balances['${row.kind}-${row.reference}-${row.createdAt.microsecondsSinceEpoch}'] =
          runningBalance;
    }

    return Column(
      children: [
        if (widget.showFilter) ...[
          _JournalFilterTabs(
            value: filter,
            onChanged: (value) => setState(() {
              filter = value;
              page = 0;
            }),
          ),
          const SizedBox(height: 10),
          _buildAdvancedFilters(context, filteredRows),
          const SizedBox(height: 10),
        ],
        if (widget.showSwipeHint) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Glisse vers la gauche pour voir les autres colonnes du tableau.',
              style: TextStyle(
                color: _mutedTextColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Référence')),
                DataColumn(label: Text('Produits')),
                DataColumn(label: Text('Client')),
                DataColumn(label: Text('Entrée')),
                DataColumn(label: Text('Sortie')),
                DataColumn(label: Text('Solde')),
              ],
              rows: visible.map((row) {
                final key =
                    '${row.kind}-${row.reference}-${row.createdAt.microsecondsSinceEpoch}';
                final balance = balances[key] ?? 0;
                final inAmount = row.amount > 0 ? widget.money(row.amount) : '-';
                final outAmount = row.amount < 0 ? widget.money(row.amount.abs()) : '-';
                return DataRow(
                  cells: [
                    DataCell(Text(_formatDate(row.createdAt))),
                    DataCell(Text(row.kind)),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          row.reference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          row.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 170),
                        child: Text(
                          row.party,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(inAmount)),
                    DataCell(Text(outAmount)),
                    DataCell(Text(widget.money(balance))),
                  ],
                  onSelectChanged: widget.onRowTap == null
                      ? null
                      : (_) => widget.onRowTap!(row),
                );
              }).toList(),
            ),
          ),
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 10),
          _PagerControls(
            page: safePage,
            totalPages: totalPages,
            onPrevious: safePage == 0 ? null : () => setState(() => page -= 1),
            onNext: safePage >= totalPages - 1
                ? null
                : () => setState(() => page += 1),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedFilters(BuildContext context, List<LedgerRow> filteredRows) {
    final actionBar = Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _hasAnySearchFilter
                ? () => setState(() {
                    _dateController.clear();
                    _productController.clear();
                    _clientController.clear();
                    dateQuery = '';
                    productQuery = '';
                    clientQuery = '';
                    page = 0;
                  })
                : null,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Effacer'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: filteredRows.isEmpty
                ? null
                : () => downloadBytes(
                    'grand-livre-simplifie.pdf',
                    _buildLedgerPdfBytes(
                      filteredRows,
                      widget.money,
                      typeFilter: filter,
                      dateFilter: dateQuery,
                      productFilter: productQuery,
                      clientFilter: clientQuery,
                    ),
                    'application/pdf',
                  ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('PDF'),
          ),
        ),
      ],
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LedgerCompactPicker(
                icon: Icons.calendar_month_rounded,
                label: 'Date',
                value: _dateController.text,
                placeholder: 'Choisir',
                onTap: _pickLedgerDate,
                onClear: dateQuery.trim().isEmpty ? null : _clearDateFilter,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LedgerCompactPicker(
                icon: Icons.inventory_2_rounded,
                label: 'Produit',
                value: _productController.text,
                placeholder: 'Choisir',
                onTap: () => _pickLedgerOption(
                  title: 'Produit',
                  controller: _productController,
                  options: _productOptions,
                  onApply: (value) => productQuery = value,
                ),
                onClear:
                    productQuery.trim().isEmpty ? null : _clearProductFilter,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _LedgerCompactPicker(
                icon: Icons.person_search_rounded,
                label: 'Client',
                value: _clientController.text,
                placeholder: 'Choisir',
                onTap: () => _pickLedgerOption(
                  title: 'Client',
                  controller: _clientController,
                  options: _clientOptions,
                  onApply: (value) => clientQuery = value,
                ),
                onClear: clientQuery.trim().isEmpty ? null : _clearClientFilter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: 280, child: actionBar),
        ),
      ],
    );
  }

  bool get _hasAnySearchFilter =>
      dateQuery.trim().isNotEmpty ||
      productQuery.trim().isNotEmpty ||
      clientQuery.trim().isNotEmpty;

  List<String> get _productOptions {
    final values = widget.rows
        .map((row) => row.label.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }

  List<String> get _clientOptions {
    final values = widget.rows
        .map((row) => row.party.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }

  Future<void> _pickLedgerDate() async {
    var initialDate = DateTime.now();
    final raw = dateQuery.trim().replaceAll('/', '-');
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      initialDate = parsed;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Filtrer par date',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      _dateController.text = value;
      dateQuery = value;
      page = 0;
    });
  }

  Future<void> _pickLedgerOption({
    required String title,
    required TextEditingController controller,
    required List<String> options,
    required ValueChanged<String> onApply,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LedgerOptionPickerSheet(
        title: title,
        initialValue: controller.text,
        options: options,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      controller.text = selected;
      onApply(selected);
      page = 0;
    });
  }

  void _clearDateFilter() {
    setState(() {
      _dateController.clear();
      dateQuery = '';
      page = 0;
    });
  }

  void _clearProductFilter() {
    setState(() {
      _productController.clear();
      productQuery = '';
      page = 0;
    });
  }

  void _clearClientFilter() {
    setState(() {
      _clientController.clear();
      clientQuery = '';
      page = 0;
    });
  }

  bool _matchesLedgerFilter(LedgerRow row) {
    final matchesType = switch (filter) {
      'Tout' => true,
      'Ventes' => row.kind == 'Vente',
      'Dépenses' => row.kind == 'Depense',
      'Achats' => row.kind == 'Achat',
      _ => row.kind == filter,
    };
    if (!matchesType) return false;

    final normalizedDate = _normalizeSearchText(dateQuery);
    final normalizedProduct = _normalizeSearchText(productQuery);
    final normalizedClient = _normalizeSearchText(clientQuery);

    final dateMatches =
        normalizedDate.isEmpty || _ledgerDateVariants(row.createdAt).any((value) => value.contains(normalizedDate));
    final productMatches =
        normalizedProduct.isEmpty || _normalizeSearchText(row.label).contains(normalizedProduct);
    final clientMatches =
        normalizedClient.isEmpty || _normalizeSearchText(row.party).contains(normalizedClient);

    return dateMatches && productMatches && clientMatches;
  }

  List<String> _ledgerDateVariants(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return [
      _normalizeSearchText(_formatDate(value)),
      _normalizeSearchText('$day/$month'),
      _normalizeSearchText('$day/$month/$year'),
      _normalizeSearchText('$year-$month-$day'),
    ];
  }
}

class CompanyLogoBadge extends StatelessWidget {
  const CompanyLogoBadge({super.key, required this.settings});
  final CompanySettings settings;

  @override
  Widget build(BuildContext context) {
    final source = settings.logoUrl.trim();
    Widget child;
    if (source.startsWith('data:image')) {
      final data = UriData.parse(source);
      child = Image.memory(data.contentAsBytes(), fit: BoxFit.cover);
    } else if (source.isNotEmpty) {
      child = Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else {
      child = _fallback();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: 46, height: 46, child: child),
    );
  }

  Widget _fallback() {
    final initial = settings.companyName.trim().isEmpty
        ? 'D'
        : settings.companyName.trim().substring(0, 1).toUpperCase();
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: _green,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }
}

enum DocumentPreviewMode { invoice, ticket }

class DocumentPreviewSheet extends StatefulWidget {
  const DocumentPreviewSheet({
    super.key,
    required this.store,
    required this.sale,
    required this.onClose,
    required this.onPrintTicket,
    required this.onPrintInvoice,
    required this.onExportInvoicePdf,
    this.onSettleCredit,
    this.initialMode = DocumentPreviewMode.invoice,
  });

  final AppStore store;
  final Sale sale;
  final VoidCallback onClose;
  final VoidCallback onPrintTicket;
  final VoidCallback onPrintInvoice;
  final VoidCallback onExportInvoicePdf;
  final VoidCallback? onSettleCredit;
  final DocumentPreviewMode initialMode;

  @override
  State<DocumentPreviewSheet> createState() => _DocumentPreviewSheetState();
}

class _DocumentPreviewSheetState extends State<DocumentPreviewSheet> {
  late DocumentPreviewMode mode = widget.initialMode;
  late final Future<Uint8List> _invoicePdfFuture;

  @override
  void initState() {
    super.initState();
    _invoicePdfFuture = _buildModernInvoicePdfBytes(widget.store, widget.sale);
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final isInvoice = mode == DocumentPreviewMode.invoice;
    final ticketHtml = _buildThermalTicketHtml(widget.store, sale);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final previewHeight = isInvoice
        ? (screenHeight * 0.58).clamp(420.0, 620.0)
        : (screenHeight * 0.44).clamp(280.0, 380.0);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModalHeader(
              title: isInvoice ? 'Facture ${sale.invoiceNo}' : 'Ticket ${sale.ticketNo}',
              onClose: widget.onClose,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PreviewModeButton(
                    label: 'Facture',
                    icon: Icons.description_rounded,
                    selected: isInvoice,
                    onTap: () => setState(() => mode = DocumentPreviewMode.invoice),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PreviewModeButton(
                    label: 'Ticket',
                    icon: Icons.receipt_long_rounded,
                    selected: !isInvoice,
                    onTap: () => setState(() => mode = DocumentPreviewMode.ticket),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _softPanelColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _panelBorderColor(context)),
              ),
              child: isInvoice
                  ? FutureBuilder<Uint8List>(
                      future: _invoicePdfFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return InvoicePreviewCard(
                            store: widget.store,
                            sale: sale,
                            qrPayload: _documentQrPayloadStatic(widget.store, sale, 'FACTURE'),
                          );
                        }
                        return PdfDocumentPreview(
                          bytes: snapshot.data!,
                          height: previewHeight,
                          fallback: InvoicePreviewCard(
                            store: widget.store,
                            sale: sale,
                            qrPayload: _documentQrPayloadStatic(widget.store, sale, 'FACTURE'),
                          ),
                        );
                      },
                    )
                  : HtmlDocumentPreview(
                      htmlDocument: ticketHtml,
                      height: previewHeight,
                      fallback: ReceiptPreview(
                        store: widget.store,
                        sale: sale,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            if (isInvoice)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onPrintInvoice,
                          icon: const Icon(Icons.print_rounded),
                          label: const Text('Imprimer facture'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: widget.onExportInvoicePdf,
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text('PDF facture'),
                        ),
                      ),
                    ],
                  ),
                  if (widget.sale.isCredit && widget.onSettleCredit != null) ...[
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: widget.onSettleCredit,
                      icon: const Icon(Icons.paid_rounded),
                      label: const Text('Marquer comme payee'),
                    ),
                  ],
                ],
              )
            else
              FilledButton.icon(
                onPressed: widget.onPrintTicket,
                icon: const Icon(Icons.print_rounded),
                label: const Text('Imprimer ticket'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewModeButton extends StatelessWidget {
  const _PreviewModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _green : _panelColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : _panelBorderColor(context),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : _greenDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : _greenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.store, required this.sale});
  final AppStore store;
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final legalText = [
      if (s.rccm.trim().isNotEmpty) 'RCCM: ${s.rccm}',
      if (s.idNat.trim().isNotEmpty) 'ID NAT: ${s.idNat}',
      if (s.nif.trim().isNotEmpty) 'NIF: ${s.nif}',
      if (s.efo.trim().isNotEmpty) 'EFO: ${s.efo}',
    ].join(' | ');
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFD6E5EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'monospace',
            color: _ink,
            fontSize: 12,
            height: 1.3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.companyName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(s.phone, textAlign: TextAlign.center),
              if (s.email.trim().isNotEmpty)
                Text(s.email, textAlign: TextAlign.center),
              if (s.address.trim().isNotEmpty)
                Text(s.address, textAlign: TextAlign.center),
              if (legalText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  legalText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const _DashedDivider(),
              const SizedBox(height: 8),
              Text(
                'TICKET DE CAISSE',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _ReceiptRow('Ticket', sale.ticketNo),
              _ReceiptRow('Facture', sale.invoiceNo),
              _ReceiptRow('Date', _formatDate(sale.createdAt)),
              _ReceiptRow('Client', sale.customer.name),
              _ReceiptRow('Caissier', sale.cashierName),
              _ReceiptRow('Paiement', sale.method),
              const SizedBox(height: 8),
              const _DashedDivider(),
              const SizedBox(height: 8),
              ...sale.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _ReceiptRow(
                    '${line.product} x${line.qty}',
                    store.money(line.qty * line.price),
                  ),
                ),
              ),
              const _DashedDivider(),
              const SizedBox(height: 8),
              _ReceiptRow('Sous-total', store.money(sale.subtotal)),
              _ReceiptRow('Remise', store.money(sale.discount)),
              _ReceiptRow('Total', store.money(sale.total), highlight: true),
              _ReceiptRow('Payé', store.money(sale.paid)),
              _ReceiptRow('Reste', store.money(sale.due)),
              const SizedBox(height: 8),
              const _DashedDivider(),
              const SizedBox(height: 8),
              Text(
                'Merci pour votre achat',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoicePreviewCard extends StatelessWidget {
  const InvoicePreviewCard({
    super.key,
    required this.store,
    required this.sale,
    required this.qrPayload,
  });

  final AppStore store;
  final Sale sale;
  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final width = MediaQuery.sizeOf(context).width;
    final compactLayout = width < 760;
    final stackedMeta = width < 620;
    final stackedFooter = width < 820;
    final stackedNoteContent = width < 560;
    final legalText = [
      if (s.rccm.trim().isNotEmpty) 'RCCM: ${s.rccm}',
      if (s.idNat.trim().isNotEmpty) 'ID NAT: ${s.idNat}',
      if (s.nif.trim().isNotEmpty) 'NIF: ${s.nif}',
      if (s.efo.trim().isNotEmpty) 'EFO: ${s.efo}',
    ].join('   ');

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFD6E5EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD6E5EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: CompanyLogoBadge(settings: s),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.companyName,
                              style: const TextStyle(
                                color: _greenDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (s.address.trim().isNotEmpty)
                              Text(
                                s.address,
                                style: const TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              s.phone,
                              style: const TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (s.email.trim().isNotEmpty)
                              Text(
                                s.email,
                                style: const TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (legalText.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                legalText,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  children: [
                    const Text(
                      'FACTURE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _greenDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sale.invoiceNo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _greenDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                stackedMeta
                    ? Column(
                        children: [
                          _DocumentInfoTile(
                            label: 'Ticket',
                            value: sale.ticketNo,
                            boldValue: false,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Commande',
                            value: sale.orderNo,
                            boldValue: false,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Date',
                            value: _formatDate(sale.createdAt),
                            boldValue: false,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Client',
                            value: sale.customer.name,
                            boldValue: true,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Caissier',
                            value: sale.cashierName,
                            boldValue: false,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Paiement',
                            value: sale.method,
                            boldValue: false,
                            alignRight: false,
                          ),
                          const SizedBox(height: 8),
                          _DocumentInfoTile(
                            label: 'Statut',
                            value: sale.status,
                            boldValue: true,
                            alignRight: false,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _DocumentInfoTile(
                                  label: 'Ticket',
                                  value: sale.ticketNo,
                                  boldValue: false,
                                  alignRight: false,
                                ),
                                const SizedBox(height: 8),
                                _DocumentInfoTile(
                                  label: 'Commande',
                                  value: sale.orderNo,
                                  boldValue: false,
                                  alignRight: false,
                                ),
                                const SizedBox(height: 8),
                                _DocumentInfoTile(
                                  label: 'Date',
                                  value: _formatDate(sale.createdAt),
                                  boldValue: false,
                                  alignRight: false,
                                ),
                                const SizedBox(height: 8),
                                _DocumentInfoTile(
                                  label: 'Client',
                                  value: sale.customer.name,
                                  boldValue: true,
                                  alignRight: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                _DocumentInfoTile(
                                  label: 'Caissier',
                                  value: sale.cashierName,
                                  boldValue: false,
                                  alignRight: true,
                                ),
                                const SizedBox(height: 8),
                                _DocumentInfoTile(
                                  label: 'Paiement',
                                  value: sale.method,
                                  boldValue: false,
                                  alignRight: true,
                                ),
                                const SizedBox(height: 8),
                                _DocumentInfoTile(
                                  label: 'Statut',
                                  value: sale.status,
                                  boldValue: true,
                                  alignRight: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FBFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD6E5EB)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F4F7),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                'No',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Désignation',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Qte',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PU',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Total',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...sale.lines.asMap().entries.map(
                        (entry) => _InvoiceTableRow(
                          index: entry.key + 1,
                          product: entry.value.product,
                          qty: entry.value.qty.toString(),
                          unitPrice: store.money(entry.value.price),
                          total: store.money(entry.value.qty * entry.value.price),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                stackedFooter
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InvoicePreviewNoteBox(
                            sale: sale,
                            qrPayload: qrPayload,
                            stackedContent: stackedNoteContent,
                            compactLayout: compactLayout,
                          ),
                          const SizedBox(height: 12),
                          _InvoiceTotalsCard(store: store, sale: sale),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _InvoicePreviewNoteBox(
                              sale: sale,
                              qrPayload: qrPayload,
                              stackedContent: false,
                              compactLayout: compactLayout,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 206,
                            child: _InvoiceTotalsCard(store: store, sale: sale),
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}

class InvoiceQrBadge extends StatelessWidget {
  const InvoiceQrBadge({super.key, required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 136,
            height: 136,
            child: CustomPaint(
              painter: _PseudoQrPainter(payload),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Verification',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payload,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 7.6,
              color: _muted,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoicePreviewNoteBox extends StatelessWidget {
  const _InvoicePreviewNoteBox({
    required this.sale,
    required this.qrPayload,
    required this.stackedContent,
    required this.compactLayout,
  });

  final Sale sale;
  final String qrPayload;
  final bool stackedContent;
  final bool compactLayout;

  @override
  Widget build(BuildContext context) {
    final qrColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InvoiceStamp(isCredit: sale.isCredit),
        const SizedBox(height: 10),
        InvoiceQrBadge(payload: qrPayload),
      ],
    );
    const noteText = Text(
      'Merci pour votre confiance. Toute réclamation se fait sur présentation de cette facture. Merci de vérifier les quantités et montants avant validation définitive.',
      style: TextStyle(
        color: _ink,
        height: 1.45,
        fontWeight: FontWeight.w700,
      ),
    );
    return Container(
      padding: EdgeInsets.all(compactLayout ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E5EB)),
      ),
      child: stackedContent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                qrColumn,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: noteText,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                qrColumn,
                const SizedBox(width: 12),
                const Expanded(child: noteText),
              ],
            ),
    );
  }
}

class _PseudoQrPainter extends CustomPainter {
  _PseudoQrPainter(this.payload);

  final String payload;

  @override
  void paint(Canvas canvas, Size size) {
    const cells = 17;
    final cell = size.width / cells;
    final bg = Paint()..color = Colors.white;
    final fg = Paint()..color = const Color(0xFF0A4C5D);
    canvas.drawRect(Offset.zero & size, bg);
    final bytes = utf8.encode(payload);
    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        final index = (x + y * cells) % bytes.length;
        final value = bytes[index] + x * 7 + y * 11;
        final filled = value % 3 == 0 || _finderCell(x, y, cells);
        if (!filled) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell - 0.6, cell - 0.6),
          fg,
        );
      }
    }
  }

  bool _finderCell(int x, int y, int cells) {
    bool inFinder(int startX, int startY) {
      final localX = x - startX;
      final localY = y - startY;
      if (localX < 0 || localY < 0 || localX > 4 || localY > 4) return false;
      final border = localX == 0 || localX == 4 || localY == 0 || localY == 4;
      final center = localX >= 1 && localX <= 3 && localY >= 1 && localY <= 3;
      return border || center;
    }

    return inFinder(0, 0) || inFinder(cells - 5, 0) || inFinder(0, cells - 5);
  }

  @override
  bool shouldRepaint(covariant _PseudoQrPainter oldDelegate) =>
      oldDelegate.payload != payload;
}

class _DocumentInfoGrid extends StatelessWidget {
  const _DocumentInfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width < 560 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: MediaQuery.sizeOf(context).width < 560 ? 1.95 : 2.4,
      children: children,
    );
  }
}

class _DocumentInfoTile extends StatelessWidget {
  const _DocumentInfoTile({
    required this.label,
    required this.value,
    this.boldValue = false,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool boldValue;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: _strongTextColor(context),
              fontWeight: boldValue ? FontWeight.w900 : FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceLineRow extends StatelessWidget {
  const _InvoiceLineRow({
    required this.label,
    required this.unit,
    required this.total,
  });

  final String label;
  final String unit;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _strongTextColor(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            unit,
            style: TextStyle(
              color: _mutedTextColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            total,
            style: TextStyle(
              color: _greenDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceTableRow extends StatelessWidget {
  const _InvoiceTableRow({
    required this.index,
    required this.product,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });

  final int index;
  final String product;
  final String qty;
  final String unitPrice;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2EDF1)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              product,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              qty,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              unitPrice,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              total,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _greenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceStatusBadge extends StatelessWidget {
  const _InvoiceStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final credit = _matchesSearchText(status, 'credit');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: credit ? const Color(0xFFFFF1EF) : const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: credit ? const Color(0xFFF3C9C2) : const Color(0xFFC6E8D2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: credit ? _danger : _greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: credit ? _danger : _greenDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalPill extends StatelessWidget {
  const _LegalPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E5EB)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: _ink, fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceTotalsCard extends StatelessWidget {
  const _InvoiceTotalsCard({
    required this.store,
    required this.sale,
  });

  final AppStore store;
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final taxableBase = (sale.subtotal - sale.discount).clamp(0, double.infinity);
    final taxAmount = (sale.total - taxableBase).clamp(0, double.infinity);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A4C5D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x334DFFFF)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Sous-total', value: store.money(sale.subtotal)),
          _SummaryRow(label: 'Remise', value: store.money(sale.discount)),
          _SummaryRow(label: 'Taxe', value: store.money(taxAmount)),
          _SummaryRow(label: 'Payé', value: store.money(sale.paid)),
          _SummaryRow(label: 'Reste', value: store.money(sale.due)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white30, height: 1),
          ),
          _SummaryRow(
            label: 'TOTAL',
            value: store.money(sale.total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _InvoiceStamp extends StatelessWidget {
  const _InvoiceStamp({required this.isCredit});

  final bool isCredit;

  @override
  Widget build(BuildContext context) {
    final color = isCredit ? const Color(0xFFC54040) : const Color(0xFF118556);
    final label = isCredit ? 'À PAYER' : 'PAYÉE CASH';
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        width: 176,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 3.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: highlight ? _greenDark : _ink,
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 16 : 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: emphasize ? 24 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            count,
            (index) => Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: index.isEven ? const Color(0xFF10251D) : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GridView.count(
      crossAxisCount: width < 560 ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: width < 560
          ? 3.8
          : width >= 1180
              ? 3.75
              : width >= 900
                  ? 3.35
                  : 2.7,
      children: children,
    );
  }
}

class _InsightStatsGrid extends StatelessWidget {
  const _InsightStatsGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width < 560 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: MediaQuery.sizeOf(context).width < 560 ? 1.32 : 1.65,
      children: children,
    );
  }
}

class _CashMetricsGrid extends StatelessWidget {
  const _CashMetricsGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: MediaQuery.sizeOf(context).width < 560 ? 2.65 : 2.9,
      children: children,
    );
  }
}

class AutoCategoryStrip extends StatefulWidget {
  const AutoCategoryStrip({super.key, required this.categories});
  final List<String> categories;

  @override
  State<AutoCategoryStrip> createState() => _AutoCategoryStripState();
}

class _AutoCategoryStripState extends State<AutoCategoryStrip> {
  Timer? _timer;
  int startIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.categories.length <= 3) return;
      setState(() {
        startIndex = (startIndex + 1) % widget.categories.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = List.generate(
      categories.length < 3 ? categories.length : 3,
      (index) => categories[(startIndex + index) % categories.length],
    );
    return SizedBox(
      height: 42,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.25, 0),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(position: offset, child: child);
          },
          child: Row(
            key: ValueKey(visible.join('|')),
            children: visible
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key == visible.length - 1 ? 0 : 8,
                      ),
                      child: _CategoryPill(
                        label: entry.value,
                        highlighted: entry.key == 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.highlighted,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlighted
              ? const [Color(0xFF1598AB), Color(0xFF0D6D82)]
              : const [Color(0xFF12899B), Color(0xFF0A6175)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: highlighted
            ? const [
                BoxShadow(
                  color: Color(0x22129B6A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (highlighted) ...[
            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _softAccentColor(context),
          child: Icon(icon, color: _green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: _strongTextColor(context),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: _mutedTextColor(context)),
              ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _AccessGuardPage extends StatelessWidget {
  const _AccessGuardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _PageHeader(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
        const SizedBox(height: 16),
        _EmptyStateTile(
          icon: Icons.lock_outline_rounded,
          title: 'Acces restreint',
          subtitle: subtitle,
        ),
      ],
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount = 0,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badgeCount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0x33D8F26E)
                : Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFFD8F26E)
                  : Colors.white.withOpacity(.42),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 31, height: 31),
            icon: Icon(icon, size: 15.5),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD83B36),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.1),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 8.6,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageSectionChip extends StatelessWidget {
  const _MessageSectionChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? _softAccentStrong(context) : _panelColor(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? _green : _panelBorderColor(context),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0x26073B48),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: selected ? _strongTextColor(context) : _mutedTextColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: selected ? _green : _softAccentColor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : _greenDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBrandSwitcher extends StatefulWidget {
  const _HeaderBrandSwitcher({required this.darkMode});

  final bool darkMode;

  @override
  State<_HeaderBrandSwitcher> createState() => _HeaderBrandSwitcherState();
}

class _HeaderBrandSwitcherState extends State<_HeaderBrandSwitcher> {
  late final Timer _timer;
  int phase = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => phase = (phase + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Padding(
          key: ValueKey(phase),
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            switch (phase) {
              0 => '(From DTech)',
              1 => '(DSquare)',
              _ => '(Technologies)',
            },
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: Colors.white.withAlpha(widget.darkMode ? 242 : 255),
              fontWeight: FontWeight.w700,
              fontSize: 10.2,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBadgeButton extends StatelessWidget {
  const _HeaderBadgeButton({
    required this.count,
    required this.onTap,
    this.selected = false,
  });

  final int count;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0x33D8F26E)
                  : Colors.white.withAlpha(24),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? const Color(0xFFD8F26E)
                    : Colors.white.withAlpha(42),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_rounded,
              size: 15.5,
              color: Colors.white,
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4D64E),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.1),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Color(0xFF5B4700),
                  fontWeight: FontWeight.w900,
                  fontSize: 8.6,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PageContextStrip extends StatelessWidget {
  const _PageContextStrip({
    required this.label,
    this.accountName,
  });

  final String label;
  final String? accountName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF10212A)
            : Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_checked_rounded,
            size: 12,
            color: _green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (accountName != null && accountName!.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x140C5D6D),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                accountName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _greenDark,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConnectivityStrip extends StatelessWidget {
  const _ConnectivityStrip({
    required this.isOnline,
    required this.pendingChanges,
  });

  final bool isOnline;
  final int pendingChanges;

  @override
  Widget build(BuildContext context) {
    final tone = isOnline ? _greenDark : _danger;
    final text = isOnline
        ? pendingChanges > 0
              ? '$pendingChanges modification(s) en attente de synchronisation.'
              : 'En ligne - synchronisation automatique active.'
        : 'Mode hors ligne - les données seront synchronisées des que la connexion reviendra.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isOnline
            ? _softAccentStrong(context)
            : _dangerSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            size: 18,
            color: tone,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _strongTextColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: _PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [
                      Color(0xFF0A4C5D),
                      Color(0xFF0F6F82),
                      Color(0xFF1490A2),
                    ]
                  : const [
                      Color(0xFF0B5A6C),
                      Color(0xFF0F6F82),
                      Color(0xFF17A2B7),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220F6F82),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: _mutedTextColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppField extends StatefulWidget {
  const _AppField({
    super.key,
    required this.label,
    required this.controller,
    this.number = false,
    this.obscure = false,
  });
  final String label;
  final TextEditingController controller;
  final bool number;
  final bool obscure;

  @override
  State<_AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<_AppField> {
  late bool _obscure;

  bool get _isSecretField {
    final normalized = widget.label.toLowerCase();
    return widget.obscure ||
        normalized.contains('pin') ||
        normalized.contains('code secret') ||
        normalized.contains('mot de passe') ||
        (normalized.contains('confirmer') && normalized.contains('code'));
  }

  @override
  void initState() {
    super.initState();
    _obscure = _isSecretField;
  }

  @override
  Widget build(BuildContext context) {
    final secret = _isSecretField;
    return TextField(
      controller: widget.controller,
      keyboardType:
          widget.number && !secret ? TextInputType.number : TextInputType.text,
      textInputAction: secret ? TextInputAction.done : TextInputAction.next,
      enableSuggestions: !secret,
      autocorrect: !secret,
      obscureText: secret ? _obscure : false,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: secret
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                tooltip: _obscure ? 'Afficher' : 'Masquer',
              )
            : null,
      ),
    );
  }
}

class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 520) {
      return Column(children: [left, const SizedBox(height: 10), right]);
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line, required this.money});
  final CartLine line;
  final String Function(num value) money;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        line.product.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${line.qty} x ${money(line.product.price)}'),
      trailing: Text(
        money(line.qty * line.product.price),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class LedgerTile extends StatelessWidget {
  const LedgerTile({
    super.key,
    required this.row,
    required this.money,
    this.onTap,
  });
  final LedgerRow row;
  final String Function(num value) money;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        row.amount >= 0
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        color: row.amount >= 0 ? _green : _danger,
      ),
      title: Text(
        row.kind,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${row.reference} - ${row.label}'),
      trailing: Text(
        money(row.amount),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({
    super.key,
    required this.sale,
    required this.money,
    required this.onTap,
  });
  final Sale sale;
  final String Function(num value) money;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final credit = sale.isCredit;
    return ListTile(
      leading: const Icon(Icons.description_rounded, color: _green),
      title: Text(
        sale.invoiceNo,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${sale.customer.name} - ${sale.ticketNo} - ${sale.cashierName}',
        style: TextStyle(color: _mutedTextColor(context)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            money(sale.total),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            credit ? 'Crédit' : 'Payée',
            style: TextStyle(
              color: credit ? _danger : _green,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class CreditSaleTile extends StatelessWidget {
  const CreditSaleTile({
    super.key,
    required this.sale,
    required this.money,
    required this.canSettle,
    required this.onTap,
    required this.onSettle,
    this.onWhatsApp,
  });

  final Sale sale;
  final String Function(num value) money;
  final bool canSettle;
  final VoidCallback onTap;
  final VoidCallback onSettle;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final dueSoon = sale.dueDate.isBefore(
      DateTime.now().add(const Duration(days: 2)),
    );
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: _softAccentColor(context),
                    child: Icon(
                      Icons.credit_score_rounded,
                      color: dueSoon ? _danger : _green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sale.invoiceNo} - échéance ${_formatDate(sale.dueDate)}',
                          style: TextStyle(
                            color: _mutedTextColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        money(sale.due),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: dueSoon ? _danger : _greenDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sale.method,
                        style: TextStyle(
                          color: _mutedTextColor(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _CreditMetaPill(
                    icon: Icons.receipt_long_rounded,
                    label: 'Client',
                    value: sale.customer.code,
                  ),
                  _CreditMetaPill(
                    icon: Icons.payments_rounded,
                    label: 'Total',
                    value: money(sale.total),
                  ),
                  _CreditMetaPill(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Reste',
                    value: money(sale.due),
                    tone: dueSoon ? _danger : _greenDark,
                  ),
                ],
              ),
              if (canSettle) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onWhatsApp != null) ...[
                      IconButton.filledTonal(
                        onPressed: onWhatsApp,
                        icon: const Icon(Icons.chat_rounded),
                        color: const Color(0xFF25D366),
                        tooltip: 'Rappeler sur WhatsApp',
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton.tonalIcon(
                      onPressed: onSettle,
                      icon: const Icon(Icons.paid_rounded),
                      label: const Text('Valider le paiement'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditMetaPill extends StatelessWidget {
  const _CreditMetaPill({
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final color = tone ?? _greenDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _softPanelColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _strongTextColor(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class PartyTile extends StatelessWidget {
  const PartyTile({
    super.key,
    required this.name,
    required this.code,
    required this.phone,
  });
  final String name;
  final String code;
  final String phone;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _softPanelColor(context),
        child: const Icon(Icons.person_rounded, color: _green),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(
        '$code - ${phone.isEmpty ? "Pas de telephone" : phone}',
        style: TextStyle(color: _mutedTextColor(context)),
      ),
    );
  }
}

class PurchaseTile extends StatelessWidget {
  const PurchaseTile({super.key, required this.purchase, required this.money});
  final Purchase purchase;
  final String Function(num value) money;
  @override
  Widget build(BuildContext context) {
    final due = purchase.due;
    return ListTile(
      leading: const Icon(Icons.move_to_inbox_rounded, color: _green),
      title: Text(
        purchase.reference,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${purchase.supplier} - ${purchase.product} x${purchase.quantity}',
        style: TextStyle(color: _mutedTextColor(context)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            money(purchase.total),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            due > 0 ? 'Reste ${money(due)}' : 'Solde',
            style: TextStyle(
              color: due > 0 ? _danger : _green,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsPanel extends StatelessWidget {
  const ReportsPanel({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) {
    final metrics = store.todayMetrics;
    final cashierView = store.activeUser.isCashier;
    return Column(
      children: [
        _ResponsiveGrid(
          children: [
            KpiTile(
              icon: Icons.sell_rounded,
              label: 'Ventes du jour',
              value: store.money(metrics.revenue),
            ),
            KpiTile(
              icon: cashierView
                  ? Icons.account_balance_wallet_rounded
                  : Icons.trending_up_rounded,
              label: cashierView ? 'Caisse' : 'Bénéfice',
              value: store.money(cashierView ? metrics.cash : metrics.profit),
            ),
            KpiTile(
              icon: cashierView
                  ? Icons.receipt_rounded
                  : Icons.warehouse_rounded,
              label: cashierView ? 'Dépenses' : 'Stock achat',
              value: store.money(cashierView ? metrics.expenses : store.stockValue),
            ),
            KpiTile(
              icon: Icons.credit_card_rounded,
              label: 'Crédits',
              value: store.money(store.customerDebt),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key, required this.settings});
  final CompanySettings settings;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Entreprise'),
          subtitle: Text(settings.companyName),
          leading: const Icon(Icons.store_rounded),
        ),
        ListTile(
          title: const Text('Contact'),
          subtitle: Text('${settings.phone} - ${settings.address}'),
          leading: const Icon(Icons.phone_rounded),
        ),
        ListTile(
          title: const Text('Legal'),
          subtitle: Text(
            'RCCM ${settings.rccm.isEmpty ? "-" : settings.rccm} - ID NAT ${settings.idNat.isEmpty ? "-" : settings.idNat}',
          ),
          leading: const Icon(Icons.badge_rounded),
        ),
        ListTile(
          title: const Text('Fiscal'),
          subtitle: Text(
            'NIF ${settings.nif.isEmpty ? "-" : settings.nif} - EFO ${settings.efo.isEmpty ? "-" : settings.efo}',
          ),
          leading: const Icon(Icons.account_balance_rounded),
        ),
      ],
    );
  }
}

TextStyle get _whiteLabel =>
    const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800);
TextStyle get _heroAmount => const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w900,
  fontSize: 46,
  height: 1,
);

String _formatDate(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

String _documentQrPayloadStatic(AppStore store, Sale sale, String kind) {
  final s = store.settings;
  final taxableBase = (sale.subtotal - sale.discount).clamp(0, double.infinity);
  final taxAmount = (sale.total - taxableBase).clamp(0, double.infinity);
  final lines = sale.lines
      .map(
        (line) =>
            '${line.product}#QTE=${line.qty}#PU=${line.price.round()}#PT=${(line.qty * line.price).round()}',
      )
      .join(';');
  return [
    'DOC=$kind',
    'ENT=${s.companyName}',
    'ADR=${s.address}',
    'TEL=${s.phone}',
    'MAIL=${s.email}',
    'RCCM=${s.rccm}',
    'IDNAT=${s.idNat}',
    'NIF=${s.nif}',
    'EFO=${s.efo}',
    'FAC=${sale.invoiceNo}',
    'TCK=${sale.ticketNo}',
    'CMD=${sale.orderNo}',
    'DATE=${sale.createdAt.toIso8601String()}',
    'CLI=${sale.customer.code}-${sale.customer.name}',
    'CAISSIER=${sale.cashierCode}-${sale.cashierName}',
    'PAY=${sale.method}',
    'STATUT=${sale.status}',
    'SOUS_TOTAL=${sale.subtotal.round()}',
    'REMISE=${sale.discount.round()}',
    'TAXE=${taxAmount.round()}',
    'TOTAL=${sale.total.round()}',
    'PAYE=${sale.paid.round()}',
    'RESTE=${sale.due.round()}',
    'LIGNES=$lines',
  ].join('|');
}

String _buildModernInvoiceHtml(AppStore store, Sale sale) {
  final s = store.settings;
  final qrPayload = _documentQrPayloadStatic(store, sale, 'FACTURE');
  final logo = _companyLogoHtml(s);
  final qrMarkup = _qrSvgMarkup(qrPayload, size: 224);
  final stampLabel = sale.isCredit
      ? 'À PAYER'
      : sale.method == 'Cash'
      ? 'PAYÉE CASH'
      : 'PAYÉE';
  final stampClass = sale.isCredit ? 'credit' : 'paid';
  final legal = [
    if (s.rccm.trim().isNotEmpty) 'RCCM: ${_escapeHtml(s.rccm)}',
    if (s.idNat.trim().isNotEmpty) 'ID NAT: ${_escapeHtml(s.idNat)}',
    if (s.nif.trim().isNotEmpty) 'NIF: ${_escapeHtml(s.nif)}',
    if (s.efo.trim().isNotEmpty) 'EFO: ${_escapeHtml(s.efo)}',
  ].join(' | ');
  final taxableBase = (sale.subtotal - sale.discount).clamp(0, double.infinity);
  final taxAmount = (sale.total - taxableBase).clamp(0, double.infinity);
  final lines = sale.lines
      .asMap()
      .entries
      .map(
        (entry) {
          final line = entry.value;
          return '''
          <tr>
            <td class="center">${entry.key + 1}</td>
            <td>${_escapeHtml(line.product)}</td>
            <td class="center">${line.qty}</td>
            <td class="right">${store.money(line.price)}</td>
            <td class="right">${store.money(line.qty * line.price)}</td>
          </tr>
        ''';
        },
      )
      .join();
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Facture ${_escapeHtml(sale.invoiceNo)}</title>
  <style>
    * { box-sizing:border-box; }
    html, body { margin:0; }
    body { font-family: "Segoe UI", Arial, sans-serif; background:#eaf2f5; padding:12px; color:#173038; }
    .page { position:relative; background:#fff; width:100%; max-width:980px; margin:0 auto; border-radius:24px; overflow:hidden; box-shadow:0 24px 60px rgba(10,76,93,.13); border:1px solid #d9e7eb; }
    .hero { padding:26px 28px 20px; background:linear-gradient(135deg,#f9fcfd 0%,#eef7fa 100%); border-bottom:1px solid #d6e5eb; }
    .hero-top { display:flex; justify-content:space-between; gap:20px; align-items:flex-start; }
    .brand { display:flex; gap:16px; align-items:flex-start; }
    .logo { width:84px; height:84px; border-radius:18px; background:#fff; border:1px solid #d6e5eb; display:flex; align-items:center; justify-content:center; overflow:hidden; box-shadow:0 8px 20px rgba(10,76,93,.06); }
    .logo img { width:100%; height:100%; object-fit:cover; }
    .company { font-size:30px; font-weight:900; color:#0A4C5D; line-height:1.05; margin-bottom:6px; }
    .muted { color:#37535c; font-weight:600; line-height:1.45; }
    .legal { color:#5d7179; font-size:11px; font-weight:700; line-height:1.45; margin-top:8px; }
    .doc-side { min-width:250px; max-width:290px; text-align:center; padding-top:4px; }
    .doc-title { font-size:38px; font-weight:900; color:#0A4C5D; letter-spacing:.5px; text-align:center; }
    .doc-no { font-size:17px; font-weight:800; margin-top:6px; color:#173038; }
    .status { display:inline-block; margin-top:10px; padding:10px 14px; border-radius:999px; font-weight:900; font-size:12px; background:${sale.isCredit ? '#FFF1EF' : '#EAF8EF'}; color:${sale.isCredit ? '#B44336' : '#0A4C5D'}; }
    .floating-stamp { min-width:220px; margin:0 auto 12px; padding:13px 24px; border:3.2px solid currentColor; border-radius:18px; font-weight:900; font-size:20px; letter-spacing:1px; text-align:center; transform:rotate(-12deg); background:transparent; box-shadow:0 8px 18px rgba(0,0,0,.08); display:inline-block; }
    .floating-stamp.paid { color:#118556; }
    .floating-stamp.credit { color:#C54040; }
    .hero-bottom { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-top:18px; }
    .panel { background:#fff; border:1px solid #d6e5eb; border-radius:18px; padding:16px; }
    .meta-grid { display:grid; grid-template-columns:1fr; gap:10px; }
    .meta { border:1px solid #dce9ed; border-radius:14px; padding:10px 12px; background:#fbfdfe; }
    .meta .k { color:#6a7c84; font-size:11px; font-weight:800; text-transform:uppercase; }
    .meta .v { color:#173038; font-size:14px; font-weight:900; margin-top:4px; line-height:1.3; }
    .meta.right { text-align:right; }
    .meta.customer .v { font-weight:900; }
    .content { padding:52px 28px 28px; }
    table { width:100%; border-collapse:separate; border-spacing:0; border:1px solid #d6e5eb; border-radius:18px; overflow:hidden; }
    thead th { background:#0A4C5D; color:#fff; padding:14px 12px; font-size:12px; text-transform:uppercase; letter-spacing:.35px; }
    tbody td { padding:13px 12px; border-top:1px solid #e3edf1; font-size:13px; color:#173038; }
    tbody tr:nth-child(even) td { background:#fbfdfe; }
    .center { text-align:center; }
    .right { text-align:right; }
    .bottom { display:grid; grid-template-columns:minmax(0,1fr) 326px; gap:18px; margin-top:18px; align-items:end; }
    .note-box { background:#f8fcfd; border:1px solid #d6e5eb; border-radius:18px; padding:16px; min-height:212px; display:flex; flex-direction:column; justify-content:space-between; }
    .note { color:#24414a; font-size:12px; line-height:1.65; font-weight:700; }
    .qr-wrap { margin-top:16px; display:flex; align-items:flex-end; gap:16px; }
    .qr-card { width:252px; padding:0; background:transparent; text-align:center; flex:0 0 auto; }
    .qr-card svg { width:246px; height:246px; display:block; margin:0 auto; }
    .qr-caption { margin-top:8px; font-size:10px; color:#5d7179; font-weight:800; line-height:1.35; word-break:break-word; }
    .totals { background:#0A4C5D; color:#fff; border-radius:24px; padding:20px 18px; box-shadow:0 14px 30px rgba(10,76,93,.16); border:1px solid rgba(255,255,255,.14); }
    .totals .line { display:flex; justify-content:space-between; gap:12px; margin:0; padding:11px 0; font-size:13px; }
    .totals .line strong { font-weight:900; }
    .totals .grand { border-top:1px solid rgba(255,255,255,.28); margin-top:12px; padding-top:16px; font-size:23px; font-weight:900; }
    .totals .grand span, .totals .grand strong { font-weight:900; }
    .footer { margin-top:18px; padding-top:12px; border-top:1px solid #e1ecef; display:flex; justify-content:space-between; gap:18px; font-size:11px; color:#687b82; font-weight:700; line-height:1.45; }
    @media (max-width: 820px) {
      body { padding:8px; }
      .page { border-radius:18px; }
      .hero { padding:18px 16px 14px; }
      .hero-top, .hero-bottom, .bottom, .footer { display:block; }
      .doc-side { min-width:0; max-width:none; text-align:center; margin-top:14px; }
      .doc-title { font-size:30px; }
      .company { font-size:24px; }
      .panel { margin-top:12px; }
      .content { padding:16px; }
      .floating-stamp { min-width:170px; padding:10px 18px; font-size:15px; }
      .qr-wrap { display:block; }
      .qr-card { width:100%; margin-bottom:12px; }
      .qr-card svg { width:210px; height:210px; }
      .totals { margin-top:14px; }
      thead th, tbody td { padding:10px 8px; font-size:12px; }
    }
  </style>
</head>
<body>
  <div class="page">
    <div class="hero">
      <div class="hero-top">
        <div class="brand">
          <div class="logo">$logo</div>
          <div>
            <div class="company">${_escapeHtml(s.companyName)}</div>
            <div class="muted">${_escapeHtml(s.address)}</div>
            <div class="muted">${_escapeHtml(s.phone)}${s.email.trim().isEmpty ? '' : ' | ${_escapeHtml(s.email)}'}</div>
            ${legal.isEmpty ? '' : '<div class="legal">${_escapeHtml(legal)}</div>'}
          </div>
        </div>
        <div class="doc-side">
          <div class="doc-title">FACTURE</div>
          <div class="doc-no">${_escapeHtml(sale.invoiceNo)}</div>
          <div class="status">${_escapeHtml(sale.status)}</div>
        </div>
      </div>

      <div class="hero-bottom">
        <div class="panel">
          <div class="meta-grid">
            <div class="meta"><div class="k">Ticket</div><div class="v">${_escapeHtml(sale.ticketNo)}</div></div>
            <div class="meta"><div class="k">Commande</div><div class="v">${_escapeHtml(sale.orderNo)}</div></div>
            <div class="meta"><div class="k">Date</div><div class="v">${_escapeHtml(_formatDate(sale.createdAt))}</div></div>
            <div class="meta customer"><div class="k">Client</div><div class="v">${_escapeHtml(sale.customer.name)}</div></div>
          </div>
        </div>
        <div class="panel">
          <div class="meta-grid">
            <div class="meta right"><div class="k">Caissier</div><div class="v">${_escapeHtml(sale.cashierName)}</div></div>
            <div class="meta right"><div class="k">Paiement</div><div class="v">${_escapeHtml(sale.method)}</div></div>
            <div class="meta right"><div class="k">Statut</div><div class="v">${_escapeHtml(sale.status)}</div></div>
            <div class="meta right"><div class="k">Devise</div><div class="v">${_escapeHtml(s.currency)}</div></div>
          </div>
        </div>
      </div>
    </div>

    <div class="content">
      <table>
        <thead>
          <tr>
            <th class="center" style="width:60px;">No</th>
            <th style="text-align:left">Désignation</th>
            <th class="center" style="width:90px;">Quantité</th>
            <th class="right" style="width:140px;">Prix unitaire</th>
            <th class="right" style="width:150px;">Prix total</th>
          </tr>
        </thead>
        <tbody>
          $lines
        </tbody>
      </table>

      <div class="bottom">
        <div class="note-box">
          <div class="qr-wrap">
            <div class="qr-card">
              <div class="floating-stamp $stampClass">$stampLabel</div>
              $qrMarkup
              <div class="qr-caption">${_escapeHtml(qrPayload)}</div>
            </div>
            <div class="note">
              Merci pour votre confiance. Toute réclamation se fait sur présentation de cette facture. Merci de vérifier les quantités et montants avant validation définitive.
            </div>
          </div>
        </div>

        <div class="totals">
          <div class="line"><span>Sous-total</span><strong>${store.money(sale.subtotal)}</strong></div>
          <div class="line"><span>Remise</span><strong>${store.money(sale.discount)}</strong></div>
          <div class="line"><span>Taxe${s.taxRate > 0 ? ' (${s.taxRate}%)' : ''}</span><strong>${store.money(taxAmount)}</strong></div>
          <div class="line"><span>Payé</span><strong>${store.money(sale.paid)}</strong></div>
          <div class="line"><span>Reste</span><strong>${store.money(sale.due)}</strong></div>
          <div class="line grand"><span>Total</span><strong>${store.money(sale.total)}</strong></div>
        </div>
      </div>

      <div class="footer">
        <div>Document commercial émis par ${_escapeHtml(s.companyName)}.</div>
        <div>${_escapeHtml(s.address)}${s.phone.trim().isEmpty ? '' : ' | ${_escapeHtml(s.phone)}'}</div>
      </div>
    </div>
  </div>
</body>
</html>
''';
}

String _buildThermalTicketHtml(AppStore store, Sale sale) {
  final s = store.settings;
  final legal = [
    if (s.rccm.trim().isNotEmpty) 'RCCM: ${_escapeHtml(s.rccm)}',
    if (s.idNat.trim().isNotEmpty) 'ID NAT: ${_escapeHtml(s.idNat)}',
    if (s.nif.trim().isNotEmpty) 'NIF: ${_escapeHtml(s.nif)}',
    if (s.efo.trim().isNotEmpty) 'EFO: ${_escapeHtml(s.efo)}',
  ].join(' | ');
  final lines = sale.lines
      .map(
        (line) =>
            '<div class="line"><span>${_escapeHtml(line.product)} x${line.qty}</span><strong>${store.money(line.qty * line.price)}</strong></div>',
      )
      .join();
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Ticket ${_escapeHtml(sale.ticketNo)}</title>
  <style>
    body { font-family: Consolas, "Courier New", monospace; background:#f5f5f5; padding:18px; }
    .ticket { width:320px; margin:0 auto; background:white; color:#10251D; border-radius:18px; padding:20px; box-shadow:0 14px 30px rgba(0,0,0,.08); }
    .center { text-align:center; }
    .muted { color:#61746B; font-size:12px; }
    .rule { border-top:1px dashed #8da7af; margin:12px 0; }
    .line { display:flex; justify-content:space-between; gap:10px; margin:6px 0; font-size:12px; }
    .strong { font-weight:900; }
  </style>
</head>
<body>
  <div class="ticket">
    <div class="center strong" style="font-size:18px;">${_escapeHtml(s.companyName)}</div>
    <div class="center muted">${_escapeHtml(s.phone)}</div>
    ${s.email.trim().isEmpty ? '' : '<div class="center muted">${_escapeHtml(s.email)}</div>'}
    <div class="center muted">${_escapeHtml(s.address)}</div>
    ${legal.isEmpty ? '' : '<div class="center muted" style="font-size:11px;line-height:1.35;">$legal</div>'}
    <div class="rule"></div>
    <div class="center strong">TICKET DE CAISSE</div>
    <div class="line"><span>Ticket</span><strong>${_escapeHtml(sale.ticketNo)}</strong></div>
    <div class="line"><span>Facture</span><strong>${_escapeHtml(sale.invoiceNo)}</strong></div>
    <div class="line"><span>Date</span><strong>${_escapeHtml(_formatDate(sale.createdAt))}</strong></div>
    <div class="line"><span>Client</span><strong>${_escapeHtml(sale.customer.name)}</strong></div>
    <div class="line"><span>Caissier</span><strong>${_escapeHtml(sale.cashierName)}</strong></div>
    <div class="line"><span>Paiement</span><strong>${_escapeHtml(sale.method)}</strong></div>
    <div class="rule"></div>
    $lines
    <div class="rule"></div>
    <div class="line"><span>Sous-total</span><strong>${store.money(sale.subtotal)}</strong></div>
    <div class="line"><span>Remise</span><strong>${store.money(sale.discount)}</strong></div>
    <div class="line strong"><span>Total</span><strong>${store.money(sale.total)}</strong></div>
    <div class="line"><span>Payé</span><strong>${store.money(sale.paid)}</strong></div>
    <div class="line"><span>Reste</span><strong>${store.money(sale.due)}</strong></div>
    <div class="rule"></div>
    <div class="center strong">Merci pour votre achat</div>
  </div>
</body>
</html>
''';
}

Uint8List _buildThermalTicketPdfBytes(AppStore store, Sale sale) {
  final s = store.settings;
  final legal = [
    if (s.rccm.trim().isNotEmpty) 'RCCM: ${s.rccm}',
    if (s.idNat.trim().isNotEmpty) 'ID NAT: ${s.idNat}',
    if (s.nif.trim().isNotEmpty) 'NIF: ${s.nif}',
    if (s.efo.trim().isNotEmpty) 'EFO: ${s.efo}',
  ].join(' | ');
  final content = StringBuffer();

  void text(num x, num y, String value, {num size = 10}) {
    content.writeln(
      'BT /F1 $size Tf 1 0 0 1 $x $y Tm ${_pdfTextLiteral(value)} Tj ET',
    );
  }

  void line(num y) {
    content.writeln('0.60 0.68 0.71 RG 0.8 w 24 $y m 296 $y l S');
  }

  text(88, 790, s.companyName, size: 16);
  text(42, 772, s.phone, size: 9);
  if (s.email.trim().isNotEmpty) {
    text(42, 758, s.email, size: 9);
  }
  if (s.address.trim().isNotEmpty) {
    text(42, 744, s.address, size: 9);
  }
  if (legal.isNotEmpty) {
    text(30, 730, legal, size: 7);
  }
  line(718);
  text(98, 700, 'TICKET DE CAISSE', size: 13);
  text(30, 682, 'Ticket', size: 9);
  text(190, 682, sale.ticketNo, size: 9);
  text(30, 668, 'Facture', size: 9);
  text(190, 668, sale.invoiceNo, size: 9);
  text(30, 654, 'Date', size: 9);
  text(190, 654, _formatDate(sale.createdAt), size: 9);
  text(30, 640, 'Client', size: 9);
  text(190, 640, sale.customer.name, size: 9);
  text(30, 626, 'Caissier', size: 9);
  text(190, 626, sale.cashierName, size: 9);
  text(30, 612, 'Paiement', size: 9);
  text(190, 612, sale.method, size: 9);
  line(598);

  var y = 580;
  for (final lineItem in sale.lines.take(18)) {
    text(30, y, '${lineItem.product} x${lineItem.qty}', size: 8);
    text(212, y, store.money(lineItem.qty * lineItem.price), size: 8);
    y -= 12;
  }

  line(y - 2);
  y -= 18;
  text(30, y, 'Sous-total', size: 9);
  text(212, y, store.money(sale.subtotal), size: 9);
  y -= 14;
  text(30, y, 'Remise', size: 9);
  text(212, y, store.money(sale.discount), size: 9);
  y -= 16;
  text(30, y, 'TOTAL', size: 12);
  text(198, y, store.money(sale.total), size: 12);
  y -= 14;
  text(30, y, 'Paye', size: 9);
  text(212, y, store.money(sale.paid), size: 9);
  y -= 14;
  text(30, y, 'Reste', size: 9);
  text(212, y, store.money(sale.due), size: 9);
  y -= 18;
  line(y + 6);
  text(84, y - 10, 'Merci pour votre achat', size: 10);

  final stream = content.toString();
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 320 842] /Contents 5 0 R /Resources << /Font << /F1 4 0 R >> >> >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
    '<< /Length ${utf8.encode(stream).length} >>\nstream\n$stream\nendstream',
  ];
  return _buildPdfFromObjects(objects);
}

String _companyLogoHtml(CompanySettings settings) {
  final source = settings.logoUrl.trim();
  if (source.isNotEmpty) {
    return '<img src="${_escapeHtml(source)}" alt="logo" />';
  }
  final initial = settings.companyName.trim().isEmpty
      ? 'K'
      : _escapeHtml(settings.companyName.trim().substring(0, 1).toUpperCase());
  return '<div style="font-size:30px;font-weight:900;color:#0A4C5D;">$initial</div>';
}

String _qrSvgMarkup(String payload, {int size = 140}) {
  final cells = _qrCells(payload);
  const grid = 17;
  final cell = size / grid;
  final rects = cells
      .map(
        (point) =>
            '<rect x="${(point.$1 * cell).toStringAsFixed(2)}" y="${(point.$2 * cell).toStringAsFixed(2)}" width="${(cell - 0.4).toStringAsFixed(2)}" height="${(cell - 0.4).toStringAsFixed(2)}" fill="#0A4C5D" />',
      )
      .join();
  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size" role="img" aria-label="QR facture">
  <rect width="$size" height="$size" rx="10" fill="#FFFFFF"/>
  $rects
</svg>
''';
}

Future<Uint8List> _buildModernInvoicePdfBytes(AppStore store, Sale sale) async {
  final s = store.settings;
  final qrPayload = _documentQrPayloadStatic(store, sale, 'FACTURE');
  final taxableBase = (sale.subtotal - sale.discount).clamp(0, double.infinity);
  final taxAmount = (sale.total - taxableBase).clamp(0, double.infinity);
  final stampLabel = sale.isCredit
      ? 'À PAYER'
      : sale.method == 'Cash'
      ? 'PAYÉE CASH'
      : 'PAYÉE';
  final stampColor = sale.isCredit ? '0.77 0.25 0.25' : '0.07 0.52 0.34';
  final qrCells = _qrCells(qrPayload);
  const qrGrid = 17;
  const qrCell = 8.2;
  final content = StringBuffer();
  final logoImage = await _loadPdfLogoImage(s.logoUrl);
  final headerTextX = logoImage == null ? 52 : 122;

  void text(
    num x,
    num y,
    String value, {
    num size = 12,
    String color = '0 0 0',
  }) {
    content.writeln('$color rg');
    content.writeln(
      'BT /F1 $size Tf 1 0 0 1 $x $y Tm ${_pdfTextLiteral(value)} Tj ET',
    );
  }

  void rect(num x, num y, num w, num h, {String color = '0.95 0.98 0.99'}) {
    content.writeln('$color rg $x $y $w $h re f');
  }

  void roundedRectPath(num x, num y, num w, num h, num r) {
    const k = 0.5522847498;
    final c = r * k;
    content.writeln('${x + r} $y m');
    content.writeln('${x + w - r} $y l');
    content.writeln('${x + w - r + c} $y ${x + w} ${y + r - c} ${x + w} ${y + r} c');
    content.writeln('${x + w} ${y + h - r} l');
    content.writeln('${x + w} ${y + h - r + c} ${x + w - r + c} ${y + h} ${x + w - r} ${y + h} c');
    content.writeln('${x + r} ${y + h} l');
    content.writeln('${x + r - c} ${y + h} $x ${y + h - r + c} $x ${y + h - r} c');
    content.writeln('$x ${y + r} l');
    content.writeln('$x ${y + r - c} ${x + r - c} $y ${x + r} $y c');
    content.writeln('h');
  }

  void fillRoundedRect(
    num x,
    num y,
    num w,
    num h,
    num r, {
    String color = '0.95 0.98 0.99',
  }) {
    content.writeln('$color rg');
    roundedRectPath(x, y, w, h, r);
    content.writeln('f');
  }

  void strokeRoundedRect(
    num x,
    num y,
    num w,
    num h,
    num r, {
    String color = '0 0 0',
    num width = 1,
  }) {
    content.writeln('$color RG');
    content.writeln('$width w');
    roundedRectPath(x, y, w, h, r);
    content.writeln('S');
  }

  void rotatedStamp(
    num x,
    num y,
    String value, {
    required String stroke,
  }) {
    final angle = -14 * math.pi / 180;
    final cosA = math.cos(angle).toStringAsFixed(4);
    final sinA = math.sin(angle).toStringAsFixed(4);
    content.writeln('q');
    content.writeln('$cosA $sinA ${(-math.sin(angle)).toStringAsFixed(4)} $cosA $x $y cm');
    content.writeln('$stroke RG');
    strokeRoundedRect(0, 0, 176, 46, 14, color: stroke, width: 3.2);
    text(24, 16, value, size: 16, color: stroke);
    content.writeln('Q');
  }

  rect(36, 720, 523, 86, color: '0.97 0.98 0.99');
  content.writeln('0.84 0.90 0.92 RG 36 720 523 86 re S');
  if (logoImage != null) {
    content.writeln('0.84 0.90 0.92 RG 52 732 56 56 re S');
    _drawPdfImage(content, logoImage, x: 53, y: 733, width: 54, height: 54);
  }
  text(headerTextX, 782, s.companyName, size: 20, color: '0.04 0.30 0.36');
  if (s.address.trim().isNotEmpty) text(headerTextX, 764, s.address, size: 10);
  text(headerTextX, 750, s.phone + (s.email.trim().isEmpty ? '' : ' | ${s.email}'), size: 10);
  final legal = [
    if (s.rccm.trim().isNotEmpty) 'RCCM: ${s.rccm}',
    if (s.idNat.trim().isNotEmpty) 'ID NAT: ${s.idNat}',
    if (s.nif.trim().isNotEmpty) 'NIF: ${s.nif}',
    if (s.efo.trim().isNotEmpty) 'EFO: ${s.efo}',
  ].join('   ');
  if (legal.isNotEmpty) text(headerTextX, 736, legal, size: 9);

  text(36, 694, 'FACTURE', size: 22, color: '0.04 0.30 0.36');
  text(430, 694, sale.invoiceNo, size: 15, color: '0.04 0.30 0.36');
  rotatedStamp(42, 194, stampLabel, stroke: stampColor);

  final infoLines = [
    'Ticket: ${sale.ticketNo}',
    'Commande: ${sale.orderNo}',
    'Date: ${_formatDate(sale.createdAt)}',
    'Client: ${sale.customer.name}',
    'Caissier: ${sale.cashierName}',
    'Paiement: ${sale.method}',
    'Statut: ${sale.status}',
  ];
  var infoY = 668;
  for (final line in infoLines) {
    text(36, infoY, line, size: 10);
    infoY -= 14;
  }

  rect(36, 560, 523, 22, color: '0.91 0.96 0.97');
  text(44, 567, 'No', size: 10, color: '0.04 0.30 0.36');
  text(72, 567, 'Désignation', size: 10, color: '0.04 0.30 0.36');
  text(292, 567, 'Qté', size: 10, color: '0.04 0.30 0.36');
  text(360, 567, 'PU', size: 10, color: '0.04 0.30 0.36');
  text(470, 567, 'Total', size: 10, color: '0.04 0.30 0.36');

  var rowY = 540;
  for (var i = 0; i < sale.lines.take(12).length; i++) {
    final line = sale.lines[i];
    content.writeln('0.89 0.93 0.95 RG 36 ${rowY - 6} 523 24 re S');
    text(44, rowY, '${i + 1}', size: 9);
    text(72, rowY, line.product, size: 10);
    text(292, rowY, '${line.qty}', size: 10);
    text(360, rowY, store.money(line.price), size: 10);
    text(470, rowY, store.money(line.qty * line.price), size: 10);
    rowY -= 26;
  }

  fillRoundedRect(356, rowY - 116, 203, 128, 18, color: '0.04 0.30 0.36');
  strokeRoundedRect(356, rowY - 116, 203, 128, 18, color: '0.16 0.46 0.54', width: 0.8);
  text(372, rowY - 18, 'Sous-total', size: 10, color: '1 1 1');
  text(478, rowY - 18, store.money(sale.subtotal), size: 10, color: '1 1 1');
  text(372, rowY - 36, 'Remise', size: 10, color: '1 1 1');
  text(478, rowY - 36, store.money(sale.discount), size: 10, color: '1 1 1');
  text(372, rowY - 54, 'Taxe', size: 10, color: '1 1 1');
  text(478, rowY - 54, store.money(taxAmount), size: 10, color: '1 1 1');
  text(372, rowY - 72, 'Payé', size: 10, color: '1 1 1');
  text(478, rowY - 72, store.money(sale.paid), size: 10, color: '1 1 1');
  text(372, rowY - 90, 'Reste', size: 10, color: '1 1 1');
  text(478, rowY - 90, store.money(sale.due), size: 10, color: '1 1 1');
  content.writeln('1 1 1 RG 1 w 372 ${rowY - 98} m 542 ${rowY - 98} l S');
  text(372, rowY - 116, 'TOTAL', size: 15, color: '1 1 1');
  text(462, rowY - 116, store.money(sale.total), size: 15, color: '1 1 1');

  for (final point in qrCells) {
    final px = 48 + point.$1 * qrCell;
    final py = 38 + (qrGrid - 1 - point.$2) * qrCell;
    content.writeln('0.04 0.30 0.36 rg $px $py ${qrCell - 0.25} ${qrCell - 0.25} re f');
  }
  text(236, 178, 'Merci pour votre confiance.', size: 10, color: '0.10 0.19 0.22');
  text(236, 162, 'Toute réclamation se fait sur présentation de cette facture.', size: 9, color: '0.10 0.19 0.22');
  text(236, 146, '${s.companyName} - ${s.address}', size: 9, color: '0.10 0.19 0.22');
  text(236, 130, qrPayload.length > 82 ? qrPayload.substring(0, 82) : qrPayload, size: 7, color: '0.39 0.47 0.50');

  final stream = content.toString();
  final imageObject = logoImage == null ? null : _pdfImageObject(logoImage);
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [${imageObject == null ? '4 0 R' : '5 0 R'}] /Count 1 >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
    if (imageObject != null) imageObject,
    if (imageObject != null)
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 6 0 R /Resources << /Font << /F1 3 0 R >> /XObject << /ImLogo 4 0 R >> >> >>'
    else
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 5 0 R /Resources << /Font << /F1 3 0 R >> >> >>',
    '<< /Length ${latin1.encode(stream).length} >>\nstream\n$stream\nendstream',
  ];
  return _buildPdfFromObjects(objects);
}

List<(int, int)> _qrCells(String payload) {
  const cells = 17;
  final bytes = utf8.encode(payload);
  final result = <(int, int)>[];
  for (var y = 0; y < cells; y++) {
    for (var x = 0; x < cells; x++) {
      final index = (x + y * cells) % bytes.length;
      final value = bytes[index] + x * 7 + y * 11;
      final filled =
          value % 3 == 0 || _finderCellStatic(x, y, cells);
      if (filled) result.add((x, y));
    }
  }
  return result;
}

bool _finderCellStatic(int x, int y, int cells) {
  bool inFinder(int startX, int startY) {
    final localX = x - startX;
    final localY = y - startY;
    if (localX < 0 || localY < 0 || localX > 4 || localY > 4) return false;
    final border = localX == 0 || localX == 4 || localY == 0 || localY == 4;
    final center = localX >= 1 && localX <= 3 && localY >= 1 && localY <= 3;
    return border || center;
  }

  return inFinder(0, 0) || inFinder(cells - 5, 0) || inFinder(0, cells - 5);
}

Uint8List _buildLedgerPdfBytes(
  List<LedgerRow> rows,
  String Function(num value) money, {
  required String typeFilter,
  required String dateFilter,
  required String productFilter,
  required String clientFilter,
}) {
  String clip(String value, int max) =>
      value.length <= max ? value : '${value.substring(0, max - 1)}…';

  final orderedForBalance = rows.reversed.toList();
  num runningBalance = 0;
  final balanceByKey = <String, num>{};
  for (final row in orderedForBalance) {
    runningBalance += row.amount;
    balanceByKey['${row.kind}-${row.reference}-${row.createdAt.microsecondsSinceEpoch}'] =
        runningBalance;
  }

  final filters = [
    'Type: ${typeFilter == 'Tout' ? 'Tous' : typeFilter}',
    'Date: ${dateFilter.trim().isEmpty ? 'Toutes' : dateFilter.trim()}',
    'Produit: ${productFilter.trim().isEmpty ? 'Tous' : productFilter.trim()}',
    'Client: ${clientFilter.trim().isEmpty ? 'Tous' : clientFilter.trim()}',
  ].join('   |   ');

  final chunks = <List<LedgerRow>>[];
  for (var i = 0; i < rows.length; i += 12) {
    chunks.add(rows.skip(i).take(12).toList());
  }
  if (chunks.isEmpty) {
    chunks.add(const <LedgerRow>[]);
  }

  final pageObjects = <String>[];
  final contentObjects = <String>[];

  for (var pageIndex = 0; pageIndex < chunks.length; pageIndex++) {
    final chunk = chunks[pageIndex];
    final content = StringBuffer();

    void text(num x, num y, String value, {num size = 10, String color = '0 0 0'}) {
      content.writeln('$color rg');
      content.writeln(
        'BT /F1 $size Tf 1 0 0 1 $x $y Tm ${_pdfTextLiteral(value)} Tj ET',
      );
    }

    void rect(num x, num y, num w, num h, {String fill = '1 1 1'}) {
      content.writeln('$fill rg $x $y $w $h re f');
    }

    rect(28, 540, 786, 28, fill: '1 1 1');
    text(40, 548, 'GRAND LIVRE SIMPLIFIÉ', size: 16, color: '0 0 0');
    text(575, 548, 'Page ${pageIndex + 1}/${chunks.length}', size: 10, color: '0.45 0.45 0.45');
    text(40, 530, filters, size: 8, color: '0.45 0.45 0.45');
    text(40, 516, 'Export du ${_formatDate(DateTime.now())}', size: 8, color: '0.45 0.45 0.45');

    rect(28, 484, 786, 24, fill: '1 1 1');
    text(36, 491, 'Date', size: 9, color: '0 0 0');
    text(96, 491, 'Type', size: 9, color: '0 0 0');
    text(160, 491, 'Référence', size: 9, color: '0 0 0');
    text(270, 491, 'Produits', size: 9, color: '0 0 0');
    text(470, 491, 'Client', size: 9, color: '0 0 0');
    text(610, 491, 'Entrée', size: 9, color: '0 0 0');
    text(680, 491, 'Sortie', size: 9, color: '0 0 0');
    text(748, 491, 'Solde', size: 9, color: '0 0 0');

    var rowY = 464;
    for (final row in chunk) {
      final key =
          '${row.kind}-${row.reference}-${row.createdAt.microsecondsSinceEpoch}';
      final balance = balanceByKey[key] ?? 0;
      content.writeln('0.76 0.76 0.76 RG 28 ${rowY - 8} 786 24 re S');
      text(36, rowY, clip(_formatDate(row.createdAt), 11), size: 8);
      text(96, rowY, clip(row.kind, 10), size: 8);
      text(160, rowY, clip(row.reference, 18), size: 8);
      text(270, rowY, clip(row.label, 34), size: 8);
      text(470, rowY, clip(row.party, 20), size: 8);
      text(610, rowY, row.amount > 0 ? money(row.amount) : '-', size: 8);
      text(680, rowY, row.amount < 0 ? money(row.amount.abs()) : '-', size: 8);
      text(748, rowY, money(balance), size: 8);
      rowY -= 28;
    }

    if (chunk.isEmpty) {
      text(40, 448, 'Aucune écriture ne correspond aux filtres sélectionnés.', size: 10);
    }

    rect(28, 24, 786, 28, fill: '1 1 1');
    text(
      40,
      34,
      'Document comptable simplifié - clients et produits filtrés selon la vue active.',
      size: 8,
      color: '0.45 0.45 0.45',
    );

    contentObjects.add(
      '<< /Length ${utf8.encode(content.toString()).length} >>\nstream\n$content\nendstream',
    );
    pageObjects.add(
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Contents ${5 + pageIndex * 2} 0 R /Resources << /Font << /F1 3 0 R >> >> >>',
    );
  }

  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [${List.generate(chunks.length, (i) => '${4 + i * 2} 0 R').join(' ')}] /Count ${chunks.length} >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
  ];

  for (var i = 0; i < pageObjects.length; i++) {
    objects.add(pageObjects[i]);
    objects.add(contentObjects[i]);
  }

  return _buildPdfFromObjects(objects);
}

Uint8List _simplePdfFromLines(List<String> lines) {
  final buffer = StringBuffer();
  buffer.writeln('BT');
  buffer.writeln('/F1 12 Tf');
  var y = 800;
  for (final line in lines) {
    buffer.writeln('1 0 0 1 48 $y Tm ${_pdfTextLiteral(line)} Tj');
    y -= 18;
    if (y < 60) break;
  }
  buffer.writeln('ET');
  final content = buffer.toString();
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 5 0 R /Resources << /Font << /F1 4 0 R >> >> >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
    '<< /Length ${utf8.encode(content).length} >>\nstream\n$content\nendstream',
  ];
  return _buildPdfFromObjects(objects);
}

num _num(String value) => num.tryParse(value.replaceAll(',', '.')) ?? 0;

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}










