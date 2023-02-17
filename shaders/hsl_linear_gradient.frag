#include <flutter/runtime_effect.glsl>
#include <tile_mode.glsl>

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

uniform vec2 start_offset;
uniform vec2 end_offset;
uniform float tile_mode;
uniform vec4 start_color;
uniform vec4 end_color;

out vec4 frag_color;

void main() {
  float len = length(end_offset - start_offset);
  float dot = dot(FlutterFragCoord() - start_offset, end_offset - start_offset);
  float t = dot / (len * len);

  vec4 hsl_color = ComputeWithTileMode(start_color, end_color, t, tile_mode);

  frag_color = HSLtoRGB(hsl_color);
}
