# Maintenance and Release Strategy

## Release gates

1. Freeze a release-candidate commit and pass Ubuntu, macOS, and Windows validation.
2. Perform a clean-clone installation rehearsal using only the public user guide and `renv.lock`.
3. Confirm bidirectional software–documentation traceability and render all documentation.
4. Inspect the bundled example outputs and uploaded validation artifacts.
5. Synchronize project, citation, CodeMeta, changelog, and documentation version identifiers.
6. Publish a new Semantic Version from the tested commit; never move an existing tag.

## Release package

- Tagged source archive and immutable GitHub Release.
- User guide, architecture, reproducibility guide, and module documentation.
- License, citation metadata, CodeMeta, dependency lock, and changelog.
- Software quality improvements summary, release validation report, and traceability matrix.
- Per-operating-system CI evidence artifacts.

## Change management

Any change to code, dependencies, configuration, tests, or documented behavior must pass the same automated gates. A failed platform job, documentation render, coverage threshold, or traceability check blocks release publication. Evidence must be regenerated after every material change.

## Responsibilities

Maintainers own version consistency, documentation alignment, and release approval. Contributors must update tests and traceability records with behavioral changes. Independent users can reproduce the release validation protocol from a clean clone without unpublished configuration.
