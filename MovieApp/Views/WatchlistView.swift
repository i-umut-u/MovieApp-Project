import SwiftUI

struct WatchlistView: View {
    @State private var watchlistMovies: [Movie] = []
    @State private var watchlistSeries: [Series] = []
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
                    if watchlistMovies.isEmpty {
                        Spacer()
                        Text("No movies in favorites...")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        MovieGrid(movies: watchlistMovies)
                    }
                } else {
                    if watchlistSeries.isEmpty {
                        Spacer()
                        Text("No series in favorites...")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        SeriesGrid(series: watchlistSeries)
                    }
                }
            }
            
        }
        .navigationTitle("Watchlist")
        .onAppear {
            loadWatchlist()
        }
    }
    
    func loadWatchlist() {
        guard !sessionID.isEmpty else { return }
        let session = sessionID
        
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            DispatchQueue.main.async {
                if case .success(let account) = result {
                    MovieService.shared.getWatchlistMovies(accountID: account.id, sessionID: sessionID) { result in
                        DispatchQueue.main.async {
                            if case .success(let response) = result {
                                watchlistMovies = response.results.reversed()
                            }
                        }
                    }
                }
            }
        }
        
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            DispatchQueue.main.async {
                if case .success(let account) = result {
                    SeriesService.shared.getWatchlistSeries(accountID: account.id, sessionID: sessionID) { result in
                        DispatchQueue.main.async {
                            if case .success(let response) = result {
                                watchlistSeries = response.results.reversed()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
}
