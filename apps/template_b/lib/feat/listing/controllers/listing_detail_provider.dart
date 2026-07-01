import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/usecases/get_listing_detail_usecase.dart';
import '../data/repositories/listing_repository_impl.dart';
import '../state/listing_detail_state.dart';

/// Provider for GetListingDetailUseCase
final getListingDetailUseCaseProvider = Provider<GetListingDetailUseCase>((ref) {
  final repository = ref.watch(listingRepositoryProvider);
  return GetListingDetailUseCase(repository: repository);
});

/// Notifier for managing listing detail state
class ListingDetailNotifier extends Notifier<ListingDetailState> {
  @override
  ListingDetailState build() => ListingDetailState();

  /// Initialize and fetch listing detail by ID or slug
  Future<void> init(String id, {bool bySlug = false}) async {
    await fetchListing(id, bySlug: bySlug);
  }

  /// Fetch listing detail
  Future<void> fetchListing(String id, {bool bySlug = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = ref.read(getListingDetailUseCaseProvider);
      final result = await usecase.call(GetListingDetailParams(
        listingId: id,
        bySlug: bySlug,
      ));

      result.fold(
        (error) => state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        ),
        (listing) => state = state.copyWith(
          isLoading: false,
          listing: listing,
          error: null,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String listingId) async {
    state = state.copyWith(isFavorited: !state.isFavorited);

    // TODO: Call API to update favorite status when ready
    // For now, just toggle the UI
  }

  /// Retry fetching listing
  Future<void> retry(String id, {bool bySlug = false}) async {
    await fetchListing(id, bySlug: bySlug);
  }

  /// Reset state
  void reset() {
    state = ListingDetailState();
  }
}

/// Provider for listing detail notifier
final listingDetailProvider =
    NotifierProvider<ListingDetailNotifier, ListingDetailState>(
  () => ListingDetailNotifier(),
);

/// Dummy data for testing/development
/// COMMENTED OUT - Now using real API through GetListingDetailUseCase
/*
ListingModel getDummyListingDetail(String id) {
  final dummyListings = {
    '1': ListingModel(
      id: '1',
      title: 'Report from the public meeting of the Administrative Committee on 18.11.2025',
      summary: 'The following topics were discussed - The municipal council was unanimously to approve the agenda of the ongoing..',
      content: 'Full detailed content about the administrative committee meeting and all discussed topics. This report covers all agenda items, decisions made, and action items assigned to committee members.',
      viewCount: 342,
      likeCount: 67,
      shareCount: 23,
      moderationStatus: ModerationStatus.approved,
      visibility: Visibility.public,
      isFeatured: true,
      publishAt: '2026-01-15T10:00:00.000Z',
      createdAt: '2025-11-18T10:00:00.000Z',
      updatedAt: '2025-11-18T15:00:00.000Z',
      heroImageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
      address: '123 Main Street, City Center, 12345',
      contactPhone: '+1 (555) 123-4567',
      contactEmail: 'info@municipality.gov',
      website: 'www.municipality.gov',
      organizerName: 'Municipal Administration Office',
      media: [
        ListingMediaModel(id: '1', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '2', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '3', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
      ],
    ),
    '2': ListingModel(
      id: '2',
      title: 'Community Event Announcement',
      summary: 'Join us for this year\'s community gathering and celebration',
      content: 'Come and be part of our annual community event with activities for the whole family. We have planned numerous activities including live music, food trucks, games for children, and much more. This is a great opportunity to meet your neighbors and build community spirit.',
      viewCount: 189,
      likeCount: 34,
      shareCount: 12,
      moderationStatus: ModerationStatus.approved,
      visibility: Visibility.public,
      isFeatured: false,
      publishAt: '2026-01-14T10:00:00.000Z',
      createdAt: '2025-11-17T10:00:00.000Z',
      updatedAt: '2025-11-17T14:00:00.000Z',
      heroImageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&h=600&fit=crop',
      address: 'Central Park, 456 Oak Avenue, City, 12345',
      contactPhone: '+1 (555) 987-6543',
      contactEmail: 'events@community.org',
      website: 'www.communityevents.org',
      organizerName: 'Community Events Team',
      eventStart: '2026-02-15T10:00:00.000Z',
      eventEnd: '2026-02-15T18:00:00.000Z',
      isAllDay: false,
      media: [
        ListingMediaModel(id: '1', url: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '2', url: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&h=300&fit=crop'),
      ],
    ),
    '3': ListingModel(
      id: '3',
      title: 'Business Opportunity Launching',
      summary: 'Exciting new business venture launching soon in our region',
      content: 'We are proud to announce our new business initiative that will bring great opportunities to our community. This venture focuses on sustainable development and creating local jobs. We invite partners and investors to join us in this exciting journey.',
      viewCount: 456,
      likeCount: 89,
      shareCount: 45,
      moderationStatus: ModerationStatus.approved,
      visibility: Visibility.public,
      isFeatured: true,
      publishAt: '2026-01-13T10:00:00.000Z',
      createdAt: '2025-11-16T10:00:00.000Z',
      updatedAt: '2025-11-16T16:00:00.000Z',
      heroImageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
      address: '789 Business Park, Suite 100, City, 12345',
      contactPhone: '+1 (555) 246-8135',
      contactEmail: 'business@venture.com',
      website: 'www.newbusinessventure.com',
      registrationUrl: 'https://www.newbusinessventure.com/register',
      organizerName: 'Business Development Corp',
      media: [
        ListingMediaModel(id: '1', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '2', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '3', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ListingMediaModel(id: '4', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
      ],
    ),
  };

  return dummyListings[id] ??
      ListingModel(
        id: id,
        title: 'Listing Detail - $id',
        summary: 'This is a sample listing with id $id',
        content: 'Full content for listing $id...',
        viewCount: 0,
        likeCount: 0,
        shareCount: 0,
        moderationStatus: ModerationStatus.approved,
        visibility: Visibility.public,
        publishAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        heroImageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop',
        organizerName: 'Organization',
        media: [
          ListingMediaModel(id: '1', url: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=300&fit=crop'),
        ],
      );
}
*/
