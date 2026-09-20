// AppleUI Design Pro: corrected encoding of source-sampling offsets, no dependencies.
export function roundedRectSDF(x, y, halfWidth, halfHeight, radius) {
  if (![x, y, halfWidth, halfHeight, radius].every(Number.isFinite) ||
      halfWidth <= 0 || halfHeight <= 0) throw new RangeError('Invalid shape');
  const r = Math.max(0, Math.min(radius, halfWidth, halfHeight));
  const qx = Math.abs(x) - halfWidth + r;
  const qy = Math.abs(y) - halfHeight + r;
  return Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) + Math.min(Math.max(qx, qy), 0) - r;
}

export function smooth01(value) {
  if (!Number.isFinite(value)) throw new RangeError('Non-finite profile');
  const t = Math.max(0, Math.min(1, value));
  return t * t * (3 - 2 * t);
}

// offsets: [dx0, dy0, dx1, dy1, ...] in texture pixels.
// Return scale in logical pixels for an equivalently sized SVG filter coordinate system.
export function encodeDisplacement(offsets, density = 1) {
  if (offsets.length % 2 || !Number.isFinite(density) || density <= 0) {
    throw new RangeError('Expected xy pairs and positive pixel density');
  }
  let maximum = 0;
  for (const offset of offsets) {
    if (!Number.isFinite(offset)) throw new RangeError('Non-finite displacement');
    maximum = Math.max(maximum, Math.abs(offset));
  }
  const textureScale = 2 * maximum;
  if (!Number.isFinite(textureScale)) throw new RangeError('Displacement overflow');
  const data = new Uint8ClampedArray(offsets.length * 2);
  for (let i = 0; i < offsets.length; i += 2) {
    const pixel = i * 2;
    data[pixel] = textureScale ? Math.round(255 * (0.5 + offsets[i] / textureScale)) : 128;
    data[pixel + 1] = textureScale ? Math.round(255 * (0.5 + offsets[i + 1] / textureScale)) : 128;
    data[pixel + 2] = 0;
    data[pixel + 3] = 255;
  }
  return { data, scale: textureScale / density };
}
