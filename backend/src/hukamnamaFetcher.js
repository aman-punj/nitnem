'use strict';

const logger = require('./logger');

const MONTHS = [
  'january', 'february', 'march', 'april', 'may', 'june',
  'july', 'august', 'september', 'october', 'november', 'december',
];

const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchHukamnama() {
  const now = new Date();
  const url = `https://sgpc.net/${now.getDate()}-${MONTHS[now.getMonth()]}-${now.getFullYear()}/`;

  let lastError;
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      logger.info(`Fetching Hukamnama from sgpc.net (attempt ${attempt})`, { url });

      const res = await fetch(url, {
        headers: {
          'User-Agent':
            'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 ' +
            '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          Accept:
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,pa;q=0.9,en;q=0.8',
        },
        signal: AbortSignal.timeout(15_000),
      });

      if (!res.ok) throw new Error(`sgpc.net responded with HTTP ${res.status}`);

      const html = await res.text();
      const data = parseHukamnamaHtml(html);
      logger.info('Parsed Hukamnama from sgpc.net', {
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

// ── HTML helpers ─────────────────────────────────────────────────────────────

function stripHtml(html) {
  return html
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<[^>]+>/g, '')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&nbsp;/g, ' ')
    .replace(/&#8211;/g, '–')
    .replace(/&#8217;/g, "'")
    .replace(/&#038;/g, '&')
    .trim();
}

function isDateLine(text) {
  return (
    /\b(January|February|March|April|May|June|July|August|September|October|November|December)\b/i.test(
      text
    ) && /\d{4}/.test(text)
  );
}

function parseHukamnamaHtml(html) {
  // SGPC wraps the shabad in <article class="small single">
  const articleStart = html.indexOf('<article class="small single">');
  const articleEnd = html.lastIndexOf('</article>');
  if (articleStart === -1 || articleEnd === -1) {
    throw new Error('Validation failed: <article class="small single"> not found');
  }
  const articleHtml = html.slice(articleStart, articleEnd);

  // Collect all <p> text blocks
  const pRegex = /<p[^>]*>([\s\S]*?)<\/p>/gi;
  const paragraphs = [];
  let match;
  while ((match = pRegex.exec(articleHtml)) !== null) {
    const text = stripHtml(match[1]).trim();
    if (text) paragraphs.push(text);
  }

  if (paragraphs.length === 0) {
    throw new Error('Validation failed: no paragraphs found in article');
  }

  let gurmukhi = '';
  let translationPunjabi = '';
  const englishParts = [];
  let inEnglish = false;

  for (const p of paragraphs) {
    if (p.startsWith('ਪੰਜਾਬੀ ਵਿਆਖਿਆ:')) {
      translationPunjabi = p.replace('ਪੰਜਾਬੀ ਵਿਆਖਿਆ:', '').trim();
      inEnglish = false;
    } else if (p.includes('English Translation')) {
      inEnglish = true;
    } else if (inEnglish) {
      if (!isDateLine(p)) englishParts.push(p);
    } else if (!gurmukhi) {
      gurmukhi = p;
    }
  }

  if (!gurmukhi) throw new Error('Validation failed: no Gurmukhi text found');

  const sourceLine = gurmukhi.split('\n')[0]?.trim() ?? '';
  const source = sourceLine
    ? `Sri Darbar Sahib, Amritsar — ${sourceLine}`
    : 'Sri Darbar Sahib, Amritsar';

  const now = new Date();
  const date = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, '0'),
    String(now.getDate()).padStart(2, '0'),
  ].join('-');

  return {
    date,
    gurmukhi,
    translationEnglish: englishParts.join('\n\n'),
    translationPunjabi,
    source,
  };
}

module.exports = { fetchHukamnama };
