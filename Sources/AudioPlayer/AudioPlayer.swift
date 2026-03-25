import Foundation
import AVFoundation

// https://stackoverflow.com/questions/34563329/how-to-play-mp3-audio-from-url-in-ios-swift
// https://santoshkumarjm.medium.com/how-to-design-a-custom-avplayer-to-play-audio-using-url-in-ios-swift-439f0dbf2ff2

protocol AudioPlayerDelegate {
	func onAudioPlayerUpdateTime(sender: AudioPlayer);
	func onAudioPlayerFinishedPlaying(sender: AudioPlayer);
}

class AudioPlayer {
	var audioPlayer: AVPlayer;
	var delegate: AudioPlayerDelegate;
	var observer: NSKeyValueObservation;
	
	init (url: String, delegate: AudioPlayerDelegate, onFileLoaded: @escaping () -> Void = {}) {
		NSLog("url: %@ ", url);
		self.delegate = delegate;
		
		let playerItem = AVPlayerItem(url: URL(string: url)!);
		self.audioPlayer = AVPlayer(playerItem: playerItem);
		//self.audioPlayer = AVPlayer(url: url);
		
		// check player has completed loading
		self.observer = playerItem.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
			//NSLog(String(format: "playerItem.status: %d", playerItem.status as! CVarArg));
			if playerItem.status == .readyToPlay {
				//NSLog("audio duration:  %f", self.getAudioDuration());
				onFileLoaded();
			}
		});
		
		// periodic callback
		audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
			self.delegate.onAudioPlayerUpdateTime(sender: self);
		}
		
		// check player has completed playing audio
		NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem);
	}
	
	/*
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (object as? NSObject == self.audioPlayer!.currentItem && keyPath == "status") {
			if (self.audioPlayer!.currentItem?.status == AVPlayerItem.Status.readyToPlay) {
				NSLog("Pas d'erreur ");
			}
			else if (self.audioPlayer!.currentItem?.status == AVPlayerItem.Status.failed) {
				NSLog("Erreur : %@ ", self.audioPlayer!.currentItem?.error.debugDescription ?? "");
			}
		}
	}
	*/

	// Simply fire the play Event
	func playAudio() {
		self.audioPlayer.play();
	}

	// Simply fire the pause Event
	func pauseAudio() {
		self.audioPlayer.pause();
	}

	// To set the current Position of the playing audio File
	func setCurrentAudioTime(_ value: Float) {
		self.audioPlayer.currentItem?.seek(to: CMTimeMake(value: Int64(value) * 1000, timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: nil);
	}

	// Get the time where audio is playing right now
	func getCurrentAudioTime() -> Float {
		//return Float(self.audioPlayer.currentItem?.currentTime() ?? 0);
		return Float(CMTimeGetSeconds((self.audioPlayer.currentItem?.currentTime())!));
	}

	// Get the whole length of the audio file
	func getAudioDuration() -> Float {
		guard let playerItem = self.audioPlayer.currentItem else { return 0; }
		return Float(CMTimeGetSeconds(playerItem.asset.duration));
	}
	
	func getCurrentStatus() -> AVPlayerItem.Status {
		return self.audioPlayer.currentItem?.status ?? AVPlayerItem.Status.unknown;
	}
	
	func isReadyToPlay() -> Bool {
		return self.getCurrentStatus() == .readyToPlay;
	}
	func isPaused() -> Bool {
		return self.audioPlayer.rate == 0;
	}
	func isPlaybackLikelyToKeepUp() -> Bool {
		return self.audioPlayer.currentItem?.isPlaybackLikelyToKeepUp ?? false;
	}
	
	@objc func finishedPlaying() {
		self.delegate.onAudioPlayerUpdateTime(sender: self);
	}
	
	@objc func statusChanged( _ myNotification:NSNotification) {
		NSLog("status changed : ", myNotification.description);
	}
	
}
