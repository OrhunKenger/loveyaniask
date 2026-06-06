//
//  LibraryRepository.swift
//  Loveyaniask
//
//  Dijital kütüphane öğeleri için Domain sözleşmesi (gerçek zamanlı).
//

import Foundation

protocol LibraryRepository {
    func observe(_ onChange: @escaping ([LibraryItem]) -> Void)
    func add(_ item: LibraryItem)
    func update(_ item: LibraryItem)
    func delete(id: UUID)
}
