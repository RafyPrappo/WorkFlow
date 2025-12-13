class User {
  final String id;
  final String email;
  final String name;
  final DateTime joinedDate;

  User({
    required this.id,
    required this.email,
    required this.name,
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      joinedDate: DateTime.parse(map['joinedDate']),
    );
  }
}