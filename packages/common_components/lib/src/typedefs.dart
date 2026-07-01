import 'package:flutter/material.dart';

/// Builds a [PreferredSizeWidget] app bar.
/// Feature packages accept this typedef so the host template can inject
/// its own app bar without the feature depending on any template.
typedef AppBarBuilder = PreferredSizeWidget Function(BuildContext context);
