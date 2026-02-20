import SwiftUI

struct HomeView: View {
    @StateObject private var mvm = MoviesViewModel()
    @StateObject private var svm = SeriesViewModel()
    @State private var showMovies = true
    @State private var toggleCollapsed = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation { showMovies = true }
                    }) {
                        Text("Movies")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(showMovies ? .black : .gray)
                    }
                    
                    Button(action: {
                        withAnimation { showMovies = false }
                    }) {
                        Text("Series")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(showMovies ? .gray : .black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        if showMovies {
                            VStack(alignment: .leading, spacing: 5) {
                                MovieSection(title: "Now Playing", movies: mvm.nowPlaying)
                                MovieSection(title: "Popular", movies: mvm.popular)
                                MovieSection(title: "Upcoming", movies: mvm.upcoming)
                                MovieSection(title: "Top Rated", movies: mvm.topRated)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 5) {
                                SeriesSection(title: "Airing Today", series: svm.airingToday)
                                SeriesSection(title: "On The Air", series: svm.onTheAir)
                                SeriesSection(title: "Popular", series: svm.popularSeries)
                                SeriesSection(title: "Top Rated", series: svm.topRatedSeries)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await refreshHomeData()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .onAppear {
                loadHomeData()
            }
        }
    }
    
    private func loadHomeData() {
        mvm.loadNowPlaying()
        mvm.loadPopular()
        mvm.loadUpcoming()
        mvm.loadTopRated()
        svm.loadAiringToday()
        svm.loadOnTheAir()
        svm.loadPopularSeries()
        svm.loadTopRatedSeries()
    }
    
    private func refreshHomeData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await mvm.loadNowPlaying() }
            group.addTask { await mvm.loadPopular() }
            group.addTask { await mvm.loadUpcoming() }
            group.addTask { await mvm.loadTopRated() }
            group.addTask { await svm.loadAiringToday() }
            group.addTask { await svm.loadOnTheAir() }
            group.addTask { await svm.loadPopularSeries() }
            group.addTask { await svm.loadTopRatedSeries() }
            print("refreshed")
        }
    }
}

struct MovieSection: View {
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                Spacer()
                NavigationLink(destination: MovieCategoryView(title: title, movies: movies)) {
                    Text("More")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(movies.prefix(10), id: \.id) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            VStack(alignment: .leading, spacing: 4){
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w200\(movie.poster_path ?? "")")) { img in
                                    img.resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 180)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Color.gray.frame(width: 120, height: 180)
                                }
                                
                                Text(movie.title)
                                    .font(.callout)
                                    .frame(width: 120, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(2)
                            }
                            .frame(width: 120, alignment: .top)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SeriesSection: View {
    let title: String
    let series: [Series]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                Spacer()
                NavigationLink(destination: SeriesCategoryView(title: title, series: series)) {
                    Text("More")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(series.prefix(10), id: \.id) { series in
                        NavigationLink(destination: SeriesDetailView(series: series)) {
                            VStack(alignment: .leading, spacing: 4){
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w200\(series.poster_path ?? "")")) { img in
                                    img.resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 180)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Color.gray.frame(width: 120, height: 180)
                                }
                                
                                Text(series.name)
                                    .font(.callout)
                                    .frame(width: 120, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(width: 120, alignment: .top)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
