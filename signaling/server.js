const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });
const rooms = {};

wss.on('connection', (ws, req) => {
  const url   = new URL(req.url, 'http://localhost');
  const room  = url.searchParams.get('room') || 'default';
  const role  = url.searchParams.get('role') || 'unknown';

  if (!rooms[room]) rooms[room] = new Set();
  rooms[room].add(ws);
  ws._role = role;
  console.log(`[+] ${role} joined room "${room}" — peers: ${rooms[room].size}`);

  // Tell everyone a new peer joined
  rooms[room].forEach(client => {
    if (client !== ws && client.readyState === 1) {
      client.send(JSON.stringify({ type: 'peer_joined', role }));
    }
  });

  ws.on('message', raw => {
    // Relay to all other peers in same room
    rooms[room].forEach(client => {
      if (client !== ws && client.readyState === 1) {
        client.send(raw.toString());
      }
    });
  });

  ws.on('close', () => {
    rooms[room]?.delete(ws);
    console.log(`[-] ${role} left room "${room}"`);
    rooms[room]?.forEach(client => {
      if (client.readyState === 1)
        client.send(JSON.stringify({ type: 'peer_left', role }));
    });
    if (rooms[room]?.size === 0) delete rooms[room];
  });

  ws.on('error', e => console.error('WS error:', e.message));
});

console.log('✅ Signaling server ready → ws://localhost:8080');