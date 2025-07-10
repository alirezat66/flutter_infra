import 'dart:convert';

import 'package:flutter_infra/flutter_infra.dart';

extension TypedStorage on StorageService {
  /// Store and retrieve JSON objects
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Store and retrieve JSON objects in secure storage
  Future<bool> setSecureJson(String key, Map<String, dynamic> value) async {
    return await setSecureString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final jsonString = await getSecureString(key);
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

  Future<List<String>?> getStringList(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    try {
      return List<String>.from(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Store and retrieve lists in secure storage
  Future<bool> setSecureStringList(String key, List<String> value) async {
    return await setSecureString(key, jsonEncode(value));
  }

  Future<List<String>?> getSecureStringList(String key) async {
    final jsonString = await getSecureString(key);
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

  Future<DateTime?> getDateTime(String key) async {
    final dateString = await getString(key);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Store and retrieve DateTime in secure storage
  Future<bool> setSecureDateTime(String key, DateTime value) async {
    return await setSecureString(key, value.toIso8601String());
  }

  Future<DateTime?> getSecureDateTime(String key) async {
    final dateString = await getSecureString(key);
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
