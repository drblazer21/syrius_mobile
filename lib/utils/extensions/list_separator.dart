extension ListSeparator<T> on List<T> {
  List<T> addSeparator(T separator) {
    return expand(
      (item) sync* {
        yield separator;
        yield item;
      },
    ).skip(1).toList();
  }
}
