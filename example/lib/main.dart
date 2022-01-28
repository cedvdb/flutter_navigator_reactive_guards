import 'package:beamer/beamer.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:navigator_reactive_guards/navigator_reactive_guards.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

// reactive guards

class AuthGuard extends ReactiveGuard<bool> {
  final BehaviorSubject<bool> _authStatusController =
      BehaviorSubject.seeded(false);

  login() {
    _authStatusController.add(true);
  }

  logout() {
    _authStatusController.add(false);
  }

  @override
  ReactiveGuardResult resolve(bool streamValue, String currentRoute) {
    if (streamValue == true) {
      if (currentRoute == Routes.login) {
        return const Redirect(target: Routes.home);
      } else {
        return const Next();
      }
    } else {
      if (currentRoute == Routes.login) {
        return const Next();
      } else {
        return const Redirect(target: Routes.login);
      }
    }
  }

  @override
  Stream<bool> get stream => _authStatusController.stream.asBroadcastStream();
}

// app

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final AuthGuard _authGuard = AuthGuard();
  // beamer used here but other libraries can be used
  static final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        Routes.login: (context, state) => LoginPage(
              onLoginPress: () => _authGuard.login(),
            ),
        Routes.home: (context, state) => HomePage(
              onLogoutPress: () => _authGuard.logout(),
            ),
      },
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // beamer used here but other libraries can be used

    return BeamerProvider(
      routerDelegate: routerDelegate,
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
        builder: (ctx, child) => ReactiveGuardDispatcher(
          key: const ValueKey('reactive-guard'),
          child: child ?? Container(),
          guards: [_authGuard],
          onRedirectRequest: (req) => Beamer.of(ctx).beamToNamed(req.target),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Function() onLoginPress;
  const LoginPage({
    Key? key,
    required this.onLoginPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLoginPress,
      child: const Text('login'),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function() onLogoutPress;
  const HomePage({
    Key? key,
    required this.onLogoutPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogoutPress,
      child: const Text('logout'),
    );
  }
}
