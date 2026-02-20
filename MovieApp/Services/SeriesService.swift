import Foundation

class SeriesService {
    static let shared = SeriesService()
    private let baseURL = "https://api.themoviedb.org/3"
    
    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + path)
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: APIConfig.apiKey))
        components?.queryItems = items
        return components?.url
    }
    
    func fetchAiringToday(completion: @escaping (Result<[Series], Error>) -> Void) {
        guard let url = makeURL(path: "/tv/airing_today") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(SeriesResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchOnTheAir(completion: @escaping (Result<[Series], Error>) -> Void) {
        guard let url = makeURL(path: "/tv/on_the_air") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(SeriesResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchPopularSeries(completion: @escaping (Result<[Series], Error>) -> Void) {
        guard let url = makeURL(path: "/tv/popular") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(SeriesResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchTopRatedSeries(completion: @escaping (Result<[Series], Error>) -> Void) {
        guard let url = makeURL(path: "/tv/top_rated") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(SeriesResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSeriesCredits(id: Int, completion: @escaping (Result<CreditsResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/tv/\(id)/credits") else { return }
        
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

    func fetchSeriesVideos(id: Int, completion: @escaping (Result<[Video], Error>) -> Void) {
        guard let url = makeURL(path: "/tv/\(id)/videos") else { return }
        
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
    
    func fetchSeriesDetail(id: Int, completion: @escaping (Result<SeriesDetail, Error>) -> Void) {
        guard let url = makeURL(path: "/tv/\(id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let detail = try JSONDecoder().decode(SeriesDetail.self, from: data)
                completion(.success(detail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSeriesImages(id: Int, completion: @escaping (Result<[Backdrop], Error>) -> Void) {
        guard let url = makeURL(
            path: "/tv/\(id)/images",
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
    
    func searchSeries(query: String, completion: @escaping (Result<[Series], Error>) -> Void) {
        guard let url = makeURL(path: "/search/tv",
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
                let decoded = try JSONDecoder().decode(SeriesResponse.self, from: data)
                let filtered = decoded.results.filter { !($0.adult ?? false) }
                completion(.success(filtered))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func setFavoriteSeries(accountID: Int, sessionID: String, seriesID: Int, favorite: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/favorite", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "media_type": "tv",
            "media_id": seriesID,
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
    
    func getFavoriteSeries(accountID: Int, sessionID: String, completion: @escaping (Result<SeriesResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/favorite/tv", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(SeriesResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func setWatchlistSeries(accountID: Int, sessionID: String, seriesID: Int, watchlist: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/watchlist", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "media_type": "tv",
            "media_id": seriesID,
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
    
    func getWatchlistSeries(accountID: Int, sessionID: String, completion: @escaping (Result<SeriesResponse, Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/watchlist/tv", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(SeriesResponse.self, from: data)
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
