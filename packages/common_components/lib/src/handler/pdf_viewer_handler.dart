import 'package:common_components/src/handler/action_handler.dart';
import 'package:common_components/src/widgets/common_pdf_viewer_widget/common_pdf_viewer_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:template_b/routes/app_routes.dart';

final pdfViewerHandlerProvider = Provider((ref) => PdfViewerHandler());

class PdfViewerHandler implements ActionHandler<CommonPdfViewerWidgetParams> {
  @override
  void executeAction(BuildContext context, data, {String? title}) {
    context.pushNamed(AppRouteConstants.commonPdfViewer.name, extra: data);
  }
}
