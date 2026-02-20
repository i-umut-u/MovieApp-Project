import Foundation

class MovieService {
    static let shared = MovieService()
    private let baseURL = "https://api.themoviedb.org/3"
    
    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + path)
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: APIConfig.apiKey))
        components?.queryItems = items
        return components?.url
    }
    
    func fetchTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = makeURL(path: "/movie/top_rated") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchNowPlaying(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = makeURL(path: "/movie/now_playing") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = makeURL(path: "/movie/popular") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUpcoming(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = makeURL(path: "/movie/upcoming") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchMovieCredits(id: Int, completion: @escaping (Result<CreditsResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/movie/\(id)/credits") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let credits = try JSONDecoder().decode(CreditsResponse.self, from: data)
                completion(.success(credits))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchMovieVideos(id: Int, completion: @escaping (Result<[Video], Error>) -> Void) {
        guard let url = makeURL(path: "/movie/\(id)/videos") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let videos = try JSONDecoder().decode(VideosResponse.self, from: data)
                completion(.success(videos.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchMovieDetail(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = makeURL(path: "/movie/\(id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let detail = try JSONDecoder().decode(MovieDetail.self, from: data)
                completion(.success(detail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchMovieImages(id: Int, completion: @escaping (Result<[Backdrop], Error>) -> Void) {
        guard let url = makeURL(
            path: "/movie/\(id)/images",
            queryItems: [
                URLQueryItem(name: "include_image_language", value: "en, null")
            ]
        ) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(ImagesResponse.self, from: data)
                completion(.success(decoded.backdrops))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = makeURL(path: "/search/movie",
                                queryItems: [
                                    URLQueryItem(name: "query", value: query),
                                    URLQueryItem(name: "include_adult", value: "false"),
                                    URLQueryItem(name: "language", value: "en-US"),
                                    URLQueryItem(name: "region", value: "US")
                                ]
        ) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                let filtered = decoded.results.filter { !($0.adult ?? false) }
                completion(.success(filtered))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func setFavoriteMovies(accountID: Int, sessionID: String, movieID: Int, favorite: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/favorite", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "media_type": "movie",
            "media_id": movieID,
            "favorite": favorite
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(GenericResponse.self, from: data)
                completion(.success(decoded.success))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getFavoriteMovies(accountID: Int, sessionID: String, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/favorite/movies", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func setWatchlistMovies(accountID: Int, sessionID: String, movieID: Int, watchlist: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/watchlist", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "media_type": "movie",
            "media_id": movieID,
            "watchlist": watchlist
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(GenericResponse.self, from: data)
                completion(.success(decoded.success))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getWatchlistMovies(accountID: Int, sessionID: String, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/watchlist/movies", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    struct GenericResponse: Codable {
        let success: Bool
    }
}
