import express from 'express';
import path from 'node:path';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const app = express();
const port = process.env.PORT || 3000;
const publicDir = path.join(path.dirname(fileURLToPath(import.meta.url)), 'public');

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/api/message', (req, res) => {
  res.json({ message: 'Bonjour depuis le backend :)' });
});

if (existsSync(publicDir)) {
  app.use(express.static(publicDir));
  app.use((req, res) => {
    res.sendFile(path.join(publicDir, 'index.html'));
  });
}

app.listen(port, () => {
  console.log(`backend listen to http://localhost:${port}`);
});
