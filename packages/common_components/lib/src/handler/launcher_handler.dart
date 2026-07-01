import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:common_components/src/handler/action_handler.dart';
import 'package:common_components/src/short_code/controller/controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final launcherHandler = Provider(
  (ref) => LauncherHandler(
    shortCodeController: ref.read(shortCodeControllerProvider),
  ),
);

class LauncherHandler implements ActionHandler<String> {
  ShortCodeController shortCodeController;

  LauncherHandler({required this.shortCodeController});

  @override
  void executeAction(
    BuildContext context,
    data, {
    String? title,
    bool shortCodeRequired = false,
  }) async {
    final Uri url = Uri.parse(data);
    try {
      if (shortCodeRequired) {
        final result = await shortCodeController.getShortCode();
        result.fold(
          (l) {
            debugPrint('Error fetching short code: $l');

            AppSnackBar.showError(context, l.toString());
          },
          (r) async {
            final modifiedUrl = url.replace(
              queryParameters: {...url.queryParameters, 'ott': r ?? ''},
            );
            debugPrint('launching to url: $modifiedUrl');
            await launch(modifiedUrl);
          },
        );
      } else {
        await launch(url);
        debugPrint('launching to url: $url');
      }
    } catch (e) {
      debugPrint('Exception launching browser: $e');
    }
  }

  launch(Uri url) async {
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      rethrow;
    }
  }
}
