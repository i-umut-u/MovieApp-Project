import SwiftUI

struct MovieGrid: View {
    let movies: [Movie]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    var titleView: ((String) -> AnyView)? = nil
    
    init(movies: [Movie], titleView: ((String) -> AnyView)? = nil) {
        self.movies = movies
        self.titleView = titleView
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    VStack(alignment: .leading, spacing: 4){
                        AsyncImage(
                            url: URL(string: "https://image.tmdb.org/t/p/w200\(movie.poster_path ?? "")"),
                            content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 180)
                                    .clipped()
                                    .cornerRadius(8)
                            },
                            placeholder: {
                                ZStack {
                                    Color.gray
                                    Text("No image available")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .padding(4)
                                }
                                .frame(width: 120, height: 210)
                                .cornerRadius(8)
                            }
                        )

                        if let titleView = titleView {
                            titleView(movie.title)
                        } else {
                            Text(movie.title)
                                .font(.callout)
                                .frame(width: 120, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
