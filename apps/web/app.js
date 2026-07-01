const MODULES = [
  { id: 'mathematics', name: 'Matemáticas', tagline: 'Números y formas', icon: '🔢', className: 'math', color: '#2878e8', progress: 72 },
  { id: 'letters', name: 'Letras', tagline: 'Palabras e historias', icon: '📚', className: 'letters', color: '#2e9f69', progress: 56 },
  { id: 'logic', name: 'Lógica', tagline: 'Patrones y memoria', icon: '🧩', className: 'logic', color: '#f06c27', progress: 34 },
  { id: 'art', name: 'Arte', tagline: 'Colores y creatividad', icon: '🎨', className: 'art', color: '#d9478d', progress: 45 }
];

const ACTIVITIES = {
  mathematics: [
    { type: 'count', instruction: '¿Cuántas manzanas hay?', hint: 'Puedes señalarlas una por una.', items: ['🍎','🍎','🍎','🍎'], options: [3,4,5,6], answer: 4, correct: '¡Exacto! Hay cuatro manzanas.', incorrect: 'Casi. Señala cada manzana y cuenta otra vez.' },
    { type: 'choice', instruction: '¿Qué número completa la serie?', hint: '2, 4, 6, ...', visual: '2　4　6　❓', options: [7,8,9,10], answer: 8, correct: '¡Muy bien! La serie avanza de dos en dos.', incorrect: 'Observa cuánto aumenta cada número.' }
  ],
  letters: [
    { type: 'letter', instruction: '¿Qué palabra empieza con M?', hint: 'Escucha el sonido “mmm”.', letter: 'M', options: ['🐸 Rana','🍎 Manzana','☀️ Sol','🦋 Mariposa'], answer: '🍎 Manzana', correct: '¡Manzana empieza con M!', incorrect: 'Di las palabras lentamente y escucha su primer sonido.' },
    { type: 'choice', instruction: 'Completa la palabra: C _ S A', hint: 'Es el lugar donde vives.', visual: '🏠  C _ S A', options: ['A','E','I','O'], answer: 'A', correct: '¡Eso es! La palabra es CASA.', incorrect: 'Pronuncia “casa” lentamente.' }
  ],
  logic: [
    { type: 'memory', instruction: 'Encuentra las cuatro parejas', hint: 'Recuerda dónde viste cada figura.', pairs: ['🌙','☀️','🌈','⭐'] }
  ],
  art: [
    { type: 'paint', instruction: 'Pinta la estrella de amarillo', hint: 'El amarillo brilla como el sol.', colors: [{name:'Rojo',value:'#ef5350'},{name:'Amarillo',value:'#ffd028'},{name:'Azul',value:'#3b82f6'},{name:'Verde',value:'#36a269'}], answer: '#ffd028', correct: '¡Una estrella brillante!', incorrect: 'Busca el color del sol.' }
  ]
};

const defaultState = { profile: 'Valentina', stars: 120, completed: 18, streak: 3, moduleProgress: Object.fromEntries(MODULES.map(module => [module.id, module.progress])), sound: true, motion: true };
let state = loadState();
let currentModule = 'mathematics';
let activityIndex = 0;
let nextFeedbackAction = null;
let memoryState = null;

function loadState() {
  try { return { ...defaultState, ...JSON.parse(localStorage.getItem('aj-state') || '{}') }; }
  catch { return { ...defaultState }; }
}
function saveState() { localStorage.setItem('aj-state', JSON.stringify(state)); }
function escapeHtml(value) { return String(value).replace(/[&<>'"]/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[char])); }

function renderApp() {
  document.querySelectorAll('[data-profile-name]').forEach(node => node.textContent = state.profile);
  document.querySelector('#profileButton').textContent = state.profile[0];
  document.querySelector('.profile-avatar').textContent = state.profile[0];
  document.querySelector('#streakCount').textContent = state.streak;
  document.querySelector('#starCount').textContent = state.stars;
  document.querySelector('#summaryStars').textContent = state.stars;
  document.querySelector('#summaryActivities').textContent = state.completed;
  renderModules();
  renderWorlds();
  renderProgress();
  syncToggles();
}

function renderModules() {
  document.querySelector('#moduleGrid').innerHTML = MODULES.map(module => `
    <button class="module-card ${module.className}" data-start="${module.id}" aria-label="Empezar ${module.name}, ${state.moduleProgress[module.id]} por ciento completado">
      <span class="module-icon" aria-hidden="true">${module.icon}</span>
      <h3>${module.name}</h3><p>${module.tagline}</p>
      <div class="mini-progress" aria-hidden="true"><span style="width:${state.moduleProgress[module.id]}%"></span></div>
      <div class="module-meta"><span>Nivel ${Math.max(1,Math.ceil(state.moduleProgress[module.id]/25))}</span><span>${state.moduleProgress[module.id]}%</span></div>
    </button>`).join('');
}

function renderWorlds() {
  document.querySelector('#worldList').innerHTML = MODULES.map(module => `
    <article class="world-card" style="--accent:${module.color}">
      <div class="world-icon" aria-hidden="true">${module.icon}</div>
      <div><span class="eyebrow purple">MUNDO ${MODULES.indexOf(module)+1}</span><h2>${module.name}</h2><p>${module.tagline}. Retos de 3 a 5 minutos.</p></div>
      <div class="world-stats"><strong>${state.moduleProgress[module.id]}% completado</strong><div><span style="width:${state.moduleProgress[module.id]}%"></span></div><button data-start="${module.id}">${state.moduleProgress[module.id] ? 'Continuar' : 'Empezar'}</button></div>
    </article>`).join('');
}

function renderProgress() {
  document.querySelector('#progressList').innerHTML = MODULES.map(module => `
    <div class="progress-row" style="--color:${module.color}"><strong>${module.icon} ${module.name}</strong><div><span style="width:${state.moduleProgress[module.id]}%"></span></div><b>${state.moduleProgress[module.id]}%</b></div>`).join('');
}

function navigate(route) {
  document.querySelectorAll('.screen').forEach(screen => screen.classList.toggle('active', screen.dataset.screen === route));
  document.querySelectorAll('.bottom-nav button').forEach(button => button.classList.toggle('active', button.dataset.route === route));
  document.querySelector('.bottom-nav').hidden = route === 'activity' || route === 'parent';
  window.scrollTo({ top: 0, behavior: state.motion ? 'smooth' : 'auto' });
  document.querySelector(`[data-screen="${route}"]`)?.focus({ preventScroll: true });
}

function startModule(moduleId) {
  currentModule = moduleId;
  activityIndex = 0;
  navigate('activity');
  renderActivity();
}

function renderActivity() {
  const activities = ACTIVITIES[currentModule];
  const activity = activities[activityIndex % activities.length];
  const progress = ((activityIndex + 1) / activities.length) * 100;
  document.querySelector('#activityProgress').style.width = `${progress}%`;
  document.querySelector('#coachText').textContent = activityIndex ? '¡Buen ritmo! Lee antes de elegir.' : 'Mira con calma. ¡Tú puedes!';
  const card = document.querySelector('#challengeCard');
  let interaction = '';
  if (activity.type === 'count') interaction = `<div class="visual-items" aria-label="${activity.items.length} manzanas">${activity.items.map(item => `<span>${item}</span>`).join('')}</div>${answers(activity.options)}`;
  if (activity.type === 'choice') interaction = `<div class="visual-items">${activity.visual}</div>${answers(activity.options)}`;
  if (activity.type === 'letter') interaction = `<div class="letter-visual" aria-label="Letra ${activity.letter}">${activity.letter}</div>${answers(activity.options)}`;
  if (activity.type === 'memory') interaction = renderMemory(activity);
  if (activity.type === 'paint') interaction = `<div class="paint-shape" id="paintShape" aria-label="Estrella para colorear"></div><div class="color-options" aria-label="Elige un color">${activity.colors.map(color => `<button class="color-option" style="--color:${color.value}" data-color="${color.value}" aria-label="${color.name}"></button>`).join('')}</div>`;
  card.innerHTML = `<span class="challenge-number">RETO ${activityIndex + 1} DE ${activities.length}</span><h1 id="activityTitle">${activity.instruction}</h1><p class="challenge-hint">${activity.hint}</p>${interaction}`;
}

function answers(options) { return `<div class="answer-grid">${options.map(option => `<button class="answer-button" data-answer="${escapeHtml(option)}">${escapeHtml(option)}</button>`).join('')}</div>`; }

function renderMemory(activity) {
  const cards = [...activity.pairs, ...activity.pairs].map((value, index) => ({ id: index, value, matched: false }));
  for (let i = cards.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [cards[i], cards[j]] = [cards[j], cards[i]]; }
  memoryState = { cards, open: [], locked: false, matches: 0 };
  return `<div class="memory-grid">${cards.map(card => `<button class="memory-card" data-card="${card.id}" aria-label="Carta oculta"></button>`).join('')}</div>`;
}

function handleAnswer(rawAnswer) {
  const activity = ACTIVITIES[currentModule][activityIndex % ACTIVITIES[currentModule].length];
  const expected = String(activity.answer);
  const correct = String(rawAnswer) === expected;
  showFeedback(correct, correct ? activity.correct : activity.incorrect, correct ? continueActivity : null);
}

function handleMemory(cardId, button) {
  if (!memoryState || memoryState.locked || button.classList.contains('matched') || button.classList.contains('revealed')) return;
  const card = memoryState.cards.find(item => item.id === Number(cardId));
  button.classList.add('revealed');
  button.textContent = card.value;
  button.setAttribute('aria-label', card.value);
  memoryState.open.push({ card, button });
  if (memoryState.open.length < 2) return;
  const [first, second] = memoryState.open;
  if (first.card.value === second.card.value) {
    first.button.classList.add('matched'); second.button.classList.add('matched');
    memoryState.matches += 1; memoryState.open = [];
    if (memoryState.matches === 4) setTimeout(() => showFeedback(true, '¡Memoria increíble! Encontraste todas las parejas.', continueActivity), 300);
    return;
  }
  memoryState.locked = true;
  setTimeout(() => {
    [first, second].forEach(item => { item.button.classList.remove('revealed'); item.button.textContent = ''; item.button.setAttribute('aria-label','Carta oculta'); });
    memoryState.open = []; memoryState.locked = false;
  }, 700);
}

function handlePaint(color) {
  document.querySelector('#paintShape').style.background = color;
  const activity = ACTIVITIES.art[activityIndex];
  setTimeout(() => showFeedback(color === activity.answer, color === activity.answer ? activity.correct : activity.incorrect, color === activity.answer ? continueActivity : null), 180);
}

function showFeedback(correct, message, action) {
  const dialog = document.querySelector('#feedbackDialog');
  document.querySelector('#feedbackIcon').textContent = correct ? '🌟' : '💡';
  document.querySelector('#feedbackTitle').textContent = correct ? '¡Lo lograste!' : 'Intentemos otra vez';
  document.querySelector('#feedbackText').textContent = message;
  document.querySelector('#feedbackContinue').textContent = correct ? 'Continuar' : 'Volver a intentar';
  nextFeedbackAction = action;
  dialog.showModal();
}

function continueActivity() {
  state.stars += 10; state.completed += 1;
  state.moduleProgress[currentModule] = Math.min(100, state.moduleProgress[currentModule] + 4);
  saveState(); renderApp();
  if (activityIndex + 1 >= ACTIVITIES[currentModule].length) {
    showToast('¡Aventura completada! Ganaste 10 estrellas.');
    navigate('home');
  } else { activityIndex += 1; renderActivity(); }
}

function showToast(message) {
  const toast = document.querySelector('#toast');
  toast.textContent = message; toast.classList.add('show');
  clearTimeout(showToast.timeout); showToast.timeout = setTimeout(() => toast.classList.remove('show'), 3000);
}

function syncToggles() {
  document.querySelector('#soundToggle .toggle').classList.toggle('on', state.sound);
  document.querySelector('#motionToggle .toggle').classList.toggle('on', state.motion);
  document.querySelector('#soundToggle .toggle').setAttribute('aria-label', state.sound ? 'Activado' : 'Desactivado');
  document.querySelector('#motionToggle .toggle').setAttribute('aria-label', state.motion ? 'Activado' : 'Desactivado');
}

document.addEventListener('click', event => {
  const routeButton = event.target.closest('[data-route]');
  if (routeButton) navigate(routeButton.dataset.route);
  const startButton = event.target.closest('[data-start]');
  if (startButton) startModule(startButton.dataset.start);
  const answerButton = event.target.closest('[data-answer]');
  if (answerButton) handleAnswer(answerButton.dataset.answer);
  const memoryButton = event.target.closest('[data-card]');
  if (memoryButton) handleMemory(memoryButton.dataset.card, memoryButton);
  const colorButton = event.target.closest('[data-color]');
  if (colorButton) handlePaint(colorButton.dataset.color);
  const profileOption = event.target.closest('[data-profile]');
  if (profileOption) { state.profile = profileOption.dataset.profile; saveState(); renderApp(); document.querySelector('#profileDialog').close(); showToast(`Perfil de ${state.profile} activo`); }
  if (event.target.closest('.dialog-close')) event.target.closest('dialog').close();
});

document.querySelector('#profileButton').addEventListener('click', () => document.querySelector('#profileDialog').showModal());
document.querySelector('#switchProfile').addEventListener('click', () => document.querySelector('#profileDialog').showModal());
document.querySelector('#soundToggle').addEventListener('click', () => { state.sound = !state.sound; saveState(); syncToggles(); showToast(state.sound ? 'Sonidos activados' : 'Sonidos desactivados'); });
document.querySelector('#motionToggle').addEventListener('click', () => { state.motion = !state.motion; saveState(); syncToggles(); document.documentElement.classList.toggle('reduce-motion', !state.motion); });
document.querySelector('#parentAccess').addEventListener('click', () => { document.querySelector('#gateAnswer').value = ''; document.querySelector('#gateError').textContent = ''; document.querySelector('#gateDialog').showModal(); });
document.querySelector('#gateSubmit').addEventListener('click', () => {
  if (document.querySelector('#gateAnswer').value.trim() === '13') { document.querySelector('#gateDialog').close(); navigate('parent'); }
  else document.querySelector('#gateError').textContent = 'Revisa la suma e inténtalo otra vez.';
});
document.querySelector('#feedbackContinue').addEventListener('click', () => {
  document.querySelector('#feedbackDialog').close();
  if (nextFeedbackAction) { const action = nextFeedbackAction; nextFeedbackAction = null; action(); }
});

renderApp();
if ('serviceWorker' in navigator) window.addEventListener('load', () => navigator.serviceWorker.register('/service-worker.js').catch(() => {}));
