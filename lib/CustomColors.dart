import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color abc;

  const CustomColors({required this.abc});

  @override
  CustomColors copyWith({Color? abc}) {
    return CustomColors(
      abc: abc ?? this.abc,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      abc: Color.lerp(abc, other.abc, t)!,
    );
  }
}
