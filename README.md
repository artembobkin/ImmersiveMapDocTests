# ImmersiveMapDocTests

A macOS SwiftUI app that tests whether the [ImmersiveMap documentation](https://immersivemap.dev/documentation/) is complete and correct. It uses the package the way a new user would, relying only on the documentation.

## What it checks

- **Compile checks:** every documentation snippet and every API mentioned in prose is built with the app.
- **Scenarios:** 67 launches of the app, each with one feature on. Each saves a screenshot and logs, to compare with what the docs promise.

[SCENARIOS.md](SCENARIOS.md) lists the expected result for each scenario and the last result.

## Requirements

- macOS 26.5 or later, as set by the project's deployment target
- Xcode 26.6
- The app needs outgoing network access, which is already enabled. Without it, the map draws a black globe.
- Screen Recording permission for your terminal, so the script can capture windows

The package follows the `main` branch and is locked in `Package.resolved`. To test newer code, use File > Packages > Update to Latest Package Versions in Xcode.

## Running

Open `ImmersiveMapDocTests.xcodeproj` and press ⌘R to see the default map.

To run the scenarios:

```sh
Scripts/run_scenarios.sh                 # all scenarios, about 13 minutes
Scripts/run_scenarios.sh camera layers   # only these
```

Map windows open and close during the run, so don't click them. Everything is written to `Results/`:

| File | Contents |
|---|---|
| `<scenario>.png` | Screenshot of the window |
| `<scenario>.log` | Values printed by the test, as `[T]` lines |
| `<scenario>.err` | Engine and system messages |
| `sheet-N.png` | Labelled contact sheets of eight screenshots |
| `headers.server.log` | Requests received by the local server in the `headers` scenario |
| `status.txt` | Whether each scenario stayed alive and showed a window |

## Adding a scenario

1. Add a `case` to `scene()` in `ImmersiveMapDocTests/Scenarios.swift`.
2. Add its name and wait time to `Scripts/scenarios.txt`.
3. Add its expected result to `SCENARIOS.md`.

A screenshot can be taken before the tiles finish loading. Rerun with a longer wait before reporting a blank map as a bug.
