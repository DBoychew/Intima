import 'package:flutter/foundation.dart';

/// Бръмва при всеки запис в базата — екрани с производни данни
/// (инсайтите) се преизчисляват сами, без ръчен refresh.
final ValueNotifier<int> dataVersion = ValueNotifier(0);

void bumpDataVersion() => dataVersion.value++;
