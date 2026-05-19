'use strict';

const logger = require('./logger');

const HUKAMNAMA_API_URL = 'https://dev-api.gurbaninow.com/v2/hukamnama/today';
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchHukamnama() {
  let lastError;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      logger.info(`Fetching Hukamnama from GurbaniNow (attempt ${attempt})`);

      const res = await fetch(HUKAMNAMA_API_URL, {
        headers: { Accept: 'application/json' },
        signal: AbortSignal.timeout(15_000),
      });

      if (!res.ok) {
        throw new Error(`GurbaniNow API responded with HTTP ${res.status}`);
      }

      const json = await res.json();
      return normalizeHukamnama(json);
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

function normalizeHukamnama(raw) {
  const { date, hukamnama } = raw ?? {};

  if (!date || !hukamnama) {
    throw new Error('Invalid API response: missing "date" or "hukamnama" fields');
  }

  // Build ISO date string from gregorian fields
  const greg = date.gregorian ?? {};
  const monthNo =
    typeof greg.month === 'object' ? greg.month?.no : greg.month;
  if (!greg.year || !monthNo || !greg.date) {
    throw new Error('Invalid API response: incomplete gregorian date fields');
  }
  const dateStr = [
    greg.year,
    String(monthNo).padStart(2, '0'),
    String(greg.date).padStart(2, '0'),
  ].join('-');

  const lines = Array.isArray(hukamnama.lines) ? hukamnama.lines : [];

  const gurmukhi = lines
    .map((l) => l?.line?.gurmukhi?.unicode ?? '')
    .filter(Boolean)
    .join(' ');

  if (!gurmukhi) {
    throw new Error('Validation failed: gurmukhi text is empty in API response');
  }

  const translationEnglish = lines
    .map((l) => {
      const en = l?.line?.translation?.en ?? {};
      return en.bdb || en.ssk || en.ms || '';
    })
    .filter(Boolean)
    .join(' ');

  const translationPunjabi = lines
    .map((l) => l?.line?.translation?.pu?.bdb?.unicode ?? '')
    .filter(Boolean)
    .join(' ');

  const src = hukamnama.source ?? {};
  const ang = hukamnama.ang;
  const source = [
    src.english || 'Sri Guru Granth Sahib Ji',
    ang ? `Ang ${ang}` : null,
    src.raagName?.EN ? `Raag ${src.raagName.EN}` : null,
  ]
    .filter(Boolean)
    .join(', ');

  return { date: dateStr, gurmukhi, translationEnglish, translationPunjabi, source };
}

module.exports = { fetchHukamnama };
