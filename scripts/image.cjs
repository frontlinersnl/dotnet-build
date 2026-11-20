const { execFileSync } = require('node:child_process');
const { readFileSync, readdirSync } = require('node:fs');
const { version } = require('../package.json');

const repository = 'frontliners/dotnet-build';
const [action, ...args] = process.argv.slice(2);

function major(value) {
  if (!/^[1-9]\d{0,2}(?:\.0)?$/.test(value)) {
    throw new Error(`Expected a .NET major version such as 11 or 11.0, received "${value}".`);
  }
  return Number(value);
}

function main() {
  const variants = readdirSync('.', { withFileTypes: true })
    .filter(entry => entry.isFile() && /^Dockerfile\.[a-z0-9]+(?:-[a-z0-9]+)*$/.test(entry.name))
    .map(entry => entry.name.slice('Dockerfile.'.length))
    .sort();
  const [selector, ...rest] = args;
  const namedOption = selector === '--variant';
  const variant = namedOption ? rest[0] : selector?.replace(/^--/, '');
  const versions = namedOption ? rest.slice(1) : rest;
  if (!['build', 'push', 'publish'].includes(action) ||
      !variants.includes(variant) || versions.length === 0) {
    throw new Error(`Usage: npm run <build|push|publish> <variant> <sdk> [runtime ...]. Available variants: ${variants.join(', ')}`);
  }

  const [sdk, ...extra] = versions.map(major);
  const runtimes = [...new Set(extra)].filter(runtime => runtime !== sdk).sort((a, b) => b - a);
  const parts = [`sdk${sdk}`];
  if (runtimes.length) parts.push(`runtime${runtimes.join('_')}`);
  parts.push(variant);
  const profile = parts.join('-');
  const tag = `${version}-${profile}`;
  if (tag.length > 128) throw new Error('Generated Docker tag exceeds 128 characters.');
  const image = `${repository}:${tag}`;

  if (action !== 'push') {
    const filename = `Dockerfile.${variant}`;
    const template = readFileSync(filename, 'utf8');
    const block = /^# BEGIN additional runtimes\r?\n[\s\S]*?^# END additional runtimes\r?$/m;
    if (!block.test(template)) throw new Error(`Missing runtime block in ${filename}`);
    const copies = runtimes.map(runtime =>
      `COPY --from=mcr.microsoft.com/dotnet/aspnet:${runtime}.0 /usr/share/dotnet/shared/ /usr/share/dotnet/shared/`
    );
    const args = ['build', '-f', '-', '--build-arg', `SDK_VERSION=${sdk}.0`, '-t', image, '.'];
    execFileSync('docker', args, {
      input: template.replace(block, copies.join('\n')),
      stdio: ['pipe', 'inherit', 'inherit']
    });
  }
  if (action !== 'build') {
    execFileSync('docker', ['push', image], { stdio: 'inherit' });
  }
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exitCode = error.status || 1;
}
