import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/profile/data/models/faq_model.dart';
import 'package:template_c/feat/profile/domain/usecases/get_faq_usecase.dart';

final faqProvider = NotifierProvider<FaqNotifier, FAQModel?>(
  () => FaqNotifier(),
);

class FaqNotifier extends Notifier<FAQModel?> {
  @override
  FAQModel? build() {
    Future.microtask(_loadFAQ);
    return null;
  }

  Future<void> _loadFAQ() async {
    final result = await ref.read(getFAQUseCaseProvider).call(NoParams());
    result.fold(
      (error) {
        developer.log(
          'Failed to load FAQ: $error',
          name: 'FaqNotifier',
          error: error,
        );
      },
      (faqData) {
        developer.log('FAQ loaded successfully', name: 'FaqNotifier');
        state = faqData;
      },
    );
  }
}
