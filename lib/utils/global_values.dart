import 'dart:io';

import 'package:flutter/material.dart';

class GlobalValues {
  static ValueNotifier<File?> userImage = ValueNotifier<File?>(null);

  static ValueNotifier updateList = ValueNotifier(false);
  static ValueNotifier mountCart = ValueNotifier(0);
}
