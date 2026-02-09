# Branching Rules

Branch model: **main ← test ← dev ← feature/***.

## Branches

| Branch       | Purpose |
| ----------- | ------- |
| **main**    | Stable, release-ready code only. Protected branch; merge only via Pull Request. |
| **dev**     | Development branch. Feature branches are merged here after review. Integration before promoting to test. |
| **test**    | QA branch. Merge from dev when ready for verification. After successful tests — PR from test to main. |
| **feature/*** | Short-lived branches from dev (e.g. `feature/pagination`). One feature = one branch. Delete after merging into dev. |

## Daily Workflow

| Action              | Steps |
| ------------------- | ----- |
| Start a new feature | `git checkout dev && git pull && git checkout -b feature/name` |
| Ready for review    | Pull Request **feature/xxx → dev** |
| Ready for testing   | Pull Request **dev → test** |
| Ready for release   | Pull Request **test → main** |
| After merge         | Delete the branch (feature/test if needed), update local: `git fetch --prune`, `git checkout dev && git pull` |

## Xcode Builds

| Task           | Scheme / configuration       |
| -------------- | ---------------------------- |
| Development   | **PicsumGallery-Dev** (Debug-Dev)  |
| Tests / QA     | **PicsumGallery-Test** (Debug-Test) |

On **dev** branch build PicsumGallery-Dev by default. On **test** branch — PicsumGallery-Test (including for CI and tests).
