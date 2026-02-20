import Foundation

struct SeriesResponse: Codable {
    let results: [Series]
}

struct Series: Codable, Identifiable {
    let id: Int
    let name: String
    let overview: String
    let poster_path: String?
    let first_air_date: String?
    let vote_average: Double?
    let adult: Bool?
}
