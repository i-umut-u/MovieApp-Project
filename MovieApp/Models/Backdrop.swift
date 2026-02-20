// Movie backdrop images

struct ImagesResponse: Codable {
    let backdrops: [Backdrop]
}

struct Backdrop: Codable, Identifiable {
    let file_path: String
    var id: String { file_path }
}
