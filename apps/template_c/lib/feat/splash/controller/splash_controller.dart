import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/splash/state/splash_state.dart';
import 'package:template_c/offline/theme_offline/controller/theme_offline_controller.dart';
import 'package:template_c/theme_config/domain/usecases/get_theme_config_usecase.dart';
import 'package:theme/theme.dart';

final splashControllerProvider =
    NotifierProvider.autoDispose<SplashNotifier, SplashState>(() {
      return SplashNotifier();
    });

class SplashNotifier extends Notifier<SplashState> {
  late GetThemeConfigUseCase _getThemeConfigUseCase;

  @override
  SplashState build() {
    _getThemeConfigUseCase = ref.read(getThemeConfigUseCaseProvider);
    return const SplashState();
  }

  Future<void> initializeApp() async {
    await _loadThemeConfig();

    if (ref.mounted && !state.hasError) {
      state = state.copyWith(isSuccess: true);
    }
  }

  Future<void> _loadThemeConfig() async {
    final result = await _getThemeConfigUseCase.call(const NoParams());
    result.fold(
      (error) {
        debugPrint('Splash: theme config error: $error');
        state = state.copyWith(stateConstant: StateConstant.error);
      },
      (theme) async {
        ref.read(appThemeNotifierProvider.notifier).setAppTheme(theme);

        // Update Hive cache: remove old theme then store the fresh one
        final themeOffline = ref.read(themeOfflineControllerProvider.notifier);
        await themeOffline.clearCache();
        await themeOffline.cacheTheme(theme);

        state = state.copyWith(stateConstant: StateConstant.success);

        await Future.delayed(Duration(seconds: 3), () {
          state = state.copyWith(isThemeLoaded: true);
        });
      },
    );
  }
}
