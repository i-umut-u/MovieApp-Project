import SwiftUI

struct ProfileView: View {
    @State private var account: SharedService.Account?
    @State private var favorites: [Movie] = []
    @State private var watchlist: [Movie] = []
    @State private var errorMessage: String?
    @State private var sessionID: String = UserDefaults.standard.string(forKey: "session_id") ?? ""
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Not logged in
                        if sessionID.isEmpty {
                            VStack(spacing: 20) {
                                Text("Please log in to view your profile")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
                                // Go to login button
                                NavigationLink(destination: LoginView()) {
                                    Text("Go to Login")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        }
                        
                        // Account loaded
                        else if let account = account {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Username: \(account.username)")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            
                            NavigationLink(destination: FavoritesView()) {
                                Text("Favorites")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            NavigationLink(destination: WatchlistView()) {
                                Text("Watchlist")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        else {
                            Text("Loading profile...")
                                .padding()
                        }
                    }
                }
                Spacer()
                if !sessionID.isEmpty {
                    Button(action: logout) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            sessionID = UserDefaults.standard.string(forKey: "session_id") ?? ""
            loadData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                let savedSession = UserDefaults.standard.string(forKey: "session_id") ?? ""
                if savedSession != sessionID {
                    DispatchQueue.main.async {
                        sessionID = savedSession
                        loadData()
                    }
                }
            }
        }
    }
    
    func loadData() {
        guard !sessionID.isEmpty else {
            account = nil
            favorites = []
            watchlist = []
            return
        }
        
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let acc):
                    account = acc
                    loadFavoritesAndWatchlist(for: acc.id)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadFavoritesAndWatchlist(for accountID: Int) {
        MovieService.shared.getFavoriteMovies(accountID: accountID, sessionID: sessionID) { result in
            DispatchQueue.main.async {
                if case .success(let resp) = result {
                    favorites = resp.results
                }
            }
        }
        MovieService.shared.getWatchlistMovies(accountID: accountID, sessionID: sessionID) { result in
            DispatchQueue.main.async {
                if case .success(let resp) = result {
                    watchlist = resp.results
                }
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "session_id")
        sessionID = ""
        account = nil
        favorites = []
        watchlist = []
        errorMessage = nil
    }
    
}
