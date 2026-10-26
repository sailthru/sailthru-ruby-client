// Discover every stable release line from the existing CI minimum.
const metadataUrl = 'https://raw.githubusercontent.com/ruby/setup-ruby/master/ruby-builder-versions.json';
const compare = (a, b) => a.localeCompare(b, 'en', {numeric: true});

module.exports = async function discover({core, fetch = globalThis.fetch}) {
  const response = await fetch(metadataUrl, {
    headers: {'User-Agent': 'sailthru-ci-runtime-matrix'},
    signal: AbortSignal.timeout(30000)
  });
  if (!response.ok) throw new Error(`Runtime metadata request failed: ${response.status}`);
  const releases = await response.json();
  const versions = releases.ruby
    .filter(version => /^\d+\.\d+\.\d+$/.test(version))
    .map(version => version.split('.').slice(0, 2).join('.'))
    .filter(version => compare(version, '3.3') >= 0);

  const matrix = [...new Set(versions)].sort(compare);
  if (!matrix.includes('3.3') || matrix.length > 256) {
    throw new Error('Runtime matrix is incomplete or exceeds the GitHub Actions limit');
  }
  core.info(`Testing ruby release lines: ${matrix.join(', ')}`);
  core.setOutput('versions', JSON.stringify(matrix));
};
