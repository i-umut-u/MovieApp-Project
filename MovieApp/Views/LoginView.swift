import SwiftUI

struct LoginView: View {
    @State private var requestToken: String?
    @State private var sessionID: String?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if let sessionID = sessionID {
                Text("Logged in! Session ID: \(sessionID)")
                    .foregroundColor(.green)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
        }
        .onAppear {
            if requestToken == nil && sessionID == nil {
                startLogin()
            }
        }
        .padding()
    }
    
    func startLogin() {
        SharedService.shared.getRequestToken { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    requestToken = token
                    if let url = URL(string: "https://www.themoviedb.org/authenticate/\(token)") {
                        UIApplication.shared.open(url)
                    }
                    
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.willEnterForegroundNotification,
                        object: nil,
                        queue: .main
                    ) { _ in
                        completeLogin()
                    }
                    
                case .failure(let error):
                    errorMessage = "Failed to get token: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func completeLogin() {
        guard let token = requestToken else { return }
        SharedService.shared.createSession(requestToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let id):
                    sessionID = id
                    UserDefaults.standard.set(id, forKey: "session_id")
                case .failure(let error):
                    errorMessage = "Failed to create session: \(error.localizedDescription)"
                }
            }
        }
    }
    
}
