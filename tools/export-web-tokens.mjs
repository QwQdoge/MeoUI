#!/usr/bin/env node
// Export existing MeoUI fallback roles; never evaluate QML or invent a palette.
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const args = process.argv.slice(2);
if (args.length !== 4 || args[0] !== '--bindings' || args[2] !== '--output') {
  throw new Error('Usage: export-web-tokens.mjs --bindings <token-aliases.json> --output <file.css>');
}
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const source = await readFile(path.join(root, 'MeoTheme.qml'), 'utf8');
const bindings = JSON.parse(await readFile(args[1], 'utf8'));
if (bindings.authority !== 'MeoUI' || bindings.schemaVersion !== 1) throw new Error('Unsupported token authority/version');
function declaration(mode) {
  const match = source.match(new RegExp(`readonly property var fallback${mode}ColorScheme: \\(\\{([\\s\\S]*?)\\}\\)`));
  if (!match) throw new Error(`Missing ${mode} source palette`);
  const palette = JSON.parse(`{${match[1]}}`);
  return Object.entries(bindings.color).map(([alias, role]) => {
    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(alias)) throw new Error('Invalid token alias');
    const color = palette[role];
    if (typeof color !== 'string' || !/^#[a-fA-F0-9]{6}$/.test(color)) throw new Error(`Unknown source role: ${role}`);
    const rgb = [1, 3, 5].map((offset) => parseInt(color.slice(offset, offset + 2), 16)).join(' ');
    return `  --meo-color-${alias}: ${rgb};`;
  }).join('\n');
}
const light = declaration('Light');
const dark = declaration('Dark');
const css = `/* Generated from MeoUI/MeoTheme.qml; source sha256 ${createHash('sha256').update(source).digest('hex')} */\n:root {\n${light}\n  color-scheme: light;\n}\n:root[data-theme="dark"] {\n${dark}\n  color-scheme: dark;\n}\n@media (prefers-color-scheme: dark) {\n  :root:not([data-theme="light"]) {\n${dark}\n  color-scheme: dark;\n  }\n}\n`;
await mkdir(path.dirname(path.resolve(args[3])), { recursive: true });
await writeFile(args[3], css);
