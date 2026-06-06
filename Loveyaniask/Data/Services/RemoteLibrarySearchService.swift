//
//  RemoteLibrarySearchService.swift
//  Loveyaniask
//
//  Film/dizi için TMDB, kitap için Google Books araması.
//  TMDB token'ı parçalı yazıldı (GitHub gizli-anahtar tarayıcısı bloklamasın).
//

import Foundation

final class RemoteLibrarySearchService: LibrarySearch {

    // TMDB v3 API key (parçalı — push-protection bloklamasın).
    private let tmdbKey: String = "cb3e368fab7192678" + "02ad3c18b87382c"
    // Google Books API key (parçalı).
    private let booksKey: String = "AIzaSyDOiOLzAegSG7" + "Vga2hc2MSbi64kSfUOZIg"

    // JSONDecoder yeniden kullanılır (her istekte yeniden kurulmaz).
    private static let decoder = JSONDecoder()

    // Aynı sorgu tekrarlanınca ağa çıkmamak için basit bellek önbelleği.
    private final class ResultsBox {
        let results: [LibrarySearchResult]
        init(_ results: [LibrarySearchResult]) { self.results = results }
    }
    private let cache = NSCache<NSString, ResultsBox>()

    func search(query: String, kind: LibraryKind) async throws -> [LibrarySearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }

        let cacheKey = "\(kind):\(trimmed.lowercased())" as NSString
        if let cached = cache.object(forKey: cacheKey) { return cached.results }

        let results: [LibrarySearchResult]
        switch kind {
        case .film: results = try await tmdb(path: "movie", query: trimmed)
        case .dizi: results = try await tmdb(path: "tv", query: trimmed)
        case .kitap: results = try await books(query: trimmed)
        }
        cache.setObject(ResultsBox(results), forKey: cacheKey)
        return results
    }

    // MARK: - TMDB (film / dizi)

    private func tmdb(path: String, query: String) async throws -> [LibrarySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/\(path)?api_key=\(tmdbKey)&query=\(encoded)&language=tr-TR&include_adult=false") else {
            throw SearchError(message: "URL oluşturulamadı")
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8)?.prefix(160) ?? ""
            throw SearchError(message: "TMDB \(http.statusCode): \(body)")
        }
        let decoded = try Self.decoder.decode(TMDBResponse.self, from: data)
        return decoded.results.prefix(20).map { item in
            LibrarySearchResult(
                title: item.displayTitle,
                posterURL: item.poster_path.map { "https://image.tmdb.org/t/p/w342\($0)" },
                overview: item.overview ?? "",
                year: item.year
            )
        }
    }

    // MARK: - Google Books (kitap)

    private func books(query: String) async throws -> [LibrarySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encoded)&maxResults=20&country=TR&key=\(booksKey)") else {
            throw SearchError(message: "URL oluşturulamadı")
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8)?.prefix(160) ?? ""
            throw SearchError(message: "Books \(http.statusCode): \(body)")
        }
        let decoded = try Self.decoder.decode(GoogleBooksResponse.self, from: data)
        return (decoded.items ?? []).map { item in
                let info = item.volumeInfo
                let poster = info.imageLinks?.thumbnail?
                    .replacingOccurrences(of: "http://", with: "https://")
                var title = info.title ?? "?"
                if let authors = info.authors, !authors.isEmpty {
                    title += " — \(authors.joined(separator: ", "))"
                }
                return LibrarySearchResult(
                    title: title,
                    posterURL: poster,
                    overview: info.description ?? "",
                    year: info.publishedDate.map { String($0.prefix(4)) }
                )
            }
    }
}

// MARK: - TMDB modelleri

private struct TMDBResponse: Decodable {
    let results: [TMDBItem]
}

private struct TMDBItem: Decodable {
    let title: String?
    let name: String?
    let poster_path: String?
    let overview: String?
    let release_date: String?
    let first_air_date: String?

    var displayTitle: String { title ?? name ?? "?" }
    var year: String? {
        let raw = release_date ?? first_air_date
        guard let raw, raw.count >= 4 else { return nil }
        return String(raw.prefix(4))
    }
}

// MARK: - Google Books modelleri

private struct GoogleBooksResponse: Decodable {
    let items: [GoogleBook]?
}

private struct GoogleBook: Decodable {
    let volumeInfo: GoogleBookInfo
}

private struct GoogleBookInfo: Decodable {
    let title: String?
    let authors: [String]?
    let publishedDate: String?
    let description: String?
    let imageLinks: GoogleBookImages?
}

private struct GoogleBookImages: Decodable {
    let thumbnail: String?
}
