# redux_persist [![pub package](https://img.shields.io/pub/v/redux_persist.svg)](https://pub.dartlang.org/packages/redux_persist)

Persist [Redux](https://pub.dartlang.org/packages/redux) state across app restarts in Flutter, Web, or custom storage engines.

Features:

* Save and load from multiple engine (Flutter, Web, custom)
* Fully type safe
* Transform state and raw on load/save
* Flutter integration (`PersistorGate`)
* Easy to use, integrate into your codebase in a few minutes!

Storage Engines:

* [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
* [Web](https://pub.dartlang.org/packages/redux_persist_web)
* File and custom (see below)

## Usage

See [Flutter example](https://github.com/Cretezy/redux_persist/tree/master/packages/redux_persist_flutter/example) for a full overview.

The library creates a middleware that saves on every action.
It also loads on initial load and sets a `LoadedAction` to your store.

### State Setup

You will need to use a state class, with a required `toJson` method, as such:

```dart
class AppState {
  final int counter;

  AppState({this.counter = 0});

  AppState copyWith({int counter}) =>
      AppState(counter: counter ?? this.counter);

  // !!!
  static AppState fromJson(dynamic json) => AppState(counter: json["counter"]);

  // !!!
  dynamic toJson() => {'counter': counter};
}
```

(the `copyWith` method is optional, but a great helper.
The `fromJson` is required as decoder, but can be renamed)

### Persistor

Next, create your persistor, storage engine,
and store, then load the last state in.
This will usually be in your `main` or in your root widget:

```dart
// Create Persistor
final persistor = Persistor<AppState>(
  storage: FlutterStorage("my-app"), // Or use other engines
  decoder: AppState.fromJson,
);

// Create Store with Persistor middleware
final store = Store<AppState>(
  reducer,
  initialState: AppState(),
  middleware: [persistor.createMiddleware()],
);

// Load state to store
persistor.start(store);
```

(the `key` param is used as a key of the save file name.
The `decoder` param takes in a `dynamic` type and outputs
an instance of your state class, see the above example)

### Load

In your reducer, you must add a handler for the
`PersistLoadedAction` action (with the generic type), like so:

```dart
class IncrementCounterAction {}

AppState reducer(state, action) {
  // !!!
  if (action is PersistLoadedAction<AppState>) {
    return action.state ?? state; // Use existing state if null
  }else if (action is IncrementCounterAction) {
    return state.copyWith(counter: state.counter + 1);
  }

  return state;
}
```

### Optional Actions

The persistor dispatches a few other actions based on it's lifecycle:

* `PersistLoadAction` is dispatched when the store is being loaded
* `PersistErrorAction` is dispatched when an error occurs on loading/saving

## Storage Engines

You can use different storage engines for different application types:

* [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
* [Web](https://pub.dartlang.org/packages/redux_persist_web)
* `FileStorage`:

  ```dart
  final persistor = Persistor<AppState>(
    // ...
    storage: FileStorage("path/to/state.json"),
  );
  ```

* Build your own custom storage engine:

  To create a custom engine, you will need to implement the following [interface](https://github.com/Cretezy/redux_persist/blob/master/packages/redux_persist/lib/src/storage.dart#L5)
  to save/load a string to disk:

  ```dart
  abstract class StorageEngine {
    external Future<void> save(String json);

    external Future<String> load();
  }
  ```

## Whitelist/Blacklist

To only save parts of your state,
simply omit the fields that you wish to not save
from your `toJson` and decoder (usually `fromJson`) methods.

For instance, if we have a state with `counter` and `name`,
but we don't want `counter` to be saved, you would do:

```dart
class AppState {
  final int counter;
  final String name;

  AppState({this.counter = 0, this.name});

  // ...

  static AppState fromJson(dynamic json) =>
      AppState(name: json["name"]); // Don't load counter, will use default of 0


  Map toJson() => {'name': name}; // Don't save counter
}
```

## Migrations

As your state grows, you will need new state versions.
You can version you state and apply migrations between state versions.

Versions are integers, starting at `0`.
You may use any integer as long as it is higher than the last version number.

Migrations are pure functions taking in a `dynamic` state,
and returning a transformed state (do not modify the original state passed).

```dart
final persistor = Persistor<State>(
  // ...
  version: 1,
  migrations: {
    // Renamed fields from "oldCounter" to "counter"
    0: (dynamic state) => {"counter": state["oldCounter"]},
    // "counter" is now a string
    1: (dynamic state) => {"counter": state["counter"].toString()                                                                       }
  },
);
```

## Transforms

All transformers are ran in order, from first to last.

Make sure all transformation are pure. Do not modify the original state passed.

### State

State transformations transform your _state_
before it's written to disk (on save) or loaded from disk (on load).

```dart
final persistor = Persistor<AppState>(
  // ...
  transforms: Transforms(
    onSave: [
      // Set counter to 3 when writing to disk
      (state) => state.copyWith(counter: 3),
    ],
    onLoad: [
      // Set counter to 0 when loading from disk
      (state) => state.copyWith(counter: 0),
    ],
  ),
);
```

### Raw

Raw transformation are applied to the raw text (JSON)
before it's written to disk (on save) or loaded from disk (on load).

```dart
final persistor = Persistor<AppState>(
  // ...
  rawTransforms: RawTransforms(
    onSave: [
      // Encrypt raw json
      (json) => encrypt(json),
    ],
    onLoad: [
      // Decrypt raw json
      (json) => decrypt(json),
    ],
  )
);
```

## Debug

`Persistor` has a `debug` option, which will eventually log more debug information.

Use it like so:

```dart
final persistor = Persistor<AppState>(
  // ...
  debug: true
);
```

### Errors

Middleware errors (save/load) are dispatched as `PersistErrorAction`
and broadcasted to `persistor.errorStream`(alongside `debug`).

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
