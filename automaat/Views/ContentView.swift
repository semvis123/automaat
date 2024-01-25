import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selection = 2
    @Namespace var animation
    
    var body: some View {
        TabView(selection: $selection) {
            CarListView()
                .tabItem {
                    Label("Cars", systemImage: "car.fill")
                }
                .tag(1)
            MapPageView(animation: animation)
                .ignoresSafeArea(.all)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(2)
            CarControlPageView()
                .ignoresSafeArea(edges: .top)
                .tabItem {
                    Label {
                        Text("Your car")
                    } icon: {
                        Image("steeringwheel")
                            .imageScale(.large)
                    }
                }
                .tag(3)
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }.onOpenURL { url in
            if url.absoluteString.contains("passwordreset") || url.absoluteString.contains("activate") {
                selection = 4
            }
        }

    }
    
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//
//}
