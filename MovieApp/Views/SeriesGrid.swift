import SwiftUI

struct DefaultSeriesTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.callout)
            .frame(width: 120, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct SeriesGrid<TitleView: View>: View {
    let series: [Series]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    let titleView: (Series) -> TitleView

    init(series: [Series], @ViewBuilder titleView: @escaping (Series) -> TitleView) {
        self.series = series
        self.titleView = titleView
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(series) { seriesItem in
                NavigationLink(destination: SeriesDetailView(series: seriesItem)) {
                    VStack(alignment: .leading, spacing: 4){
                        AsyncImage(
                            url: URL(string: "https://image.tmdb.org/t/p/w200\(seriesItem.poster_path ?? "")"),
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
                        
                        titleView(seriesItem)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

extension SeriesGrid where TitleView == DefaultSeriesTitleView {
    init(series: [Series]) {
        self.init(series: series) { seriesItem in
            DefaultSeriesTitleView(title: seriesItem.name)
        }
    }
}
