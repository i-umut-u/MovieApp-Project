import Foundation

class SharedService {
    static let shared = SharedService()
    private let baseURL = "https://api.themoviedb.org/3"
    
    private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? { 
        var components = URLComponents(string: baseURL + path)
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: APIConfig.apiKey))
        components?.queryItems = items
        return components?.url
    }
    
    func getRequestToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = makeURL(path: "/authentication/token/new") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            struct TokenResponse: Codable {
                let success: Bool
                let request_token: String
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse.request_token))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createSession(requestToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = makeURL(path: "/authentication/session/new") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["request_token": requestToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            struct SessionResponse: Codable {
                let success: Bool
                let session_id: String
            }
            
            do {
                let sessionResponse = try JSONDecoder().decode(SessionResponse.self, from: data)
                completion(.success(sessionResponse.session_id))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getAccountDetails(sessionID: String, completion: @escaping (Result<Account, Error>) -> Void) {
        guard let url = makeURL(path: "/account", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let account = try JSONDecoder().decode(Account.self, from: data)
                completion(.success(account))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func setFavorite(accountID: Int, sessionID: String, movieID: Int, favorite: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
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
    
    func getUserLists(accountID: Int, sessionID: String, completion: @escaping (Result<[ListInfo], Error>) -> Void) {
        guard let url = makeURL(path: "/account/\(accountID)/lists", queryItems: [
            URLQueryItem(name: "session_id", value: sessionID)
        ]) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(UserListsResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    struct UserListsResponse: Codable {
        let results: [ListInfo]
    }
    
    struct ListInfo: Codable {
        let id: Int
        let name: String
    }
    
    struct Account: Codable {
        let id: Int
        let name: String?
        let username: String
    }
    
    struct GenericResponse: Codable {
        let success: Bool
    }
    
}
