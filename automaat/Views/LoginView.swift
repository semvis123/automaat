import SwiftUI

struct LoginView: View {
    @EnvironmentObject var api: APIController
    
    @State var username = ""
    @State var password = ""
    @State var imageUrl: String? = nil
    @State var loading = false
    @State var error = false
    @State var isRegistering = false
    @State var isResettingPassword = false
    @State var didResetPassword = false
    @State var activatingAccountUrl: URL? = nil
    @State var activationError = false
    @State var activationSuccess = false
    
    var body: some View {
        NavigationView() {
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
                
                NavigationLink("Registreren", isActive: $isRegistering) {
                    RegistrationView()
                }
                .buttonStyle(.plain)
                
                NavigationLink("Wachtwoord resetten", isActive: $isResettingPassword) {
                    PasswordResetView(didResetPassword: $didResetPassword)
                }
                .buttonStyle(.plain)
                
                
                if loading {
                    ProgressView("Inloggen...")
                }
                if error {
                    Text("Inloggen mislukt.")
                        .foregroundStyle(.red)
                }
                if didResetPassword {
                    Text("Wachtwoord gereset.")
                        .foregroundStyle(.green)
                }
                
                if let url = activatingAccountUrl {
                    ProgressView("activeren...")
                        .onAppear {
                            Task {
                                do {
                                    try await api.activateAccount(url: url)
                                    activationSuccess = true
                                } catch {
                                    activationError = true
                                }
                                activatingAccountUrl = nil
                            }
                        }
                }
                
                if activationSuccess {
                    Text("Account geactiveerd! U kunt nu inloggen.")
                        .foregroundStyle(.green)
                }
                
                if activationError {
                    Text("Account activeren mislukt.")
                        .foregroundStyle(.red)
                }
            }
            .frame(width: 300, height: nil)
            .onOpenURL { url in
                if url.absoluteString.contains("passwordreset") {
                    isResettingPassword = true
                }
                else if url.absoluteString.contains("activate") {
                    activatingAccountUrl = url
                    isRegistering = false
                }
            }
        }
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
    
}

#Preview {
    LoginView().environmentObject(APIController())
}
