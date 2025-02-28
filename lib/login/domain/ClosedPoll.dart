import 'dart:convert';
import 'dart:core';

class Closedpoll {
  String pollId;
  String title;
  String totalVotes;
  String fields;
  String groups;

  Closedpoll({required this.pollId, required this.title, required this.totalVotes, required this.fields, required this.groups});

  factory Closedpoll.fromMap(Map<String, dynamic> map) {
    return Closedpoll(
      pollId: map['pollId'] as String,
      title: map['title'] as String,
      totalVotes: map['totalVotes'] as String,
      fields: map['fields'] as String,
      groups: map['groups'] as String,
    );
  }

  factory Closedpoll.fromJson(Map<String, dynamic> json) {
    return Closedpoll(
      title: json['title']?? '',
      totalVotes: json['totalVotes']?? '',
      fields: json['fields']?? '',
      pollId: json['pollId']?? '',
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
    };
  }


}
