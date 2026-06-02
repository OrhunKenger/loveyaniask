//
//  PlaceSearchCompleter.swift
//  Loveyaniask
//
//  Yazdıkça canlı mekan önerileri (MKLocalSearchCompleter).
//  Seçilen öneri MKLocalSearch ile koordinata çözülür.
//

import Foundation
import Observation
import MapKit

@Observable
final class PlaceSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var query: String = "" {
        didSet { completer.queryFragment = query }
    }
    private(set) var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }

    /// Seçilen öneriyi koordinata çözer.
    func resolve(_ completion: MKLocalSearchCompletion, handler: @escaping (CLLocationCoordinate2D?) -> Void) {
        let request = MKLocalSearch.Request(completion: completion)
        MKLocalSearch(request: request).start { response, _ in
            handler(response?.mapItems.first?.placemark.coordinate)
        }
    }

    func clear() {
        query = ""
        results = []
    }
}
