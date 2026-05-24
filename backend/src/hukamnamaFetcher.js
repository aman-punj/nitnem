'use strict';

const logger = require('./logger');

const API_URL = 'https://api.gurbaninow.com/v2/hukamnama/today';
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchHukamnama() {
  let lastError;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      logger.info(`Fetching Hukamnama from GurbaniNow API (attempt ${attempt})`);

      const res = await fetch(API_URL, {
        headers: { Accept: 'application/json' },
        signal: AbortSignal.timeout(15_000),
      });

      if (!res.ok) throw new Error(`API responded with HTTP ${res.status}`);

      const json = await res.json();
      if (json.error) throw new Error('API returned error flag');

      const data = parseResponse(json);
      logger.info('Parsed Hukamnama from GurbaniNow API', {
        date: data.date,
        gurmukhiLines: data.gurmukhi.split('\n').length,
        hasEnglish: data.translationEnglish.length > 0,
        hasPunjabi: data.translationPunjabi.length > 0,
      });
      return data;
    } catch (err) {
      lastError = err;
      logger.warn(`Fetch attempt ${attempt} failed`, { error: err.message });
      if (attempt < MAX_RETRIES) await sleep(RETRY_DELAY_MS * attempt);
    }
  }

  throw new Error(
    `Failed to fetch Hukamnama after ${MAX_RETRIES} attempts: ${lastError?.message}`
  );
}

function parseResponse(json) {
  const lines = json.hukamnama ?? [];
  if (lines.length === 0) throw new Error('Validation failed: no lines in response');

  const gurmukhiLines = [];
  const englishLines = [];
  const punjabiLines = [];

  for (const entry of lines) {
    const line = entry.line;
    if (!line) continue;

    const gurmukhi = line.gurmukhi?.unicode?.trim();
    if (gurmukhi) gurmukhiLines.push(gurmukhi);

    const english = line.translation?.english?.default?.trim();
    if (english) englishLines.push(english);

    const punjabi = line.translation?.punjabi?.default?.unicode?.trim();
    if (punjabi) punjabiLines.push(punjabi);
  }

  if (gurmukhiLines.length === 0) throw new Error('Validation failed: no Gurmukhi text found');

  const info = json.hukamnamainfo ?? {};
  const pageno = info.pageno ?? '';
  const source = pageno
    ? `Sri Darbar Sahib, Amritsar — Ang ${pageno}`
    : 'Sri Darbar Sahib, Amritsar';

  const now = new Date();
  const date = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, '0'),
    String(now.getDate()).padStart(2, '0'),
  ].join('-');

  return {
    date,
    gurmukhi: gurmukhiLines.join('\n'),
    translationEnglish: englishLines.join('\n'),
    translationPunjabi: punjabiLines.join('\n'),
    source,
  };
}

module.exports = { fetchHukamnama };
