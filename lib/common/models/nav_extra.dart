import 'dart:convert';

/// A base class for passing extra data during navigation.
class NavExtra {
  NavExtra(
    Map<String, dynamic> data, {
    this.linkingData,
    bool processData = true,
  }) : data = processData ? _NavExtraExt._processData(data) : data;

  final Map<String, dynamic> data;
  final Map<String, dynamic>? linkingData;
}

extension _NavExtraExt on NavExtra {
  static Map<String, dynamic> _processData(Map<String, dynamic> data) {
    if (data.isNotEmpty) {
      final jsonString = jsonEncode(data);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return data;
  }
}
