class UserModel {
  final String id;
  final String name;
  final String? email;        
  final String? phoneNumber;    
  final String role;
  final String password;

  UserModel({
    required this.id,
    required this.name,
    this.email,               
    this.phoneNumber,         
    required this.role,
    required this.password,
  });

  // Factory method to create a UserModel from a Map (Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'],              
      phoneNumber: data['phoneNumber'],   
      role: data['role'] ?? 'user',
      password: data['password'] ?? '',
    );
  }

  // Method to convert UserModel into a Map (for storing in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,              
      'phoneNumber': phoneNumber,  
      'role': role,
      'password': password,
    };
  }
}
