struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let release_date: String?
    let vote_average: Double
    let runtime: Int?
    let genres: [Genre]?
}

