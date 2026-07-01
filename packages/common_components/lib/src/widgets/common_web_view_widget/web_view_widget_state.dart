class WebViewWidgetState {
  bool isLoading;

  WebViewWidgetState(this.isLoading);

  WebViewWidgetState copyWith({bool? isLoading}) {
    return WebViewWidgetState(isLoading ?? this.isLoading);
  }
}
