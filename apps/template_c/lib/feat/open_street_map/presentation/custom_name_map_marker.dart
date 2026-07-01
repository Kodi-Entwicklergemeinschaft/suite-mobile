import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNameMapMarker extends StatelessWidget {
  final String name;
  final Color backgroundColor;

  const CustomNameMapMarker({
    super.key,
    required this.name,
    this.backgroundColor = const Color(0xFF2D2D2D), // Dark grey from image
  });

  String get _initials {
    List<String> names = name.trim().split(" ");
    if (names.length >= 2) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 52.h,
          width: 51.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: CircleAvatar(
            backgroundColor: backgroundColor,
            child: CommonText(
              titleText: name,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0.h,
          child: CustomPaint(
            size: Size(15.w, 12.h),
            painter: MarkerPointerPainter(),
          ),
        ),
      ],
    );
  }
}

class MarkerPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
