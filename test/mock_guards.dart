import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigator_reactive_guards/src/reactive_guard.dart';
import 'package:rxdart/subjects.dart';

import 'routes.dart';

class MockLoadingGuard extends ReactiveGuard<bool> {
  final BehaviorSubject<bool> _loadingController =
      BehaviorSubject.seeded(false);

  setLoaded() {
    _loadingController.add(true);
  }

  @override
  ReactiveGuardResult resolve(bool streamValue, String currentRoute) {
    if (streamValue == false) {
      return const Loading(loadingScreen: CircularProgressIndicator());
    } else {
      return const Next();
    }
  }

  @override
  Stream<bool> get stream => _loadingController.stream;
}

class MockPassThroughGuard extends ReactiveGuard<bool> {
  @override
  ReactiveGuardResult resolve(bool streamValue, String currentRoute) {
    return const Next();
  }

  @override
  Stream<bool> get stream => Stream.value(false);
}

class MockAuthGuard extends ReactiveGuard<bool> {
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
  Stream<bool> get stream => _authStatusController.stream;
}
