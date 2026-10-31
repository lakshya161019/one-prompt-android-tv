import { spawn } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';
import { pathToFileURL } from 'node:url';
import { join, resolve } from 'node:path';
import { mkdir, readFile, readdir, stat, copyFile, writeFile } from 'node:fs/promises';

const [chrome, html, profile, downloads, output] = process.argv.slice(2).map(value => resolve(value));
await mkdir(join(profile, 'Default'), { recursive: true });
await mkdir(downloads, { recursive: true });
await writeFile(join(profile, 'Default', 'Preferences'), JSON.stringify({
  download: { default_directory: downloads, prompt_for_download: false, directory_upgrade: true },
  savefile: { default_directory: downloads }
}));
const child = spawn(chrome, [
  '--headless=new', '--disable-gpu', '--no-sandbox', '--autoplay-policy=no-user-gesture-required',
  '--disable-background-networking', '--disable-extensions', '--no-first-run',
  `--user-data-dir=${profile}`, pathToFileURL(html).href
], { stdio: 'ignore', windowsHide: true });

try {
  let complete = false;
  for (let i = 0; i < 900; i++) {
    const files = await readdir(downloads);
    const video = files.find(f => f.endsWith('.webm'));
    if (video && !files.some(f => f.endsWith('.crdownload'))) {
      const source = join(downloads, video), info = await stat(source);
      if (info.size < 100_000) throw new Error(`Rendered file is unexpectedly small (${info.size} bytes).`);
      await copyFile(source, output);
      console.log(`Rendered ${(info.size / 1048576).toFixed(1)} MB to ${output}`);
      complete = true; break;
    }
    if (child.exitCode !== null) throw new Error(`Chrome exited with ${child.exitCode} before download completed.`);
    await delay(1000);
  }
  if (!complete) throw new Error('Timed out waiting for the rendered WebM file.');
} finally {
  child.kill();
}

