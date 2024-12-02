class UserModel {
  String uid;
  String email;
  String? name;
  String image;
  bool isAdmin;

  UserModel(
      {required this.uid,
      required this.email,
      this.name,
      this.image = '',
      this.isAdmin = false});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      image: json.containsKey('image') ? json['image'] : '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'image': image,
      'isAdmin': isAdmin,
    };
  }
}
