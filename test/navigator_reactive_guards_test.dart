import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:navigator_reactive_guards/navigator_reactive_guards.dart';

import 'mock_guards.dart';
import 'routes.dart';

void main() {
  Widget getApp({
    required List<ReactiveGuard> guards,
  }) {
    final routerDelegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          Routes.login: (context, state) => Container(
                key: const ValueKey(Routes.login),
              ),
          Routes.home: (context, state) => Container(
                key: const ValueKey(Routes.home),
              ),
          Routes.books: (context, state) => Container(
                key: const ValueKey(Routes.books),
              ),
        },
      ),
    );
    return BeamerProvider(
      routerDelegate: routerDelegate,
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
        builder: (ctx, child) => ReactiveGuardDispatcher(
          child: child ?? Container(),
          guards: guards,
          onRedirectRequest: (req) => Beamer.of(ctx).beamToNamed(req.target),
        ),
      ),
    );
  }

  group('ReactiveGuardDispatcher', () {
    testWidgets('Should display loading widget', (tester) async {
      final loadingGuard = MockLoadingGuard();
      await tester.pumpWidget(getApp(guards: [
        MockPassThroughGuard(),
        loadingGuard,
        MockPassThroughGuard(),
      ]));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      loadingGuard.setLoaded();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Should send redirect request', (tester) async {
      final authGuard = MockAuthGuard();
      await tester.pumpWidget(getApp(guards: [
        MockPassThroughGuard(),
        authGuard,
        MockPassThroughGuard(),
      ]));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(Routes.login)), findsOneWidget);
      authGuard.login();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(Routes.home)), findsOneWidget);
      expect(find.byKey(const ValueKey(Routes.login)), findsNothing);
      authGuard.logout();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey(Routes.login)), findsOneWidget);
      expect(find.byKey(const ValueKey(Routes.home)), findsNothing);
    });
  });
}
