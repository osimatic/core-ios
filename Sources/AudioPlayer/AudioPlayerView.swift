import SwiftUI

public struct AudioPlayerView: View {
	@StateObject private var player: AudioPlayer

	public init(url: String) {
		_player = StateObject(wrappedValue: AudioPlayer(url: url))
	}

	public var body: some View {
		HStack(spacing: 12) {
			Button(action: { player.togglePlay() }) {
				Image(uiImage: UIImage(named: player.isPlaying ? "audioplayer_pause" : "audioplayer_play", in: .module, with: nil) ?? UIImage())
					.resizable()
					.scaledToFit()
					.frame(width: 36, height: 36)
			}
			.buttonStyle(.plain)
			.disabled(player.duration == 0)
			.opacity(player.duration > 0 ? 1 : 0.4)

			VStack(spacing: 4) {
				Slider(
					value: Binding(
						get: { player.duration > 0 ? Double(player.currentTime / player.duration) : 0 },
						set: { player.seek(to: Float($0)) }
					)
				)
				.disabled(player.duration == 0)

				HStack {
					Text(Duration.formatNbSeconds(player.currentTime, withHours: false))
						.font(.system(size: 12)).foregroundColor(.secondary)
					Spacer()
					if player.duration > 0 {
						Text(String(format: "-%@", Duration.formatNbSeconds(player.duration - player.currentTime, withHours: false)))
							.font(.system(size: 12)).foregroundColor(.secondary)
					}
				}
			}
		}
	}
}