class FeedbackState {
  bool isLoading;

  FeedbackState(this.isLoading);

  FeedbackState copyWith({bool? isLoading}) {
    return FeedbackState(isLoading ?? this.isLoading);
  }
}
