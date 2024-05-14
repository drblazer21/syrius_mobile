enum AppCurrency {
  usd;

  String get symbol {
    switch (this) {
      case usd:
        return '\$';
    }
  }
}
