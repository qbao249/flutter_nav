/// Represents the result of a navigation linking operation.
///
/// It contains the matched route path, path parameters, and query parameters
/// extracted from the URI.
class NavLinkResult {
  NavLinkResult({
    required this.matchedRoutePath,
    required this.pathParameters,
    required this.queryParameters,
  });

  final String matchedRoutePath;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
}
