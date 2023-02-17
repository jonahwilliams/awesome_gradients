// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';

enum _ShaderTypes {
  hslLinear('packages/awesome_gradients/shaders/hsl_linear_gradient.frag'),
  hslRadial('packages/awesome_gradients/shaders/hsl_radial_gradient.frag');

  const _ShaderTypes(this.path);

  final String path;
}

class _ShaderEntry {
  Future<void>? pending;
  FragmentProgram? program;
}

class _GradientShaderManager {
  static final entries = <_ShaderTypes, _ShaderEntry>{
    _ShaderTypes.hslLinear: _ShaderEntry(),
    _ShaderTypes.hslRadial: _ShaderEntry(),
  };

  static Future<void> init() {
    var pending = <Future<void>>[];
    for (var entry in entries.entries) {
      if (entry.value.pending != null) {
        pending.add(entry.value.pending!);
      } else if (entry.value.program == null) {
        var future = FragmentProgram.fromAsset(entry.key.path).then((shader) {
          entry.value.program = shader;
          entry.value.pending = null;
        });
        entry.value.pending = future;
        pending.add(future);
      }
    }
    if (pending.isNotEmpty) {
      return Future.wait(pending);
    }
    return Future.value();
  }
}

Future<void> preloadShaders() {
  return _GradientShaderManager.init();
}

/// A linear gradient that interpolates its color in HSL space.
class HslLinearGradient implements Gradient {
  /// Create a new [HslLinearGradient].
  const HslLinearGradient(
    this.startColor,
    this.endColor, {
    this.tileMode = TileMode.clamp,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  /// The beginning color of the gradient.
  final Color startColor;

  /// The end color of the gradient.
  final Color endColor;

  /// How this gradient should tile the plane beyond in the region before
  /// [begin] and after [end].
  ///
  /// For details, see [TileMode].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
  final TileMode tileMode;

  /// The offset at which stop 0.0 of the gradient is placed.
  ///
  /// If this is an [Alignment], then it is expressed as a vector from
  /// coordinate (0.0, 0.0), in a coordinate space that maps the center of the
  /// paint box at (0.0, 0.0) and the bottom right at (1.0, 1.0).
  ///
  /// For example, a begin offset of (-1.0, 0.0) is half way down the
  /// left side of the box.
  ///
  /// It can also be an [AlignmentDirectional], where the start is the
  /// left in left-to-right contexts and the right in right-to-left contexts. If
  /// a text-direction-dependent value is provided here, then the [createShader]
  /// method will need to be given a [TextDirection].
  final AlignmentGeometry begin;

  /// The offset at which stop 1.0 of the gradient is placed.
  ///
  /// If this is an [Alignment], then it is expressed as a vector from
  /// coordinate (0.0, 0.0), in a coordinate space that maps the center of the
  /// paint box at (0.0, 0.0) and the bottom right at (1.0, 1.0).
  ///
  /// For example, a begin offset of (1.0, 0.0) is half way down the
  /// right side of the box.
  ///
  /// It can also be an [AlignmentDirectional], where the start is the left in
  /// left-to-right contexts and the right in right-to-left contexts. If a
  /// text-direction-dependent value is provided here, then the [createShader]
  /// method will need to be given a [TextDirection].
  final AlignmentGeometry end;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    var shader = _GradientShaderManager
        .entries[_ShaderTypes.hslLinear]!.program!
        .fragmentShader();
    var resolvedBegin = begin.resolve(textDirection).withinRect(rect);
    var resolvedEnd = end.resolve(textDirection).withinRect(rect);
    var startColorHSL = HSLColor.fromColor(startColor);
    var endColorHsl = HSLColor.fromColor(endColor);
    return shader
      ..setFloat(0, resolvedBegin.dx)
      ..setFloat(1, resolvedBegin.dy)
      ..setFloat(2, resolvedEnd.dx)
      ..setFloat(3, resolvedEnd.dy)
      ..setFloat(4, tileMode.index.toDouble())
      ..setFloat(5, startColorHSL.hue)
      ..setFloat(6, startColorHSL.saturation)
      ..setFloat(7, startColorHSL.lightness)
      ..setFloat(8, startColorHSL.alpha)
      ..setFloat(9, endColorHsl.hue)
      ..setFloat(10, endColorHsl.saturation)
      ..setFloat(11, endColorHsl.lightness)
      ..setFloat(12, endColorHsl.alpha);
  }

  @override
  List<Color> get colors => throw UnimplementedError();

  @override
  Gradient? lerpFrom(Gradient? a, double t) {
    throw UnimplementedError();
  }

  @override
  Gradient? lerpTo(Gradient? b, double t) {
    throw UnimplementedError();
  }

  @override
  Gradient scale(double factor) {
    throw UnimplementedError();
  }

  @override
  List<double>? get stops => null;

  @override
  GradientTransform? get transform => null;
}

/// A linear gradient that interpolates its color in HSL space.
class HslRadialGradient implements Gradient {
  /// Create a new [HslLinearGradient].
  const HslRadialGradient(this.startColor, this.endColor,
      {this.tileMode = TileMode.clamp,
      this.center = Alignment.center,
      this.radius = 0.5});

  /// The beginning color of the gradient.
  final Color startColor;

  /// The end color of the gradient.
  final Color endColor;

  /// How this gradient should tile the plane beyond in the region before
  /// [begin] and after [end].
  ///
  /// For details, see [TileMode].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_clamp_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_decal_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_mirror_linear.png)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/tile_mode_repeated_linear.png)
  final TileMode tileMode;

  /// The center of the gradient, as an offset into the (-1.0, -1.0) x (1.0, 1.0)
  /// square describing the gradient which will be mapped onto the paint box.
  ///
  /// For example, an alignment of (0.0, 0.0) will place the radial
  /// gradient in the center of the box.
  ///
  /// If this is an [Alignment], then it is expressed as a vector from
  /// coordinate (0.0, 0.0), in a coordinate space that maps the center of the
  /// paint box at (0.0, 0.0) and the bottom right at (1.0, 1.0).
  ///
  /// It can also be an [AlignmentDirectional], where the start is the left in
  /// left-to-right contexts and the right in right-to-left contexts. If a
  /// text-direction-dependent value is provided here, then the [createShader]
  /// method will need to be given a [TextDirection].
  final AlignmentGeometry center;

  /// The radius of the gradient, as a fraction of the shortest side
  /// of the paint box.
  ///
  /// For example, if a radial gradient is painted on a box that is
  /// 100.0 pixels wide and 200.0 pixels tall, then a radius of 1.0
  /// will place the 1.0 stop at 100.0 pixels from the [center].
  final double radius;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    var shader = _GradientShaderManager
        .entries[_ShaderTypes.hslRadial]!.program!
        .fragmentShader();

    var centerOffset = center.resolve(textDirection).withinRect(rect);
    var radiusValue = radius * rect.shortestSide;
    var startColorHSL = HSLColor.fromColor(startColor);
    var endColorHsl = HSLColor.fromColor(endColor);

    return shader
      ..setFloat(0, centerOffset.dx)
      ..setFloat(1, centerOffset.dy)
      ..setFloat(2, radiusValue)
      ..setFloat(3, tileMode.index.toDouble())
      ..setFloat(4, startColorHSL.hue)
      ..setFloat(5, startColorHSL.saturation)
      ..setFloat(6, startColorHSL.lightness)
      ..setFloat(7, startColorHSL.alpha)
      ..setFloat(8, endColorHsl.hue)
      ..setFloat(9, endColorHsl.saturation)
      ..setFloat(10, endColorHsl.lightness)
      ..setFloat(11, endColorHsl.alpha);
  }

  @override
  List<Color> get colors => throw UnimplementedError();

  @override
  Gradient? lerpFrom(Gradient? a, double t) {
    throw UnimplementedError();
  }

  @override
  Gradient? lerpTo(Gradient? b, double t) {
    throw UnimplementedError();
  }

  @override
  Gradient scale(double factor) {
    throw UnimplementedError();
  }

  @override
  List<double>? get stops => null;

  @override
  GradientTransform? get transform => null;
}
