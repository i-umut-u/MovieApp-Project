import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let release_date: String?
    let vote_average: Double
    let adult: Bool?
}
