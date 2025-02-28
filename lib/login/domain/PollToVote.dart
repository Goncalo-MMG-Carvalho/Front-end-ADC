import 'dart:convert';
import 'dart:core';

class PolltoVote {
  String pollId;
  String title;
  String fields;
  String groups;


  PolltoVote({required this.pollId, required this.title, required this.fields, required this.groups});

  factory PolltoVote.fromMap(Map<String, dynamic> map) {
    return PolltoVote(
      pollId: map['pollId'] as String,
      title: map['title'] as String,
      fields: map['fields'] as String,
      groups: map['groups'] as String,
    );
  }

  factory PolltoVote.fromJson(Map<String, dynamic> json) {
    return PolltoVote(
      title: json['title']?? '',
      fields: json['fields']?? '',
      pollId: json['pollId']?? '',
      groups: json['groups']?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pollId': pollId,
      'title': title,
      'fields': fields,
      'groups': groups,
    };
  }


}