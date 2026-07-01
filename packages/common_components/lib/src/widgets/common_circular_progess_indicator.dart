import 'package:flutter/material.dart';

class CommonCircularProgessIndicator extends StatelessWidget {
  const CommonCircularProgessIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
