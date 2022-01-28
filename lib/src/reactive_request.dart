import 'package:equatable/equatable.dart';

class RedirectRequest with EquatableMixin {
  final String origin;
  final String target;

  RedirectRequest({
    required this.origin,
    required this.target,
  });

  @override
  List<Object?> get props => [origin, target];
}
