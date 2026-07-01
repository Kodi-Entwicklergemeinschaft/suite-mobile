class ContactState {
  bool isLoading;
  ContactState(this.isLoading );

  ContactState copyWith({bool? isLoading}) {
    return ContactState(isLoading ?? this.isLoading);
  }
}
