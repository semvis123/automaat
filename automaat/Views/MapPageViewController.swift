import Foundation
import SwiftUI

class MapPageViewController: UIViewController, UISheetPresentationControllerDelegate {
    var animation: Namespace.ID?
    var sheet: UISheetPresentationController?
    var carSheetViewController: UIHostingController<CarSheetView>?
    var mapViewController: UIHostingController<MapView>?
    var onSheetClose: (() -> ())?
    var imageFetcher: ImageFetcher?
    
    convenience init(animation: Namespace.ID, imageFetcher: ImageFetcher) {
        self.init()
        self.animation = animation
        self.imageFetcher = imageFetcher
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: MapView(viewController: self))
        mapViewController = vc
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(vc)
        view.addSubview(swiftuiView)
        
        NSLayoutConstraint.activate([
            swiftuiView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftuiView.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftuiView.widthAnchor.constraint(equalTo: view.widthAnchor),
            swiftuiView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        vc.didMove(toParent: self)
    }
    
    func openSheet(car: Car, etaData: Binding<EtaData?>, onClose: @escaping () -> ()) {
        carSheetViewController = UIHostingController(rootView:
                                                        CarSheetView(
                                                            car: car,
                                                            etaData: etaData,
                                                            imageFetcher: imageFetcher!,
                                                            animation: animation!,
                                                            mapViewController: self
                                                        )
        )
        
        if let sheet = carSheetViewController!.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.delegate = self
            self.sheet = sheet;
        }
        
        onSheetClose = onClose
        present(carSheetViewController!, animated: true, completion: nil)
    }
    
    func closeSheet() {
        dismiss(animated: true)
        onSheetClose?()
    }
    
    
    func lockSheetSize(large: Bool) {
        if large {
            sheet?.animateChanges {
                sheet?.selectedDetentIdentifier = .large
                sheet?.detents = [.large()]
                sheet?.prefersGrabberVisible = false
            }
        } else {
            sheet?.animateChanges {
                sheet?.detents = [.medium(), .large()]
                sheet?.prefersGrabberVisible = true
            }
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onSheetClose?()
    }
}

struct MapPageView: UIViewControllerRepresentable {
    @EnvironmentObject var imageFetcher: ImageFetcher
    var animation: Namespace.ID
    
    func makeUIViewController(context: Context) -> MapPageViewController {
        MapPageViewController(animation: animation, imageFetcher: imageFetcher)
    }
    
    func updateUIViewController(_ uiViewController: MapPageViewController, context: Context) {
    }
    
    typealias UIViewControllerType = MapPageViewController
}
