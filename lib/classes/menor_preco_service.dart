class MenorPrecoService {
  static const String base32Alphabet = "0123456789bcdefghjkmnpqrstuvwxyz";
  static const List<int> bitMasks = [16, 8, 4, 2, 1];
  static const double minRange = -100;
  static const double maxRange = 100;
  static const int outputLength = 12;

  static String getLocationHash(List<double> values) {
    String output = "";
    int currentCharValue = 0;
    int bitIndex = 0;
    int iteration = 0;
    final ranges = values.map((v) => [minRange, maxRange]).toList();

    while (output.length < outputLength) {
      int valueIndex = iteration % values.length;
      iteration++;

      List<double> range = ranges[valueIndex];
      double value = values[valueIndex];
      double midpoint = (range[0] + range[1]) / 2;

      if (value > midpoint) {
        currentCharValue |= bitMasks[bitIndex];
        range[0] = midpoint;
      } else {
        range[1] = midpoint;
      }

      if (bitIndex == 4) {
        output += base32Alphabet[currentCharValue];
        currentCharValue = 0;
        bitIndex = 0;
      } else {
        bitIndex++;
      }
    }

    return output;
  }
}

// 6gs3687kzupu
