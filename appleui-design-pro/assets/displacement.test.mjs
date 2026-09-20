import assert from 'node:assert/strict';
import { roundedRectSDF, smooth01, encodeDisplacement } from './displacement.mjs';

assert(roundedRectSDF(0, 0, 50, 30, 10) < 0);
assert.equal(roundedRectSDF(50, 0, 50, 30, 10), 0);
assert(roundedRectSDF(60, 0, 50, 30, 10) > 0);
assert.equal(roundedRectSDF(-45, 20, 50, 30, 10), roundedRectSDF(45, -20, 50, 30, 10));
assert.equal(smooth01(-1), 0);
assert.equal(smooth01(2), 1);
assert.equal(smooth01(0.5), 0.5);
const identity = encodeDisplacement([0, 0, 0, 0]);
assert.equal(identity.scale, 0);
assert.deepEqual([...identity.data], [128, 128, 0, 255, 128, 128, 0, 255]);

const offsets = [-20, 20, -5, 3, 0, 0, 15, -12];
for (const density of [1, 2, 3]) {
  const { data, scale } = encodeDisplacement(offsets, density);
  for (let i = 0; i < offsets.length; i += 2) {
    for (let channel = 0; channel < 2; channel++) {
      const decoded = scale * (data[i * 2 + channel] / 255 - 0.5);
      assert(Math.abs(decoded - offsets[i + channel] / density) <= scale / 510 + 1e-12);
    }
  }
  assert.equal(data[0], 0);
  assert.equal(data[1], 255);
}
assert.throws(() => encodeDisplacement([1]), RangeError);
assert.throws(() => encodeDisplacement([NaN, 0]), RangeError);
assert.throws(() => encodeDisplacement([0, 0], 0), RangeError);
assert.throws(() => roundedRectSDF(0, 0, 0, 3, 1), RangeError);
console.log('Passed: SDF geometry, smooth profile, identity, signed offset roundtrip, density, validation.');
