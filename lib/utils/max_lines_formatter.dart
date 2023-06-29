import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

/// Credits to: https://www.youtube.com/watch?v=FxmlU5NnRX8
/// https://github.com/JohannesMilke/textfield_maxlength_example/blob/master/

class MaxLinesTextInputFormatter extends TextInputFormatter {
  final int maxLines;
  final VoidCallback onLinesExceeded;


  MaxLinesTextInputFormatter(this.maxLines, this.onLinesExceeded);


  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
                                    TextEditingValue newValue) {
    int numberOfCharacters = ((newValue.text).length);
    numberOfCharacters += '\n'.allMatches(newValue.text).length * 38;
    print(numberOfCharacters);
    int newLineCount = (numberOfCharacters / 38).ceil();

    if(newLineCount > maxLines) {
      print("NO");

      onLinesExceeded();

      return oldValue;
    }

    return newValue;
  }
}