import SwiftUI

struct MovieCategoryView: View {
    let title: String
    let movies: [Movie]
    
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            MovieGrid(movies: movies) { movieTitle in
                AnyView(
                    Text(movieTitle)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 120)
                )
            }
        }
        .refreshable {
            await refreshData()
        }
        .navigationTitle(title)
    }
    
    func refreshData() async {
        isRefreshing = true
        await Task.sleep(1_000_000_000)
        isRefreshing = false
    }
}
