const {execSync} = require('child_process');
const {join} = require('path');
const fs = require('fs');
function findPoms(dir) {
  const entries = fs.readdirSync(dir, {withFileTypes: true});
  let res = [];
  for (const ent of entries) {
    if (ent.isDirectory()) {
      res = res.concat(findPoms(join(dir, ent.name)));
    } else if (ent.isFile() && ent.name === 'pom.xml') {
      res.push(join(dir, ent.name));
    }
  }
  return res;
}
const root = process.cwd();
const poms = findPoms(root);
const deps = new Set();
for (const pom of poms) {
  console.error('POM:', pom);
  try {
    const out = execSync(`mvn -q -f "${pom}" dependency:list -DexcludeTransitive=true -DincludeScope=compile -DoutputAbsoluteArtifactFilename=false`, {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    for (const line of out.split(/\r?\n/)) {
      const text = line.trim();
      if (!text) continue;
      const parts = text.split(':');
      if (parts.length >= 4 && parts[0] && parts[1] && parts[2] && parts[3]) {
        deps.add(text);
      }
    }
  } catch (err) {
    console.error('FAILED', pom, err.message);
  }
}
console.log([...deps].sort().join('\n'));
