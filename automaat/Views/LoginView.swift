import SwiftUI

struct LoginView: View {
    @EnvironmentObject var api: APIController
    
    @State var username = ""
    @State var password = ""
    @State var imageUrl: String? = nil
    @State var loading = false
    @State var error = false
    
    var body: some View {
        VStack(alignment:.center,  spacing: 30) {
            Text("U bent momenteel niet ingelogt. Maak een account aan of login om verder te gaan.")
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            
            Button(action: self.signIn) {
                Text("Inloggen")
            }
            .buttonStyle(.borderedProminent)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            
            Button(action: self.resetPassword) {
                Text("Wachtwoord resetten")
            }
            .buttonStyle(.plain)
        
            if loading {
                ProgressView("Inloggen...")
            }
            if error {
                Text("Inloggen mislukt.")
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 300, height: nil)
    }
    
    func signIn() {
        loading = true
        error = false
        Task {
            do {
                try await api.login(username: username, password: password)
            } catch {
                self.error = true
            }
            loading = false
        }
    }
    
    func resetPassword() {
        
    }
}

#Preview {
    LoginView().environmentObject(APIController())
}
