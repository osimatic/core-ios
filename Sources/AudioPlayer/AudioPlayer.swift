import Foundation
import AVFoundation
import Combine

public protocol AudioPlayerDelegate {
	func onAudioPlayerUpdateTime(sender: AudioPlayer)
	func onAudioPlayerFinishedPlaying(sender: AudioPlayer)
}

public class AudioPlayer: ObservableObject {
	@Published public var isPlaying: Bool = false
	@Published public var currentTime: Float = 0
	@Published public var duration: Float = 0

	public var audioPlayer: AVPlayer
	public var delegate: AudioPlayerDelegate?
	public var observer: NSKeyValueObservation

	public init(url: String, delegate: AudioPlayerDelegate? = nil, onFileLoaded: @escaping () -> Void = {}) {
		self.delegate = delegate

		let playerItem = AVPlayerItem(url: URL(string: url)!)
		self.audioPlayer = AVPlayer(playerItem: playerItem)

		self.observer = playerItem.observe(\.status, options: [.new, .old]) { playerItem, _ in
			if playerItem.status == .readyToPlay {
				onFileLoaded()
			}
		}

		self.audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: .main) { [weak self] _ in
			guard let self else { return }
			if self.isReadyToPlay() {
				self.currentTime = self.getCurrentAudioTime()
				self.duration = self.getAudioDuration()
			}
			if !self.isPlaybackLikelyToKeepUp() {
				self.isPlaying = false
			}
			self.delegate?.onAudioPlayerUpdateTime(sender: self)
		}

		NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
	}

	// MARK: - Playback

	public func togglePlay() {
		if isPaused() {
			isPlaying = true
			playAudio()
		} else {
			isPlaying = false
			pauseAudio()
		}
	}

	public func seek(to value: Float) {
		let time = value * duration
		setCurrentAudioTime(time)
		currentTime = time
	}

	public func playAudio() {
		audioPlayer.play()
	}

	public func pauseAudio() {
		audioPlayer.pause()
	}

	public func setCurrentAudioTime(_ value: Float) {
		audioPlayer.currentItem?.seek(to: CMTimeMake(value: Int64(value) * 1000, timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: nil)
	}

	public func getCurrentAudioTime() -> Float {
		return Float(CMTimeGetSeconds(audioPlayer.currentItem?.currentTime() ?? .zero))
	}

	public func getAudioDuration() -> Float {
		guard let item = audioPlayer.currentItem else { return 0 }
		return Float(CMTimeGetSeconds(item.asset.duration))
	}

	public func getCurrentStatus() -> AVPlayerItem.Status {
		return audioPlayer.currentItem?.status ?? .unknown
	}

	public func isReadyToPlay() -> Bool {
		return getCurrentStatus() == .readyToPlay
	}

	public func isPaused() -> Bool {
		return audioPlayer.rate == 0
	}

	public func isPlaybackLikelyToKeepUp() -> Bool {
		return audioPlayer.currentItem?.isPlaybackLikelyToKeepUp ?? false
	}

	@objc private func finishedPlaying() {
		isPlaying = false
		setCurrentAudioTime(0)
		currentTime = 0
		delegate?.onAudioPlayerFinishedPlaying(sender: self)
	}
}