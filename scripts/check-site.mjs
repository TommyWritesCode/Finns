#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const errors = [];
const warnings = [];

function walk(dir, exts, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const name of fs.readdirSync(dir)) {
    const p = path.join(dir, name);
    const st = fs.statSync(p);
    if (st.isDirectory() && !['node_modules', 'dist', '.git'].includes(name)) walk(p, exts, out);
    else if (st.isFile() && exts.some(ext => p.endsWith(ext))) out.push(p);
  }
  return out;
}

const files = walk(root, ['.astro', '.md', '.ts', '.js', '.json']);

for (const file of files) {
  const rel = path.relative(root, file);
  const txt = fs.readFileSync(file, 'utf8');

  if (/lorem ipsum|TODO|FIXME|\[NEEDS:/i.test(txt)) {
    warnings.push(`${rel}: placeholder or missing-fact marker found`);
  }

  if (file.endsWith('.astro')) {
    const h1s = (txt.match(/<h1\b/gi) || []).length;
    if (h1s > 1) warnings.push(`${rel}: multiple <h1> tags found (${h1s})`);

    const imageTags = txt.match(/<(img|Image)\b[^>]*>/g) || [];
    for (const tag of imageTags) {
      if (!/\salt\s*=/.test(tag)) warnings.push(`${rel}: image component/tag missing alt attribute: ${tag.slice(0, 100)}`);
    }

    const internalLinks = [...txt.matchAll(/href=["']([^"']+)["']/g)]
      .map(m => m[1])
      .filter(h => h.startsWith('/') && !h.startsWith('//') && !h.includes('#'));
    for (const href of internalLinks) {
      const route = href === '/' ? 'index' : href.replace(/^\//, '').replace(/\/$/, '');
      const page = path.join(root, 'src', 'pages', `${route}.astro`);
      const indexPage = path.join(root, 'src', 'pages', route, 'index.astro');
      if (!fs.existsSync(page) && !fs.existsSync(indexPage)) {
        warnings.push(`${rel}: internal link may not resolve: ${href}`);
      }
    }
  }

  if (file.endsWith('.json')) {
    try { JSON.parse(txt); }
    catch (err) { errors.push(`${rel}: invalid JSON — ${err.message}`); }
  }
}

console.log('# check-site report');
console.log(`Files inspected: ${files.length}`);

if (errors.length) {
  console.log('\n## Errors');
  for (const e of errors) console.log(`- ${e}`);
}

if (warnings.length) {
  console.log('\n## Warnings');
  for (const w of warnings) console.log(`- ${w}`);
}

if (!errors.length && !warnings.length) {
  console.log('\nNo obvious static issues found.');
}

process.exit(errors.length ? 1 : 0);
