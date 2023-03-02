class User {
  String? token;
  String? id;
  String? name;
  String? email;
  String? phone;
  String? bio;
  String? address;
  String? profilePic;
  String? fcsProfilePicPath;
  String? fcmToken;
  String? type_of_user;
  User({
    required this.token,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.address,
    required this.profilePic,
    required this.fcsProfilePicPath,
    required this.fcmToken,
    required this.type_of_user,
  });

  User.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    bio = json['bio'] ?? "";
    address = json['address'];
    profilePic = json['profile_pic'];
    fcsProfilePicPath = json['fcs_profile_pic_path'];
    fcmToken = json['fcm_token'];
    type_of_user = json['type_of_user'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['bio'] = bio;
    data['address'] = address;
    data['profile_pic'] = profilePic;
    data['fcs_profile_pic_path'] = fcsProfilePicPath;
    data['fcm_token'] = fcmToken;
    return data;
  }
}