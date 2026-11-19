const { execFileSync } = require('node:child_process');
const { readFileSync } = require('node:fs');
const { version } = require('../package.json');

const repository = 'frontliners/dotnet-build';
const [action, variant, ...versions] = process.argv.slice(2);

function major(value) {
  if (!/^[1-9]\d{0,2}(?:\.0)?$/.test(value)) {
    throw new Error(`Expected a .NET major version such as 11 or 11.0, received "${value}".`);
  }
  return Number(value);
}

function main() {
  if (!['full', 'slim'].includes(variant) || !['build', 'push', 'publish'].includes(action)) {
    throw new Error('Usage: node scripts/image.cjs <build|push|publish> <full|slim> [sdk [runtime ...]]');
  }
  // Preserve the existing SDK 11 + runtime 10 profile for argument-free commands.
  const [sdk, ...extra] = versions.length ? versions.map(major) : [11, 10];
  const runtimes = [...new Set(extra)].filter(runtime => runtime !== sdk).sort((a, b) => b - a);
  const parts = [`sdk${sdk}`, ...runtimes.map(runtime => `runtime${runtime}`)];
  if (variant === 'slim') parts.push('slim');
  const profile = parts.join('-');
  const tags = [`${version}-${profile}`, profile];
  if (variant === 'full' && sdk === 11 && runtimes.length === 1 && runtimes[0] === 10) {
    tags.push(version, 'latest');
  }
  if (tags.some(tag => tag.length > 128)) throw new Error('Generated Docker tag exceeds 128 characters.');
  const images = tags.map(tag => `${repository}:${tag}`);

  if (action !== 'push') {
    const filename = variant === 'slim' ? 'Dockerfile.slim' : 'Dockerfile';
    const template = readFileSync(filename, 'utf8');
    const block = /^# BEGIN additional runtimes\r?\n[\s\S]*?^# END additional runtimes\r?$/m;
    if (!block.test(template)) throw new Error(`Missing runtime block in ${filename}`);
    const copies = runtimes.map(runtime =>
      `COPY --from=mcr.microsoft.com/dotnet/aspnet:${runtime}.0 /usr/share/dotnet/shared/ /usr/share/dotnet/shared/`
    );
    const args = ['build', '-f', '-', '--build-arg', `SDK_VERSION=${sdk}.0`];
    for (const image of images) args.push('-t', image);
    execFileSync('docker', [...args, '.'], {
      input: template.replace(block, copies.join('\n')),
      stdio: ['pipe', 'inherit', 'inherit']
    });
  }
  if (action !== 'build') {
    for (const image of images) execFileSync('docker', ['push', image], { stdio: 'inherit' });
  }
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exitCode = error.status || 1;
}
