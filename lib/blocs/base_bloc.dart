import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBloc<T> {
  final BehaviorSubject<T> _controller = BehaviorSubject();

  StreamSink<T> get _sink => _controller.sink;
  T? get lastValue => _controller.valueOrNull;
  Stream<T> get stream => _controller.stream;

  void addEvent(T event) {
    if (!_controller.isClosed) _sink.add(event);
  }

  void addError(Object error) {
    if (!_controller.isClosed) {
      Logger('BaseBloc').log(Level.INFO, error.toString(), error,);
      _sink.addError(error);
    }
  }

  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
