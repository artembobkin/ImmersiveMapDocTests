# Scenarios

Each scenario is a case in `ImmersiveMapDocTests/Scenarios.swift`. The last result is from 2026-11-09, on ImmersiveMap `main` at `053724d`, macOS with Xcode 26.6.

Results come from the screenshot, the `[T]` lines in `Results/<scenario>.log`, or the engine messages in `Results/<scenario>.err`.

## Getting started

| Scenario | Expected | Last result |
|---|---|---|
| `urls` | Prints the hosted tile and model archive URLs. | Pass |
| `night` | Night palette and sky. | Pass |
| `treesOff` | No trees and no shadows. | Pass |
| `settingsNight` | `ImmersiveMapSettings` value applies night. | Pass |
| `settingsOverride` | `.night(false)` on the view overrides a night settings value. | Pass |
| `toggleNight` | Changing state after 6 s switches the map to night. | Pass |

## Tile source

| Scenario | Expected | Last result |
|---|---|---|
| `headers` | `Results/headers.server.log` shows `?key=abc`, `Authorization: Bearer TESTTOKEN` and a `Range` header. | Pass |
| `maxZoom10` | At zoom 16 the zoom 10 tiles are stretched, with no buildings. | Pass |
| `cacheSize` | `.megabytes(1.5)` is accepted and the map draws. | Pass |
| `missingFile` | A missing file URL fails clearly. | Gap: blank map and no log message |
| `cached` | With no network, a place seen before draws from the disk cache. Run after the other scenarios. | Pass |

## Attribution

| Scenario | Expected | Last result |
|---|---|---|
| `attrLook` | Red, bold, top-left, with no "Powered by ImmersiveMap". | Pass |
| `attrOverride` | "© My City" replaces "© OpenStreetMap". | Pass |
| `attrEmpty` | An empty override removes the whole line. | Pass |
| `attrHidden` | No badge, and `[Attribution]` warning in the `.err` file. | Pass |
| `attrHiddenExt` | No badge and no warning. | Pass |
| `attrZoom16` | "Aerial © Survey Office" shows inside its zoom range. | Pass |
| `attrZoom12` | "Aerial © Survey Office" is hidden outside its zoom range. | Pass |

## Camera

| Scenario | Expected | Last result |
|---|---|---|
| `cameraButtons` | On-screen bearing and pitch controls appear. | Pass |
| `camera` | `jump` lands at once; default `fly` takes about 1.35 s and reports `true`; a cancelled flight reports `false`; `onCameraPositionChanged` fires. | Pass (1.30 s; 2.27 s in one run with an empty cache) |
| `limits` | Zoom, pitch and bearing stay inside the limits after out-of-range jumps. | Pass |
| `bounds` | With `.hard`, a jump or flight to Paris stays inside the Moscow region. | Pass |
| `follow` | The camera moves along the path and turns to the direction of travel. | Pass |
| `tour` | The tour reaches each shot in order. | Pass |

## Style

| Scenario | Expected | Last result |
|---|---|---|
| `styleColors` | Water is red. | Pass |
| `greens` | Park, grass and wood take their own colours. The Champ de Mars is `grass`. | Pass |
| `globeColors` | Only the globe's water is red. | Pass |
| `russian` | Names in Russian. | Pass |
| `japanese` | `LabelLanguage("ja")` shows Japanese names. | Fail: Latin names |
| `jaTokyo` | The same, in Tokyo. | Fail: Latin names |
| `french` | Names in French. | Not confirmed: was still loading |
| `german` | Names in German. | Pass |
| `codeDe` | `LabelLanguage("de")` matches `.german`. | Pass |
| `labelsOff` | No names. | Pass |
| `poiOpacity` | `theme.labelOpacity.pois` of 0 hides points of interest. | Pass |

## Custom style

| Scenario | Expected | Last result |
|---|---|---|
| `mono` | The documented style at zoom 16, with grey roads. | Fail: black land |
| `monoExact` | The documented style, exactly, at zoom 16. | Fail: black land |
| `monoZ12` | The documented style at zoom 12. | Pass |

## Relief

| Scenario | Expected | Last result |
|---|---|---|
| `reliefOff` | Flat map and no terrain credit. | Pass |
| `reliefOn` | Mountains, "© Mapterhorn", and surroundings reported as `.mountains`. | Pass |
| `reliefZ15` | Flat at zoom 15 and no terrain credit. | Pass |
| `reliefExag` | `exaggeration: 3` makes the mountains visibly taller. | Pass |

## Scene

| Scenario | Expected | Last result |
|---|---|---|
| `flat` | A flat map at zoom 2. | Pass |
| `noAtmo` | No glow around the globe. | Pass |
| `transparent` | The red background shows around the globe, with no stars. | Pass |
| `globeLightOff` | The globe is lit evenly. | Not confirmed: compare with `noAtmo` |
| `nightSideDefault` | The globe shows a night side. | Not confirmed: no dark side visible at lon 150 |
| `nightSideLightOff` | Differs from `nightSideDefault`. | Not confirmed: images match |
| `fogOff` | No sky gradient or ground fog. | Pass |
| `msaaFxaa` | The map draws with both enabled. | Pass |
| `buildingsZ17` | No raised buildings at zoom 16. | Pass |

To compare two 1000x500 images from `Results/small`: `swift Scripts/compare_images.swift a.png b.png`.

## Your own data

| Scenario | Expected | Last result |
|---|---|---|
| `layers` | Blue draws over red, the green route shows, and buildings stay on top. | Pass |
| `layersReplace` | Only the later `.layers(...)` call shows. | Pass |
| `layerHidden` | `isVisible: false` draws nothing. | Pass |
| `layerZoom` | A layer limited to zooms 10...12 is hidden at zoom 14. | Pass |
| `pts` | A default-styled point shows. | Pass |
| `geojson` | simplestyle fill and stroke apply; bad input throws `ImmersiveMapGeoJSONError`. | Pass |

## Markers and taps

| Scenario | Expected | Last result |
|---|---|---|
| `markers` | The last item draws on top. | Pass |
| `markersReplace` | Only the later `.markers(...)` set shows. | Pass |
| `avatars` | An avatar with a battery badge. The other two are off-screen on purpose. | Pass |
| `avatars2` | Battery, speed and count badges. | Pass (avatars are rounded squares, not round) |
| `selection` | `select` and `clearSelection` fire their callbacks. | Pass |

## 3D content

| Scenario | Expected | Last result |
|---|---|---|
| `modelArchiveOff` | Plain raised buildings at the Kremlin. | Pass |
| `modelArchiveOn` | Detailed models replace some buildings. | Fail: `unsupportedVersion(4)`, waiting for a new hosted archive |
| `ownModel` | The OBJ cube floats at the Eiffel Tower. | Pass |

## Export

| Scenario | Expected | Last result |
|---|---|---|
| `still` | A 1280x720 `CGImage` with no badge. The PNG is in the app's container `tmp` folder. | Pass |
| `video` | HEVC, 640x360, about 2 s, with progress; cancel throws and deletes the partial file. | Pass |

## Compile checks

These run on every build, so a build failure means the docs and the package disagree.

- `CompileChecks/DocSnippets.swift`: every code snippet from the docs, as written. Names the docs leave undefined are declared at the top of the file.
- `CompileChecks/ProseAPIs.swift`: APIs the docs mention only in prose, written from their wording.

Prose APIs that needed a guess or a workaround:

- `PullCurve(x1:y1:x2:y2:)` is not found by that name; `.init(...)` works in `pullCurve:`.
- `move(id:to:duration:)` on the scene models controller is rejected.
- `.roadLabel` needs `key:color:width:textStyle:`, which the docs don't show, so it is not in the file.
- `feature.zoom` does not exist.

## Not covered

- Real gestures and taps.
- Bundled offline `.pmtiles` archives.
- ETag updates of a re-uploaded archive.
