class AppGlobal {
  static final AppGlobal _instance = AppGlobal._internal();

  factory AppGlobal() {
    return _instance;
  }

  AppGlobal._internal();
}
