import 'package:flutter/foundation.dart';

@immutable
class GroupMember {
  final String id;
  final String name;
  final String? photoUrl;
  final MemberRole role;
  final bool isOnline;
  final DateTime joinedAt;

  const GroupMember({
    required this.id,
    required this.name,
    this.photoUrl,
    this.role = MemberRole.member,
    this.isOnline = false,
    required this.joinedAt,
  });
}

enum MemberRole {
  admin,
  moderator,
  member,
}
