import Foundation

class MoviesViewModel: ObservableObject {
    @Published var nowPlaying: [Movie] = []
    @Published var popular: [Movie] = []
    @Published var upcoming: [Movie] = []
    @Published var topRated: [Movie] = []
    @Published var searchResults: [Movie] = []
    
    
    func loadNowPlaying() {
        MovieService.shared.fetchNowPlaying { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let nowPlaying) = result {
                    self?.nowPlaying = nowPlaying.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadPopular() {
        MovieService.shared.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let popular) = result {
                    self?.popular = popular.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadUpcoming() {
        MovieService.shared.fetchUpcoming { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let upcoming) = result {
                    self?.upcoming = upcoming.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadTopRated() {
        MovieService.shared.fetchTopRatedMovies { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let topRated) = result {
                    self?.topRated = topRated.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        MovieService.shared.searchMovies(query: query) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let movies) = result {
                    self?.searchResults = movies.filter { !($0.adult ?? false) }
                }
            }
        }
    }
}
