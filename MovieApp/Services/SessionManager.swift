import Foundation
import Combine

// Manage login session
class SessionManager: ObservableObject {
    @Published var sessionID: String = UserDefaults.standard.string(forKey: "session_id") ?? ""
    
    var isLoggedIn: Bool {
        !sessionID.isEmpty
    }
    
    var validSessionID: String? {
        sessionID.isEmpty ? nil : sessionID
    }
    
    func updateSession(_ id: String) {
        sessionID = id
        UserDefaults.standard.set(id, forKey: "session_id")
    }
    
    func clearSession() {
        sessionID = ""
        UserDefaults.standard.removeObject(forKey: "session_id")
    }
}
