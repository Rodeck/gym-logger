class User {
  final String email;
  final String id;

  User(this.email, this.id);

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'id': id,
      };
}
