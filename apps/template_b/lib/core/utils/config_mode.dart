import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns true when a real BASE_URL is configured in .env.
/// Placeholder values like YOUR_BASE_URL are treated as unconfigured.
/// Services use this to decide: API-first (live mode) vs asset-first (open-source mode).
bool get isLiveMode {
  final value = dotenv.maybeGet('BASE_URL') ?? '';
  return value.isNotEmpty && !value.startsWith('YOUR_');
}
