import Foundation
import SwiftUI

class MapPageViewController: UIViewController, UISheetPresentationControllerDelegate {
    var animation: Namespace.ID?
    var sheet: UISheetPresentationController?
    var carSheetViewController: UIHostingController<CarSheetView>?
    var mapViewController: UIHostingController<MapView>?
    var theme: Theme?
    var onSheetClose: (() -> ())?
    var imageFetcher: ImageFetcher?
    
    convenience init(animation: Namespace.ID, imageFetcher: ImageFetcher, theme: Theme) {
        self.init()
        self.animation = animation
        self.imageFetcher = imageFetcher
        self.theme = theme
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
    
    func openSheet(api: APIController, car: Car, etaData: Binding<EtaData?>, onClose: @escaping () -> ()) {
        carSheetViewController = UIHostingController(rootView:
                                                        CarSheetView(
                                                            api: api,
                                                            car: car,
                                                            etaData: etaData,
                                                            imageFetcher: imageFetcher!,
                                                            animation: animation!,
                                                            mapViewController: self,
                                                            theme: theme!
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
    
    func setTheme(theme: Theme) {
        self.theme = theme
    }
}

struct MapPageView: UIViewControllerRepresentable {
    @EnvironmentObject var imageFetcher: ImageFetcher
    @Environment(\.theme) private var theme
    var animation: Namespace.ID    
    
    func makeUIViewController(context: Context) -> MapPageViewController {
        MapPageViewController(animation: animation, imageFetcher: imageFetcher, theme: theme)
    }
    
    func updateUIViewController(_ uiViewController: MapPageViewController, context: Context) {
        uiViewController.setTheme(theme: theme)       
    }
    
    typealias UIViewControllerType = MapPageViewController
}
