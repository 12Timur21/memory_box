enum SubscriptionType {
  noSubscription,
  month,
  year,
}

class UserModel {
  String? uid;
  String? displayName;
  String? phoneNumber;
  SubscriptionType? subscriptionType;
  String? avatarUrl;

  UserModel({
    this.uid,
    this.displayName,
    this.phoneNumber,
    this.subscriptionType,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    SubscriptionType subscriptionType = SubscriptionType.values.firstWhere(
      (f) => f.toString() == json['subscriptionType'],
      orElse: () => SubscriptionType.noSubscription,
    );

    return UserModel(
      uid: json['uid'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      subscriptionType: subscriptionType,
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'subscriptionType': subscriptionType.toString(),
        'avatarUrl': avatarUrl,
      };

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? phoneNumber,
    SubscriptionType? subscriptionType,
    String? avatarUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
