import SwiftUI

struct SeriesDetailView: View {
    let series: Series
    @State private var detail: SeriesDetail?
    @State private var credits: CreditsResponse?
    @State private var trailers: [Video] = []
    @State private var backdrops: [Backdrop] = []
    @State private var isFavorite: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var showSignInAlert = false
    @State private var alertMessage = ""

    
    private var displayedTrailers: [Video] {
        trailers.filter { $0.type == "Trailer" }
            .sorted { a, b in
                if a.name.lowercased().contains("official") && !b.name.lowercased().contains("official") { return true }
                if !a.name.lowercased().contains("official") && b.name.lowercased().contains("official") { return false }
                return a.name < b.name
            }
    }
    
    private var firstBackdropURL: URL? {
        if let first = backdrops.first { return URL(string: "https://image.tmdb.org/t/p/w500\(first.file_path)") }
        if let poster = detail?.poster_path { return URL(string: "https://image.tmdb.org/t/p/w500\(poster)") }
        return nil
    }
    
    private var voteAverageString: String {
        let average = detail?.vote_average ?? series.vote_average ?? 0.0
            return String(format: "%.1f", average)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                topImageView
                titleAndFavoriteButton
                genreAndInfoView
                descriptionView
                ratingAndWatchlistView
                
                Divider().padding(.vertical)
                
                creditsView
                
                Divider().padding(.vertical)

                trailersView
            }
            .padding(.vertical)
        }
        .onAppear(perform: loadSeriesDetail)
        .alert(isPresented: $showSignInAlert) {
            Alert(title: Text("Sign In Required"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private var topImageView: some View {
        AsyncImage(url: firstBackdropURL) { img in
            img.resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(8)
                .padding(.horizontal)
        } placeholder: {
            Color.gray.frame(height: 200).padding(.horizontal)
        }
    }

    private var titleAndFavoriteButton: some View {
        HStack {
            Text(detail?.name ?? series.name)
                .font(.largeTitle)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.title)
            }
            .padding(.trailing)
        }
    }

    private var genreAndInfoView: some View {
        HStack(spacing: 16) {
            if let genres = detail?.genres {
                Text(genres.prefix(2).map { $0.name }.joined(separator: ", "))
            }
            if let year = detail?.first_air_date?.prefix(4) {
                Text(String(year))
            }
            if let seasons = detail?.number_of_seasons,
               let episodes = detail?.number_of_episodes {
                Text("\(seasons) Season\(seasons > 1 ? "s" : ""), \(episodes) Episodes")
            }
            if let runtime = detail?.episode_run_time?.first {
                let hours = runtime / 60
                let minutes = runtime % 60
                if hours > 0 {
                    Text("\(hours)h \(minutes)m per ep")
                } else {
                    Text("\(minutes)m per ep")
                }
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }

    private var descriptionView: some View {
        Text(detail?.overview ?? series.overview)
            .padding(.horizontal)
    }
    
    private var ratingAndWatchlistView: some View {
        HStack {
            ratingView
            Spacer()
            watchlistButton
        }
        .padding(.horizontal)
    }

    private var ratingView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            
            Text("\(voteAverageString)/10")
        }
        .font(.headline)
    }

    private var watchlistButton: some View {
        Button(action: toggleWatchlist) {
            HStack(spacing: 4) {
                Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                Text("Watchlist")
            }
            .font(.subheadline)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .foregroundColor(isInWatchlist ? .blue : .primary)
            .cornerRadius(8)
        }
    }

    private var creditsView: some View {
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
                
                if let directors = credits?.crew.filter({ $0.job == "Director" }), !directors.isEmpty,
                   let producers = credits?.crew.filter({ $0.job == "Producer" }), !producers.isEmpty {
                    Spacer().frame(height: 8)
                }
                
                if let producers = credits?.crew.filter({ $0.job == "Producer" }), !producers.isEmpty {
                    Text("Producer(s):")
                        .font(.headline)
                    if let firstProducer = producers.first {
                        Text(firstProducer.name)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .padding(.horizontal)
    }

    private var trailersView: some View {
        VStack(alignment: .leading) {
            if !displayedTrailers.isEmpty {
                Text("Trailers:")
                    .font(.headline)
                    .padding([.horizontal, .bottom], 4)
                ForEach(displayedTrailers) { trailer in
                    if trailer.site == "YouTube" {
                        Link(trailer.name, destination: URL(string: "https://www.youtube.com/watch?v=\(trailer.key)")!)
                            .padding(.horizontal)
                            .padding(.bottom, 2)
                    }
                }
            }
        }
    }

    private func loadSeriesDetail() {
        SeriesService.shared.fetchSeriesDetail(id: series.id) { result in
            if case .success(let fetchedDetail) = result { detail = fetchedDetail }
        }
        SeriesService.shared.fetchSeriesCredits(id: series.id) { result in
            if case .success(let fetchedCredits) = result { credits = fetchedCredits }
        }
        SeriesService.shared.fetchSeriesVideos(id: series.id) { result in
            if case .success(let fetchedVideos) = result { trailers = fetchedVideos }
        }
        SeriesService.shared.fetchSeriesImages(id: series.id) { result in
            if case .success(let fetchedBackdrops) = result { backdrops = fetchedBackdrops }
        }
        loadFavoriteAndWatchlist()
    }

    private func loadFavoriteAndWatchlist() {
        guard let sessionID = UserDefaults.standard.string(forKey: "session_id") else { return }
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            if case .success(let account) = result {
                SeriesService.shared.getFavoriteSeries(accountID: account.id, sessionID: sessionID) { result in
                    if case .success(let response) = result {
                        DispatchQueue.main.async { isFavorite = response.results.contains(where: { $0.id == series.id }) }
                    }
                }
                SeriesService.shared.getWatchlistSeries(accountID: account.id, sessionID: sessionID) { result in
                    if case .success(let response) = result {
                        DispatchQueue.main.async { isInWatchlist = response.results.contains(where: { $0.id == series.id }) }
                    }
                }
            }
        }
    }
    
    private func toggleFavorite() {
            guard let sessionID = UserDefaults.standard.string(forKey: "session_id"), !sessionID.isEmpty else {
                alertMessage = "You need to sign in to use this feature."
                showSignInAlert = true
                return
            }
            
            SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
                if case .success(let account) = result {
                    SeriesService.shared.setFavoriteSeries(accountID: account.id, sessionID: sessionID, seriesID: series.id, favorite: !isFavorite) { _ in
                        DispatchQueue.main.async { isFavorite.toggle() }
                    }
                }
            }
        }

    private func toggleWatchlist() {
        guard let sessionID = UserDefaults.standard.string(forKey: "session_id"), !sessionID.isEmpty else {
            alertMessage = "You need to sign in to use this feature."
            showSignInAlert = true
            return
        }
        
        SharedService.shared.getAccountDetails(sessionID: sessionID) { result in
            if case .success(let account) = result {
                SeriesService.shared.setWatchlistSeries(accountID: account.id, sessionID: sessionID, seriesID: series.id, watchlist: !isInWatchlist) { _ in
                    DispatchQueue.main.async { isInWatchlist.toggle() }
                }
            }
        }
    }
     
}
