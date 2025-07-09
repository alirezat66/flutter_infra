import 'dart:convert';

import 'package:flutter_infra/flutter_infra.dart';

extension TypedStorage on LocalStorage {
  /// Store and retrieve JSON objects
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Store and retrieve lists
  Future<bool> setStringList(String key, List<String> value) async {
    return await setString(key, jsonEncode(value));
  }

  List<String>? getStringList(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return List<String>.from(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Store and retrieve DateTime
  Future<bool> setDateTime(String key, DateTime value) async {
    return await setString(key, value.toIso8601String());
  }

  DateTime? getDateTime(String key) {
    final dateString = getString(key);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
