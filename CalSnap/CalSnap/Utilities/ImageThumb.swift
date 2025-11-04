import UIKit

enum ImageThumb {
    static func jpegData(from image: UIImage, maxSizeKB: Int = 200) -> Data? {
        var compression: CGFloat = 0.8
        var data = image.jpegData(compressionQuality: compression)
        while let jpeg = data, jpeg.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression)
        }
        return data
    }

    static func thumbnail(from image: UIImage, targetSize: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
