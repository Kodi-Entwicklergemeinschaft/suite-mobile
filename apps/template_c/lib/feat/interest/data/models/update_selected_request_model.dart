class UpdateSelectedRequestModel {
  final List<String> subcategoryIds;

  UpdateSelectedRequestModel({required this.subcategoryIds});

  Map<String, dynamic> toJson() {
    return {
      'subcategoryIds': subcategoryIds,
    };
  }
}
