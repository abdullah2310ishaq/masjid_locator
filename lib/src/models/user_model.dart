class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String role;
  final String password;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.password,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 'user',
      password: data['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
      'password': password,
    };
  }
}
