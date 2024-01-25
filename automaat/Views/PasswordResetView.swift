import SwiftUI

enum LoadingState {
    case loading
    case error
    case success
}

struct PasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var api: APIController
    
    @Binding var didResetPassword: Bool
    @State var firstStage = true
    @State var magicUrl: URL? = nil
    @State var input = ""
    @State var loadingState: LoadingState? = nil
    
    var body: some View {
        VStack(alignment:.center,  spacing: 30) {
            if firstStage {
                Text("Voer uw email adres in om een wachtwoord reset link te ontvangen.")
            } else {              
                Text("Voer uw nieuwe wachtwoord in.")
            }
            TextField(firstStage ? "Email" : "Wachtwoord", text: $input)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
            Button(action: self.resetPassword) {
                Text("Reset wachtwoord")
            }
            .buttonStyle(.borderedProminent)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
                        
            if loadingState == .loading {
                ProgressView("laden...")
            }
            if loadingState == .error {
                if firstStage {
                    Text("Email verzenden mislukt.")
                        .foregroundStyle(.red)
                } else {
                    Text("Wachtwoord resetten mislukt.")
                        .foregroundStyle(.red)
                }
            }
            if loadingState == .success {
                if firstStage {
                    Text("Email verzonden.")
                        .foregroundStyle(.green)
                } else {
                    Text("Wachtwoord gereset.")
                        .foregroundStyle(.green)
                }
            }
        }
        .frame(width: 300, height: nil)
        .onOpenURL { url in
            magicUrl = url
            firstStage = false
            input = ""
            loadingState = nil
        }
    }
    
    func resetPassword() {
        Task {
            loadingState = .loading
            do {
                if firstStage {
                    try await api.requestPasswordReset(email: input)
                } else {
                    try await api.completePasswordReset(url: magicUrl!, newPassword: input)
                    didResetPassword = true
                    dismiss()
                }
                loadingState = .success
            } catch {
                loadingState = .error
            }
        }
    }
}
//
//#Preview {
////    PasswordResetView()
//}
