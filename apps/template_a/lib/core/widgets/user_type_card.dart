import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

/// Card widget for selecting user type during onboarding
class UserTypeCard extends StatelessWidget {
  final String text;
  final int value;
  final String imagePath;
  final String semanticsLabel;
  final int? selected;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  const UserTypeCard({
    super.key,
    required this.text,
    required this.value,
    required this.imagePath,
    required this.semanticsLabel,
    this.selected,
    this.onTap,
    this.onInfoTap,
  });

  bool get isSelected => selected == value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      selected: isSelected,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: Colors.white,
          border: isSelected
              ? Border.all(
                  color: AppColors.defaultColors.primary,
                  width: 3,
                )
              : null,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 32.h, right: 24.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.defaultColors.primary,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                spacing: 10.h,
                children: [
                  _buildImage(),
                  _buildTitle(),
                  _buildRadio(context),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildImage() {
    return CommonImage(
      imagePath: imagePath,
      width: 120.w,
      height: 120.h,
      label: semanticsLabel,
    );
  }

  Widget _buildTitle() {
    return Center(
      child: CommonText(
        titleText: text,
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.defaultColors.surfaceDark,
          fontSize: 16.w,
        ),
      ),
    );
  }

  Widget _buildRadio(BuildContext context) {
    return ExcludeSemantics(
      child: Radio<int>(
        value: value,
        groupValue: selected,
        onChanged: (_) => onTap?.call(),
        fillColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}

/// Enum representing user types during onboarding
enum UserTypeEnum {
  guest(0),
  resident(1);

  final int intValue;

  const UserTypeEnum(this.intValue);

  /// Convert enum to int
  int get toInt => intValue;

  /// Convert int to enum
  static UserTypeEnum fromInt(int value) {
    return UserTypeEnum.values.firstWhere(
      (e) => e.intValue == value,
      orElse: () => throw ArgumentError('Invalid UserTypeEnum value: $value'),
    );
  }
}
