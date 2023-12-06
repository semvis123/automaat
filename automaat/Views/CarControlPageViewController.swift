import Foundation
import SwiftUI

class CarControlPageViewController: UIViewController {
    var sheet: UISheetPresentationController?
    var serviceSheet: UIHostingController<CarServiceView>?
    var mapViewController: UIHostingController<CurrentCarView>?
    
    
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
        serviceSheet = UIHostingController(rootView: CarServiceView())
        
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
}

struct CarControlPageView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CarControlPageViewController {
        CarControlPageViewController()
    }
    
    func updateUIViewController(_ uiViewController: CarControlPageViewController, context: Context) {
    }
    
    typealias UIViewControllerType = CarControlPageViewController
}
