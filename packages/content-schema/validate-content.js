const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '../..');
const contentRoot = path.join(root, 'content');
const modules = { mathematics: 'MATHEMATICS', letters: 'LETTERS', logic: 'LOGIC', art: 'ART' };
const types = new Set(['multiple_choice', 'visual_count', 'memory_pairs', 'paint_shape', 'pattern_completion', 'image_word_match']);
const ids = new Set();
const errors = [];

for (const [folder, moduleName] of Object.entries(modules)) {
  const files = fs.readdirSync(path.join(contentRoot, folder)).filter(file => file.endsWith('.json')).sort();
  let previousLevel = 0;
  for (const file of files) {
    const location = path.join(contentRoot, folder, file);
    let level;
    try { level = JSON.parse(fs.readFileSync(location, 'utf8')); }
    catch (error) { errors.push(`${folder}/${file}: JSON inválido (${error.message})`); continue; }
    check(level.schemaVersion === 1, location, 'schemaVersion debe ser 1');
    check(level.module === moduleName, location, `module debe ser ${moduleName}`);
    check(Number.isInteger(level.levelNumber) && level.levelNumber > previousLevel, location, 'levelNumber debe ser entero, positivo y estar ordenado');
    previousLevel = level.levelNumber;
    checkId(level.id, location);
    check(['DRAFT','REVIEW','PUBLISHED','ARCHIVED'].includes(level.status), location, 'status editorial inválido');
    check(typeof level.title === 'string' && level.title.trim().length >= 3, location, 'title es obligatorio');
    check(Array.isArray(level.activities) && level.activities.length > 0, location, 'activities no puede estar vacío');
    for (const activity of level.activities || []) validateActivity(activity, location);
  }
}

function validateActivity(activity, location) {
  checkId(activity.id, location);
  check(types.has(activity.type), location, `tipo no soportado: ${activity.type}`);
  check(typeof activity.instruction === 'string' && activity.instruction.trim().length >= 5, location, `${activity.id}: instruction es obligatoria`);
  check(activity.answer && typeof activity.answer === 'object', location, `${activity.id}: answer es obligatorio`);
  check(activity.feedback?.correct && activity.feedback?.incorrect, location, `${activity.id}: feedback completo es obligatorio`);
  check(Number.isFinite(activity.reward?.xp) && Number.isFinite(activity.reward?.stars), location, `${activity.id}: reward inválido`);
  check(typeof activity.accessibility?.spokenInstruction === 'boolean', location, `${activity.id}: accessibility.spokenInstruction es obligatorio`);
}
function checkId(id, location) {
  check(typeof id === 'string' && id.length > 0, location, 'id es obligatorio');
  if (ids.has(id)) errors.push(`${relative(location)}: id duplicado ${id}`);
  ids.add(id);
}
function check(condition, location, message) { if (!condition) errors.push(`${relative(location)}: ${message}`); }
function relative(location) { return path.relative(root, location).replaceAll('\\', '/'); }

if (errors.length) { console.error(errors.map(error => `- ${error}`).join('\n')); process.exit(1); }
console.log(`Contenido válido: ${ids.size} IDs únicos en ${Object.keys(modules).length} módulos.`);

module.exports = { types };
