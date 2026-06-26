import Foundation
import UIKit

/*
 * Extension on UIImage providing resizing, compression and JPEG helpers.
 */
public extension UIImage {

	/*
	 * Returns a copy of the image scaled by the given percentage.
	 *
	 * @param percentage The scale factor (e.g. 0.5 = 50%).
	 * @param isOpaque   If true, the rendered image is treated as opaque (default: true).
	 * @return The scaled image, or nil if rendering fails.
	 */
	public func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
		let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image {
			_ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}

	/*
	 * Compresses the image to be at most kb kilobytes in size.
	 * Progressively reduces resolution until the target size is reached or the image
	 * can no longer be resized (returns empty Data in that case).
	 *
	 * @param kb            The target maximum size in kilobytes.
	 * @param allowedMargin Fractional tolerance above the target (default: 0.2 = 20%).
	 * @return JPEG data at or below the target size, or empty Data if compression failed.
	 */
	public func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
		let bytes = kb * 1024
		var compression: CGFloat = 1.0
		let step: CGFloat = 0.05
		var holderImage = self
		var complete = false
		while(!complete) {
			if let data = holderImage.jpegData(compressionQuality: 1.0) {
				let ratio = data.count / bytes
				if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
					complete = true
					return data
				} else {
					let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
					compression -= (step * multiplier)
				}
			}

			guard let newImage = holderImage.resized(withPercentage: compression) else { break }
			holderImage = newImage
		}
		return Data()
	}

	/*
	 * JPEG quality presets.
	 */
	public enum JPEGQuality: CGFloat {
		case lowest  = 0
		case low     = 0.25
		case medium  = 0.5
		case high    = 0.75
		case highest = 1
	}

	/*
	 * Returns the image encoded as JPEG data at the given quality level.
	 * Returns nil if the image has no data or the underlying bitmap format is unsupported.
	 *
	 * @param quality The desired JPEG quality preset.
	 */
	public func jpeg(_ quality: JPEGQuality) -> Data? {
		return self.jpegData(compressionQuality: quality.rawValue);
	}
}

/*
 * Utility class for converting UIImage instances to text attachments or Base64 strings.
 */
public class Image {

	/*
	 * Wraps a UIImage in an NSTextAttachment sized for inline display in attributed text.
	 *
	 * @param img    The image to embed.
	 * @param width  The attachment width in points (default: 18).
	 * @param height The attachment height in points (default: 18).
	 * @return A configured NSTextAttachment.
	 */
	public static func toTextAttachment(_ img: UIImage, width: CGFloat? = 18, height: CGFloat? = 18) -> NSTextAttachment {
		let imageAttachment = NSTextAttachment();
		imageAttachment.image = img;
		let imageOffsetY: CGFloat = -5.0;
		imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: width ?? imageAttachment.image!.size.width, height: height ?? imageAttachment.image!.size.height);
		return imageAttachment;
	}

	/*
	 * Returns a Base64-encoded JPEG string for the given image, or an empty string on failure.
	 *
	 * @param img                The image to encode.
	 * @param compressionQuality JPEG compression quality (default: 1.0).
	 */
	public static func convertImageToBase64String(_ img: UIImage, compressionQuality: CGFloat = 0.85) -> String {
		return img.jpegData(compressionQuality: compressionQuality)?.base64EncodedString() ?? "";
	}

	/*
	 * Decodes a Base64 string to a UIImage.
	 *
	 * @param string The Base64-encoded image string.
	 * @return The decoded UIImage, or nil if the string is invalid.
	 */
	public static func convertBase64StringToImage(_ string: String) -> UIImage? {
		guard let data = Data(base64Encoded: string) else { return nil };
		return UIImage(data: data);
	}

	/*
	 * Encodes an array of UIImages to Base64 JPEG strings.
	 *
	 * @param images             The images to encode.
	 * @param compressionQuality JPEG compression quality (default: 0.85).
	 * @return Array of Base64 strings, one per successfully encoded image.
	 */
	public static func convertImagesToBase64(_ images: [UIImage], compressionQuality: CGFloat = 0.85) -> [String] {
		return images.compactMap { convertImageToBase64String($0, compressionQuality: compressionQuality) };
	}

	/*
	 * Decodes an array of Base64 strings back to UIImages.
	 *
	 * @param strings The Base64-encoded image strings.
	 * @return Array of UIImages, skipping any strings that fail to decode.
	 */
	public static func convertBase64StringsToImages(_ strings: [String]) -> [UIImage] {
		return strings.compactMap { convertBase64StringToImage($0) };
	}
	
	/*
	static func scale(image originalImage: UIImage, toLessThan maxResolution: CGFloat) -> UIImage? {
		guard let imageReference = originalImage.cgImage else { return nil }

		let rotate90 = CGFloat.pi/2.0 // Radians
		let rotate180 = CGFloat.pi // Radians
		let rotate270 = 3.0*CGFloat.pi/2.0 // Radians

		let originalWidth = CGFloat(imageReference.width)
		let originalHeight = CGFloat(imageReference.height)
		let originalOrientation = originalImage.imageOrientation

		var newWidth = originalWidth
		var newHeight = originalHeight

		if originalWidth > maxResolution || originalHeight > maxResolution {
			let aspectRatio: CGFloat = originalWidth / originalHeight
			newWidth = aspectRatio > 1 ? maxResolution : maxResolution * aspectRatio
			newHeight = aspectRatio > 1 ? maxResolution / aspectRatio : maxResolution
		}

		let scaleRatio: CGFloat = newWidth / originalWidth
		var scale: CGAffineTransform = .init(scaleX: scaleRatio, y: -scaleRatio)
		scale = scale.translatedBy(x: 0.0, y: -originalHeight)

		var rotateAndMirror: CGAffineTransform

		switch originalOrientation {
		case .up:
			rotateAndMirror = .identity

		case .upMirrored:
			rotateAndMirror = .init(translationX: originalWidth, y: 0.0)
			rotateAndMirror = rotateAndMirror.scaledBy(x: -1.0, y: 1.0)

		case .down:
			rotateAndMirror = .init(translationX: originalWidth, y: originalHeight)
			rotateAndMirror = rotateAndMirror.rotated(by: rotate180 )

		case .downMirrored:
			rotateAndMirror = .init(translationX: 0.0, y: originalHeight)
			rotateAndMirror = rotateAndMirror.scaledBy(x: 1.0, y: -1.0)

		case .left:
			(newWidth, newHeight) = (newHeight, newWidth)
			rotateAndMirror = .init(translationX: 0.0, y: originalWidth)
			rotateAndMirror = rotateAndMirror.rotated(by: rotate270)
			scale = .init(scaleX: -scaleRatio, y: scaleRatio)
			scale = scale.translatedBy(x: -originalHeight, y: 0.0)

		case .leftMirrored:
			(newWidth, newHeight) = (newHeight, newWidth)
			rotateAndMirror = .init(translationX: originalHeight, y: originalWidth)
			rotateAndMirror = rotateAndMirror.scaledBy(x: -1.0, y: 1.0)
			rotateAndMirror = rotateAndMirror.rotated(by: rotate270)

		case .right:
			(newWidth, newHeight) = (newHeight, newWidth)
			rotateAndMirror = .init(translationX: originalHeight, y: 0.0)
			rotateAndMirror = rotateAndMirror.rotated(by: rotate90)
			scale = .init(scaleX: -scaleRatio, y: scaleRatio)
			scale = scale.translatedBy(x: -originalHeight, y: 0.0)

		case .rightMirrored:
			(newWidth, newHeight) = (newHeight, newWidth)
			rotateAndMirror = .init(scaleX: -1.0, y: 1.0)
			rotateAndMirror = rotateAndMirror.rotated(by: CGFloat.pi/2.0)
		}

		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		context.concatenate(scale)
		context.concatenate(rotateAndMirror)
		context.draw(imageReference, in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))
		let copy = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return copy
	}
	*/
}