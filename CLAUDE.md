# ImmersiveMapDocTests

## Goal

This project tests whether the [ImmersiveMap documentation](https://immersivemap.dev/documentation/) is complete, correct and understandable. It is a macOS SwiftUI app that uses the ImmersiveMap package the way a new user would. When the docs are missing a step, describe something that doesn't work, or leave a detail that has to be guessed, that is a finding.

## The main rule

The documentation at https://immersivemap.dev/documentation/ is the only source of information about ImmersiveMap. Do not read the package source, its GitHub repository, or other sites to learn how the API works, because that would hide gaps in the docs.

Compiler errors, runtime behaviour and the engine's log messages are allowed: a new user would see them too.

When something can't be done from the docs alone, report it as a finding instead of working around it silently.

## How the testing works

- **Compile checks:** `ImmersiveMapDocTests/CompileChecks/` holds every documentation snippet and every API mentioned only in prose. They build with the app.
- **Scenarios:** `ImmersiveMapDocTests/Scenarios.swift` has one case per documented behaviour. `Scripts/run_scenarios.sh` launches each one and saves a screenshot and logs to `Results/`.
- **Expected results:** `SCENARIOS.md` lists what each scenario should do and its last result. Keep it up to date.

```sh
Scripts/run_scenarios.sh                 # all scenarios, about 13 minutes
Scripts/run_scenarios.sh camera layers   # only these
```

## Working notes

- Scenarios are selected with the named option `-scenario <name>`. A bare launch argument stops macOS from opening the app's window.
- A screenshot can be taken before the tiles finish loading. Rerun with a longer wait in `Scripts/scenarios.txt` before reporting a blank map as a bug.
- The package follows the `main` branch of ImmersiveMap, because the docs may describe code newer than the latest release.
- To add a scenario, add a case to `scene()`, add it to `Scripts/scenarios.txt`, and add its expected result to `SCENARIOS.md`.
- Always commit and push directly to `main`. Do not create other branches.
