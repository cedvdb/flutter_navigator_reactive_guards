import 'package:navigator_reactive_guards/src/reactive_request.dart';
import 'package:flutter/material.dart';

import 'reactive_guard.dart';
import 'package:rxdart/rxdart.dart';

/// Widget to be placed in the builder of MaterialApp.router
///
/// example:
///
/// ```dart
/// MaterialApp.router(
///   routerDelegate: BeamerDelegate(...),
///   routeInformationParser: BeamerParser(),
///   builder: (ctx, child) {
///     return ReactiveGuardDispatcher(
///       key: const ValueKey('reactive-guard'),
///       child: child ?? Container(),
///       onRedirectRequest: (req) => Beamer.of(ctx).beamToNamed(req.target),
///     );
///   },
/// ),
/// ```
///
class ReactiveGuardDispatcher extends StatefulWidget {
  /// list of active guards
  final List<ReactiveGuard> guards;
  // when none of the guards resolve this is what is targeted
  final Widget child;
  final void Function(RedirectRequest) onRedirectRequest;

  const ReactiveGuardDispatcher({
    required this.guards,
    required this.child,
    required this.onRedirectRequest,
    Key? key,
  }) : super(key: key);

  @override
  State<ReactiveGuardDispatcher> createState() =>
      _ReactiveGuardDispatcherState();
}

class _ReactiveGuardDispatcherState extends State<ReactiveGuardDispatcher> {
  late final Stream<ReactiveGuardResult> _redirectStream;

  @override
  didChangeDependencies() {
    _redirectStream = _buildRedirectStream();
    super.didChangeDependencies();
  }

  Stream<ReactiveGuardResult> _buildRedirectStream() {
    final guards = widget.guards;
    // when one of the guard emit we resolve
    return CombineLatestStream(
      guards.map((g) => g.stream),
      (values) => _resolve(values, guards),
    ).distinct();
  }

  ReactiveGuardResult _resolve(
      List<dynamic> values, List<ReactiveGuard> guards) {
    final currentRoute = _getCurrentRoute();
    for (int i = 0; i < guards.length; i++) {
      final value = values[i];
      final guard = guards[i];
      final resolved = guard.resolve(value, currentRoute);

      if (resolved is! Next) {
        return resolved;
      }
    }
    return const Next();
  }

  String _getCurrentRoute() {
    final child = widget.child;
    if (child is! Router) {
      throw 'ReactiveGuardDispatcher must be placed '
          'in the builder of material app and its child must be '
          'the one that is passed as the builder param';
    }
    return child.routeInformationProvider?.value.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ReactiveGuardResult>(
      stream: _redirectStream,
      builder: (ctx, snap) {
        /// the client stream is supposed to always have a value.
        /// If the user has not done its due diligence then
        /// when no data is available we display an empty container.
        if (!snap.hasData) {
          return Container();
        }

        final result = snap.data as ReactiveGuardResult;

        if (result is Loading) {
          return result.loadingScreen;
        }
        if (result is Redirect) {
          final origin = _getCurrentRoute();
          final target = result.target;
          final needsRedirect = origin != target;
          if (needsRedirect) {
            final redirect = RedirectRequest(
              origin: origin,
              target: target,
            );
            widget.onRedirectRequest(redirect);
          }
        }
        // result is Next
        return widget.child;
      },
    );
  }
}
