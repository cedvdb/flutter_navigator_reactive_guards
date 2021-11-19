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

class Next extends ReactiveGuardResult {
  const Next();
}

class Loading extends ReactiveGuardResult {
  final Widget loadingScreen;
  const Loading({required this.loadingScreen});
}

class Redirect extends ReactiveGuardResult {
  final String target;
  const Redirect({required this.target});

  @override
  String toString() => 'Redirect(target: $target)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Redirect && other.target == target;
  }

  @override
  int get hashCode => target.hashCode;
}
