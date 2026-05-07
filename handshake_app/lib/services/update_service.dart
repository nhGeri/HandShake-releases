import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateInfo {
  final String version;
  final String name;
  final String description;
  final String downloadUrl;
  final int sizeInBytes;
  final DateTime publishedAt;
  final bool isNewerThanCurrent;

  UpdateInfo({
    required this.version,
    required this.name,
    required this.description,
    required this.downloadUrl,
    required this.sizeInBytes,
    required this.publishedAt,
    required this.isNewerThanCurrent,
  });

  String get sizeFormatted {
    final mb = sizeInBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class UpdateService {
  // ⚠️ ITT CSERÉLD KI A SAJÁT REPO-RA!
  static const String repoOwner = 'nhGeri';
  static const String repoName = 'HandShake-releases';

  static const String _apiUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  /// Lekérdezi a GitHub-ról a legújabb verziót
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode != 200) {
        print('❌ Update check failed: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body);
      final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
      final name = data['name'] ?? 'Új verzió';
      final description = data['body'] ?? '';
      final publishedAt = DateTime.parse(data['published_at']);

      // APK asset megkeresése
      final assets = data['assets'] as List;
      Map<String, dynamic>? apkAsset;
      for (final asset in assets) {
        if ((asset['name'] as String).endsWith('.apk')) {
          apkAsset = asset;
          break;
        }
      }

      if (apkAsset == null) {
        print('❌ No APK found in latest release');
        return null;
      }

      // Jelenlegi verzió lekérdezése
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      print('📌 Current version: $currentVersion');
      print('📌 Latest version: $latestVersion');

      final isNewer = _isVersionNewer(latestVersion, currentVersion);

      return UpdateInfo(
        version: latestVersion,
        name: name,
        description: description,
        downloadUrl: apkAsset['browser_download_url'],
        sizeInBytes: apkAsset['size'] ?? 0,
        publishedAt: publishedAt,
        isNewerThanCurrent: isNewer,
      );
    } catch (e) {
      print('❌ Error checking for update: $e');
      return null;
    }
  }

  /// Letölti az APK-t és telepíti
  static Future<bool> downloadAndInstall(
    UpdateInfo update, {
    Function(double progress)? onProgress,
  }) async {
    try {
      // Engedély kérése (Android 13+)
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          print('❌ Install permission denied');
          return false;
        }
      }

      // Letöltés
      final request = http.Request('GET', Uri.parse(update.downloadUrl));
      final streamedResponse = await request.send();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/handshake_update.apk');
      final sink = file.openWrite();

      int received = 0;
      final total = streamedResponse.contentLength ?? 0;

      await streamedResponse.stream.forEach((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      });

      await sink.close();

      // Telepítő megnyitása
      print('✅ Download complete: ${file.path}');
      final result = await OpenFilex.open(file.path);
      print('📲 Open result: ${result.message}');

      return true;
    } catch (e) {
      print('❌ Error downloading update: $e');
      return false;
    }
  }

  /// Verzió összehasonlítás (1.2.0 > 1.1.5)
  static bool _isVersionNewer(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Jelenlegi verzió lekérdezése
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0';
    }
  }
}
