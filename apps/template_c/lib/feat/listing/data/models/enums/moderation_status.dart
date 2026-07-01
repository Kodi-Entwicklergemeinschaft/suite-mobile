enum ModerationStatus {
  pending,
  approved,
  changesRequested, // changes_requested in API
  rejected,
  archived;

  String toApiValue() {
    switch (this) {
      case ModerationStatus.changesRequested:
        return 'changes_requested';
      default:
        return name;
    }
  }

  static ModerationStatus? fromApiValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'changes_requested':
        return ModerationStatus.changesRequested;
      case 'pending':
        return ModerationStatus.pending;
      case 'approved':
        return ModerationStatus.approved;
      case 'rejected':
        return ModerationStatus.rejected;
      case 'archived':
        return ModerationStatus.archived;
      default:
        return null;
    }
  }
}
