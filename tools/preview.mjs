import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const buildFolder = process.env.MARING_PREVIEW_APP === 'true' ? 'web-app' : 'web';
const root = resolve(fileURLToPath(new URL(`../maring-frontend/build/${buildFolder}/`, import.meta.url)));
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.json': 'application/json', '.png': 'image/png', '.wasm': 'application/wasm', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.css': 'text/css', '.svg': 'image/svg+xml' };
const port = Number(process.env.MARING_PREVIEW_PORT || 5173);
createServer(async (request, response) => {
  try {
    const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    let target = resolve(root, '.' + pathname);
    if (target !== root && !target.startsWith(root + sep)) {
      response.writeHead(403).end(); return;
    }
    if ((await stat(target)).isDirectory()) target = resolve(target, 'index.html');
    const body = await readFile(target);
    response.writeHead(200, { 'Content-Type': types[extname(target)] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    response.end(body);
  } catch {
    response.writeHead(404).end('Not found');
  }
}).listen(port, '127.0.0.1', () => console.log(`Maring preview: http://127.0.0.1:${port}`));
