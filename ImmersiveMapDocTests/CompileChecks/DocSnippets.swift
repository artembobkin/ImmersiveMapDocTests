// Every code snippet from immersivemap.dev/documentation, as written.
// Placeholders the docs leave undefined are declared at the top.
import SwiftUI
import ImmersiveMap
import CoreGraphics

let url = URL(string: "https://tiles.example.com/planet.pmtiles")!
let myArchiveURL = url
let start = ImmersiveMapCameraPosition(latitudeDegrees: 48.858, longitudeDegrees: 2.294, zoom: 15)
let position = start
let eiffelTower = start
let louvre = start
let route: [GeoCoordinate] = []
let stops: [GeoCoordinate] = []
let park: [GeoCoordinate] = []
let zones: [ImmersiveMapPolygon] = []
let showZones = true
let data = Data()
let photoURL = url
let outputURL = URL(fileURLWithPath: "/tmp/a.mov")
struct Place: Identifiable { let id = UUID(); let name: String; let coordinate: GeoCoordinate }
let places: [Place] = []

// getting-started
func gs1() -> some View { ImmersiveMapView().ignoresSafeArea() }
func gs2() -> some View {
    ImmersiveMapView()
        .cameraPosition(ImmersiveMapCameraPosition(latitudeDegrees: 48.858, longitudeDegrees: 2.294, zoom: 15))
        .night()
        .shadows(strength: 0.6)
        .trees(isEnabled: false)
}
func gs3() -> some View {
    let settings = ImmersiveMapSettings.default
        .night()
        .shadows(strength: 0.6)
    return ImmersiveMapView(settings: settings)
        .cameraPosition(start)
}

// tile-source
func ts1() -> some View { ImmersiveMapView().tileArchive(URL(string: "https://tiles.example.com/planet.pmtiles")!) }
func ts2() -> some View { ImmersiveMapView().tileArchive(url, headers: ["Authorization": "Bearer x"]) }
func ts3() -> some View { ImmersiveMapView().tileArchive(Bundle.main.url(forResource: "city", withExtension: "pmtiles")!) }
func ts4() -> some View { ImmersiveMapView().tileMaximumZoomLevel(14) }
func ts5() -> some View { ImmersiveMapView().preparedTileDiskCacheSize(.gigabytes(4)) }
func ts6() {
    let _: URL = ImmersiveMapTilesService.tileArchiveURL
    let _: [ImmersiveMapByteCount] = [.gigabytes(1), .megabytes(1.5), .kilobytes(1), .bytes(1)]
}

// attribution
func at1() -> some View {
    ImmersiveMapView()
        .tileArchive(url)
        .attributionSettings(.init(attributionOverride: ImmersiveMapAttribution("© My City",
                                                                                linkURL: URL(string: "https://mycity.example/license"))))
}
func at2() -> ImmersiveMapAttribution {
    ImmersiveMapAttribution(credits: [
        .init("© My City"),
        .init("Aerial © Survey Office", zoomRange: 14..<22),
    ])
}
func at3() -> some View {
    ImmersiveMapView()
        .attributionSettings(size: .small,
                             position: .bottomLeading,
                             margin: 8,
                             respectsBottomSafeArea: true,
                             textColor: SIMD4(0, 0, 0, 0.8),
                             emphasizesLeadingCredit: true,
                             showsEngineCredit: false)
}
func at4() -> some View {
    ImmersiveMapView()
        .attributionSettings(isVisible: false)
        .attributionProvidedExternally()
}

// camera
func c1() -> some View { ImmersiveMapView().cameraControlZones(pitch: false, zoom: false) }
func c2() -> some View {
    ImmersiveMapView()
        .cameraPosition(ImmersiveMapCameraPosition(latitudeDegrees: 48.8584,
                                                   longitudeDegrees: 2.2945,
                                                   zoom: 16,
                                                   bearing: 0,
                                                   pitch: 1.0))
}
struct C3: View {
    @State private var camera = ImmersiveMapCameraController()
    var body: some View {
        ImmersiveMapView()
            .cameraController(camera)
    }
    func f() {
        let position = start
        camera.jump(to: position)
        camera.fly(to: position)
        camera.fly(to: position,
                   options: CameraFlightOptions(duration: 4, altitudeStyle: .overviewFirst)) { finished in
            // false when a gesture or another command interrupted it
            _ = finished
        }
        camera.cancelFlight()
        camera.cancelFollow()
        _ = camera.currentCameraPosition()
        let tour = ImmersiveMapCameraTourController(camera: camera)
        tour.start(shots: [
            ImmersiveMapCameraTourShot(position: eiffelTower, holdAfter: 2),
            ImmersiveMapCameraTourShot(position: louvre, options: CameraFlightOptions(duration: 3)),
        ], loop: true)
    }
}
func c4() -> some View { ImmersiveMapView().enableCameraUIControls() }
func c5() -> some View {
    ImmersiveMapView()
        .zoomRange(minimum: 3, maximum: 18)
        .pitchRange(minimum: 0, maximum: 1.2)
        .bearingLimit(.pi / 2)  // at most a quarter turn from north
}
func c6() -> some View {
    ImmersiveMapView()
        .cameraBounds(southWest: GeoCoordinate(latitude: 55.57, longitude: 37.36),
                      northEast: GeoCoordinate(latitude: 55.92, longitude: 37.86))
}
func c7() -> some View { ImmersiveMapView().globeUprightPull(nil) }
func c8() -> some View { ImmersiveMapView().cameraBounds(nil) }

// style
func s1() -> some View {
    ImmersiveMapView()
        .mapStyle(.default.apply { theme in
            theme.layers.water = SIMD4(0.55, 0.75, 0.95, 1)
            theme.layers.park = SIMD4(0.70, 0.86, 0.62, 1)
            theme.labels.city.sizePoints = 18
            theme.labelOpacity.pois = [14: 0.6, 16: 1]
        })
}
func s2() -> some View { ImmersiveMapView().night() }
func s3() -> some View {
    ImmersiveMapView()
        .mapStyle(.night.apply { theme in theme.layers.water = SIMD4(0, 0, 0, 1) })
        .fogSettings(.night)
}
func s4() -> some View {
    ImmersiveMapView()
        .mapStyle(.default.apply { theme in
            theme = theme.globeLayers { layers in
                layers.water = SIMD4(0.2, 0.4, 0.8, 1)
            }
        })
}
func s5() -> some View { ImmersiveMapView().labelSettings(language: .russian) }
func s6() -> some View { ImmersiveMapView().labelSettings(language: ImmersiveMapSettings.LabelLanguage("ja"), fallbackPolicy: .localFirst) }
func s7() -> some View { ImmersiveMapView().labels(isEnabled: false) }

// custom-style
struct MonoStyle: ImmersiveMapVectorTileStyle {
    let cacheFingerprint: UInt32 = 1
    let styleID = "mono"

    func makeStyle(for feature: ImmersiveMapFeatureStyleContext) -> FeatureStyle {
        switch feature.layerName {
        case "earth":
            return .polygon(key: 1, color: SIMD4(0.95, 0.95, 0.95, 1))
        case "water":
            return .polygon(key: 2, color: SIMD4(0.75, 0.80, 0.85, 1))
        case "roads":
            return .line(key: 10, color: SIMD4(1, 1, 1, 1), width: 6)
        case "buildings":
            return .extrudedPolygon(key: 20, color: SIMD4(0.85, 0.85, 0.85, 1), fallbackHeight: 10)
        case "places":
            return .pointLabel(key: 30, LabelTextStyle(fillColor: SIMD3(0.2, 0.2, 0.2),
                                                       strokeColor: SIMD3(1, 1, 1),
                                                       haloEm: 0.15,
                                                       sizePoints: 14,
                                                       weight: .bold))
        default:
            return .hidden
        }
    }
}
typealias MyStyle = MonoStyle
func cs1() -> some View { ImmersiveMapView().mapStyle(VectorTileMapStyle(style: MonoStyle())) }
struct MySchema: ImmersiveMapTileSchema {
    let cacheFingerprint: UInt32 = 1

    func read(_ feature: ImmersiveMapFeature) -> ImmersiveMapFeatureFacts {
        switch feature.layerName {
        case "building":
            return .building(ImmersiveMapBuildingExtrusion(
                heightMetres: feature.properties.double("render_height").map(Float.init)))
        case "place":
            return .labelled(ImmersiveMapLabelFacts(name: feature.properties.string("name")))
        default:
            return .none
        }
    }
}
func cs2() -> some View {
    ImmersiveMapView()
        .tileArchive(myArchiveURL)
        .mapStyle(VectorTileMapStyle(style: MyStyle(), schema: MySchema()))
}

// relief
func r1() -> some View { ImmersiveMapView().groundRelief(isEnabled: true) }
func r2() -> some View { ImmersiveMapView().groundRelief(isEnabled: true, appearZoom: 9, collapseZoom: 15, transitionSeconds: 0.5) }
func r3() -> some View { ImmersiveMapView().groundRelief(isEnabled: true, exaggeration: 1.5) }
func r4() -> some View {
    ImmersiveMapView()
        .terrain(ImmersiveMapTerrainSource(tileURLTemplate: "https://terrain.example.com/{z}/{x}/{y}.png",
                                           encoding: .mapbox,
                                           credit: "© Example Terrain"))
        .groundRelief(isEnabled: true)
}
func r5() -> some View {
    ImmersiveMapView().mapStyle(.default.apply { theme in
        theme.hillshade.intensity = 0.5
        theme.terrainOcclusion.strength = 0.3
    })
}
func r6() -> some View { ImmersiveMapView().groundRelief(isEnabled: true, cameraClearanceMetres: 50) }
func r7() -> some View {
    ImmersiveMapView()
        .groundRelief(isEnabled: true)
        .onTerrainSurroundingsChange { surroundings in
            // surroundings?.kind is .mountains or .plain, nil off the relief
            _ = surroundings?.kind
        }
}

// scene
func sc1() -> some View {
    ImmersiveMapView()
        .globe(isEnabled: false)       // a flat map at every zoom
        .atmosphere(isEnabled: false)  // no glow around the globe
        .transparentSpace()            // your own background around the globe
}
func sc2() -> some View { ImmersiveMapView().globeLight(isEnabled: false) }
func sc3() -> some View {
    ImmersiveMapView()
        .sceneLight(direction: SIMD3(-0.5, -0.4, 0.8))  // towards the sun: x east, y north, z up
        .shadows(strength: 0.6, softness: 1.5)
}
func sc4() -> some View { ImmersiveMapView().shadows(isEnabled: false) }
func sc5() -> some View {
    ImmersiveMapView()
        .fog(isEnabled: false)        // no sky gradient
        .groundFog(isEnabled: false)  // no ground fog
}
func sc6() -> some View {
    ImmersiveMapView()
        .buildingExtrusion(buildingsMinimumZoom: 15, risesFromTheGround: false)
        .trees(minimumZoom: 15, maximumPerTile: 2000)
}
func sc7() -> some View {
    ImmersiveMapView()
        .msaa()   // 4 samples a pixel, the cleaner of the two
        .fxaa()   // one cheap pass over the finished frame
}

// layers
func l1() -> some View {
    ImmersiveMapView()
        .layers([
            ImmersiveMapLayer(id: "route",
                              polylines: [ImmersiveMapPolyline(coordinates: route)],
                              polylineStyle: ImmersiveMapPolylineStyle(color: SIMD4(0.9, 0.2, 0.2, 1), widthPoints: 4)),
            ImmersiveMapLayer(id: "stops",
                              points: stops.map { ImmersiveMapPoint(coordinate: $0) })
        ])
}
func l2() -> ImmersiveMapPolygon {
    ImmersiveMapPolygon(exterior: park,
                        style: ImmersiveMapPolygonStyle(fillColor: SIMD4(0.2, 0.7, 0.3, 0.3),
                                                        strokeColor: SIMD4(0.2, 0.7, 0.3, 1),
                                                        strokeWidthPoints: 2))
}
func l3() throws -> ImmersiveMapLayer {
    let districts = try ImmersiveMapLayer(id: "districts", geoJSON: data)
    return districts
}
func l4() -> ImmersiveMapLayer {
    ImmersiveMapLayer(id: "zones", polygons: zones,
                      isVisible: showZones,
                      zoomRange: 10...18,
                      hidesBehindTerrain: true)
}

// markers-and-taps
func m1() -> some View {
    ImmersiveMapView()
        .markers(places, coordinate: \.coordinate) { place in
            Label(place.name, systemImage: "mappin")
                .padding(6)
                .background(.thinMaterial, in: Capsule())
        }
}
struct M2: View {
    let placeholder: CGImage
    @State private var avatars = ImmersiveMapAvatarsController()

    var body: some View {
        ImmersiveMapView()
            .avatars(avatars)
            .onAppear {
                avatars.set([
                    AvatarMarker(id: 1,
                                 coordinate: GeoCoordinate(latitude: 55.75, longitude: 37.62),
                                 image: .remote(photoURL, placeholder: placeholder),
                                 batteryBadge: AvatarBatteryBadge(levelPct: 80)),
                ])
            }
    }
}
func m3() -> some View {
    ImmersiveMapView()
        .onAvatarTap { event in
            print("tapped avatar \(event.marker.id)")
        }
        .onSceneModelTap { event in
            print("tapped model \(event.model.id)")
        }
}
struct M4: View {
    @State private var selection = ImmersiveMapSelectionController()
    var body: some View {
        ImmersiveMapView()
            .selection(selection)
    }
    func f() {
        selection.select(ImmersiveMapSelection(kind: .avatar, objectID: 1))
        selection.clearSelection()
    }
}

// 3d-content
func d1() -> some View { ImmersiveMapView().modelArchive(ImmersiveMapTilesService.modelArchiveURL) }
func d2() -> some View {
    ImmersiveMapView().modelArchiveSettings(memoryBudgetInBytes: 300_000_000,
                                            depthBias: [14: 0.05, 15.5: 0.01],
                                            minimumZoom: 14)
}
func d3() -> some View { ImmersiveMapView().modelArchive(nil) }
struct D4: View {
    @State private var models = ImmersiveMapSceneModelsController()

    var body: some View {
        ImmersiveMapView()
            .sceneModels(models)
            .onAppear {
                models.set([
                    ImmersiveMapSceneModel(id: 1,
                                           source: .init(resource: "balloon", withExtension: "usdz")!,
                                           coordinate: GeoCoordinate(latitude: 48.8584, longitude: 2.2945),
                                           altitudeMeters: 120,
                                           headingDegrees: 90,
                                           fitDiameterMeters: 40),
                ])
            }
    }
    func f(start: GeoCoordinate, end: GeoCoordinate) {
        models.animate(id: 1,
                       along: ImmersiveMapGeoPath(from: start, to: end, peakAltitudeMeters: 300),
                       duration: 20) { finished in
            // false when it was interrupted
            _ = finished
        }
    }
}

// export
func e1() async throws -> CGImage {
    let recorder = ImmersiveMapStillRecorder()
    let image = try await recorder.capture(
        settings: .default,
        camera: ImmersiveMapCameraPosition(latitudeDegrees: 55.75, longitudeDegrees: 37.61, zoom: 14),
        configuration: ImmersiveMapStillConfiguration(width: 1280, height: 720))
    return image
}
struct E2: View {
    @State private var recorder = ImmersiveMapTourVideoRecorder()
    let end = start
    var body: some View {
        ImmersiveMapView()
            .tourVideoRecorder(recorder)
    }
    func f() async throws {
        try await recorder.export(
            shots: [
                ImmersiveMapCameraTourShot(position: start),
                ImmersiveMapCameraTourShot(position: end, options: CameraFlightOptions(duration: 6)),
            ],
            configuration: ImmersiveMapVideoExportConfiguration(width: 1920, height: 1080, framesPerSecond: 60),
            to: outputURL)
    }
}
