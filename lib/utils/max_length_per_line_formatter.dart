import 'package:flutter/services.dart';

class MaxLengthPerLineFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback onMaxLengthExceeded;

  MaxLengthPerLineFormatter(this.maxLength, this.onMaxLengthExceeded);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final texts = newValue.text.split('\n');
    final maxLengthExceeded = texts.any((text) => text.length > maxLength);


    if(maxLengthExceeded) {
      onMaxLengthExceeded();
      TextEditingValue newerValue = TextEditingValue(text: "${oldValue.text}\n${newValue.text[newValue.text.length - 1]}");

      return newerValue;
    }

    return newValue;
  }
}