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
    private let addPlaceUseCase: AddPlaceUseCase
    private let deletePlaceUseCase: DeletePlaceUseCase
    private let getPhotoUseCase: GetPlacePhotoUseCase
    private let setRatingUseCase: SetPlaceRatingUseCase

    init(
        currentUser: UserProfile,
        getPlaces: GetPlacesUseCase,
        addPlace: AddPlaceUseCase,
        deletePlace: DeletePlaceUseCase,
        getPhoto: GetPlacePhotoUseCase,
        setRating: SetPlaceRatingUseCase
    ) {
        self.currentUser = currentUser
        self.getPlaces = getPlaces
        self.addPlaceUseCase = addPlace
        self.deletePlaceUseCase = deletePlace
        self.getPhotoUseCase = getPhoto
        self.setRatingUseCase = setRating
        self.places = getPlaces.execute()
    }

    func reload() {
        places = getPlaces.execute()
    }

    func place(by id: UUID) -> Place? {
        places.first { $0.id == id }
    }

    // MARK: - Ekleme / silme / puan

    func add(name: String, latitude: Double, longitude: Double, rating: Int, note: String, dateVisited: Date, imageData: Data?) {
        addPlaceUseCase.execute(
            name: name,
            latitude: latitude,
            longitude: longitude,
            raterKey: currentUser.rawValue,
            rating: rating,
            note: note,
            dateVisited: dateVisited,
            imageData: imageData
        )
        reload()
    }

    func delete(_ place: Place) {
        deletePlaceUseCase.execute(id: place.id)
        reload()
    }

    func setMyRating(_ place: Place, rating: Int) {
        setRatingUseCase.execute(placeId: place.id, userKey: currentUser.rawValue, rating: rating)
        reload()
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: place.dateVisited)
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
