#!/usr/bin/env node
'use strict';

/**
 * Manual trigger for the Hukamnama sync endpoint.
 *
 * Local (while `npm run dev` is running):
 *   node scripts/trigger-sync.js
 *
 * Against deployed Render backend:
 *   BACKEND_URL=https://your-app.onrender.com SYNC_API_KEY=your-key node scripts/trigger-sync.js
 */

const url = (process.env.BACKEND_URL ?? 'http://localhost:3000').replace(/\/$/, '');
const key = process.env.SYNC_API_KEY ?? '';

async function main() {
  console.log(`\nTriggering Hukamnama sync → ${url}/sync-hukamnama`);
  console.log('(waiting up to 3 min for Render cold start if needed…)\n');

  const res = await fetch(`${url}/sync-hukamnama`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(key && { 'x-api-key': key }),
    },
    signal: AbortSignal.timeout(180_000),
  });

  const data = await res.json();
  console.log('HTTP', res.status);
  console.log(JSON.stringify(data, null, 2));

  if (!res.ok || !data.success) {
    console.error('\nSync failed.');
    process.exit(1);
  }

  console.log('\nSync succeeded.');
  if (data.fcmAlreadySent) {
    console.log('FCM was already sent today — notification not re-sent (idempotent).');
  }
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
