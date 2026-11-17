import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';

void main() {
  group('CrashReporter.userHash', () {
    test('é estável para o mesmo usuário', () {
      expect(
        CrashReporter.userHash('12345678900'),
        CrashReporter.userHash('12345678900'),
      );
    });

    test('muda entre usuários e não contém o valor original', () {
      final a = CrashReporter.userHash('12345678900');
      final b = CrashReporter.userHash('12345678901');
      expect(a, isNot(b));
      expect(a, isNot(contains('12345678900')));
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  group('CrashReporter.isExpected', () {
    test('ignora falhas de conexão', () {
      expect(CrashReporter.isExpected(const SocketException('x')), isTrue);
      expect(CrashReporter.isExpected(TimeoutException('x')), isTrue);
      expect(CrashReporter.isExpected(http.ClientException('x')), isTrue);
      expect(CrashReporter.isExpected(const HandshakeException('x')), isTrue);
    });

    test('ignora login cancelado pelo usuário', () {
      expect(
        CrashReporter.isExpected(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          PlatformException(
            code: 'authorize_failed',
            message:
                'Failed to authorize: [error: null, description: User cancelled flow]',
          ),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          PlatformException(
            code: 'authorize_failed',
            message:
                'Failed to authorize: The operation couldn’t be completed. '
                '(org.openid.appauth.general error -3.)',
          ),
        ),
        isTrue,
      );
    });

    test('relata erros reais', () {
      expect(CrashReporter.isExpected(Exception('x')), isFalse);
      expect(CrashReporter.isExpected(const FormatException('x')), isFalse);
      expect(CrashReporter.isExpected(StateError('x')), isFalse);
      expect(
        CrashReporter.isExpected(
          PlatformException(code: 'authorize_failed', message: 'outro erro'),
        ),
        isFalse,
      );
      expect(
        CrashReporter.isExpected(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.providerConfigurationError,
          ),
        ),
        isFalse,
      );
    });
  });
}
