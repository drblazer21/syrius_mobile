import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stacked/stacked.dart';

abstract class BaseBloc<T> extends BaseViewModel {
  final BehaviorSubject<T> _controller = BehaviorSubject();

  StreamSink<T?> get _sink => _controller.sink;
  T? get lastValue => _controller.valueOrNull;
  Stream<T> get stream => _controller.stream;

  void addEvent(T event) {
    if (!_controller.isClosed) _sink.add(event);
  }

  void addError(Object error) {
    if (!_controller.isClosed) {
      Logger('BaseBloc').log(Level.INFO, 'addError', error.toString());
      _sink.addError(error);
    }
  }

  @override
  void dispose() {
    _controller.close();
    if (!super.disposed) {
      super.dispose();
    }
  }
}
