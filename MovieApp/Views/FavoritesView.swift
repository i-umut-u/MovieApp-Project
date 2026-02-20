import SwiftUI

struct FavoritesView: View {
    @State private var favoriteMovies: [Movie] = []
    @State private var favoriteSeries: [Series] = []
    @State private var showMovies = true
    
    private var sessionID: String {
        UserDefaults.standard.string(forKey: "session_id") ?? ""
    }
    
    let columns = Array(repeating: GridItem(.flexible(), spacing:12), count:3)
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button(action: { showMovies = true }) {
                    Text("Movies")
                        .font(.title2)
                        .bold()
                        .foregroundColor(showMovies ? .black : .gray)
                }
                
                Button(action: { showMovies = false }) {
                    Text("Series")
                        .font(.title2)
                        .bold()
                        .foregroundColor(showMovies ? .gray : .black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                if showMovies {
                    if favoriteMovies.isEmpty {
                        Spacer()
                        Text("No movies in favorites...")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        MovieGrid(movies: favoriteMovies)
                    }
                } else {
                    if favoriteSeries.isEmpty {
                        Spacer()
                        Text("No series in favorites...")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        SeriesGrid(series: favoriteSeries)
                    }
                }
            }
            
        }
        .navigationTitle("Favorites")
        .onAppear {
            loadFavorites()
        }
    }
    
    func loadFavorites() {
        guard !sessionID.isEmpty else { return }
        let session = sessionID
        
        SharedService.shared.getAccountDetails(sessionID: session) { result in
            if case .success(let account) = result {
                MovieService.shared.getFavoriteMovies(accountID: account.id, sessionID: session) { result in
                    if case .success(let response) = result {
                        DispatchQueue.main.async {
                            self.favoriteMovies = response.results.reversed()
                        }
                    }
                }
            }
        }
        
        SharedService.shared.getAccountDetails(sessionID: session) { result in
            if case .success(let account) = result {
                SeriesService.shared.getFavoriteSeries(accountID: account.id, sessionID: session) { result in
                    if case .success(let response) = result {
                        DispatchQueue.main.async {
                            self.favoriteSeries = response.results.reversed()
                        }
                    }
                }
            }
        }
        
    }
    
}
