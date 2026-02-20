import SwiftUI

struct SeriesCategoryView: View {
    let title: String
    let series: [Series]
    
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            SeriesGrid(series: series) { seriesItem in
                AnyView(
                    Text(seriesItem.name)
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
