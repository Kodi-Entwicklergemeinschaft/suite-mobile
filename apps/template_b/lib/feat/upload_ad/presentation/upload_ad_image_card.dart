import 'package:common_components/common_components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/feat/upload_ad/controller/upload_ad_controller.dart';

class UploadAdImageCard extends BaseStatefulWidget {
  final String label;

  UploadAdImageCard({required this.label});
  @override
  ConsumerState<UploadAdImageCard> createState() => _UploadAdImageCardState();
}

class _UploadAdImageCardState
    extends BaseStatefulWidgetState<UploadAdImageCard> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = 5.r;
    final state = ref.watch(uploadAdControllerProvider);
    final controller = ref.read(uploadAdControllerProvider.notifier);

    return Semantics(
      button: true,
      label: [
        widget.label,
        'upload_image'.tr,
      ].where((s) => s.isNotEmpty).join(', '),
      child: GestureDetector(
        onTap: () async {
          final file = await ref
              .read(imagePickerControllerProvider.notifier)
              .pickImageWithDialog(context);

          await controller.updateImageFile(file);
        },
        child: ExcludeSemantics(
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.inverseSurface.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.inverseSurface.withOpacity(0.5),
                ),
              ),

              contentPadding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 16.h),
            ),
            child: SizedBox(
              height: 90.h,

              child: (state.imageFile != null)
                  ? CommonImage(
                      imagePath: state.imageFile!.path,
                      imageFile: state.imageFile,
                      fit: BoxFit.cover,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonImage(imagePath: 'assets/svg/upload_image.svg'),
                        12.verticalSpace,
                        CommonText(
                          titleText: 'upload_image'.tr,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
