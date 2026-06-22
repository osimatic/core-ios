import Foundation

/*
 * Utility class for file size formatting and file download helpers.
 */
public class File {

	/*
	 * Formats a file size in bytes into a human-readable string (B, KB, MB, GB, TB).
	 *
	 * @param size The file size in bytes.
	 * @return A formatted string with the appropriate unit.
	 */
	public static func formatFileSize(_ size: Int) -> String {
		if (size <= 0) {
			return "0";
		}

		let units: [String] = [String.localize("file_size_bytes"), String.localize("file_size_kilobytes"), String.localize("file_size_megabytes"), String.localize("file_size_gigabytes"), String.localize("file_size_terrabytes")];
		let digitGroups = min(Int(log10(Float(size)) / log10(1024.0)), units.count - 1);

		let value = Float(size) / pow(1024, Float(digitGroups));

		let numberFormatter = NumberFormatter();
		numberFormatter.numberStyle = .decimal;
		return (numberFormatter.string(for: value) ?? "") + " " + units[digitGroups];
	}

	/*
	 * Downloads a file synchronously from the given URL and saves it to the documents directory.
	 * If the file already exists locally it is returned immediately without re-downloading.
	 *
	 * @param url        The remote URL of the file to download.
	 * @param onComplete Called with the local file path and an optional error.
	 */
	public static func loadFileSync(url: String, onComplete:(_ path: String, _ error: Error?) -> Void) {
		let urlObj = URL(string: url)!;

		let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
		let destinationUrl = documentsUrl.appendingPathComponent(urlObj.lastPathComponent);
		if FileManager().fileExists(atPath: destinationUrl.path) {
			NSLog("file already exists %@", destinationUrl.path);
			onComplete(destinationUrl.path, nil);
			return;
		}

		guard let dataFromURL = NSData(contentsOf: urlObj) else {
			let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil);
			onComplete(destinationUrl.path, error);
			return;
		}

		guard dataFromURL.write(to: destinationUrl, atomically: true) else {
			NSLog("error saving file");
			let error = NSError(domain:"Error saving file", code:1001, userInfo:nil);
			onComplete(destinationUrl.path, error);
			return;
		}

		NSLog("file saved %@", destinationUrl.path);
		onComplete(destinationUrl.path, nil);

	}

	/*
	 * Downloads a file asynchronously from the given URL and saves it to the documents directory.
	 * If the file already exists locally it is returned immediately without re-downloading.
	 *
	 * @param url        The remote URL of the file to download.
	 * @param onComplete Called on the calling queue with the local file path and an optional error.
	 */
	public static func loadFileAsync(url: String, onComplete: @escaping (_ path: String, _ error: Error?) -> Void) {
		let urlObj = URL(string: url)!;

		let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
		let destinationUrl = documentsUrl.appendingPathComponent(urlObj.lastPathComponent);

		if FileManager().fileExists(atPath: destinationUrl.path) {
			NSLog("file already exists %@", destinationUrl.path);
			onComplete(destinationUrl.path, nil);
			return;
		}

		let sessionConfig = URLSessionConfiguration.default;
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil);
		let request = NSMutableURLRequest(url: urlObj);
		request.httpMethod = HTTPMethod.GET;
		let task = session.dataTask(with: request as URLRequest, completionHandler: { data, httpResponse, error in
			guard let data = data, error == nil else {
				NSLog("Failure: %@", error?.localizedDescription ?? "");
				onComplete(destinationUrl.path, error);
				return;
			}

			let httpResponse = httpResponse as! HTTPURLResponse;
			NSLog("Code HTTP : %d ; Response : %@ ; URL : %@", httpResponse.statusCode, data.description, urlObj.absoluteString);

			if (httpResponse.statusCode != 200) {
				onComplete(destinationUrl.path, NSError(domain:"Error downloading file", code:1002, userInfo:nil));
				return;
			}

			do {
				try data.write(to: destinationUrl, options: [.atomic]);
				NSLog("file saved %@", destinationUrl.path);
				onComplete(destinationUrl.path, nil);
			}
			catch let error {
				NSLog("error saving file: %@", error.localizedDescription);
				onComplete(destinationUrl.path, NSError(domain:"Error saving file", code:1001, userInfo:nil));
			}
		});
		task.resume();
	}

	public static func detectMimeType(_ data: Data) -> String {
		guard data.count >= 4 else {
			return "application/octet-stream";
		}

		let bytes = [UInt8](data.prefix(4));

		if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
			return "image/jpeg";
		}

		if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
			return "image/png";
		}

		if bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 {
			return "image/gif";
		}

		if bytes[0] == 0x42 && bytes[1] == 0x4D {
			return "image/bmp";
		}

		if bytes[0] == 0x49 && bytes[1] == 0x49 && bytes[2] == 0x2A && bytes[3] == 0x00 {
			return "image/tiff";
		}

		if bytes[0] == 0x4D && bytes[1] == 0x4D && bytes[2] == 0x00 && bytes[3] == 0x2A {
			return "image/tiff";
		}

		return "application/octet-stream";
	}

	public static func getFileExtension(mimeType: String) -> String {
		switch mimeType {
		case "image/jpeg":
			return "jpg";
		case "image/png":
			return "png";
		case "image/gif":
			return "gif";
		case "image/bmp":
			return "bmp";
		case "image/tiff":
			return "tiff";
		case "image/webp":
			return "webp";
		case "video/mp4":
			return "mp4";
		case "video/quicktime":
			return "mov";
		case "audio/mpeg":
			return "mp3";
		case "audio/wav":
			return "wav";
		case "application/pdf":
			return "pdf";
		case "application/zip":
			return "zip";
		default:
			return "bin";
		}
	}
}