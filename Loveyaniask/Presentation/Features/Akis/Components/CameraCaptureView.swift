//
//  CameraCaptureView.swift
//  Loveyaniask
//
//  Story tarzı anlık kamera çekimi: fotoğraf veya video, sistem kamerasıyla.
//

import SwiftUI
import UIKit

struct CameraCaptureView: UIViewControllerRepresentable {
    var onCapture: (MomentMediaType, URL) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image", "public.movie"]
        // "Serbest" video süresi istendi; UIImagePickerController'ın kamerası
        // gerçekten sınırsızı desteklemiyor, cömert bir üst sınır (10 dk) koyuyoruz.
        picker.videoMaximumDuration = 600
        picker.videoQuality = .typeHigh
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let videoURL = info[.mediaURL] as? URL {
                parent.onCapture(.video, videoURL)
            } else if let image = info[.originalImage] as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.9) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".jpg")
                try? data.write(to: tempURL)
                parent.onCapture(.photo, tempURL)
            } else {
                parent.onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}
