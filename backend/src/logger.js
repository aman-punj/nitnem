'use strict';

function log(level, message, data) {
  const entry = { ts: new Date().toISOString(), level, msg: message };
  if (data) entry.data = data;
  console.log(JSON.stringify(entry));
}

module.exports = {
  info: (msg, data) => log('info', msg, data),
  warn: (msg, data) => log('warn', msg, data),
  error: (msg, data) => log('error', msg, data),
};
