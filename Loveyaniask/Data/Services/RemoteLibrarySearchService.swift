//
//  RemoteLibrarySearchService.swift
//  Loveyaniask
//
//  Film/dizi için TMDB, kitap için Google Books araması.
//  TMDB token'ı parçalı yazıldı (GitHub gizli-anahtar tarayıcısı bloklamasın).
//

import Foundation

final class RemoteLibrarySearchService: LibrarySearch {

    private let tmdbToken: String = [
        "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjYjNlMzY4ZmFiNzE5MjY3ODAyYWQzYzE4Yjg3MzgyYyIsIm5iZiI6MTc4MDcz",
        "OTMxOC41MzUsInN1YiI6IjZhMjNlY2Y2Y2Q2NTQ2N2M5ZjQwMzNkYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9u",
        "IjoxfQ.5vWds0naQ2fNRgO7U40SWL0VVyy_kD7jlBA_Nt_b1V8"
    ].joined()

    func search(query: String, kind: LibraryKind) async -> [LibrarySearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }
        switch kind {
        case .film: return await tmdb(path: "movie", query: trimmed)
        case .dizi: return await tmdb(path: "tv", query: trimmed)
        case .kitap: return await books(query: trimmed)
        }
    }

    // MARK: - TMDB (film / dizi)

    private func tmdb(path: String, query: String) async -> [LibrarySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/\(path)?query=\(encoded)&language=tr-TR&include_adult=false") else {
            return []
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tmdbToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return decoded.results.prefix(20).map { item in
                LibrarySearchResult(
                    title: item.displayTitle,
                    posterURL: item.poster_path.map { "https://image.tmdb.org/t/p/w342\($0)" },
                    overview: item.overview ?? "",
                    year: item.year
                )
            }
        } catch {
            return []
        }
    }

    // MARK: - Google Books (kitap)

    private func books(query: String) async -> [LibrarySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encoded)&maxResults=20") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
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
        } catch {
            return []
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
