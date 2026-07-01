import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HtmlContentWidget extends StatefulWidget {
  final String? htmlContent;
  final String? fontFamily;
  final EdgeInsets? padding;
  final bool enableExpand;
  final int minLengthToExpand;
  final int truncateLength;
  final String showMoreText;
  final String showLessText;
  final double? fontSize;
  final Color? showMoreColor;
  final TextDecoration? showMoreDecoration;
  final String? searchQuery;
  final Color? highlightColor;

  const HtmlContentWidget(
      {super.key,
      this.htmlContent,
      this.fontFamily,
      this.padding,
      this.enableExpand = true,
      this.minLengthToExpand = 300,
      this.truncateLength = 300,
      this.showMoreText = 'Show More',
      this.showLessText = 'Show Less',
      this.fontSize,
      this.showMoreColor,
      this.showMoreDecoration,
      this.searchQuery,
      this.highlightColor});

  @override
  State<HtmlContentWidget> createState() => _HtmlContentWidgetState();
}

class _HtmlContentWidgetState extends State<HtmlContentWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  String stripHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  String _applySearchHighlight(String html) {
    final query = widget.searchQuery;
    if (query == null || query.isEmpty) return html;
    final escaped = RegExp.escape(query);
    return html.replaceAllMapped(
      RegExp(escaped, caseSensitive: false),
      (match) => '<mark>${match.group(0)}</mark>',
    );
  }

  String _sanitizeHtml(String html) {
    return html.replaceAll(RegExp(r'<p>(\s|&nbsp;)*<\/p>', caseSensitive: false), '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.htmlContent == null || widget.htmlContent!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final sanitized = _sanitizeHtml(widget.htmlContent!);
    final displayContent = widget.enableExpand && !_isExpanded && _canExpand()
        ? '${sanitized.substring(0, sanitized.length > widget.truncateLength ? widget.truncateLength : sanitized.length)}...'
        : sanitized;
    final highlightedContent = _applySearchHighlight(displayContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: Html(
              shrinkWrap: true,
              data: highlightedContent,
              style: {
                "body": Style(
                  fontSize: FontSize((widget.fontSize ?? 13.sp) + 2),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  textAlign: TextAlign.left,
                  backgroundColor: Colors.transparent,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "a": Style(
                  color: Theme.of(context).primaryColor,
                  textDecoration: TextDecoration.underline,
                ),
                "mark": Style(
                  backgroundColor: widget.highlightColor ?? const Color(0x80FFEB3B),
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                "hr": Style(
                  margin: Margins.symmetric(vertical: 8),
                ),
                "figure": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "div": Style(
                  width: Width.auto(),
                ),
              },
              extensions: [
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: (extensionContext) {
                    final src = extensionContext.attributes['src'];
                    if (src == null || src.isEmpty) return const SizedBox.shrink();
                    final screenWidth = MediaQuery.of(extensionContext.buildContext!).size.width;
                    final imageHeight = screenWidth * 9 / 16;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        src,
                        width: screenWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ],
              onLinkTap: (url, attributes, element) async {
                if (url == null) return;
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.platformDefault);
              },
            )),
        if (widget.enableExpand && _canExpand()) ...[
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? widget.showLessText : widget.showMoreText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.showMoreColor ?? theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                decoration: widget.showMoreDecoration,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _canExpand() {
    return widget.htmlContent != null &&
        widget.htmlContent!.length > widget.minLengthToExpand;
  }
}
