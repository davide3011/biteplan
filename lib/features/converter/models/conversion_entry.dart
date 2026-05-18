class ConversionEntry {
  final String food;
  final String method;
  final double yieldFactor;

  const ConversionEntry({
    required this.food,
    required this.method,
    required this.yieldFactor,
  });

  double rawToCooked(double raw) => raw * yieldFactor;
  double cookedToRaw(double cooked) => cooked / yieldFactor;
}
