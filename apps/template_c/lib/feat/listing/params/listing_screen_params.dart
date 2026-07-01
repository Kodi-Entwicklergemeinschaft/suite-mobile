import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/home/widgets/listing/listing_item_card.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';

class ListingScreenParams {
  final String familyKey;
  final String screenTitle;
  final ListingCardVariant cardVariant;
  final ListingFilterModel initialFilter;

  const ListingScreenParams({
    required this.familyKey,
    required this.initialFilter,
    this.screenTitle = '',
    this.cardVariant = ListingCardVariant.standard,
  });

  factory ListingScreenParams.fromMap(Map<String, dynamic> map) {
    final title = map['title'] as String? ?? '';
    final categorySlug = map['category'] as String?;
    final subcategorySlug =
        map['subCategory'] as String? ?? map['subcategory'] as String?;
    final familyKey = subcategorySlug ?? categorySlug ?? '';

    return ListingScreenParams(
      familyKey: ListingFamilyKey.seeAll(familyKey),
      screenTitle: title,
      initialFilter: ListingFilterModel(
        categorySlug: subcategorySlug == null ? categorySlug : null,
        subcategorySlug: subcategorySlug,
        page: 1,
      ),
    );
  }
}
