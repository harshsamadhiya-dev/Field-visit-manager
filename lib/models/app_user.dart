class AppUser {
  final String uid;
  final String name;
  final String email;
  final String employeeId;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'employeeId': employeeId,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      employeeId: map['employeeId'] ?? '',
    );
  }
}
