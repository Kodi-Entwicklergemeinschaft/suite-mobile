import 'package:network/network.dart';
import 'package:template_c/feat/profile/data/models/edit_profile_request_model.dart';
import 'package:template_c/feat/profile/data/models/faq_model.dart';
import 'package:template_c/feat/profile/data/models/profile_model.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Fetch current user profile
  Future<Either<Exception, ProfileModel>> getProfile();

  /// Update user profile
  Future<Either<Exception, ProfileModel>> updateProfile(
    EditProfileRequestModel request, {required String userId}
  );

  /// Delete user account
  Future<Either<Exception, void>> deleteAccount({String? userId});

  /// Fetch FAQ
  Future<Either<Exception, FAQModel>> getFAQ();
}
