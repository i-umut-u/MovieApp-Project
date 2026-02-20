import SwiftUI

struct SearchView: View {
    @StateObject private var mvm = MoviesViewModel()
    @StateObject private var svm = SeriesViewModel()
    @State private var searchType: SearchType = .movies
    @State private var searchText = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    enum SearchType {
        case movies, series
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 20) {
                    Button("Movies") {
                        withAnimation { searchType = .movies }
                    }
                    .font(.title2)
                    .bold()
                    .foregroundColor(searchType == .movies ? .primary : .secondary)
                    
                    Button("Series") {
                        withAnimation { searchType = .series }
                    }
                    .font(.title2)
                    .bold()
                    .foregroundColor(searchType == .series ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
                
                TextField(searchType == .movies ? "Search movies..." : "Search series...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onChange(of: searchText, perform: performSearch)
                    .onChange(of: searchType) { _ in
                        performSearch(with: searchText)
                    }
                
                ScrollView {
                    if searchType == .movies {
                        movieResultsGrid
                    } else {
                        seriesResultsGrid
                    }
                }
            }
        }
    }
    
    private var movieResultsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(mvm.searchResults) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    SearchResultCell(
                        title: movie.title,
                        posterPath: movie.poster_path
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    private var seriesResultsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(svm.searchResults) { series in
                NavigationLink(destination: SeriesDetailView(series: series)) {
                    SearchResultCell(
                        title: series.name,
                        posterPath: series.poster_path
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    private func performSearch(with query: String) {
        if searchType == .movies {
            mvm.search(query: query)
        } else {
            svm.search(query: query)
        }
    }
}

struct SearchResultCell: View {
    let title: String
    let posterPath: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w200\(posterPath ?? "")")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 180)
                        .cornerRadius(8)
                case .failure, .empty:
                    ZStack {
                        Color(.systemGray5)
                        Text("No\nImage")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .padding(4)
                    }
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
