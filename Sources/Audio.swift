import Foundation
import AVFoundation

/*
 * Utility class for loading audio resources from the app bundle.
 */
class Audio {

	/*
	 * Creates and returns an AVAudioPlayer for a bundled audio file.
	 * @param ressource The name of the audio file (without extension).
	 * @param type      The file extension (e.g. "mp3", "wav").
	 * @return A ready-to-use AVAudioPlayer, or nil if the file is not found or fails to load.
	 */
	static func getPlayer(ressource: String, type: String) -> AVAudioPlayer? {
		guard let filePath = Bundle.main.path(forResource: ressource, ofType: type) else {
			return nil;
		}
		// Use URL(fileURLWithPath:) — file paths are not percent-encoded URL strings.
		let url = URL(fileURLWithPath: filePath);

		do {
			return try AVAudioPlayer(contentsOf: url);
		}
		catch let error {
			NSLog("Error loading audio file %@", error.localizedDescription);
		}
		return nil;
	}

}