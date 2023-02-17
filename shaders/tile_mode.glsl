// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

const int kClamp = 0;
const int kRepeat = 1;
const int kMirror = 2;
const int kDecal = 3;

float ComputeTile(float t, float tile_mode) {
  if (tile_mode == kClamp) {
    t = clamp(t, 0.0, 1.0);
  } else if (tile_mode == kRepeat) {
    t = fract(t);
  } else if (tile_mode == kMirror) {
    float t1 = t - 1;
    float t2 = t1 - 2 * floor(t1 * 0.5) - 1;
    t = abs(t2);
  }
  return t;
}

// HSL encoding
// 0 - hue
// 1 - saturation
// 2 - lightness
// 3 - alpha (same as SRGB)
vec4 HSLtoRGB(vec4 hsl) {
  float alpha = hsl[3];
  float hue = hsl[0];
  float chroma = (1.0 - abs(2.0 * hsl[2] - 1.0)) * hsl[1];
  float secondary = chroma * (1.0 - abs((mod(hsl[0] / 60.0, 2.0)) - 1.0));
  float match = hsl[2] - chroma / 2.0;
  float red = 0.0;
  float green = 0.0;
  float blue = 0.0;
  if (hue < 60.0) {
    red = chroma;
    green = secondary;
    blue = 0.0;
  } else if (hue < 120.0) {
    red = secondary;
    green = chroma;
    blue = 0.0;
  } else if (hue < 180.0) {
    red = 0.0;
    green = chroma;
    blue = secondary;
  } else if (hue < 240.0) {
    red = 0.0;
    green = secondary;
    blue = chroma;
  } else if (hue < 300.0) {
    red = secondary;
    green = 0.0;
    blue = chroma;
  } else {
    red = chroma;
    green = 0.0;
    blue = secondary;
  }
  return vec4(red + match, green + match, blue + match, 1.0) * alpha;
}

vec4 ComputeWithTileMode(vec4 start, vec4 end, float t, float tile_mode) {
  if (tile_mode == kDecal && (t < 0 || t > 1.0)) {
    return vec4(0.0);
  }
  float nt = ComputeTile(t, tile_mode);
  return mix(start, end, nt);
}
