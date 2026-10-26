const {test} = require('node:test');
const assert = require('node:assert/strict');
const discover = require('./runtime-matrix.cjs');

async function resolve(releases) {
  let output;
  await discover({
    core: {info() {}, setOutput(name, value) {
      assert.equal(name, 'versions');
      output = JSON.parse(value);
    }},
    fetch: async () => ({ok: true, json: async () => releases})
  });
  return output;
}

test('includes intermediate and future stable releases, excludes prereleases and duplicates', async () => {
  const releases = {ruby: ['4.2.0', '3.2.9', '3.3.0', '3.4.1', '3.4.2', '3.5.0-preview1',
    '4.0.1', '4.1.0', '4.3.0-rc1', 'head'], jruby: ['99.0.0']};
  assert.deepEqual(await resolve(releases), ['3.3', '3.4', '4.0', '4.1', '4.2']);
});

test('fails rather than quietly running an empty or incomplete matrix', async () => {
  await assert.rejects(resolve({ruby: []}));
  await assert.rejects(resolve({ruby: ['4.0.0']}));
  await assert.rejects(resolve(null));
});

test('metadata HTTP, JSON and network failures fail discovery without emitting a matrix', async () => {
  const core = {info() {}, setOutput() {assert.fail('Must not emit a fallback matrix');}};
  await assert.rejects(discover({core, fetch: async () => ({ok: false, status: 503})}), /503/);
  await assert.rejects(discover({core, fetch: async () => ({
    ok: true, json: async () => {throw new SyntaxError('Invalid JSON');}
  })}), /Invalid JSON/);
  await assert.rejects(discover({core, fetch: async () => {throw new Error('Network failure');}}), /Network failure/);
});
