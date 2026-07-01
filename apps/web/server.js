const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const root = __dirname;
const port = Number(process.env.PORT || 4173);
const mime = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.webmanifest': 'application/manifest+json'
};

const server = http.createServer((request, response) => {
  const requestPath = decodeURIComponent(new URL(request.url, `http://${request.headers.host}`).pathname);
  const normalized = path.normalize(requestPath).replace(/^(\.\.[/\\])+/, '');
  let filePath = path.join(root, normalized === '/' ? 'index.html' : normalized);
  if (!filePath.startsWith(root)) {
    response.writeHead(403).end('Forbidden');
    return;
  }
  fs.stat(filePath, (statError, stat) => {
    if (!statError && stat.isDirectory()) filePath = path.join(filePath, 'index.html');
    fs.readFile(filePath, (error, data) => {
      if (error) {
        fs.readFile(path.join(root, 'index.html'), (fallbackError, fallback) => {
          response.writeHead(fallbackError ? 404 : 200, { 'Content-Type': fallbackError ? 'text/plain' : mime['.html'] });
          response.end(fallbackError ? 'Not found' : fallback);
        });
        return;
      }
      response.writeHead(200, {
        'Content-Type': mime[path.extname(filePath)] || 'application/octet-stream',
        'Cache-Control': filePath.endsWith('service-worker.js') ? 'no-cache' : 'public, max-age=300',
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'Referrer-Policy': 'no-referrer'
      });
      response.end(data);
    });
  });
});

server.listen(port, '127.0.0.1', () => console.log(`AprendeJugando: http://127.0.0.1:${port}`));
