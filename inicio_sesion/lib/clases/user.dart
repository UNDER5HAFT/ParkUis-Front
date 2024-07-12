class UserSession {
  static final UserSession _instance = UserSession._internal();
  String? token;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();
}
