const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

test('el contenido demo cumple el contrato y no repite IDs', () => {
  const result = spawnSync(process.execPath, [path.resolve('packages/content-schema/validate-content.js')], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Contenido válido/);
});

test('el servidor declara cabeceras de seguridad y tipos estáticos', () => {
  const source = require('node:fs').readFileSync(path.resolve('apps/web/server.js'), 'utf8');
  assert.match(source, /X-Content-Type-Options/);
  assert.match(source, /X-Frame-Options/);
  assert.match(source, /application\/manifest\+json/);
});
