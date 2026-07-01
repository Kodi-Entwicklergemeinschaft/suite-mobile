import 'dart:io';

import 'package:common_components/common_components.dart';
import 'package:common_components/src/linkhub/linkhub_group_model.dart';
import 'package:common_components/src/linkhub/linkhub_link_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:theme/theme.dart';

class CommonLinkhubScreen extends BaseStatelessWidget {
  final String title;
  final String? imageUrl;
  final bool isAccordion;
  final List<LinkhubGroupModel> groups;
  final List<LinkhubLinkModel> links;

  const CommonLinkhubScreen({
    super.key,
    required this.title,
    this.imageUrl,
    required this.isAccordion,
    required this.groups,
    required this.links,
  });

  void _handleLinkTap(
    BuildContext context,
    WidgetRef ref,
    LinkhubLinkModel link,
  ) {
    if (link.isWebview) {
      if (Platform.isAndroid &&
          Uri.parse(link.url).path.toLowerCase().endsWith('.pdf')) {
        ref.read(pdfViewerHandlerProvider).executeAction(
              context,
              CommonPdfViewerWidgetParams(url: link.url, title: link.title),
            );
      } else {
        ref.read(webViewHandlerProvider).executeAction(
              context,
              CommonWebViewWidgetParams(
                url: link.url,
                title: link.title,
                requiredShortCode: false,
              ),
            );
      }
    } else {
      ref.read(launcherHandler).executeAction(context, link.url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTheme = ref.watch(appThemeProvider);
    final bgColor = appTheme.colors.getBackground(isDark);
    final surfaceColor = appTheme.colors.getSurface(isDark);
    final primary = appTheme.colors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CommonAppBar(
        title: title,
        // backgroundColor: primary,
        // foregroundColor: Colors.white,
        // titleTextStyle: const TextStyle(
        // color: Colors.white,
        // fontWeight: FontWeight.w600,
        // ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderImageCard(title: title, imageUrl: imageUrl ?? ''),
          SizedBox(height: 16.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              child: Material(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20.r),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.22),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: isAccordion
                      ? _AccordionContent(
                          groups: groups,
                          surfaceColor: surfaceColor,
                          onLinkTap: (link) =>
                              _handleLinkTap(context, ref, link),
                        )
                      : _LinksContent(
                          links: links,
                          onLinkTap: (link) =>
                              _handleLinkTap(context, ref, link),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _HeaderImageCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20.r),
        bottomRight: Radius.circular(20.r),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 200.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CommonImage(imagePath: imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinksContent extends StatelessWidget {
  final List<LinkhubLinkModel> links;
  final void Function(LinkhubLinkModel) onLinkTap;

  const _LinksContent({required this.links, required this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Center(child: CommonText(titleText: 'dt_no_links'.tr));
    }

    final dividerColor = Theme.of(context).dividerColor.withValues(alpha: 0.5);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      itemCount: links.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        color: dividerColor,
        indent: 16.w,
        endIndent: 16.w,
      ),
      itemBuilder: (_, i) =>
          _LinkRow(link: links[i], onTap: () => onLinkTap(links[i])),
    );
  }
}

class _AccordionContent extends StatelessWidget {
  final List<LinkhubGroupModel> groups;
  final void Function(LinkhubLinkModel) onLinkTap;
  final Color surfaceColor;

  const _AccordionContent({
    required this.groups,
    required this.onLinkTap,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(child: CommonText(titleText: 'dt_no_content'.tr));
    }

    final dividerColor = Theme.of(context).dividerColor.withValues(alpha: 0.5);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      itemCount: groups.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, thickness: 0.5, color: dividerColor),
      itemBuilder: (_, i) => _GroupTile(
        group: groups[i],
        onLinkTap: onLinkTap,
        surfaceColor: surfaceColor,
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final LinkhubGroupModel group;
  final void Function(LinkhubLinkModel) onLinkTap;
  final Color surfaceColor;

  const _GroupTile({
    required this.group,
    required this.onLinkTap,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.5);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: surfaceColor,
        collapsedBackgroundColor: surfaceColor,
        title: CommonText(
          titleText: group.title,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.visible,
          softWrap: true,
        ),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        children: [
          for (int i = 0; i < group.links.length; i++) ...[
            _LinkRow(
              link: group.links[i],
              onTap: () => onLinkTap(group.links[i]),
              indent: true,
            ),
            if (i < group.links.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: dividerColor,
                indent: 24.w,
                endIndent: 16.w,
              ),
          ],
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final LinkhubLinkModel link;
  final VoidCallback onTap;
  final bool indent;

  const _LinkRow({
    required this.link,
    required this.onTap,
    this.indent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leftPad = indent ? 24.w : 16.w;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 14.h,
        ).copyWith(left: leftPad, right: 16.w),
        child: Row(
          children: [
            Icon(
              Icons.link_rounded,
              size: 18.h,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonText(
                titleText: link.title,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.h,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
