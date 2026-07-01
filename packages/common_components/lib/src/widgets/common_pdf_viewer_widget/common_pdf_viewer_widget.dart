import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';
import 'package:theme/theme.dart';

class CommonPdfViewerWidgetParams {
  final String url;
  final String title;

  CommonPdfViewerWidgetParams({required this.url, required this.title});
}

class CommonPdfViewerWidget extends ConsumerStatefulWidget {
  final CommonPdfViewerWidgetParams params;

  const CommonPdfViewerWidget({super.key, required this.params});

  @override
  ConsumerState<CommonPdfViewerWidget> createState() =>
      _CommonPdfViewerWidgetState();
}

class _CommonPdfViewerWidgetState extends ConsumerState<CommonPdfViewerWidget> {
  late PdfController _pdfController;

  static Future<PdfDocument> _loadFromUrl(String url) async {
    final client = HttpClient();
    // dart:io drops Set-Cookie across auto-redirects; managing redirects manually
    // keeps the cookie jar intact so cookie-challenge servers (e.g. Akamai) pass.
    final cookieJar = <String, String>{};

    try {
      Uri uri = Uri.parse(url);
      int hops = 0;

      while (hops < 10) {
        final request = await client.getUrl(uri);
        request.followRedirects = false;

        if (cookieJar.isNotEmpty) {
          request.headers.set(HttpHeaders.cookieHeader,
              cookieJar.entries.map((e) => '${e.key}=${e.value}').join('; '));
        }

        final response = await request.close();

        response.headers.forEach((name, values) {
          if (name.toLowerCase() == 'set-cookie') {
            for (final raw in values) {
              final pair = raw.split(';').first.trim();
              final eq = pair.indexOf('=');
              if (eq > 0) {
                cookieJar[pair.substring(0, eq).trim()] =
                    pair.substring(eq + 1).trim();
              }
            }
          }
        });

        final location = response.headers.value(HttpHeaders.locationHeader);
        log('[PdfViewer] hop=$hops status=${response.statusCode} location=$location cookies=$cookieJar');
        if (response.statusCode >= 300 &&
            response.statusCode < 400 &&
            location != null) {
          uri = uri.resolve(location);
          await response.drain<void>();
          hops++;
          continue;
        }

        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        return PdfDocument.openData(Uint8List.fromList(bytes));
      }

      throw Exception('Failed to load PDF: too many redirects');
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: _loadFromUrl(widget.params.url),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final fontLightColor = appTheme.colors.fontLight;

    return Scaffold(
      appBar: CommonAppBar(
        title: widget.params.title,
        onBackPressed: () => context.pop(),
        actions: [
          CommonIcon(
            icon: Icons.cancel,
            onPressed: () => context.pop(),
            color: fontLightColor,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            8.verticalSpace,
            Expanded(
              child: PdfView(
                controller: _pdfController,
                scrollDirection: Axis.vertical,
                builders: PdfViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  documentLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  pageLoaderBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, error) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48.h, color: Colors.red),
                        SizedBox(height: 12.h),
                        const CommonText(titleText: 'Failed to load PDF'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
