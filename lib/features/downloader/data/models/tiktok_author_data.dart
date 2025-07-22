
class Author {
  String? id;
  String? uniqueId;
  String? nickname;
  String? avatar;

  Author({this.id, this.uniqueId, this.nickname, this.avatar});

  Author.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unique_id'] = uniqueId;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    return data;
  }
}