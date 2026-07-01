import 'dart:io';

import 'package:common_components/common_components.dart';
import 'package:common_components/src/widgets/common_pdf_viewer_widget/common_pdf_viewer_widget.dart';
import 'package:common_components/src/widgets/common_web_view_widget/web_view_widget_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template_b/routes/app_routes.dart';
import 'package:theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonWebViewWidgetParams {
  final String url;
  final String title;
  bool? requiredShortCode;
  bool? showAppBar;
  bool? loginRequired;
  bool showCloseButton;
  double? appBarHeight;
  Color? backgroundColor;
  void Function()? onBackPressHandle;
  CommonWebViewWidgetParams(
      {required this.url,
      required this.title,
      this.requiredShortCode,
      this.showAppBar,
      this.loginRequired,
      this.showCloseButton = false,
      this.appBarHeight,
      this.backgroundColor,
      this.onBackPressHandle});
}

class CommonWebViewWidget extends ConsumerStatefulWidget {
  final CommonWebViewWidgetParams params;

  const CommonWebViewWidget({super.key, required this.params});

  @override
  ConsumerState<CommonWebViewWidget> createState() =>
      _CommonWebViewWidgetState();
}

class _CommonWebViewWidgetState extends ConsumerState<CommonWebViewWidget> {
  late WebViewController _controller;
  bool _webViewCanGoBack = false;

  @override
  void initState() {
    super.initState();
    final provider = ref.read(webViewWidgetProvider.notifier);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
        debugPrint("onPageFinishedUrl = $url");
        provider.changeLoadingStatus(false);
        _controller.canGoBack().then((canGoBack) {
          if (mounted) setState(() => _webViewCanGoBack = canGoBack);
        });
      }, onNavigationRequest: (request) {
        debugPrint('onRequest: ${request.url}');

        final uri = Uri.tryParse(request.url);
        if (uri != null && (uri.scheme == 'mailto' || uri.scheme == 'tel')) {
          launchUrl(uri);
          return NavigationDecision.prevent;
        }

        return NavigationDecision.navigate;
      }, onWebResourceError: (error) {
        debugPrint('opening web resource error error = $error');
        provider.changeLoadingStatus(false);
      }, onSslAuthError: (error) {
        debugPrint('ssl auth resource error error = $error');
        provider.changeLoadingStatus(false);
      }, onHttpError: (error) {
        debugPrint('http auth resource error error = $error');
        provider.changeLoadingStatus(false);
      }, onPageStarted: (value) {
        provider.changeLoadingStatus(true);
      }));

    if (widget.params.requiredShortCode != null &&
        widget.params.requiredShortCode!) {
      Future.microtask(() {
        ref.read(webViewWidgetProvider.notifier).getShortCode(
            onError: (message) {
          AppSnackBar.showError(context, message);
        }, onSuccess: (code) {
          final url = '${widget.params.url}?ott=$code';
          debugPrint('web view launching url \n $url');
          _openUrl(url);
        });
      });
    } else {
      _openUrl(widget.params.url);
    }
  }

  // On Android, WebView can't render PDFs or other downloadable files. Check
  // the entry URL once: PDFs go to the in-app viewer, other attachments go to
  // the system browser, everything else loads in WebView. Subsequent in-page
  // link clicks are not re-checked.
  Future<void> _openUrl(String url) async {
    if (Platform.isAndroid) {
      final kind = await _classifyUrl(url);
      if (!mounted) return;
      if (kind == _UrlKind.pdf) {
        context.pushReplacementNamed(
          AppRouteConstants.commonPdfViewer.name,
          extra:
              CommonPdfViewerWidgetParams(url: url, title: widget.params.title),
        );
        return;
      }
      if (kind == _UrlKind.download) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (mounted) context.pop();
        return;
      }
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final fontLightColor = appTheme.colors.fontLight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final closeBarColor = isDark ? fontLightColor : Theme.of(context).colorScheme.primary;
    return PopScope(
      canPop: !_webViewCanGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: Scaffold(
        appBar: widget.params.showAppBar != null && !widget.params.showAppBar!
            ? null
            : widget.params.showCloseButton
                ? AppBar(
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: widget.params.backgroundColor,
                    toolbarHeight: widget.params.appBarHeight ?? kToolbarHeight,
                    leading: IconButton(
                      icon: Icon(Icons.close, color: closeBarColor),
                      onPressed: () {
                        final onBackPress = widget.params.onBackPressHandle;
                        if (onBackPress != null) {
                          onBackPress();
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    title: Text(
                      widget.params.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: closeBarColor,
                      ),
                    ),
                    centerTitle: true,
                  )
                : CommonAppBar(
                    backgroundColor: widget.params.backgroundColor,
                    title: widget.params.title,
                    onBackPressed: () async {
                      await _handleBack(context);
                    },
                    actions: [
                      CommonIcon(
                        icon: Icons.cancel,
                        onPressed: () {
                          final onBackPress = widget.params.onBackPressHandle;
                          if (onBackPress != null) {
                            onBackPress();
                          } else {
                            context.pop();
                          }
                        },
                        color: fontLightColor,
                      )
                    ],
                  ),
        body: _buildBody(context),
      ),
    );
  }

  Widget? _buildBody(BuildContext context) {
    final state = ref.watch(webViewWidgetProvider);

    return SafeArea(
      child: Column(
        children: [
          8.verticalSpace,
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<_UrlKind> _classifyUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return _UrlKind.webpage;
    if (uri.path.toLowerCase().endsWith('.pdf')) return _UrlKind.pdf;
    try {
      final client = HttpClient();
      try {
        final request = await client.headUrl(uri);
        request.followRedirects = true;
        final response = await request.close();
        await response.drain<void>();
        final contentType =
            response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
        final disposition = response.headers.value('content-disposition') ?? '';
        if (contentType.contains('application/pdf')) return _UrlKind.pdf;
        if (disposition.contains('attachment')) return _UrlKind.download;
        return _UrlKind.webpage;
      } finally {
        client.close();
      }
    } catch (_) {
      return _UrlKind.webpage;
    }
  }

  Future<void> _handleBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      final onBackPress = widget.params.onBackPressHandle;

      if (onBackPress != null) {
        onBackPress();
      } else {
        if (context.mounted) context.pop();
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller.loadRequest(Uri.parse('about:blank'));
      _controller.clearCache();
    } catch (_) {}
    super.dispose();
  }
}

enum _UrlKind { pdf, download, webpage }
