class UserPref {
  static UserPref? _instace;
  static UserPref? get instance {
    _instace ??= UserPref._init();
    return _instace;
  }

  UserPref._init();

  bool? isPermissionGranted;
}

enum UserPrefs {
  storagePermissionStatus,
  writePermissionStatus,
  isDarkMode,
}
