import SwiftUI


struct ExpandViewer <Content: View>: View {
    var title: String
    @State private var isExpanded = false
    @ViewBuilder let expandableView : Content
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation(.easeIn(duration: 0.3)) {
                    self.isExpanded.toggle()
                }
                
            }){
                VStack(alignment: .leading) {
                    HStack {
                        Text((!self.isExpanded ? "↓" : "↑"))
                            .padding(.trailing)
                            .font(.title2)
                        Text(title)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .background(.accent)
                    .cornerRadius(5.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white, lineWidth: 2)
                    )
                }

            }
            
            if self.isExpanded {
                 self.expandableView
            }
            
        }.padding()
       
    }
}



struct CarServiceView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("lifebuoy")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.accent)
                    .padding(.bottom)
                
                NavigationLink {
                    Text("FAQ")
                        .font(.largeTitle)
                    ExpandViewer(title: "Is er een reserve band aanwezig in gehuurde auto's?") {
                        Text("Nee")
                    }
                    ExpandViewer(title: "Is er een FAQ beschikbaar?") {
                        Text("Ja, die bevindt zich in de app.")
                    }
                    ExpandViewer(title: "Hoe ontgrendel ik de auto?") {
                        Text("Gebruik de grote knop in de app.")
                    }
                } label: {
                    Text("FAQ")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
                .foregroundStyle(.white)

                NavigationLink {
                    CarDamageReportView()
                } label: {
                    Text("Schade melden")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
                .foregroundStyle(.white)

                NavigationLink {
                    Text("Hoe kunnen we je helpen?")
                        .padding()
                        .font(.title)
                    Image("helpdesk")
                        .resizable().scaledToFit()
                        .frame(width: 500, height: 300)
                    Spacer()
                } label: {
                    Text("Helpdesk")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
                .foregroundStyle(.white)

                Spacer()
            }
        }
    }
}

#Preview {
    CarServiceView()
}
