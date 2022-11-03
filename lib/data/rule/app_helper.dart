String? urlFix(String? url, String baseUrl) {
  if (url?.isNotEmpty != true) return null;
  final uri = Uri.parse(url!);
  var baseUri = Uri.parse(baseUrl);
  if (baseUri.pathSegments.length > 0 && baseUri.pathSegments.last.contains(".")) {
    final newPathSegments = [...baseUri.pathSegments]..remove(baseUri.pathSegments.last);
    baseUri = baseUri.replace(pathSegments: newPathSegments);
  }
  return uri
      .replace(
        host: uri.hasAuthority ? null : Uri.parse(baseUrl).host,
        pathSegments: uri.hasAuthority || url.startsWith('/') ? null : [...baseUri.pathSegments, ...uri.pathSegments],
        scheme: uri.hasScheme ? null : "https",
      )
      .toString();
}
