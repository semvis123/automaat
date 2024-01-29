import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var api: APIController
    @Environment(\.dismiss) var dismiss
    @State var firstName = ""
    @State var lastName = ""
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var loadingState: LoadingState? = nil

    var body: some View {
        VStack(alignment:.center,  spacing: 30) {
            Text("Maak een account aan om verder te gaan.")
            TextField("Voornaam", text: $firstName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.givenName)
            TextField("Achternaam", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.familyName)
            TextField("Gebruikersnaam", text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
                .autocapitalization(.none)
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            SecureField("Wachtwoord", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            Button(action: self.register) {
                Text("Registreren")
            }
            .buttonStyle(.borderedProminent)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            
            if loadingState == .loading {
                ProgressView("laden...")
            }
            if loadingState == .error {
                Text("Registratie mislukt.")
                    .foregroundStyle(.red)
            }
            if loadingState == .success {
                Text("Check uw email om uw account te activeren.")
                    .foregroundStyle(.green)
            }
        }
        .frame(width: 300, height: nil)
    }

    func register() {
        loadingState = .loading
        Task {
            do {
                try await api.register(username: username, password: password, firstName: firstName, lastName: lastName, email: email)
                loadingState = .success
            } catch {
                loadingState = .error
            }
        }
    }
}

#Preview {
    RegistrationView()
}
