import 'package:common_components/common_components.dart';
import 'package:common_components/src/short_code/controller/controller.dart';
import 'package:common_components/src/widgets/common_web_view_widget/web_view_widget_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final webViewWidgetProvider =
    NotifierProvider.autoDispose<WebViewWidgetController, WebViewWidgetState>(
        () => WebViewWidgetController());

class WebViewWidgetController extends Notifier<WebViewWidgetState> {
  ShortCodeController get shortCodeController =>
      ref.read(shortCodeControllerProvider);

  @override
  WebViewWidgetState build() {
    return WebViewWidgetState(true);
  }

  changeLoadingStatus(bool isLoading) {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: isLoading);
  }

  getShortCode(
      {required Function(String message) onError,
      required Function(String code) onSuccess}) async {
    final result = await shortCodeController.getShortCode();
    if (!ref.mounted) return;
    result.fold(
      (l) {
        debugPrint('Error fetching short code: $l');
      },
      (r) async {
        onSuccess(r ?? '');
      },
    );
  }
}
