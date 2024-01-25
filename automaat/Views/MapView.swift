import SwiftUI
import MapKit
import Map
import CoreLocation

struct EtaData {
    var time: Double
    var distance: Double
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

struct CarMapAnnotation: Identifiable, Equatable {
    var id = UUID()
    let coordinate: CLLocationCoordinate2D
    let car: Car
    static func ==(lhs: CarMapAnnotation, rhs: CarMapAnnotation) -> Bool {
        return lhs.id == rhs.id
    }
    init(car: Car) {
        self.coordinate = .init(latitude: CLLocationDegrees(truncating: car.latitude!), longitude: CLLocationDegrees(truncating: car.longitude!))
        self.car = car
    }
}

struct MapView: View {
    @EnvironmentObject var imageFetcher: ImageFetcher
    @EnvironmentObject var api: APIController
    @State var regionVar: MKCoordinateRegion?
    @State var annotations: [CarMapAnnotation] = []
    @State var sheetDetail: Car?
    @State var activeLocation: CarMapAnnotation?
    @State var route: MKPolyline?
    @State var etaData: EtaData?
    
    var viewController: MapPageViewController
    var locationManager = CLLocationManager()
    private var region: Binding<MKCoordinateRegion> { Binding (
        get: {
            self.regionVar ?? MKCoordinateRegion(center: locationManager.location?.coordinate ?? .init(latitude: 53, longitude: 6.5),
                                                 latitudinalMeters: 100_000,
                                                 longitudinalMeters: 100_000)
        },
        set: {
            self.regionVar = $0
        }
    )}
    
    var body: some View {
        VStack {
            Map(coordinateRegion: region,
                informationVisibility: [.userLocation],
                interactionModes: [.pan, .rotate, .zoom],
                annotationItems: annotations, annotationContent: {location in
                ViewMapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "car.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(10)
                            .background(location == activeLocation ? .thickMaterial : .thinMaterial)
                            .clipShape(Circle())
                    }
                    .onTapGesture {
                        let request = MKDirections.Request()
                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate, addressDictionary: nil))
                        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary: nil))
                        request.requestsAlternateRoutes = false
                        request.transportType = .walking
                        
                        withAnimation {
                            activeLocation = location
                            viewController.closeSheet()
                        }
                        
                        
                        let directions = MKDirections(request: request)
                        
                        etaData = nil
                        directions.calculate { response, error in
                            guard let unwrappedResponse = response else { return }
                            
                            if (unwrappedResponse.routes.count > 0) {
                                let r = unwrappedResponse.routes[0]
                                route = r.polyline
                                etaData = EtaData(time: r.expectedTravelTime/60, distance: r.distance)
                            }
                            withAnimation {
                                var rect = route!.boundingMapRect
                                let origHeight = rect.size.height
                                rect.size.height = max(rect.size.height, rect.size.width) * 2.5
                                rect.origin.y -= rect.height / ((origHeight / rect.width) * 12)
                                regionVar = MKCoordinateRegion(rect)
                            }
                        }
                        
                        sheetDetail = location.car
                        if sheetDetail != nil {
                            viewController.openSheet(api: api, car: sheetDetail!, etaData: $etaData) {
                                activeLocation = nil
                                route = nil
                            }
                        }
                    }
                }
            }, overlays: route == nil ? [] : [route!], overlayContent: { overlay in
                RendererMapOverlay(overlay: overlay) { mapView, overlay in
                    guard let polyline = overlay as? MKPolyline else {
                        assertionFailure("Unknown overlay type encountered.")
                        return MKOverlayRenderer(overlay: overlay)
                    }
                    let renderer = MKPolylineRenderer(polyline: polyline)
                    renderer.lineWidth = 4
                    renderer.alpha = 0.7
                    renderer.strokeColor = .systemBlue
                    return renderer
                }
            }
            )
            .edgesIgnoringSafeArea(.top)
            .scaledToFill()
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                Task {
                    let ctx = PersistenceController.shared.container.viewContext
                    let request = Car.fetchRequest()
                    let cars = try? ctx.fetch(request)
                    if let cars = cars {
                        annotations = cars.map {
                            CarMapAnnotation(car: $0)
                        }
                    }
                }
            }
        }
    }
}
