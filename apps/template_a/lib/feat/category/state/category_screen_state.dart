import 'package:template_a/core/constant/state_constant.dart';
import '../data/models/category_filter_model.dart';

class CategoryScreenState {
  final StateConstant stateConstant;
  final CategoryFilterModel? category;
  final String? selectedFilterSlug;
  final String message;

  const CategoryScreenState({
    required this.stateConstant,
    this.category,
    this.selectedFilterSlug,
    this.message = '',
  });

  CategoryScreenState copyWith({
    StateConstant? stateConstant,
    CategoryFilterModel? category,
    String? selectedFilterSlug,
    String? message,
  }) {
    return CategoryScreenState(
      stateConstant: stateConstant ?? this.stateConstant,
      category: category ?? this.category,
      selectedFilterSlug: selectedFilterSlug ?? this.selectedFilterSlug,
      message: message ?? this.message,
    );
  }

  CategoryScreenState clearFilter() {
    return CategoryScreenState(
      stateConstant: stateConstant,
      category: category,
      selectedFilterSlug: null,
      message: message,
    );
  }
}
