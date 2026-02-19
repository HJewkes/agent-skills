#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import markdownit from 'markdown-it';
import anchor from 'markdown-it-anchor';
import tocPlugin from 'markdown-it-toc-done-right';
import hljs from 'highlight.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SKILL_DIR = resolve(__dirname, '..');

function loadConfig(configPath) {
  const defaults = JSON.parse(readFileSync(resolve(SKILL_DIR, 'defaults/config.json'), 'utf8'));
  if (!configPath) return defaults;
  try {
    const user = JSON.parse(readFileSync(configPath, 'utf8'));
    return {
      theme: { ...defaults.theme, ...user.theme },
      features: { ...defaults.features, ...user.features },
    };
  } catch {
    return defaults;
  }
}

function buildCssVars(theme) {
  return Object.entries(theme)
    .map(([key, value]) => `--${key.replace(/[A-Z]/g, c => '-' + c.toLowerCase())}: ${value};`)
    .join('\n    ');
}

function render(markdown, config) {
  const md = markdownit({
    html: true,
    linkify: true,
    typographer: false,
    highlight: (str, lang) => {
        if (lang === 'mermaid' && config.features.mermaid) {
          return `<div class="mermaid">${str}</div>`;
        }
        if (config.features.syntaxHighlight && lang && hljs.getLanguage(lang)) {
          try {
            return hljs.highlight(str, { language: lang }).value;
          } catch { /* fall through */ }
        }
        return '';
      },
  });

  if (config.features.headingAnchors) {
    md.use(anchor, {
      permalink: anchor.permalink.linkInsideHeader({
        symbol: '#',
        class: 'heading-anchor',
        ariaHidden: true,
      }),
      slugify: s => s.trim().toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]/g, ''),
    });
  }

  let tocHtml = '';
  if (config.features.toc) {
    md.use(tocPlugin, {
      containerClass: 'toc',
      listType: 'ul',
      callback: (html) => { tocHtml = html; },
    });
    markdown = '${toc}\n\n' + markdown;
  }

  let contentHtml = md.render(markdown);

  if (config.features.mermaid) {
    contentHtml = contentHtml.replace(
      /<pre><code[^>]*><div class="mermaid">([\s\S]*?)<\/div>\s*<\/code><\/pre>/g,
      '<pre class="mermaid">$1</pre>'
    );
  }

  const titleMatch = markdown.match(/^#\s+(.+)$/m);
  const title = titleMatch ? titleMatch[1] : 'Markdown Preview';

  return { contentHtml, tocHtml, title };
}

function main() {
  const configPath = process.argv[2] || null;

  const markdown = readFileSync('/dev/stdin', 'utf8');

  const config = loadConfig(configPath);
  const { contentHtml, tocHtml, title } = render(markdown, config);
  const cssVars = buildCssVars(config.theme);

  const template = readFileSync(resolve(SKILL_DIR, 'templates/page.html'), 'utf8');

  const mermaidScript = config.features.mermaid
    ? '<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>\n  <script>mermaid.initialize({ startOnLoad: true, theme: "dark" });</script>'
    : '';

  const html = template
    .replace('{{title}}', title)
    .replace('{{css-vars}}', cssVars)
    .replace('{{toc}}', tocHtml)
    .replace('{{content}}', contentHtml)
    .replace('{{mermaid}}', mermaidScript);

  process.stdout.write(html);
}

main();
