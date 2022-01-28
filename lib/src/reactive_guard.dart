import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Base class for reactive guards
///
/// The stream getter and resolve method need to be implemented.
abstract class ReactiveGuard<T> {
  const ReactiveGuard();

  Stream<T> get stream;

  /// The resolve method that is called when the stream value changes
  ///
  /// The resolve method can return 3 types of result:
  /// - Loading(loadingScreen) => will display the loadingWidget
  /// - Next => will proceed to the next resolver if any, if none then stays on current route
  /// - Redirect => redirects to target route
  ReactiveGuardResult resolve(T streamValue, String currentRoute);
}

abstract class ReactiveGuardResult {
  const ReactiveGuardResult();
}

class Next extends ReactiveGuardResult with EquatableMixin {
  const Next();

  @override
  List<Object?> get props => [];
}

class Loading extends ReactiveGuardResult with EquatableMixin {
  final Widget loadingScreen;
  const Loading({required this.loadingScreen});

  @override
  List<Object?> get props => [loadingScreen];
}

class Redirect extends ReactiveGuardResult with EquatableMixin {
  final String target;
  const Redirect({required this.target});

  @override
  List<Object?> get props => [target];
}
