/// A base class for passing extra data during navigation.
class NavExtra {
  NavExtra(this.data);
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => data;
}
