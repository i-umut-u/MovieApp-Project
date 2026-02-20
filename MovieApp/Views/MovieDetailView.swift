import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @State private var detail: MovieDetail?
    @State private var credits: CreditsResponse?
    @State private var trailers: [Video] = []
    @State private var backdrops: [Backdrop] = []
    @State private var isFavorite: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var showSignInAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                // Single top image
                if let firstBackdrop = backdrops.first {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(firstBackdrop.file_path)")) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(8)
                            .padding(.horizontal)
                    } placeholder: {
                        Color.gray.frame(height: 200).padding(.horizontal)
                    }
                } else {
                    // Fallback poster
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(detail?.poster_path ?? "")")) { img in
                        img.resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    } placeholder: {
                        Color.gray.frame(height: 200).padding(.horizontal)
                    }
                }
                
                // Movie title
                HStack {
                    Text(detail?.title ?? movie.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button(action: {
                        guard let sessionID = UserDefaults.standard.string(forKey: "session_id"), !sessionID.isEmpty else {
                            alertMessage = "You need to sign in to use this feature"
                            showSignInAlert = true
                            return
                        }
                        toggleFavoriteMovies()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                            .font(.title)
                    }
                    .padding(.trailing)
                }
                
                // Genre, Year, Length
                HStack(spacing: 16) {
                    if let genres = detail?.genres {
                        let displayedGenres = genres.prefix(2).map { $0.name }
                        Text(displayedGenres.joined(separator: ", "))
                    }
                    if let year = detail?.release_date?.prefix(4) {
                        Text(String(year))
                    }
                    if let runtime = detail?.runtime {
                        let hours = runtime / 60
                        let minutes = runtime % 60
                        Text("\(hours)h \(minutes)m")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                
                Text(detail?.overview ?? movie.overview)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    (
                        Text("★").foregroundColor(.yellow) +
                        Text(" \(String(format: "%.1f", detail?.vote_average ?? movie.vote_average))/10")
                    )
                    .font(.headline)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        guard let sessionID = UserDefaults.standard.string(forKey: "session_id"), !sessionID.isEmpty else {
                            alertMessage = "You need to sign in to use this feature"
                            showSignInAlert = true
                            return
                        }
                        toggleWatchlistMovies()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                                .foregroundColor(isInWatchlist ? .blue : .gray)
                            Text("Watchlist")
                                .foregroundColor(.primary)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    
                }
                
                Divider().padding(.vertical)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Starring:")
                            .font(.headline)
                        if let cast = credits?.cast.prefix(8) {
                            ForEach(cast) { member in
                                Text(member.name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let directors = credits?.crew.filter({ $0.job == "Director" }), !directors.isEmpty {
                            Text("Director(s):")
                                .font(.headline)
                            ForEach(directors) { director in
                                Text(director.name)
                            }
                        }
                        Spacer().frame(height: 8)
                        if let producers = credits?.crew.filter({ $0.job == "Producer" }), !producers.isEmpty {
                            Text("Producer(s):")
                                .font(.headline)
                            Text(producers.first!.name)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                }
                .padding(.horizontal)
                
                Divider().padding(.vertical)
                
                // Trailers
                if !trailers.isEmpty {
                    Text("Trailers:")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(trailers) { trailer in
                        if trailer.site == "YouTube" {
                            Link(trailer.name, destination: URL(string: "https://www.youtube.com/watch?v=\(trailer.key)")!)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            // Load movie detail
            MovieService.shared.fetchMovieDetail(id: movie.id) { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedDetail) = result {
                        detail = fetchedDetail
                    }
                }
            }
            
            // Load credits
            MovieService.shared.fetchMovieCredits(id: movie.id) { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedCredits) = result {
                        credits = fetchedCredits
                    }
                }
            }
            
            // Load trailers
            MovieService.shared.fetchMovieVideos(id: movie.id) { result in
                    DispatchQueue.main.async {
                        if case .success(let fetchedVideos) = result {
                            var trailerList = fetchedVideos.filter { $0.type == "Trailer" }
                            trailerList.sort { a, b in
                                if a.name.lowercased().contains("official") && !b.name.lowercased().contains("official") {
                                    return true
                                } else if !a.name.lowercased().contains("official") && b.name.lowercased().contains("official") {
                                    return false
                                } else {
                                    return a.name < b.name
                                }
                            }
                            trailers = trailerList
                        }
                    }
                }
            
            // Load horizontal backdrops
            MovieService.shared.fetchMovieImages(id: movie.id) { result in
                DispatchQueue.main.async {
                    if case .success(let fetchedBackdrops) = result {
                        backdrops = fetchedBackdrops
                    }
                }
            }
            
            if let sessionID = UserDefaults.standard.string(forKey: "session_id") {
                    SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
                            if case .success(let account) = result {
                                MovieService.shared.getFavoriteMovies(accountID: account.id, sessionID: sessionID) { result in
                                    DispatchQueue.main.async {
                                        if case .success(let response) = result {
                                            isFavorite = response.results.contains(where: { $0.id == movie.id })
                                        }
                                    }
                                }
                                
                                MovieService.shared.getWatchlistMovies(accountID: account.id, sessionID: sessionID) { result in
                                    DispatchQueue.main.async {
                                        if case .success(let response) = result {
                                            isInWatchlist = response.results.contains(where: { $0.id == movie.id })
                                        }
                                    }
                                }
                            }
                    }
            }
        }
        .alert(isPresented: $showSignInAlert) {
            Alert(title: Text("Sign In Required"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    
    private func toggleFavoriteMovies() {
        guard let sessionID = UserDefaults.standard.string(forKey: "session_id") else { return }
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            if case .success(let account) = result {
                MovieService.shared.setFavoriteMovies(accountID: account.id, sessionID: sessionID, movieID: movie.id, favorite: !isFavorite) { result in
                    DispatchQueue.main.async {
                        if case .success = result {
                            isFavorite.toggle()
                        }
                    }
                }
            }
        }
    }
    
    private func toggleWatchlistMovies() {
        guard let sessionID = UserDefaults.standard.string(forKey: "session_id") else { return }
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            if case .success(let account) = result {
                MovieService.shared.setWatchlistMovies(accountID: account.id, sessionID: sessionID, movieID: movie.id, watchlist: !isInWatchlist) { result in
                    DispatchQueue.main.async {
                        if case .success = result {
                            isInWatchlist.toggle()
                        }
                    }
                }
            }
        }
    }
    
    
}
