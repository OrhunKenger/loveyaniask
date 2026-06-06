//
//  PlacesViewModel.swift
//  Loveyaniask
//
//  Gidilen mekanlar: liste, harita bölgesi, ekleme/silme, ikili puan.
//

import Foundation
import Observation
import SwiftUI
import MapKit

@Observable
final class PlacesViewModel {
    private(set) var places: [Place] = []
    var showingAdd = false
    var selectedPlace: Place?

    let currentUser: UserProfile

    private let getPlaces: GetPlacesUseCase
    private let observePlacesUseCase: ObservePlacesUseCase
    private let addPlaceUseCase: AddPlaceUseCase
    private let deletePlaceUseCase: DeletePlaceUseCase
    private let getPhotoUseCase: GetPlacePhotoUseCase
    private let setRatingUseCase: SetPlaceRatingUseCase
    private let setVisitedUseCase: SetPlaceVisitedUseCase

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()

    init(
        currentUser: UserProfile,
        getPlaces: GetPlacesUseCase,
        observePlaces: ObservePlacesUseCase,
        addPlace: AddPlaceUseCase,
        deletePlace: DeletePlaceUseCase,
        getPhoto: GetPlacePhotoUseCase,
        setRating: SetPlaceRatingUseCase,
        setVisited: SetPlaceVisitedUseCase
    ) {
        self.currentUser = currentUser
        self.getPlaces = getPlaces
        self.observePlacesUseCase = observePlaces
        self.addPlaceUseCase = addPlace
        self.deletePlaceUseCase = deletePlace
        self.getPhotoUseCase = getPhoto
        self.setRatingUseCase = setRating
        self.setVisitedUseCase = setVisited
        // Firebase'den gerçek zamanlı dinle.
        observePlaces.execute { [weak self] places in
            self?.places = places.sorted { $0.dateVisited > $1.dateVisited }
        }
    }

    /// Gittiğimiz mekanlar.
    var visitedPlaces: [Place] { places.filter { $0.visited } }
    /// Gitmek istediğimiz mekanlar (hayal listesi).
    var wishlistPlaces: [Place] { places.filter { !$0.visited } }

    func reload() {
        places = getPlaces.execute()
    }

    func place(by id: UUID) -> Place? {
        places.first { $0.id == id }
    }

    // MARK: - Ekleme / silme / puan

    func add(name: String, latitude: Double, longitude: Double, rating: Int, note: String, dateVisited: Date, imageData: Data?, visited: Bool = true) {
        addPlaceUseCase.execute(
            name: name,
            latitude: latitude,
            longitude: longitude,
            raterKey: currentUser.rawValue,
            rating: rating,
            note: note,
            dateVisited: dateVisited,
            imageData: imageData,
            visited: visited
        )
        // Repository optimistik güncelleyip observer'ı tetikler; reload() gereksiz.
    }

    /// "Gittik ✓" — hayal listesindeki mekanı gittiğimize taşır.
    func markVisited(_ place: Place) {
        setVisitedUseCase.execute(placeId: place.id, visited: true, dateVisited: Date())
    }

    func delete(_ place: Place) {
        deletePlaceUseCase.execute(id: place.id)
    }

    func setMyRating(_ place: Place, rating: Int) {
        setRatingUseCase.execute(placeId: place.id, userKey: currentUser.rawValue, rating: rating)
    }

    func myRating(for place: Place) -> Int {
        place.ratings[currentUser.rawValue] ?? 0
    }

    func rating(of profile: UserProfile, for place: Place) -> Int {
        place.ratings[profile.rawValue] ?? 0
    }

    // MARK: - Görsel yardımcılar

    func photoData(for place: Place) -> Data? {
        guard let name = place.photoFileName else { return nil }
        return getPhotoUseCase.execute(fileName: name)
    }

    func coordinate(for place: Place) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }

    func pinColor(for place: Place) -> Color {
        let avg = place.averageRating
        if avg <= 0 { return .gray }
        if avg < 2.5 { return .red }
        if avg < 4 { return .orange }
        return .green
    }

    func averageText(for place: Place) -> String {
        let avg = place.averageRating
        return avg <= 0 ? "Puan yok" : String(format: "%.1f", avg)
    }

    func dateText(for place: Place) -> String {
        Self.dateFormatter.string(from: place.dateVisited)
    }

    var initialRegion: MKCoordinateRegion {
        if let first = places.first {
            return MKCoordinateRegion(
                center: coordinate(for: first),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0),
            span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
        )
    }
}
