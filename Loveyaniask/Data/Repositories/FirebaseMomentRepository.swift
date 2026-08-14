//
//  FirebaseMomentRepository.swift
//  Loveyaniask
//
//  Akış'ın Firebase implementasyonu. Meta veri Realtime Database'de
//  (moments/{id}), medyanın kendisi Firebase Storage'da (moments/{id}.jpg|mov).
//  NOT: Xcode projesine "FirebaseStorage" SPM ürününün eklenmesi gerekiyor
//  (bkz. proje notu) — bu dosya onu import ediyor.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

final class FirebaseMomentRepository: MomentRepository {
    private let ref = Database.database().reference().child("moments")
    private let storageRoot = Storage.storage().reference().child("moments")
    private let cache = MomentMediaCache()
    private let currentUser: UserProfile

    private var items: [Moment] = []
    private var onChange: (([Moment]) -> Void)?
    private var handle: DatabaseHandle?

    /// Tek seferde çekilen en fazla an sayısı — akış yıllar içinde binlerce
    /// ana ulaşabileceği için sınırsız çekmek performans/maliyet riski olurdu.
    private static let fetchLimit: UInt = 500

    init(currentUser: UserProfile) {
        self.currentUser = currentUser
        handle = ref.queryLimited(toLast: Self.fetchLimit).observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var moments: [Moment] = []
            for case let child as DataSnapshot in snapshot.children {
                guard
                    let d = child.value as? [String: Any],
                    let authorRaw = d["author"] as? String,
                    let author = UserProfile(rawValue: authorRaw),
                    let mediaTypeRaw = d["mediaType"] as? String,
                    let mediaType = MomentMediaType(rawValue: mediaTypeRaw),
                    let storagePath = d["storagePath"] as? String,
                    let createdAtMillis = d["createdAt"] as? Double
                else { continue }

                let createdAt = Date(timeIntervalSince1970: createdAtMillis / 1000)
                let resurfaceAtMillis = d["resurfaceAt"] as? Double
                moments.append(Moment(
                    id: child.key,
                    author: author,
                    mediaType: mediaType,
                    storagePath: storagePath,
                    createdAt: createdAt,
                    dayKey: DayKey.make(createdAt),
                    resurfaceAt: resurfaceAtMillis.map { Date(timeIntervalSince1970: $0 / 1000) },
                    kenComment: d["kenComment"] as? String
                ))
            }
            self.items = moments.sorted { $0.createdAt > $1.createdAt }
            self.onChange?(self.items)
        }
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }

    func observe(_ onChange: @escaping ([Moment]) -> Void) {
        self.onChange = onChange
        onChange(items)
    }

    func upload(mediaType: MomentMediaType, fileURL: URL, completion: @escaping (Bool) -> Void) {
        let id = ref.childByAutoId().key ?? UUID().uuidString
        let ext = mediaType == .photo ? "jpg" : "mov"
        let storagePath = "\(id).\(ext)"
        let itemStorageRef = storageRoot.child(storagePath)

        func writeMetadata() {
            let data: [String: Any] = [
                "author": currentUser.rawValue,
                "mediaType": mediaType.rawValue,
                "storagePath": storagePath,
                "createdAt": ServerValue.timestamp()
            ]
            self.ref.child(id).setValue(data) { error, _ in
                completion(error == nil)
            }
        }

        if mediaType == .photo, let rawData = try? Data(contentsOf: fileURL) {
            let jpegData = ImageDownsampler.downsampledJPEG(from: rawData, maxPixel: 2000, quality: 0.85) ?? rawData
            itemStorageRef.putData(jpegData, metadata: nil) { _, error in
                guard error == nil else { completion(false); return }
                writeMetadata()
            }
        } else {
            itemStorageRef.putFile(from: fileURL, metadata: nil) { _, error in
                guard error == nil else { completion(false); return }
                writeMetadata()
            }
        }
    }

    func delete(_ moment: Moment) {
        ref.child(moment.id).removeValue()
        storageRoot.child(moment.storagePath).delete(completion: nil)
        cache.remove(forStoragePath: moment.storagePath)
    }

    func setResurface(_ moment: Moment, date: Date?) {
        let node = ref.child(moment.id).child("resurfaceAt")
        if let date {
            node.setValue(date.timeIntervalSince1970 * 1000)
        } else {
            node.removeValue()
        }
    }

    func localFileURL(for moment: Moment, completion: @escaping (URL?) -> Void) {
        let local = cache.localURL(forStoragePath: moment.storagePath)
        if cache.isCached(forStoragePath: moment.storagePath) {
            completion(local)
            return
        }
        storageRoot.child(moment.storagePath).write(toFile: local) { url, error in
            completion(error == nil ? url : nil)
        }
    }
}
