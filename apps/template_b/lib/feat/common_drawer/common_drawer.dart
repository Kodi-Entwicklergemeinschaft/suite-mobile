import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/locale.dart';
import '../profile/presentation/widgets/menu_item_widget.dart';

class CommonDrawerItem {
  final String title;
  final VoidCallback onTap;
  const CommonDrawerItem({required this.title, required this.onTap});
}

class CommonDrawer extends StatelessWidget {
  final String title;
  final List<CommonDrawerItem> items;
  final VoidCallback? onLogout;
  final String logoutLabel;

  const CommonDrawer({
    super.key,
    this.title = 'Menu Bar',
    required this.items,
    this.onLogout,
    this.logoutLabel = 'Logout',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.75,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
            topLeft: Radius.circular(0.r),
            bottomLeft: Radius.circular(0.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 12,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: 26.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      button: true,
                      label: 'close_drawer'.tr,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: ExcludeSemantics(
                          child: Icon(
                            Icons.close,
                            size: 28.r,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ...items.map(
                        (item) => MenuItemWidget(
                          title: item.title,
                          onTap: () {
                            Navigator.of(context).pop();
                            item.onTap();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (onLogout != null) ...[
                  Divider(
                    thickness: 1.3,
                    color: theme.dividerColor.withValues(alpha: 0.18),
                    indent: 14,
                    endIndent: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.h,
                      left: 16.w,
                      right: 16.w,
                      top: 8.h,
                    ),
                    child: Semantics(
                      button: true,
                      label: logoutLabel,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onLogout!.call();
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                          child: ExcludeSemantics(
                            child: Text(
                              logoutLabel,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
