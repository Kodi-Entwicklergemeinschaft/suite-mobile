import 'package:flutter_dotenv/flutter_dotenv.dart';

bool get isLiveMode {
  final value = dotenv.maybeGet('BASE_URL') ?? '';
  return value.isNotEmpty && !value.startsWith('YOUR_');
}
