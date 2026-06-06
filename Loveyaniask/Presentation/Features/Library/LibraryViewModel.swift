//
//  LibraryViewModel.swift
//  Loveyaniask
//
//  Kütüphane: gerçek zamanlı öğeler, tür filtresi, arama, durum & ikili puan.
//

import Foundation
import Observation

@Observable
final class LibraryViewModel {
    private(set) var items: [LibraryItem] = []
    var selectedKind: LibraryKind = .film
    var showingAdd = false
    var selectedItem: LibraryItem?

    // Arama
    var query = ""
    private(set) var searchResults: [LibrarySearchResult] = []
    private(set) var isSearching = false

    let currentUser: UserProfile
    private let observeUseCase: ObserveLibraryUseCase
    private let addUseCase: AddLibraryItemUseCase
    private let updateUseCase: UpdateLibraryItemUseCase
    private let deleteUseCase: DeleteLibraryItemUseCase
    private let searchService: LibrarySearch

    init(
        currentUser: UserProfile,
        observe: ObserveLibraryUseCase,
        add: AddLibraryItemUseCase,
        update: UpdateLibraryItemUseCase,
        delete: DeleteLibraryItemUseCase,
        search: LibrarySearch
    ) {
        self.currentUser = currentUser
        self.observeUseCase = observe
        self.addUseCase = add
        self.updateUseCase = update
        self.deleteUseCase = delete
        self.searchService = search
        observe.execute { [weak self] items in
            self?.items = items.sorted { $0.addedAt > $1.addedAt }
        }
    }

    // MARK: - Filtreleme

    var itemsForSelectedKind: [LibraryItem] {
        items.filter { $0.kind == selectedKind }
    }

    func items(status: LibraryStatus) -> [LibraryItem] {
        itemsForSelectedKind.filter { $0.status == status }
    }

    var isEmptyForSelectedKind: Bool { itemsForSelectedKind.isEmpty }

    // MARK: - Arama

    @MainActor
    func runSearch() async {
        let q = query
        guard q.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            searchResults = []
            return
        }
        isSearching = true
        let results = await searchService.search(query: q, kind: selectedKind)
        // Yanıt geldiğinde sorgu hâlâ aynıysa göster.
        if q == query {
            searchResults = results
        }
        isSearching = false
    }

    func clearSearch() {
        query = ""
        searchResults = []
    }

    // MARK: - Aksiyonlar

    func add(_ result: LibrarySearchResult) {
        addUseCase.execute(
            title: result.title,
            kind: selectedKind,
            posterURL: result.posterURL,
            overview: result.overview,
            addedBy: currentUser.rawValue
        )
    }

    func setStatus(_ item: LibraryItem, _ status: LibraryStatus) {
        var updated = item
        updated.status = status
        updateUseCase.execute(updated)
        if selectedItem?.id == item.id { selectedItem = updated }
    }

    func setMyRating(_ item: LibraryItem, rating: Int) {
        var updated = item
        updated.ratings[currentUser.rawValue] = rating
        updateUseCase.execute(updated)
        if selectedItem?.id == item.id { selectedItem = updated }
    }

    func delete(_ item: LibraryItem) {
        deleteUseCase.execute(id: item.id)
        if selectedItem?.id == item.id { selectedItem = nil }
    }

    // MARK: - Yardımcılar

    func myRating(for item: LibraryItem) -> Int { item.ratings[currentUser.rawValue] ?? 0 }
    func rating(of profile: UserProfile, for item: LibraryItem) -> Int { item.ratings[profile.rawValue] ?? 0 }

    func ratingText(for item: LibraryItem) -> String {
        let avg = item.averageRating
        return avg <= 0 ? "" : String(format: "%.1f", avg)
    }
}
