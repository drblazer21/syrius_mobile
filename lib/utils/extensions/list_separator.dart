extension ListSeparator<T> on List<T> {
  List<T> addSeparator(
    T separator, {
    bool addAfterLastItem = false,
    int skipCount = 1,
  }) {
    return expand(
      (item) sync* {
        yield separator;
        yield item;
        if (addAfterLastItem == true) {
          final bool isLastItem = indexOf(item) == length - 1;
          if (isLastItem) {
            yield separator;
          }
        }
      },
    ).skip(skipCount).toList();
  }
}
