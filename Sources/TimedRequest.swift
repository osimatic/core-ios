import Foundation

/*
 * Requête HTTP avec délai max : à l'expiration, la requête est annulée via son canceller, puis onTimeout est appelé.
 * Chaque réponse doit appeler claimResponse() : elle n'est traitée que si le délai n'a pas encore expiré.
 * Équivalent de TimedRequest côté Android.
 */
public final class TimedRequest {

	public let canceller = HTTPRequestCanceller();

	private var answered = false;
	private var timeoutWork: DispatchWorkItem?;

	/*
	 * Démarre le délai. Doit être appelé sur le thread principal ou depuis un autre thread (le timer est planifié sur le thread principal).
	 *
	 * @param delay      Délai max avant expiration, en secondes.
	 * @param onTimeout  Appelé sur le thread principal à l'expiration, après annulation de la requête.
	 */
	public init(delay: TimeInterval, onTimeout: @escaping () -> Void) {
		let work = DispatchWorkItem { [weak self] in
			guard let self, !self.answered else { return };
			self.answered = true;
			self.canceller.cancel();
			onTimeout();
		};
		timeoutWork = work;
		DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work);
	}

	/*
	 * À appeler à chaque réponse, sur le thread principal.
	 *
	 * @return false si le délai a déjà été traité : la réponse doit alors être ignorée.
	 */
	public func claimResponse() -> Bool {
		guard !answered else { return false };
		answered = true;
		timeoutWork?.cancel();
		return true;
	}
}