import Foundation

class SeriesViewModel: ObservableObject {
    @Published var airingToday: [Series] = []
    @Published var onTheAir: [Series] = []
    @Published var popularSeries: [Series] = []
    @Published var topRatedSeries: [Series] = []
    @Published var searchResults: [Series] = []
    
    
    func loadAiringToday() {
        SeriesService.shared.fetchAiringToday { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let airingToday) = result {
                    self?.airingToday = airingToday.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadOnTheAir() {
        SeriesService.shared.fetchOnTheAir { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let onTheAir) = result {
                    self?.onTheAir = onTheAir.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadPopularSeries() {
        SeriesService.shared.fetchPopularSeries { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let popularSeries) = result {
                    self?.popularSeries = popularSeries.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func loadTopRatedSeries() {
        SeriesService.shared.fetchTopRatedSeries { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let topRatedSeries) = result {
                    self?.topRatedSeries = topRatedSeries.filter { !($0.adult ?? false) }
                }
            }
        }
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        SeriesService.shared.searchSeries(query: query) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let series) = result {
                    self?.searchResults = series.filter { !($0.adult ?? false) }
                }
            }
        }
    }
}
