import 'dart:io';

import 'package:agora_token_generator/agora_token_generator.dart';
import 'package:dotenv/dotenv.dart';

class AgoraTokenService {
  AgoraTokenService({DotEnv? env}) : _env = env ?? _loadEnv();

  static const int defaultTokenExpireSeconds = 3600;

  final DotEnv _env;

  String get appId => _read('AGORA_APP_ID');

  String buildRtcToken({
    required String channelName,
    required int uid,
    int expireSeconds = defaultTokenExpireSeconds,
  }) {
    final appCertificate = _read('AGORA_APP_CERTIFICATE');

    return RtcTokenBuilder.buildTokenWithUid(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
      tokenExpireSeconds: expireSeconds,
    );
  }

  int uidForUser(String userId) {
    var hash = 2166136261;
    for (final unit in userId.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  String _read(String key) {
    final value = _env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key is not configured');
    }

    return value;
  }

  static DotEnv _loadEnv() {
    final env = DotEnv(includePlatformEnvironment: true, quiet: true);
    final candidates = <String>[
      '.env',
      'backend/.env',
      '${Directory.current.path}/.env',
      '${Directory.current.path}/backend/.env',
    ];

    env.load(candidates);
    return env;
  }
}
