class CredentialType {
  final String name;
  final List<Field> fields;

  CredentialType({
    required this.name,
    required this.fields,
  });
}

class Field {
  final String name;
  final Range? range;

  Field({
    required this.name,
    this.range,
  });
}

class Range {
  final String operator;
  final dynamic value;

  Range({
    required this.operator,
    required this.value,
  });
}
