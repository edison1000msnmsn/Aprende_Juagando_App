import { stableJson } from './learning.service';

describe('stableJson', () => {
  it('compara respuestas sin depender del orden de propiedades', () => {
    expect(stableJson({ value: 4, meta: { hint: true, level: 1 } }))
      .toBe(stableJson({ meta: { level: 1, hint: true }, value: 4 }));
  });

  it('distingue respuestas realmente diferentes', () => {
    expect(stableJson({ value: 4 })).not.toBe(stableJson({ value: 5 }));
  });
});
