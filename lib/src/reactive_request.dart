class RedirectRequest {
  final String origin;
  final String target;

  RedirectRequest({
    required this.origin,
    required this.target,
  });

  @override
  String toString() => 'RedirectRequest(origin: $origin, target: $target)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RedirectRequest &&
        other.origin == origin &&
        other.target == target;
  }

  @override
  int get hashCode => origin.hashCode ^ target.hashCode;
}
