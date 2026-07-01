import 'package:dartz/dartz.dart';
import 'package:theme/theme.dart';

abstract class ThemeConfigRepository {
  Future<Either<Exception, AppTheme>> getThemeConfig();
}
