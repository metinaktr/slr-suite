# SoftwareX Resubmission Strategy

## Recommended route

Resubmit to SoftwareX only after the release-candidate commit satisfies every gate below. The software now fits the journal’s software-article scope, while the manuscript deliberately limits scientific claims to evidence supported by the bundled validation.

## Mandatory gates

1. Freeze a release-candidate commit and pass Ubuntu, macOS, and Windows validation.
2. Perform a clean-clone installation rehearsal using only the published user guide and `renv.lock`.
3. Confirm bidirectional manuscript–code traceability and render the final manuscript.
4. Obtain an independent maintainer/researcher sign-off on example execution and artifact inspection.
5. Update the response document with final PDF page numbers and immutable CI/Release links.
6. Publish the next Semantic Version only from the commit that passed these gates; never move an existing tag.

## Submission package

- Final SoftwareX manuscript and bibliography.
- Public tagged GitHub Release and source archive.
- `CITATION.cff`, CodeMeta, license, changelog, and C1–C9 metadata.
- Response to Reviewers with file/page evidence.
- Pre-Submission Validation Report and per-OS CI artifacts.
- Manuscript–Code Traceability Matrix.

## Decision rule and fallback

Proceed with SoftwareX when all mandatory gates pass and the editor-facing claims remain software-focused. If independent validation exposes unresolved platform or workflow failures, postpone submission and fix them rather than changing venue. If the software is stable but SoftwareX declines it for scope rather than maturity, shortlist alternative software journals using explicit criteria: executable-software focus, open-source acceptance, archival release support, reproducibility expectations, and indexing. Venue selection must not remove any validation or traceability requirement.

## Ownership and timing

The corresponding author owns manuscript/repository alignment and release approval. An independent tester owns clean-install and example-workflow sign-off. CI provides repeatable platform evidence. All evidence must be regenerated after any code, dependency, configuration, or manuscript claim change.
