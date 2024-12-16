import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
  @EnviedField(varName: 'apiKey', obfuscate: true)
  static final String apiKey = _Env.apiKey;
  @EnviedField(varName: 'apiSecret', obfuscate: true)
  static final String apiSecret = _Env.apiSecret;
}