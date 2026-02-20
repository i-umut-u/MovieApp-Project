struct CreditsResponse: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String?
}

struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String
}

struct VideosResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}
