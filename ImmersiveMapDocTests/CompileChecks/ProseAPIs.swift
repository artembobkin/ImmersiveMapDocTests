// APIs the docs mention only in prose, written from the docs' wording alone.
import SwiftUI
import ImmersiveMap
import CoreGraphics

private let g = GeoCoordinate(latitude: 48.85, longitude: 2.29)
private let pos = ImmersiveMapCameraPosition(latitudeDegrees: 48.85, longitudeDegrees: 2.29, zoom: 15)
private let u = URL(string: "https://example.com/a.pmtiles")!

// camera
func p01() -> some View { ImmersiveMapView().tiltGestureSensitivity(1.0) }
func p02() -> some View { ImmersiveMapView().globeUprightPull(zoomRange: 0...3, halfLife: 0.5) }
func p03() -> some View { ImmersiveMapView().cameraBounds(southWest: g, northEast: g, pullZoomRange: 3...3) }
func p04() -> some View { ImmersiveMapView().cameraBounds(southWest: g, northEast: g, pullCurve: .easeIn) }
func p05() -> some View { ImmersiveMapView().cameraBounds(southWest: g, northEast: g, pullCurve: .init(x1: 0.1, y1: 0.2, x2: 0.3, y2: 0.4)) }
func p06() -> some View { ImmersiveMapView().cameraBounds(southWest: g, northEast: g, edgeBehavior: .hard) }
func p07() -> some View { ImmersiveMapView().cameraBounds(southWest: g, northEast: g, edgeBehavior: .elastic(maximumStretch: 100, pullHalfLife: 0.2, pullProgression: 2)) }
func p08(_ c: ImmersiveMapCameraController) { c.follow(path: ImmersiveMapGeoPath(from: g, to: g, peakAltitudeMeters: 300), duration: 5) }
func p09(_ c: ImmersiveMapCameraController) { c.onCameraPositionChanged = { p in _ = p } }
func p10(_ c: ImmersiveMapCameraController) { c.onUserInteractionBegan = { } }
func p11(_ c: ImmersiveMapCameraController) { c.onMapBackgroundTap = { } }

// style
func p20() -> some View { ImmersiveMapView().night(false) }

// scene
func p30() -> some View { ImmersiveMapView().globeLight(subsolarLatitudeDegrees: 10, subsolarLongitudeDegrees: 20, strength: 0.5, nightColor: SIMD3(0, 0, 0.1)) }
func p31() -> some View { ImmersiveMapView().groundFog(densityPerKilometer: [12: 0.5, 16: 0.1], heightMeters: [12: 3000, 16: 400], startDistanceMeters: [12: 1000, 16: 200]) }
func p32() -> some View { ImmersiveMapView().mountainGroundFog(isEnabled: true) }
func p33() -> some View { ImmersiveMapView().shadows(isEnabled: true) }

// relief
func p40() -> some View { ImmersiveMapView().groundRelief(isEnabled: true, collapsesWhereTerrainIsMissing: false) }
func p41() -> some View { ImmersiveMapView().groundRelief(isEnabled: true, castsShadows: false) }
func p42() -> some View { ImmersiveMapView().terrainSurroundings(sampleRadiusMetres: 2000, plainBelowMetres: 100, mountainsAboveMetres: 800, smoothingHalfLife: 0.5) }

// layers
func p50() -> ImmersiveMapPolygon { ImmersiveMapPolygon(exterior: [g], holes: [[g]]) }
func p51() -> ImmersiveMapPointStyle { ImmersiveMapPointStyle(color: SIMD4(1, 0, 0, 1), radiusPoints: 4, strokeColor: SIMD4(1, 1, 1, 1), strokeWidthPoints: 1) }
func p52() -> ImmersiveMapLayer { ImmersiveMapLayer(id: "x", points: [ImmersiveMapPoint(coordinate: g)], pointStyle: p51()) }
func p53() -> ImmersiveMapLayer { ImmersiveMapLayer(id: "x", polygons: [p50()], polygonStyle: ImmersiveMapPolygonStyle(fillColor: SIMD4(1, 0, 0, 1), strokeColor: SIMD4(1, 1, 1, 1), strokeWidthPoints: 1)) }
func p54() { do { _ = try ImmersiveMapLayer(id: "x", geoJSON: Data()) } catch is ImmersiveMapGeoJSONError { } catch { } }

// markers, avatars, selection
func p60() -> some View {
    ImmersiveMapView().markers(places, coordinate: \.coordinate, anchor: .bottom) { p in Text(p.name) }
}
func p61(_ a: ImmersiveMapAvatarsController, _ i: CGImage) {
    let m = AvatarMarker(id: 1, coordinate: g, image: i)
    a.add([m])
}
func p62(_ a: ImmersiveMapAvatarsController, _ m: AvatarMarker) { a.upsert([m]) }
func p63(_ a: ImmersiveMapAvatarsController) { a.move(id: 1, to: g) }
func p64(_ a: ImmersiveMapAvatarsController, _ i: CGImage) { a.update(id: 1, image: i, borderColor: SIMD4(1, 1, 1, 1), isSelected: true) }
func p65(_ a: ImmersiveMapAvatarsController) { a.remove(ids: [1]); a.clear() }
func p66(_ a: ImmersiveMapAvatarsController) { a.merge(ids: [1, 2], mergedID: 100) }
func p67(_ a: ImmersiveMapAvatarsController) { a.unmerge(mergedID: 1) }
func p68(_ i: CGImage) -> AvatarMarker { AvatarMarker(id: 2, coordinate: g, image: i, speedBadge: AvatarSpeedBadge(kilometersPerHour: 10)) }
func p69(_ i: CGImage) -> AvatarMarker { AvatarMarker(id: 3, coordinate: g, image: i, countBadge: AvatarCountBadge(count: 3)) }
func p70(_ i: CGImage) -> AvatarMarker { AvatarMarker(id: 4, coordinate: g, image: i, borderColor: SIMD4(1, 1, 1, 1), screenSizeScale: 1.2, drawPriority: 2) }
func p71() -> some View { ImmersiveMapView().avatarSettings(sizeScale: 1, borderWidthPx: 2) }
func p72(_ s: ImmersiveMapSelectionController) { s.onSelectionChanged = { x in _ = x } }
func p73(_ s: ImmersiveMapSelectionController) { s.onSelectionCleared = { _ in } }
func p74(_ s: ImmersiveMapSelectionController) { s.onMapBackgroundTap = { _ in } }

// 3d content
func p80() -> some View { ImmersiveMapView().modelArchive(u, headers: ["A": "B"]) }
func p81() -> some View { ImmersiveMapView().modelArchiveSettings(diskCacheSizeInBytes: 1_000_000) }
func p82(_ m: ImmersiveMapSceneModelsController) { m.move(id: 1, to: g) }
func p83(_ m: ImmersiveMapSceneModelsController) { m.move(id: 1, to: g) }
func p84(_ m: ImmersiveMapSceneModelsController) { m.setOrientation(id: 1, headingDegrees: 10, pitchDegrees: 0, rollDegrees: 0) }
func p85(_ m: ImmersiveMapSceneModelsController) { m.setScale(id: 1, 2) }
func p86(_ m: ImmersiveMapSceneModelsController) { m.setAltitude(id: 1, meters: 10) }
func p87() -> ImmersiveMapSceneModel? {
    let s = ImmersiveMapSceneModel.Source(url: u)
    return ImmersiveMapSceneModel(id: 1, source: s, coordinate: g, pitchDegrees: 1, rollDegrees: 1, scale: 2)
}

// export
func p90() async throws {
    let r = ImmersiveMapStillRecorder()
    _ = try await r.capture(settings: .default, camera: pos, configuration: ImmersiveMapStillConfiguration(width: 10, height: 10, settleTimeout: 5, sceneDate: Date()))
}
func p91(_ a: [AvatarMarker], _ m: [ImmersiveMapSceneModel]) async throws {
    let r = ImmersiveMapStillRecorder()
    _ = try await r.capture(settings: .default, camera: pos, avatars: a, sceneModels: m, configuration: ImmersiveMapStillConfiguration(width: 10, height: 10))
}
func p92() -> ImmersiveMapVideoExportConfiguration { ImmersiveMapVideoExportConfiguration(width: 10, height: 10, framesPerSecond: 30, codec: .h264, includesAvatars: false, includesMarkers: false) }
func p93(_ r: ImmersiveMapTourVideoRecorder) { r.onProgress = { p in _ = p.fractionCompleted; _ = p.phase } }
func p94(_ r: ImmersiveMapTourVideoRecorder) { r.cancel() }

// custom style
struct P100Style: ImmersiveMapVectorTileStyle {
    let cacheFingerprint: UInt32 = 1
    let styleID = "p100"
    func makeStyle(for feature: ImmersiveMapFeatureStyleContext) -> FeatureStyle {
        _ = feature.properties.string("kind"); _ = feature.geometry; _ = feature.facts
        return .pointLockedLine(key: 1, color: SIMD4(1, 1, 1, 1), widthPoints: 2)
    }
}
func p101() -> ImmersiveMapFeatureFacts { .road(ImmersiveMapRoadFacts()) }

