String? isValueRequired(String? value) {
  if (value == null || value.isEmpty) {
    return 'Given field is required!';
  }

  return null;
}
