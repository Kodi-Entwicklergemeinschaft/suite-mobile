class CommonApiEndpoints {
  CommonApiEndpoints._();

  static const String _base = '/api';

  static const String shortCodeConfig = '$_base/auth/ott/session';
  static const String imageUpload = '$_base/users/media/upload';
  static const String imageDelete = '$_base/users/media/delete';
}
