# Coverage Report via bisect_ppx

## Goals

- **Visibility**: Coverage badges on README showing line and branch coverage
- **Exploration**: HTML reports to identify untested code paths
- **Advisory enforcement**: PR comments showing coverage diff (no blocking)

## Design

### Instrumentation

Use **bisect_ppx** for OCaml coverage instrumentation.

**dune-project changes:**
- Add `bisect_ppx` as dev dependency

**dune file changes:**
- Add `(instrumentation (backend bisect_ppx))` to lib/bin/test stanzas
- Instrumentation is opt-in via `--instrument-with bisect_ppx` flag

**Test execution:**
```bash
dune runtest --instrument-with bisect_ppx
bisect-ppx-report html -o _coverage/
bisect-ppx-report summary  # for percentages
```

### CI Workflow

New `coverage` job in `.github/workflows/ci.yml`:

1. Runs after build succeeds
2. Installs dependencies including bisect_ppx
3. Runs tests with instrumentation
4. Generates HTML report
5. Extracts percentages and generates badge JSON files
6. Publishes to GitHub Pages (on push to master only)

Uses `peaceiris/actions-gh-pages` to push `_coverage/` to `gh-pages` branch.

### GitHub Pages

Coverage report hosted at: `https://kfoxder.github.io/udp_multicast_examples/`

Published files:
- `index.html` - Full HTML coverage report
- `coverage-line.json` - Line coverage badge data
- `coverage-branch.json` - Branch coverage badge data

### README Badges

Two shields.io dynamic badges:

```markdown
![Line Coverage](https://img.shields.io/endpoint?url=https://kfoxder.github.io/udp_multicast_examples/coverage-line.json)
![Branch Coverage](https://img.shields.io/endpoint?url=https://kfoxder.github.io/udp_multicast_examples/coverage-branch.json)
```

Badge JSON format:
```json
{"schemaVersion":1,"label":"line coverage","message":"75%","color":"green"}
```

Color thresholds: green (>=80%), yellow (>=60%), red (<60%)

### PR Comments

On pull requests:
1. Generate coverage for PR branch
2. Fetch baseline from gh-pages branch
3. Post comment with: current %, baseline %, diff

Uses `actions/github-script` to create/update comment.

## Implementation Tasks

1. Add bisect_ppx to opam dependencies
2. Add instrumentation stanzas to dune files
3. Create coverage CI job
4. Add GitHub Pages publishing
5. Add badge JSON generation
6. Add PR comment workflow
7. Add badges to README
