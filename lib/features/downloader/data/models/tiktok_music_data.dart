class MusicInfo {
  String? id;
  String? title;
  String? play;
  String? cover;
  String? author;
  bool? original;
  int? duration;
  String? album;

  MusicInfo(
      {this.id,
      this.title,
      this.play,
      this.cover,
      this.author,
      this.original,
      this.duration,
      this.album});

  MusicInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    play = json['play'];
    cover = json['cover'];
    author = json['author'];
    original = json['original'];
    duration = json['duration'];
    album = json['album'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['play'] = play;
    data['cover'] = cover;
    data['author'] = author;
    data['original'] = original;
    data['duration'] = duration;
    data['album'] = album;
    return data;
  }
}