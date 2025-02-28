import 'dart:convert';
import 'dart:core';

class OpenPoll {
  String username;
  String pollId;
  String title;
  String totalVotes;
  String fields;
  String groups;

  OpenPoll({required this.pollId, required this.title, required this.totalVotes, required this.fields, required this.username, required this.groups});

  factory OpenPoll.fromMap(Map<String, dynamic> map) {
    return OpenPoll(
      pollId: map['pollId'] as String,
      title: map['title'] as String,
      totalVotes: map['totalVotes'] as String,
      fields: map['fields'] as String,
      username: map['username'] as String,
      groups: map['groups'] as String,
    );
  }

  factory OpenPoll.fromJson(Map<String, dynamic> json) {
    return OpenPoll(
      title: json['title']?? '',
      totalVotes: json['totalVotes']?? '',
      fields: json['fields']?? '',
      pollId: json['pollId']?? '',
      username: json['username']?? '',
      groups: json['groups']?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pollId': pollId,
      'title': title,
      'totalVotes': totalVotes,
      'fields': fields,
      'groups': groups,
      'username': username,
    };
  }


}
