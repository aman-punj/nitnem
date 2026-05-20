'use strict';

const logger = require('./logger');

const HUKAMNAMA_URL = 'https://hukamnama.khalsa.tech/';
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchHukamnama() {
  let lastError;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      logger.info(`Fetching Hukamnama from khalsa.tech (attempt ${attempt})`);

      const res = await fetch(HUKAMNAMA_URL, {
        headers: { Accept: 'text/html' },
        signal: AbortSignal.timeout(15_000),
      });

      if (!res.ok) {
        throw new Error(`khalsa.tech responded with HTTP ${res.status}`);
      }

      const html = await res.text();
      return parseHukamnamaHtml(html);
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

function stripTags(html) {
  return html.replace(/<[^>]+>/g, '').trim();
}

function parseHukamnamaHtml(html) {
  // Extract <main id="hukamnama">...</main>
  const mainMatch = html.match(/<main[^>]*id="hukamnama"[^>]*>([\s\S]*?)<\/main>/i);
  if (!mainMatch) {
    throw new Error('Validation failed: <main id="hukamnama"> not found in response');
  }
  const mainContent = mainMatch[1];

  // First <h3> is the raag / shabad header
  const h3Match = mainContent.match(/<h3>([\s\S]*?)<\/h3>/i);
  const raagLine = h3Match ? stripTags(h3Match[1]) : '';

  // All <div> elements are the shabad lines
  const divMatches = [...mainContent.matchAll(/<div>([\s\S]*?)<\/div>/gi)];
  const lines = divMatches.map((m) => stripTags(m[1])).filter(Boolean);

  if (lines.length === 0) {
    throw new Error('Validation failed: no shabad lines found in response');
  }

  // Combine raag header + shabad lines
  const gurmukhi = [raagLine, ...lines].filter(Boolean).join('\n');

  const source = raagLine
    ? `Sri Darbar Sahib, Amritsar — ${raagLine}`
    : 'Sri Darbar Sahib, Amritsar';

  // This endpoint always returns today's Hukamnama
  const now = new Date();
  const date = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, '0'),
    String(now.getDate()).padStart(2, '0'),
  ].join('-');

  return {
    date,
    gurmukhi,
    translationEnglish: '',
    translationPunjabi: '',
    source,
  };
}

module.exports = { fetchHukamnama };
