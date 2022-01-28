## Reactive guards for flutter Navigator 2.0. 

When your state changes, your url state might need to change too. 

The typical example is when the user signs out, he should be redirected to the login page. 

## Features

 - Reactive guards

## Usage

### 1. Create your reactive guards:

Create your reactive guard that expose a `stream` that will be listened to in order to resolve the new route.
All your guards `resolve` method will be called in sequence. This resolve method can return 3 possible values:

  - Redirect => redirects to a new route, subsequent guards `resolve` won't be called
  - Loading => displays a loading page, subsequent guards won't be called
  - Next => go to next guard `resolve` or if no subsequent guards, stay on current page.

```dart
class ExampleAuthGuard extends ReactiveGuard<bool> {

  @override
  ReactiveGuardResult resolve(bool streamValue, String currentRoute) {

    if (streamValue == true) {
      if (currentRoute == '/login') {
        return const Redirect(target: '/login');
      } else {
        return const Next();
      }
    } else {
      if (currentRoute == '/login') {
        return const Next();
      } else {
        return const Redirect(target: '/login');
      }
    }
  }

  // replace MyAuthService with your own in house service
  @override
  Stream<bool> get stream => MyAuthService.authenticatedStream;
}
```

### 2. add the `ReactiveGuardDispatcher`

```dart
// in case you are using beamer
MaterialApp.router(
  routeInformationParser: BeamerParser(), 
  routerDelegate: routerDelegate,
  builder: (ctx, child) => ReactiveGuardDispatcher(
    child: child ?? Container(),
    guards: [authGuard],
    onRedirectRequest: (req) => Beamer.of(ctx).beamToNamed(req.target),
  ),
),
```


