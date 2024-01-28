import Foundation
import SwiftUI

/*
    View controller that has the responsibility of opening the car service sheet.
*/
class CarControlPageViewController: UIViewController {
    var sheet: UISheetPresentationController?
    var serviceSheet: UIHostingController<CarServiceView>?
    var mapViewController: UIHostingController<CurrentCarView>?
    var api: APIController?
    var rental: Rental?
    var theme: Theme?
    
    convenience init(api: APIController, theme: Theme) {
        self.init()
        self.api = api
        self.theme = theme
    }
    
    func setActiveRental(rental: Rental) {
        self.rental = rental
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: CurrentCarView(viewController: self))
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
    
    func openSheet() {
        serviceSheet = UIHostingController(rootView: CarServiceView(api: api!, rental: rental!, theme: theme!))
        
        if let sheet = serviceSheet!.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            self.sheet = sheet;
        }
        
        present(serviceSheet!, animated: true, completion: nil)
    }
    
    func closeSheet() {
        dismiss(animated: true)
    }
    
    func setTheme(theme: Theme) {
        self.theme = theme
    }
}

struct CarControlPageView: UIViewControllerRepresentable {
    @EnvironmentObject var api: APIController
    @Environment(\.theme) var theme: Theme
    
    func makeUIViewController(context: Context) -> CarControlPageViewController {
        CarControlPageViewController(api: api, theme: theme)
    }
    
    func updateUIViewController(_ uiViewController: CarControlPageViewController, context: Context) {
        uiViewController.setTheme(theme: theme)
    }
    
    typealias UIViewControllerType = CarControlPageViewController
}
