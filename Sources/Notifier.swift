import Foundation
import UserNotifications

/*
 * Affiche une notification locale immédiate. Ne fait rien si l'utilisateur n'a pas autorisé les notifications.
 * Équivalent de Notifier côté Android. L'autorisation est demandée par l'application, pas ici.
 */
public enum Notifier {

	/*
	 * @param title Titre de la notification.
	 * @param body  Texte de la notification.
	 */
	public static func show(title: String, body: String) {
		let center = UNUserNotificationCenter.current();
		center.getNotificationSettings { settings in
			guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return; }

			let content = UNMutableNotificationContent();
			content.title = title;
			content.body = body;
			content.sound = .default;

			// Identifiant unique : plusieurs notifications successives restent visibles
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil);
			center.add(request);
		}
	}
}