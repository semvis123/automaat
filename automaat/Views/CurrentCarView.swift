import SwiftUI
import Map
import MapKit
import Foundation

class ColorOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let color: UIColor
    
    init(color: UIColor) {
        boundingMapRect = .world
        coordinate = .init()
        self.color = color
    }
}


class ColorOverlayRenderer: MKOverlayRenderer {
    override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
    }
    
    override func draw(
        _ mapRect: MKMapRect,
        zoomScale: MKZoomScale,
        in context: CGContext
    ) {
        guard let clOverlay = overlay as? ColorOverlay else {
            return
        }
        
        context.setFillColor(clOverlay.color.cgColor)
        let rect = CGRect(x: mapRect.origin.x, y: mapRect.origin.y, width: mapRect.width, height: mapRect.height)
        context.fill(rect)
    }
}


struct CurrentCarView: View {
    @EnvironmentObject var imageFetcher: ImageFetcher
    var api: APIController
    @Environment(\.theme) var theme: Theme
    @Environment(\.colorScheme) var colorScheme
    @State var currPage: Int = 1
    @State var carImage: Data? = nil
    @State var pressedUnlockBtn = false
    @State var pressedUnlockBtnAnimating = false
    @State var regionVar: MKCoordinateRegion?
    @State var isPresentingConfirm = false
    @State var annotations: [CarMapAnnotation] = []
    @State var car: Car? = nil
    @State var rental: Rental? = nil
    var viewController: CarControlPageViewController
    var locationManager = CLLocationManager()
    
    private var region: Binding<MKCoordinateRegion> { Binding (
        get: {
            self.regionVar ?? MKCoordinateRegion(center: annotations.count > 0 ? annotations[0].coordinate : .init(latitude: 82, longitude: 6.5),
                                                 latitudinalMeters: 5000,
                                                 longitudinalMeters: 5000)
        },
        set: {
            self.regionVar = $0
        }
    )}
    
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color.init(hue: 0, saturation: 0, brightness: 0.05)
                    .ignoresSafeArea(edges: .top)
            }
            if let car = car {
                VStack {
                    HStack {
                        Image(systemName: "stop.circle")
                            .resizable().frame(width: 30,height: 30)
                            .onTapGesture {
                                isPresentingConfirm = true
                            }
                            .confirmationDialog("Weet je zeker dat je de sessie wilt sluiten?",
                                                isPresented: $isPresentingConfirm) {
                                Button("Stop huur sessie", role: .destructive) {
                                    Task {
                                        do {
                                            try await api.stopRental(rental: rental!)
                                            self.car = nil
                                        } catch {
                                            print("could not stop it?")
                                        }
                                    }
                                }
                            }
                        
                        Spacer()
                        Text("\(car.brand ?? "") \(car.model ?? "")")
                        Spacer()
                        Image("lifebuoy")
                            .resizable().frame(width: 30,height: 30)
                            .onTapGesture {
                                viewController.openSheet()
                            }
                    }
                    .padding(.horizontal)
                    FetchedImage(preset: .CarFront, car: car)
                        .frame(width: 300, height: 200)
                    HStack {
                        Text("124 minuten")
                        Spacer()
                        Text("245KM")
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom)
                    ZStack {
                        ZStack {
                            Circle()
                                .fill(.background)
                                .shadow(color: theme.color, radius: 30)
                                .frame(width: 120,height: 120)
                            if pressedUnlockBtn {
                                Circle()
                                    .fill(theme.color)
                                    .shadow(color: theme.color, radius: pressedUnlockBtnAnimating ? 30 : 0)
                                    .frame(width: 120,height: 120)
                                    .transition(.scale)
                                    .animation(.smooth, value: UUID())
                            }
                            
                            Circle()
                                .stroke(theme.color, lineWidth: 3)
                                .frame(width: 120,height: 120)
                            Circle()
                                .stroke(theme.color)
                                .frame(width: 110,height: 110)
                            
                            if pressedUnlockBtn {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                    .frame(width: 120,height: 120)
                                Circle()
                                    .stroke(.white)
                                    .frame(width: 110,height: 110)
                            }
                            if pressedUnlockBtn {
                                Text("Lock")
                            } else {
                                Text("Unlock")
                            }
                        }
                        .onLongPressGesture(minimumDuration: .infinity) {}
                    onPressingChanged: { starting in
                        if starting {
                            withAnimation {
                                pressedUnlockBtn = !pressedUnlockBtn
                                pressedUnlockBtnAnimating = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                withAnimation {
                                    pressedUnlockBtnAnimating = false
                                }
                            }
                            
                        }
                    }
                    .frame(width: 250, height: 250)
                    .drawingGroup()
                    .padding(.bottom, 30)
                    }.frame(width: 150, height: 150)
                    
                    ZStack {
                        Map(coordinateRegion: region, informationVisibility: [.userLocation],
                            annotationItems: annotations,
                            annotationContent: {location in
                            ViewMapAnnotation(coordinate: location.coordinate) {
                                VStack {
                                    Image(systemName: "car.fill")
                                        .resizable()
                                        .foregroundColor(colorScheme == .dark ? .white : theme.color)
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(10)
                                        .background(.thickMaterial)
                                        .clipShape(Circle())
                                }
                            }
                        }, overlays: [ColorOverlay(color: .black.withAlphaComponent(0.2))], overlayContent: { overlay in
                            RendererMapOverlay(overlay: overlay) { mapView, overlay in
                                if let clOverlay = overlay as? ColorOverlay {
                                    return ColorOverlayRenderer(overlay: clOverlay)
                                }
                                return MKOverlayRenderer(overlay: overlay)
                            }
                        })
                        .frame(height: 200)
                        .saturation(0.1)
                        .contrast(1.5)
                    }
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding()
                }
            } else {
                Text("Er is geen actieve auto sessie.")
            }
        }
        .onAppear() {
            Task {
                do {
                    try await api.waitForRefresh()
                    rental = api.rentals.first(where: {
                        $0.from != nil && Calendar.current.isDateInToday($0.from!) &&
                        $0.state == "ACTIVE"
                    })
                    
                    if let rental = rental {
                        car = api.cars.first(where: { $0.backendId == rental.car })
                        guard car != nil else {
                            return
                        }
                        regionVar = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: car!.latitude!.doubleValue, longitude: car!.longitude!.doubleValue),
                                                       latitudinalMeters: 5000,
                                                       longitudinalMeters: 5000)
                        annotations = [CarMapAnnotation(car: car!)]
                        viewController.setActiveRental(rental: rental)
                    }
                } catch {}
            }
        }
    }
}

