import SwiftUI
import Foundation
import ImmersiveMap
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

func T(_ s: String) { print("[T] \(s)"); fflush(stdout) }
let scn = UserDefaults.standard.string(forKey: "scenario") ?? "default"

let parisTilt = ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 16, bearing: 0, pitch: 1.0)
let parisTop = ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 14)
let parisZ12 = ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 12)
let moscow = ImmersiveMapCameraPosition(latitudeDegrees: 55.75, longitudeDegrees: 37.62, zoom: 12)
let kremlin = ImmersiveMapCameraPosition(latitudeDegrees: 55.7520, longitudeDegrees: 37.6175, zoom: 16.5, bearing: 0, pitch: 1.0)
let alps = ImmersiveMapCameraPosition(latitudeDegrees: 45.90, longitudeDegrees: 6.87, zoom: 12, bearing: 0, pitch: 1.2)
let alpsZ15 = ImmersiveMapCameraPosition(latitudeDegrees: 45.90, longitudeDegrees: 6.87, zoom: 15, bearing: 0, pitch: 0.8)
let world = ImmersiveMapCameraPosition(latitudeDegrees: 30, longitudeDegrees: 10, zoom: 2)
let gE = GeoCoordinate(latitude: 48.8584, longitude: 2.2945)
func ring(_ la: Double, _ lo: Double, _ r: Double) -> [GeoCoordinate] {
    [GeoCoordinate(latitude: la - r, longitude: lo - r), GeoCoordinate(latitude: la - r, longitude: lo + r),
     GeoCoordinate(latitude: la + r, longitude: lo + r), GeoCoordinate(latitude: la + r, longitude: lo - r),
     GeoCoordinate(latitude: la - r, longitude: lo - r)]
}
func solid(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGImage {
    let c = CGContext(data: nil, width: 64, height: 64, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    c.setFillColor(red: r, green: g, blue: b, alpha: 1); c.fill(CGRect(x: 0, y: 0, width: 64, height: 64)); return c.makeImage()!
}
func v(_ x: some View) -> AnyView { AnyView(x.ignoresSafeArea()) }
func M() -> ImmersiveMapView { ImmersiveMapView() }
func redL(_ id: String, _ c: SIMD4<Float>, _ r: Double, zoom: ClosedRange<Double>? = nil, visible: Bool = true) -> ImmersiveMapLayer {
    let p = ImmersiveMapPolygon(exterior: ring(48.8584, 2.2945, r), style: ImmersiveMapPolygonStyle(fillColor: c, strokeColor: SIMD4(0, 0, 0, 1), strokeWidthPoints: 2))
    return ImmersiveMapLayer(id: id, polygons: [p], isVisible: visible)
}
struct Pl: Identifiable { let id: Int; let name: String; let c: GeoCoordinate }

func scene() -> AnyView {
    switch scn {
    // getting started
    case "night": return v(M().cameraPosition(parisTilt).night())
    case "treesOff": return v(M().cameraPosition(parisTilt).trees(isEnabled: false).shadows(isEnabled: false))
    case "settingsNight":
        return v(ImmersiveMapView(settings: ImmersiveMapSettings.default.night().shadows(strength: 0.6)).cameraPosition(parisTilt))
    case "settingsOverride":
        return v(ImmersiveMapView(settings: ImmersiveMapSettings.default.night()).night(false).cameraPosition(parisTilt))
    case "toggleNight": return v(ToggleNight())
    // tile source
    case "headers":
        return v(M().tileArchive(URL(string: "http://127.0.0.1:8765/my.pmtiles?key=abc")!, headers: ["Authorization": "Bearer TESTTOKEN"]).cameraPosition(parisTop))
    case "maxZoom10": return v(M().cameraPosition(parisTilt).tileMaximumZoomLevel(10))
    case "cacheSize": return v(M().cameraPosition(parisTop).preparedTileDiskCacheSize(.megabytes(1.5)))
    case "missingFile":
        return v(M().tileArchive(URL(fileURLWithPath: "/nonexistent/city.pmtiles")).cameraPosition(parisTop))
    case "cached": return v(M().cameraPosition(parisTilt))
    // attribution
    case "attrLook": return v(M().cameraPosition(parisTop).attributionSettings(size: .large, position: .topLeading, margin: 24, textColor: SIMD4(1, 0, 0, 1), emphasizesLeadingCredit: true, showsEngineCredit: false))
    case "attrOverride": return v(M().cameraPosition(parisTop).attributionSettings(.init(attributionOverride: ImmersiveMapAttribution("© My City", linkURL: URL(string: "https://mycity.example/license")))))
    case "attrEmpty": return v(M().cameraPosition(world).attributionSettings(.init(attributionOverride: ImmersiveMapAttribution(credits: []))))
    case "attrHidden": return v(M().cameraPosition(parisTop).attributionSettings(isVisible: false))
    case "attrHiddenExt": return v(M().cameraPosition(parisTop).attributionSettings(isVisible: false).attributionProvidedExternally())
    case "attrZoom16", "attrZoom12":
        return v(M().cameraPosition(scn == "attrZoom16" ? parisTop : parisZ12).attributionSettings(.init(attributionOverride: ImmersiveMapAttribution(credits: [.init("© My City"), .init("Aerial © Survey Office", zoomRange: 13..<22)]))))
    // camera UI
    case "cameraButtons": return v(M().cameraPosition(parisTilt).enableCameraUIControls())
    case "camera": return v(CameraT())
    case "limits": return v(LimitsT())
    case "bounds": return v(BoundsT())
    case "follow": return v(FollowT())
    case "tour": return v(TourT())
    // style
    case "styleColors": return v(M().cameraPosition(parisTilt).mapStyle(.default.apply { theme in
        theme.layers.water = SIMD4(1, 0, 0, 1)
        theme.layers.park = SIMD4(1, 0, 1, 1)
        theme.labels.city.sizePoints = 18
    }))
    case "globeColors": return v(M().cameraPosition(world).mapStyle(.default.apply { theme in
        theme = theme.globeLayers { layers in layers.water = SIMD4(1, 0, 0, 1) }
    }))
    case "russian": return v(M().cameraPosition(moscow).labelSettings(language: .russian))
    case "japanese": return v(M().cameraPosition(moscow).labelSettings(language: ImmersiveMapSettings.LabelLanguage("ja")))
    case "labelsOff": return v(M().cameraPosition(moscow).labels(isEnabled: false))
    case "poiOpacity": return v(M().cameraPosition(parisTilt).mapStyle(.default.apply { theme in theme.labelOpacity.pois = [14: 0, 20: 0] }))
    case "mono": return v(M().cameraPosition(parisTilt).mapStyle(VectorTileMapStyle(style: TestMono())))
    // relief
    case "reliefOn": return v(M().cameraPosition(alps).groundRelief(isEnabled: true).onTerrainSurroundingsChange { s in T("surroundings \(String(describing: s?.kind))") })
    case "reliefOff": return v(M().cameraPosition(alps))
    case "reliefZ15": return v(M().cameraPosition(alpsZ15).groundRelief(isEnabled: true))
    case "reliefExag": return v(M().cameraPosition(alps).groundRelief(isEnabled: true, exaggeration: 3))
    // scene
    case "flat": return v(M().cameraPosition(world).globe(isEnabled: false))
    case "noAtmo": return v(M().cameraPosition(world).atmosphere(isEnabled: false))
    case "transparent": return v(ZStack { Color.red; M().cameraPosition(world).transparentSpace() })
    case "globeLightOff": return v(M().cameraPosition(world).globeLight(isEnabled: false))
    case "fogOff": return v(M().cameraPosition(parisTilt).fog(isEnabled: false).groundFog(isEnabled: false))
    case "msaaFxaa": return v(M().cameraPosition(parisTilt).msaa().fxaa())
    case "buildingsZ17": return v(M().cameraPosition(parisTilt).buildingExtrusion(buildingsMinimumZoom: 17, risesFromTheGround: false))
    // layers
    case "layers":
        return v(M().cameraPosition(parisTop).layers([
            redL("a", SIMD4(1, 0, 0, 1), 0.012),
            redL("b", SIMD4(0, 0, 1, 1), 0.006),
            ImmersiveMapLayer(id: "route", polylines: [ImmersiveMapPolyline(coordinates: [GeoCoordinate(latitude: 48.84, longitude: 2.26), GeoCoordinate(latitude: 48.875, longitude: 2.33)])], polylineStyle: ImmersiveMapPolylineStyle(color: SIMD4(0, 1, 0, 1), widthPoints: 6)),
            ImmersiveMapLayer(id: "stops", points: [ImmersiveMapPoint(coordinate: GeoCoordinate(latitude: 48.87, longitude: 2.27))]),
        ]))
    case "layersReplace": return v(M().cameraPosition(parisTop).layers([redL("a", SIMD4(1, 0, 0, 1), 0.012)]).layers([redL("b", SIMD4(0, 0, 1, 1), 0.006)]))
    case "layerHidden": return v(M().cameraPosition(parisTop).layers([redL("a", SIMD4(1, 0, 0, 1), 0.012, visible: false)]))
    case "layerZoom":
        return v(M().cameraPosition(parisTop).layers([ImmersiveMapLayer(id: "z", polygons: [ImmersiveMapPolygon(exterior: ring(48.8584, 2.2945, 0.012), style: ImmersiveMapPolygonStyle(fillColor: SIMD4(1, 0, 0, 1), strokeColor: SIMD4(0, 0, 0, 1), strokeWidthPoints: 2))], isVisible: true, zoomRange: 10...12, hidesBehindTerrain: false)]))
    case "geojson": return v(GeoT())
    // markers
    case "markers":
        return v(M().cameraPosition(parisTop).markers([Pl(id: 1, name: "FIRST ITEM", c: gE), Pl(id: 2, name: "LAST", c: gE)], coordinate: \.c) { p in
            Text(p.name).padding(6).background(p.id == 1 ? Color.yellow : Color.cyan, in: Capsule())
        })
    case "markersReplace":
        return v(M().cameraPosition(parisTop).markers([Pl(id: 1, name: "OLD SET", c: gE)], coordinate: \.c) { p in Text(p.name).padding(6).background(.yellow) }
            .markers([Pl(id: 2, name: "NEW SET", c: GeoCoordinate(latitude: 48.865, longitude: 2.30))], coordinate: \.c) { p in Text(p.name).padding(6).background(.cyan) })
    case "avatars": return v(AvatarT())
    case "selection": return v(SelT())
    // 3d
    case "modelArchiveOn": return v(M().cameraPosition(kremlin).modelArchive(ImmersiveMapTilesService.modelArchiveURL))
    case "modelArchiveOff": return v(M().cameraPosition(kremlin))
    case "ownModel": return v(ModelT())
    // export
    case "still": return v(StillT())
    case "video": return v(VideoT())
    case "urls":
        T("tiles \(ImmersiveMapTilesService.tileArchiveURL)"); T("models \(ImmersiveMapTilesService.modelArchiveURL)")
        return v(M())
    case "greens": return v(M().cameraPosition(parisTilt).trees(isEnabled: false).mapStyle(.default.apply { theme in
        theme.layers.park = SIMD4(1, 0, 1, 1)
        theme.layers.grass = SIMD4(0, 1, 1, 1)
        theme.layers.wood = SIMD4(1, 1, 0, 1)
    }))
    case "french": return v(M().cameraPosition(moscow).labelSettings(language: .french))
    case "german": return v(M().cameraPosition(moscow).labelSettings(language: .german))
    case "codeDe": return v(M().cameraPosition(moscow).labelSettings(language: ImmersiveMapSettings.LabelLanguage("de")))
    case "jaTokyo": return v(M().cameraPosition(ImmersiveMapCameraPosition(latitudeDegrees: 35.68, longitudeDegrees: 139.76, zoom: 12)).labelSettings(language: ImmersiveMapSettings.LabelLanguage("ja")))
    case "nightSideDefault": return v(M().cameraPosition(ImmersiveMapCameraPosition(latitudeDegrees: 20, longitudeDegrees: 150, zoom: 2)))
    case "nightSideLightOff": return v(M().cameraPosition(ImmersiveMapCameraPosition(latitudeDegrees: 20, longitudeDegrees: 150, zoom: 2)).globeLight(isEnabled: false))
    case "pts": return v(M().cameraPosition(parisTop).layers([ImmersiveMapLayer(id: "stops", points: [ImmersiveMapPoint(coordinate: GeoCoordinate(latitude: 48.86, longitude: 2.283))])]))
    case "avatars2": return v(Avatar2T())
    case "monoExact": return v(M().cameraPosition(parisTilt).mapStyle(VectorTileMapStyle(style: TestMonoExact())))
    case "monoZ12": return v(M().cameraPosition(moscow).mapStyle(VectorTileMapStyle(style: TestMonoExact())))
    default: return v(M())
    }
}

struct ContentView: View { var body: some View { scene() } }

struct TestMono: ImmersiveMapVectorTileStyle {
    let cacheFingerprint: UInt32 = 7
    let styleID = "testmono"
    func makeStyle(for feature: ImmersiveMapFeatureStyleContext) -> FeatureStyle {
        switch feature.layerName {
        case "earth": return .polygon(key: 1, color: SIMD4(0.95, 0.95, 0.95, 1))
        case "water": return .polygon(key: 2, color: SIMD4(0.75, 0.80, 0.85, 1))
        case "roads": return .line(key: 10, color: SIMD4(0.6, 0.6, 0.6, 1), width: 6)
        case "buildings": return .extrudedPolygon(key: 20, color: SIMD4(0.85, 0.85, 0.85, 1), fallbackHeight: 10)
        case "places": return .pointLabel(key: 30, LabelTextStyle(fillColor: SIMD3(0.2, 0.2, 0.2), strokeColor: SIMD3(1, 1, 1), haloEm: 0.15, sizePoints: 14, weight: .bold))
        default: return .hidden
        }
    }
}

struct ToggleNight: View {
    @State var n = false
    var body: some View {
        M().cameraPosition(parisTilt).night(n).task { try? await Task.sleep(for: .seconds(6)); n = true; T("night toggled") }
    }
}

func wait(_ s: Double) async { try? await Task.sleep(for: .seconds(s)) }

struct CameraT: View {
    @State var c = ImmersiveMapCameraController()
    var body: some View {
        M().cameraPosition(parisTop).cameraController(c).task {
            var n = 0
            c.onCameraPositionChanged = { _ in n += 1 }
            await wait(4)
            T("initial \(c.currentCameraPosition())")
            c.jump(to: moscow); await wait(0.5)
            T("afterJump \(c.currentCameraPosition())")
            let t0 = Date()
            c.fly(to: parisTop) { f in T("fly default finished=\(f) took=\(Date().timeIntervalSince(t0))") }
            await wait(2.5)
            T("afterFly \(c.currentCameraPosition())")
            let t1 = Date()
            c.fly(to: moscow, options: CameraFlightOptions(duration: 4, altitudeStyle: .overviewFirst)) { f in T("fly4 finished=\(f) took=\(Date().timeIntervalSince(t1))") }
            await wait(1)
            c.cancelFlight()
            await wait(0.5)
            T("changedCallbacks=\(n)")
        }
    }
}
struct LimitsT: View {
    @State var c = ImmersiveMapCameraController()
    var body: some View {
        M().cameraPosition(parisTop).cameraController(c).zoomRange(minimum: 3, maximum: 15).pitchRange(minimum: 0, maximum: 0.5).bearingLimit(.pi / 2).task {
            await wait(3)
            c.jump(to: ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 20, bearing: 3, pitch: 1.2)); await wait(1)
            T("clampedHigh (expect zoom<=15 pitch<=0.5 |bearing|<=1.57) \(c.currentCameraPosition())")
            c.jump(to: ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 1)); await wait(1)
            T("clampedLow (expect zoom>=3) \(c.currentCameraPosition())")
        }
    }
}
struct BoundsT: View {
    @State var c = ImmersiveMapCameraController()
    var body: some View {
        M().cameraPosition(moscow).cameraController(c)
            .cameraBounds(southWest: GeoCoordinate(latitude: 55.57, longitude: 37.36), northEast: GeoCoordinate(latitude: 55.92, longitude: 37.86), edgeBehavior: .hard).task {
            await wait(3)
            c.jump(to: parisZ12); await wait(1)
            T("jumpOutside (expect inside lat 55.57-55.92 lon 37.36-37.86) \(c.currentCameraPosition())")
            c.fly(to: parisZ12) { f in T("flyOutside finished=\(f) \(c.currentCameraPosition())") }
            await wait(3)
        }
    }
}
struct FollowT: View {
    @State var c = ImmersiveMapCameraController()
    var body: some View {
        M().cameraPosition(parisTop).cameraController(c).task {
            await wait(3)
            let p = ImmersiveMapGeoPath(from: gE, to: GeoCoordinate(latitude: 48.88, longitude: 2.34), peakAltitudeMeters: 300)
            c.follow(path: p, duration: 2)
            await wait(1); T("midFollow \(c.currentCameraPosition())")
            await wait(2); T("endFollow \(c.currentCameraPosition())")
        }
    }
}
struct TourT: View {
    @State var c = ImmersiveMapCameraController()
    var body: some View {
        M().cameraPosition(parisTop).cameraController(c).task {
            await wait(3)
            let tour = ImmersiveMapCameraTourController(camera: c)
            tour.start(shots: [ImmersiveMapCameraTourShot(position: parisZ12, options: CameraFlightOptions(duration: 1), holdAfter: 1),
                               ImmersiveMapCameraTourShot(position: moscow, options: CameraFlightOptions(duration: 1))], loop: false)
            await wait(1.6); T("tourShot1 \(c.currentCameraPosition())")
            await wait(2.5); T("tourEnd \(c.currentCameraPosition())")
            withExtendedLifetime(tour) {}
        }
    }
}
struct GeoT: View {
    @State var ls: [ImmersiveMapLayer] = []
    var body: some View {
        M().cameraPosition(parisTop).layers(ls).task {
            let j = ##"{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"fill":"#ff00ff","fill-opacity":1,"stroke":"#00ff00","stroke-width":5},"geometry":{"type":"Polygon","coordinates":[[[2.28,48.85],[2.31,48.85],[2.31,48.867],[2.28,48.867],[2.28,48.85]]]}}]}"##
            do { ls = [try ImmersiveMapLayer(id: "g", geoJSON: Data(j.utf8))]; T("geojson ok") } catch { T("geojson threw \(error)") }
            do { _ = try ImmersiveMapLayer(id: "b", geoJSON: Data("nope".utf8)); T("bad geojson did NOT throw") }
            catch is ImmersiveMapGeoJSONError { T("bad geojson threw ImmersiveMapGeoJSONError") } catch { T("bad geojson threw other \(error)") }
        }
    }
}
struct AvatarT: View {
    @State var a = ImmersiveMapAvatarsController()
    var body: some View {
        M().cameraPosition(parisTop).avatars(a).onAppear {
            a.set([AvatarMarker(id: 1, coordinate: gE, image: solid(1, 0, 0), batteryBadge: AvatarBatteryBadge(levelPct: 80)),
                   AvatarMarker(id: 2, coordinate: GeoCoordinate(latitude: 48.865, longitude: 2.31), image: solid(0, 0, 1), speedBadge: AvatarSpeedBadge(kilometersPerHour: 42)),
                   AvatarMarker(id: 3, coordinate: GeoCoordinate(latitude: 48.85, longitude: 2.27), image: solid(0, 1, 0), countBadge: AvatarCountBadge(count: 5))])
        }
    }
}
struct SelT: View {
    @State var a = ImmersiveMapAvatarsController()
    @State var s = ImmersiveMapSelectionController()
    var body: some View {
        M().cameraPosition(parisTop).avatars(a).selection(s).task {
            a.set([AvatarMarker(id: 1, coordinate: gE, image: solid(1, 0, 0))])
            s.onSelectionChanged = { x in T("selectionChanged \(x)") }
            s.onSelectionCleared = { x in T("selectionCleared \(x)") }
            await wait(3)
            s.select(ImmersiveMapSelection(kind: .avatar, objectID: 1)); await wait(1)
            s.clearSelection(); await wait(1)
            T("selection test done")
        }
    }
}
struct ModelT: View {
    @State var m = ImmersiveMapSceneModelsController()
    var body: some View {
        M().cameraPosition(parisTilt).sceneModels(m).task {
            T("bundle obj \(String(describing: Bundle.main.url(forResource: "cube", withExtension: "obj")))")
            m.set([ImmersiveMapSceneModel(id: 1, source: .init(resource: "cube", withExtension: "obj")!, coordinate: gE, altitudeMeters: 120, headingDegrees: 45, fitDiameterMeters: 80)])
        }
    }
}
struct StillT: View {
    var body: some View {
        Text("still").task {
            do {
                let r = ImmersiveMapStillRecorder(); let t0 = Date()
                let img = try await r.capture(settings: .default, camera: ImmersiveMapCameraPosition(latitudeDegrees: 55.75, longitudeDegrees: 37.61, zoom: 14), configuration: ImmersiveMapStillConfiguration(width: 1280, height: 720))
                T("still \(img.width)x\(img.height) took \(Date().timeIntervalSince(t0))")
                let u = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("still.png")
                let d = CGImageDestinationCreateWithURL(u as CFURL, UTType.png.identifier as CFString, 1, nil)!
                CGImageDestinationAddImage(d, img, nil); CGImageDestinationFinalize(d); T("stillPath \(u.path)")
            } catch { T("still threw \(error)") }
        }
    }
}
struct VideoT: View {
    @State var r = ImmersiveMapTourVideoRecorder()
    var body: some View {
        M().cameraPosition(parisTop).tourVideoRecorder(r).task {
            await wait(3)
            let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            let u = dir.appendingPathComponent("tour.mov"); try? FileManager.default.removeItem(at: u)
            var last = -1.0
            r.onProgress = { p in let f = Double(p.fractionCompleted); if f - last > 0.25 { last = f; T("progress \(p.phase) \(f)") } }
            let a = ImmersiveMapCameraPosition(latitudeDegrees: 48.8584, longitudeDegrees: 2.2945, zoom: 14)
            let b = ImmersiveMapCameraPosition(latitudeDegrees: 48.87, longitudeDegrees: 2.32, zoom: 14)
            let t0 = Date()
            do {
                try await r.export(shots: [ImmersiveMapCameraTourShot(position: a), ImmersiveMapCameraTourShot(position: b, options: CameraFlightOptions(duration: 2))],
                                   configuration: ImmersiveMapVideoExportConfiguration(width: 640, height: 360, framesPerSecond: 30), to: u)
                let sz = (try? FileManager.default.attributesOfItem(atPath: u.path)[.size] as? Int) ?? -1
                T("video done bytes=\(sz) took=\(Date().timeIntervalSince(t0)) path=\(u.path)")
                let asset = AVURLAsset(url: u)
                let dur = try await asset.load(.duration).seconds
                let tr = try await asset.loadTracks(withMediaType: .video).first
                let nat = try await tr?.load(.naturalSize)
                let fd = try await tr?.load(.formatDescriptions).first
                T("video duration=\(dur) size=\(String(describing: nat)) codec=\(fd.map { CMFormatDescriptionGetMediaSubType($0) } ?? 0)")
            } catch { T("video threw \(error)") }
            let u2 = dir.appendingPathComponent("cancel.mov"); try? FileManager.default.removeItem(at: u2)
            Task { await wait(0.7); r.cancel(); T("cancel called") }
            do {
                try await r.export(shots: [ImmersiveMapCameraTourShot(position: a), ImmersiveMapCameraTourShot(position: b, options: CameraFlightOptions(duration: 30))],
                                   configuration: ImmersiveMapVideoExportConfiguration(width: 640, height: 360, framesPerSecond: 30), to: u2)
                T("cancel: export returned normally")
            } catch { T("cancel: export threw \(error)") }
            T("cancel: partial file exists=\(FileManager.default.fileExists(atPath: u2.path))")
        }
    }
}

struct TestMonoExact: ImmersiveMapVectorTileStyle {
    let cacheFingerprint: UInt32 = 9
    let styleID = "mono"
    func makeStyle(for feature: ImmersiveMapFeatureStyleContext) -> FeatureStyle {
        switch feature.layerName {
        case "earth": return .polygon(key: 1, color: SIMD4(0.95, 0.95, 0.95, 1))
        case "water": return .polygon(key: 2, color: SIMD4(0.75, 0.80, 0.85, 1))
        case "roads": return .line(key: 10, color: SIMD4(1, 1, 1, 1), width: 6)
        case "buildings": return .extrudedPolygon(key: 20, color: SIMD4(0.85, 0.85, 0.85, 1), fallbackHeight: 10)
        case "places": return .pointLabel(key: 30, LabelTextStyle(fillColor: SIMD3(0.2, 0.2, 0.2), strokeColor: SIMD3(1, 1, 1), haloEm: 0.15, sizePoints: 14, weight: .bold))
        default: return .hidden
        }
    }
}
struct Avatar2T: View {
    @State var a = ImmersiveMapAvatarsController()
    var body: some View {
        M().cameraPosition(parisTop).avatars(a).onAppear {
            a.set([AvatarMarker(id: 1, coordinate: gE, image: solid(1, 0, 0), batteryBadge: AvatarBatteryBadge(levelPct: 80)),
                   AvatarMarker(id: 2, coordinate: GeoCoordinate(latitude: 48.8584, longitude: 2.31), image: solid(0, 0, 1), speedBadge: AvatarSpeedBadge(kilometersPerHour: 42)),
                   AvatarMarker(id: 3, coordinate: GeoCoordinate(latitude: 48.8584, longitude: 2.275), image: solid(0, 1, 0), countBadge: AvatarCountBadge(count: 5))])
        }
    }
}
