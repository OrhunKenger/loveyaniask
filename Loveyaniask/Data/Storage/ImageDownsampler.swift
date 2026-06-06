//
//  ImageDownsampler.swift
//  Loveyaniask
//
//  Fotoğrafları kaydetmeden önce küçülten yardımcı.
//  ImageIO ile decode'u doğrudan küçük boyutta yapar → tam çözünürlüklü
//  kamera fotoğrafını belleğe açmadan, hem dosya boyutu hem de ileride
//  ekranda decode maliyeti ciddi şekilde düşer.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageDownsampler {
    /// Görseli en fazla `maxPixel` kenar uzunluğuna küçültüp JPEG olarak döndürür.
    /// Başarısız olursa nil döner; çağıran orijinal veriye geri düşebilir.
    static func downsampledJPEG(from data: Data, maxPixel: Int = 1600, quality: CGFloat = 0.8) -> Data? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }
        let thumbOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions) else {
            return nil
        }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output as CFMutableData, UTType.jpeg.identifier as CFString, 1, nil
        ) else {
            return nil
        }
        let destOptions = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, destOptions)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}
