//
//  PlaceRepository.swift
//  Loveyaniask
//
//  Gidilen mekanların okunup yazılması için Domain sözleşmesi.
//

import Foundation

protocol PlaceRepository {
    func all() -> [Place]
    func add(_ place: Place)
    func update(_ place: Place)
    func delete(id: UUID)
    func photoFileName(for id: UUID) -> String?
}
