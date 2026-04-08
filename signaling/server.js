const http      = require('http');
const WebSocket = require('ws');

const PORT = process.env.PORT || 8080;

// ── HTTP server (Render/Railway need HTTP for health checks) ───────
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', rooms: Object.keys(rooms).length }));
    return;
  }
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('SmartCam Signaling Server running ✅');
});

// ── WebSocket server attached to same HTTP server ─────────────────
const wss  = new WebSocket.Server({ server });
const rooms = {};

wss.on('connection', (ws, req) => {
  const url  = new URL(req.url, `http://localhost`);
  const room = url.searchParams.get('room') || 'default';
  const role = url.searchParams.get('role') || 'unknown';

  if (!rooms[room]) rooms[room] = new Set();
  rooms[room].add(ws);
  ws._room = room;
  ws._role = role;

  console.log(`[+] ${role} joined room "${room}" — peers: ${rooms[room].size}`);

  // Notify existing peers that someone new joined
  rooms[room].forEach(client => {
    if (client !== ws && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({ type: 'peer_joined', role }));
    }
  });

  // Relay all messages to every other peer in the same room
  ws.on('message', raw => {
    rooms[room]?.forEach(client => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(raw.toString());
      }
    });
  });

  ws.on('close', () => {
    rooms[room]?.delete(ws);
    console.log(`[-] ${role} left room "${room}"`);
    rooms[room]?.forEach(client => {
      if (client.readyState === WebSocket.OPEN)
        client.send(JSON.stringify({ type: 'peer_left', role }));
    });
    if (rooms[room]?.size === 0) delete rooms[room];
  });

  ws.on('error', e => console.error('[WS error]', e.message));
});

server.listen(PORT, () => {
  console.log(`✅ SmartCam signaling server running on port ${PORT}`);
  console.log(`   HTTP health → http://localhost:${PORT}/health`);
  console.log(`   WebSocket   → ws://localhost:${PORT}?room=cam_001&role=broadcaster`);
});
