struct SeriesDetail: Codable {
    let id: Int
    let name: String
    let overview: String
    let poster_path: String?
    let first_air_date: String?
    let vote_average: Double
    let genres: [Genre]?
    let number_of_seasons: Int?
    let number_of_episodes: Int?
    let seasons: [Season]?
    let episode_run_time: [Int]?
}

struct Season: Codable, Identifiable {
    let id: Int
    let name: String
    let overview: String
    let season_number: Int
    let episode_count: Int?
    let air_date: String?
    let poster_path: String?
}
