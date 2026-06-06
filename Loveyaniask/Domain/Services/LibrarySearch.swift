//
//  LibrarySearch.swift
//  Loveyaniask
//
//  Film/dizi/kitap arama sözleşmesi + arama sonucu modeli.
//

import Foundation

struct LibrarySearchResult: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let posterURL: String?
    let overview: String
    let year: String?
}

protocol LibrarySearch {
    func search(query: String, kind: LibraryKind) async -> [LibrarySearchResult]
}
