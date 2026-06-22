import Foundation

/*
 * Utility class for performing HTTP requests with optional JWT bearer authentication
 * and automatic token refresh on 401 responses.
 */
public class HTTPClient {

	/*
	 * Sends an HTTP request and delivers the response on the main thread.
	 * When sendAuthorizationHeader is true, the current authorizationToken static is attached as a Bearer token.
	 * On 401 with an expired JWT token, refreshToken() is called transparently and the request is retried.
	 * On 401 with an invalid JWT token, onInvalidToken() is called.
	 *
	 * @param httpMethod              The HTTP method (GET, POST, PATCH, DELETE).
	 * @param url                     The endpoint URL string.
	 * @param requestParams           The request parameters (appended as query string for GET,
	 *                                or as body for other methods).
	 * @param onSuccess               Called on the main thread with the response data and HTTP response.
	 * @param onError                 Called on the main thread with the error if the request fails.
	 * @param addditionalHttpHeaders  Extra headers to include in the request.
	 * @param asJson                  If true, encodes the body as JSON instead of form-urlencoded.
	 * @param sendAuthorizationHeader If true, attaches the current authorizationToken as Bearer.
	 */
	public static func request(httpMethod: String, url: String, requestParams: [String: Any], onSuccess: @escaping(Data?, HTTPURLResponse) -> Void, onError: @escaping(Error?) -> Void, addditionalHttpHeaders: [String: String] = [:], asJson: Bool = false, sendAuthorizationHeader: Bool = true) {
		var urlWithRequestParams = url;
		if (HTTPMethod.GET == httpMethod) {
			urlWithRequestParams += "?"+URLQueryString.getQueryStringFromArray(requestParams);
		}
		NSLog("HTTPClient.request. Method: %@, URL: %@", httpMethod, urlWithRequestParams);

		let urlObj = URL(string: urlWithRequestParams)!;
		var request = URLRequest(url: urlObj);

		// HTTP Headers
		let accessToken = sendAuthorizationHeader ? HTTPClient.authorizationToken : nil;
		for (key, value) in getHttpHeaders(httpMethod: httpMethod, addditionalHttpHeaders: addditionalHttpHeaders, accessToken: accessToken, asJson: asJson) {
			request.setValue(value, forHTTPHeaderField: key);
		}

		// Data
		request.httpMethod = httpMethod;

		if (asJson) {
			do {
				let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted);
				request.httpBody = jsonData;
				NSLog("Data : %@", String(data: jsonData, encoding: .utf8) ?? "");
			}
			catch let error {
				NSLog("Error encoding JSON: %@", error.localizedDescription);
				onError(error);
				return;
			}
		}
		else if (HTTPMethod.GET != httpMethod) {
			request.httpBody = Data(URLQueryString.getQueryStringFromArray(requestParams).utf8);
			NSLog("Data : %@", URLQueryString.getQueryStringFromArray(requestParams).utf8.description);
		}

		// Execution
		DispatchQueue.global(qos: .userInitiated).async {
			let task = URLSession.shared.dataTask(with: request, completionHandler: {data, httpResponse, error in
				guard error == nil, let httpResponse = httpResponse as? HTTPURLResponse else {
					NSLog("HTTP Request error: %@ ; URL: %@", error?.localizedDescription ?? "unknown error", urlObj.absoluteString);
					DispatchQueue.main.async {
						onError(error);
					}
					return;
				}

				NSLog("HTTP status: %d ; URL: %@", httpResponse.statusCode, urlObj.absoluteString);

				if sendAuthorizationHeader, isExpiredToken(httpResponse.statusCode, data) {
					refreshToken(onComplete: {
						NSLog("Retry HTTP request after token refresh");
						HTTPClient.request(httpMethod: httpMethod, url: url, requestParams: requestParams, onSuccess: onSuccess, onError: onError, addditionalHttpHeaders: addditionalHttpHeaders, asJson: asJson, sendAuthorizationHeader: sendAuthorizationHeader);
					});
					return;
				}

				if isInvalidToken(httpResponse.statusCode, data) {
					onInvalidToken();
					DispatchQueue.main.async {
						onError(nil);
					}
					return;
				}

				DispatchQueue.main.async {
					onSuccess(data, httpResponse);
				}
			});

			task.resume();
		}
	}

	/*
	 * Downloads a file via HTTP and saves it to the documents directory.
	 * When sendAuthorizationHeader is true, the current authorizationToken static is attached as a Bearer token.
	 * On 401 with an expired JWT token, refreshToken() is called transparently and the download is retried.
	 * On 401 with an invalid JWT token, onInvalidToken() is called.
	 *
	 * @param httpMethod              The HTTP method (typically GET).
	 * @param url                     The endpoint URL string.
	 * @param requestParams           The request parameters.
	 * @param fileName                The local file name used when saving to the documents directory.
	 * @param onSuccess               Called on the main thread with the HTTP response on success.
	 * @param onError                 Called on the main thread with the error if the download fails.
	 * @param addditionalHttpHeaders  Extra headers to include in the request.
	 * @param sendAuthorizationHeader If true, attaches the current authorizationToken as Bearer.
	 */
	public static func downloadFile(httpMethod: String, url: String, requestParams: [String: Any], fileName: String, onSuccess: @escaping(HTTPURLResponse, URL) -> Void, onError: @escaping(Error?) -> Void, addditionalHttpHeaders: [String: String] = [:], sendAuthorizationHeader: Bool = true) {
		DispatchQueue.global(qos: .userInitiated).async {
			var urlWithRequestParams = url;
			if (HTTPMethod.GET == httpMethod) {
				urlWithRequestParams += "?"+URLQueryString.getQueryStringFromArray(requestParams);
			}
			NSLog("HTTPClient.downloadFile. Method: %@, URL: %@", httpMethod, urlWithRequestParams);

			let urlObj = URL(string: urlWithRequestParams)!;
			var request = URLRequest(url: urlObj);

			// HTTP Headers
			let accessToken = sendAuthorizationHeader ? HTTPClient.authorizationToken : nil;
			for (key, value) in getHttpHeaders(httpMethod: httpMethod, addditionalHttpHeaders: addditionalHttpHeaders, accessToken: accessToken) {
				request.setValue(value, forHTTPHeaderField: key);
			}

			// Data
			request.httpMethod = httpMethod;

			if (HTTPMethod.GET != httpMethod) {
				request.httpBody = Data(URLQueryString.getQueryStringFromArray(requestParams).utf8);
				NSLog("Data : %@", URLQueryString.getQueryStringFromArray(requestParams).utf8.description);
			}

			let downloadTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: request) { (tempLocalUrl, httpResponse, error) in
				guard let tempLocalUrl = tempLocalUrl, error == nil, let httpResponse = httpResponse as? HTTPURLResponse else {
					NSLog("HTTP Request error: %@ ; URL: %@", error?.localizedDescription ?? "unknown error", urlObj.absoluteString);
					DispatchQueue.main.async {
						onError(error);
					}
					return;
				}

				NSLog("HTTP status: %d ; URL: %@", httpResponse.statusCode, urlObj.absoluteString);

				if sendAuthorizationHeader, httpResponse.statusCode == 401 {
					let errorData = try? Data(contentsOf: tempLocalUrl);
					if isExpiredToken(httpResponse.statusCode, errorData) {
						refreshToken(onComplete: {
							NSLog("Retry downloadFile after token refresh");
							HTTPClient.downloadFile(httpMethod: httpMethod, url: url, requestParams: requestParams, fileName: fileName, onSuccess: onSuccess, onError: onError, addditionalHttpHeaders: addditionalHttpHeaders, sendAuthorizationHeader: sendAuthorizationHeader);
						});
						return;
					}
					if isInvalidToken(httpResponse.statusCode, errorData) {
						onInvalidToken();
						DispatchQueue.main.async {
							onError(nil);
						}
						return;
					}
				}

				let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
				let destinationUrl = documentsUrl.appendingPathComponent(fileName);

				do {
					try FileManager.default.removeItem(at: destinationUrl);
				}
				catch let error {
					NSLog("Error deleting file %@: %@", destinationUrl.absoluteString, error.localizedDescription);
				}

				do {
					try FileManager.default.copyItem(at: tempLocalUrl, to: destinationUrl);
					DispatchQueue.main.async {
						onSuccess(httpResponse, destinationUrl);
					}
				}
				catch let error {
					NSLog("Error writing file %@: %@", destinationUrl.absoluteString, error.localizedDescription);
					onError(error);
				}
			}

			downloadTask.resume();
		}
	}

	/*
	 * Builds the HTTP headers dictionary for a request.
	 *
	 * @param httpMethod             The HTTP method.
	 * @param addditionalHttpHeaders Extra headers to merge.
	 * @param accessToken            Optional Bearer token.
	 * @param asJson                 If true, sets Content-Type to application/json.
	 * @return A dictionary of HTTP header key-value pairs.
	 */
	public static func getHttpHeaders(httpMethod: String, addditionalHttpHeaders: [String: String] = [:], accessToken: String? = nil, asJson: Bool = false) -> [String: String] {
		var httpHeaders = [
			"Accept-Language": Locale.current.identifier
		];

		if (asJson) {
			httpHeaders["Content-Type"] = "application/json";
		}
		else if (HTTPMethod.GET != httpMethod) {
			httpHeaders["Content-Type"] = "application/x-www-form-urlencoded";
		}

		if let accessToken = accessToken {
			httpHeaders["Authorization"] = "Bearer "+accessToken;
		}

		for (key, value) in addditionalHttpHeaders {
			NSLog("header %@ : %@", key, value);
			httpHeaders[key] = value;
		}

		return httpHeaders;
	}

	/* Current Bearer access token. Sent automatically when sendAuthorizationHeader is true. */
	public static var authorizationToken: String? = nil;

	/* URL called to refresh the access token. */
	public static var refreshTokenUrl: String? = nil;

	/* Returns the current refresh token. Called by refreshToken() to build the refresh request. */
	public static var getRefreshTokenCallback: (() -> String?)? = nil;

	/* Called after a successful refresh with the new (accessToken, refreshToken). The app should persist them in its session. */
	public static var onSuccessRefreshTokenCallback: ((String, String) -> Void)? = nil;

	/* Called when the refresh token request fails (refresh token is no longer valid). */
	public static var onInvalidRefreshTokenCallback: (() -> Void)? = nil;

	/* Called when a request returns an invalid (non-expired) JWT token. authorizationToken is cleared before this is invoked. */
	public static var onInvalidTokenCallback: (() -> Void)? = nil;

	public static func setAuthorizationToken(_ token: String?) {
		HTTPClient.authorizationToken = token;
	}

	public static func setRefreshTokenUrl(_ url: String) {
		HTTPClient.refreshTokenUrl = url;
	}

	public static func setGetRefreshTokenCallback(_ callback: @escaping () -> String?) {
		HTTPClient.getRefreshTokenCallback = callback;
	}

	public static func setOnSuccessRefreshTokenCallback(_ callback: @escaping (String, String) -> Void) {
		HTTPClient.onSuccessRefreshTokenCallback = callback;
	}

	public static func setOnInvalidRefreshTokenCallback(_ callback: @escaping () -> Void) {
		HTTPClient.onInvalidRefreshTokenCallback = callback;
	}

	public static func setOnInvalidTokenCallback(_ callback: @escaping () -> Void) {
		HTTPClient.onInvalidTokenCallback = callback;
	}

	/*
	 * Called when a request returns an invalid JWT token. Clears the stored authorizationToken
	 * and invokes onInvalidTokenCallback if configured.
	 */
	public static func onInvalidToken() {
		HTTPClient.authorizationToken = nil;
		HTTPClient.onInvalidTokenCallback?();
	}

	static var refreshTokenStarted = false;
	static var listCompleteCallbackAfterRefreshTokenStarted: [() -> Void] = [];

	/*
	 * Refreshes the access token using the configured statics.
	 * Reads refreshTokenUrl and getRefreshTokenCallback to build the request.
	 * On success, automatically updates authorizationToken with the new access token,
	 * then invokes onSuccessRefreshTokenCallback so the app can persist the new tokens.
	 * Queues all pending retry callbacks and executes them once the refresh succeeds.
	 * Concurrent refresh requests are de-duplicated: only one refresh call is made at a time.
	 *
	 * @param onComplete Called after the refresh succeeds (typically the retry of the original request).
	 * @param onError    Called for the current caller if the refresh fails.
	 */
	public static func refreshToken(
		onComplete: @escaping () -> Void = {},
		onError: ((Error?) -> Void)? = nil
	) {
		listCompleteCallbackAfterRefreshTokenStarted.append(onComplete);

		if (refreshTokenStarted) {
			return;
		}

		refreshTokenStarted = true;

		guard let refreshTokenUrl = HTTPClient.refreshTokenUrl else {
			NSLog("URL refresh token non définie. Appeler HTTPClient.setRefreshTokenUrl(url)");
			refreshTokenStarted = false;
			listCompleteCallbackAfterRefreshTokenStarted = [];
			onError?(nil);
			return;
		}

		guard let currentRefreshToken = HTTPClient.getRefreshTokenCallback?(), !currentRefreshToken.isEmpty else {
			NSLog("Refresh token getter non défini ou vide. Appeler HTTPClient.setGetRefreshTokenCallback(callback)");
			refreshTokenStarted = false;
			listCompleteCallbackAfterRefreshTokenStarted = [];
			onError?(nil);
			return;
		}

		var formData: [String: Any] = [:];
		formData["refresh_token"] = currentRefreshToken;
		HTTPClient.request(httpMethod: HTTPMethod.POST, url: refreshTokenUrl, requestParams: formData,
			onSuccess: { data, httpResponse in
				guard httpResponse.statusCode == HTTPResponseStatus.OK, let data = data else {
					HTTPClient.logErrorDataNil(refreshTokenUrl, httpResponse.statusCode);
					refreshTokenStarted = false;
					listCompleteCallbackAfterRefreshTokenStarted = [];
					HTTPClient.onInvalidRefreshTokenCallback?();
					onError?(nil);
					return;
				}

				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
						let newAccessToken = Json.getString(json["token"]);
						let newRefreshToken = Json.getString(json["refresh_token"]);
						NSLog("Token refresh succeeded. New access token: %@", newAccessToken);

						HTTPClient.authorizationToken = newAccessToken;
						HTTPClient.onSuccessRefreshTokenCallback?(newAccessToken, newRefreshToken);

						refreshTokenStarted = false;

						for callback in listCompleteCallbackAfterRefreshTokenStarted {
							callback();
						}
						listCompleteCallbackAfterRefreshTokenStarted = [];
					}
					else {
						HTTPClient.logErrorDecodingData(refreshTokenUrl, nil);
						refreshTokenStarted = false;
						listCompleteCallbackAfterRefreshTokenStarted = [];
						HTTPClient.onInvalidRefreshTokenCallback?();
						onError?(nil);
					}
				}
				catch let error {
					HTTPClient.logErrorDecodingData(refreshTokenUrl, error);
					refreshTokenStarted = false;
					listCompleteCallbackAfterRefreshTokenStarted = [];
					HTTPClient.onInvalidRefreshTokenCallback?();
					onError?(error);
				}
			},
			onError: { error in
				NSLog("Token refresh error: %@", error?.localizedDescription ?? "<nil>");
				refreshTokenStarted = false;
				listCompleteCallbackAfterRefreshTokenStarted = [];
				HTTPClient.onInvalidRefreshTokenCallback?();
				onError?(error);
			},
			addditionalHttpHeaders: [:],
			asJson: true,
			sendAuthorizationHeader: false
		);
	}

	/*
	 * Returns true if the HTTP response indicates an expired JWT token.
	 *
	 * @param responseCode The HTTP status code.
	 * @param data         The raw response body.
	 */
	public static func isExpiredToken(_ responseCode: Int, _ data: Data?) -> Bool {
		guard let data = data, responseCode == 401 else {
			return false;
		}

		NSLog("isExpiredToken");
		do {
			if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
				NSLog("json : %@", json.debugDescription);

				if let errorMessage = json["message"] as? String, errorMessage == "Expired JWT Token" {
					return true;
				}
				if let errorKey = json["error"] as? String, errorKey == "expired_token" {
					return true;
				}
			}
		}
		catch {}
		return false;
	}

	/*
	 * Returns true if the HTTP response indicates an invalid JWT token.
	 *
	 * @param responseCode The HTTP status code.
	 * @param data         The raw response body.
	 */
	public static func isInvalidToken(_ responseCode: Int, _ data: Data?) -> Bool {
		guard let data = data, responseCode == 401 else {
			return false;
		}

		do {
			if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
				if let errorMessage = json["message"] as? String, errorMessage == "Invalid JWT Token" {
					return true;
				}
				if let errorKey = json["error"] as? String, errorKey == "invalid_token" || errorKey == "authentification_failure" {
					return true;
				}
			}
		}
		catch {}
		return false;
	}

	/* Logs a successful HTTP response. */
	public static func logSuccess(_ url: String, _ responseCode: Int, _ json: Any? = nil) -> Void {
		NSLog("Success %@ : status code ok (%d)", url, responseCode);
		print(json ?? "<json nil>");
	}

	/* Logs an error caused by nil data or an unexpected status code. */
	public static func logErrorDataNil(_ url: String, _ responseCode: Int) -> Void {
		NSLog("Error %@ : data null or status code not ok (%d)", url, responseCode);
	}

	/* Logs an error response that includes a JSON body. */
	public static func logErrorWithData(_ url: String, _ responseCode: Int, _ json: Any) -> Void {
		NSLog("Error %@ : status code not ok (%d)", url, responseCode);
		print(json);
	}

	/* Logs a JSON decoding error. */
	public static func logErrorDecodingData(_ url: String, _ error: Error? = nil) -> Void {
		if let error = error {
			NSLog("Error %@ : decoding data exception with message %@", url, error.localizedDescription);
			return;
		}
		NSLog("Error %@ : decoding data", url);
	}

	/*
	 * Sends a multipart/form-data POST request with form fields and binary file parts.
	 * Handles JWT token expiry and refresh identically to request().
	 *
	 * @param url                     The endpoint URL string.
	 * @param requestParams           Form fields sent alongside the file parts.
	 * @param filesFieldName          The multipart field name applied to each file part.
	 * @param filesData               Binary data for each file to upload.
	 * @param filesMimeType           MIME type applied to each file part (default: image/jpeg).
	 * @param onSuccess               Called on the main thread with the response data and HTTP response.
	 * @param onError                 Called on the main thread with the error if the request fails.
	 * @param addditionalHttpHeaders  Extra headers to include in the request.
	 * @param sendAuthorizationHeader If true, attaches the current authorizationToken as Bearer.
	 */
	public static func multipartRequest(url: String, requestParams: [String: Any], filesFieldName: String, filesData: [Data], filesMimeType: String = "image/jpeg", onSuccess: @escaping(Data?, HTTPURLResponse) -> Void, onError: @escaping(Error?) -> Void, addditionalHttpHeaders: [String: String] = [:], sendAuthorizationHeader: Bool = true) {
		let boundary = "Boundary-\(UUID().uuidString)";
		var body = Data();

		for (key, value) in requestParams {
			body.append("--\(boundary)\r\n".data(using: .utf8)!);
			body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!);
			body.append("\(value)\r\n".data(using: .utf8)!);
		}

		let fileExtension = filesMimeType == "image/jpeg" ? "jpg" : "bin";
		for (index, fileData) in filesData.enumerated() {
			body.append("--\(boundary)\r\n".data(using: .utf8)!);
			body.append("Content-Disposition: form-data; name=\"\(filesFieldName)\"; filename=\"file_\(index).\(fileExtension)\"\r\n".data(using: .utf8)!);
			body.append("Content-Type: \(filesMimeType)\r\n\r\n".data(using: .utf8)!);
			body.append(fileData);
			body.append("\r\n".data(using: .utf8)!);
		}

		body.append("--\(boundary)--\r\n".data(using: .utf8)!);

		NSLog("HTTPClient.multipartRequest. URL: %@", url);

		let urlObj = URL(string: url)!;
		var request = URLRequest(url: urlObj);
		request.httpMethod = HTTPMethod.POST;
		request.httpBody = body;

		let accessToken = sendAuthorizationHeader ? HTTPClient.authorizationToken : nil;
		var headersWithContentType = addditionalHttpHeaders;
		headersWithContentType["Content-Type"] = "multipart/form-data; boundary=\(boundary)";
		for (key, value) in getHttpHeaders(httpMethod: HTTPMethod.POST, addditionalHttpHeaders: headersWithContentType, accessToken: accessToken) {
			request.setValue(value, forHTTPHeaderField: key);
		}

		DispatchQueue.global(qos: .userInitiated).async {
			let task = URLSession.shared.dataTask(with: request, completionHandler: {data, httpResponse, error in
				guard error == nil, let httpResponse = httpResponse as? HTTPURLResponse else {
					NSLog("HTTPClient.multipartRequest error: %@ ; URL: %@", error?.localizedDescription ?? "unknown error", url);
					DispatchQueue.main.async {
						onError(error);
					}
					return;
				}

				NSLog("HTTP status: %d ; URL: %@", httpResponse.statusCode, url);

				if sendAuthorizationHeader, isExpiredToken(httpResponse.statusCode, data) {
					refreshToken(onComplete: {
						NSLog("Retry multipartRequest after token refresh");
						HTTPClient.multipartRequest(url: url, requestParams: requestParams, filesFieldName: filesFieldName, filesData: filesData, filesMimeType: filesMimeType, onSuccess: onSuccess, onError: onError, addditionalHttpHeaders: addditionalHttpHeaders, sendAuthorizationHeader: sendAuthorizationHeader);
					});
					return;
				}

				if isInvalidToken(httpResponse.statusCode, data) {
					onInvalidToken();
					DispatchQueue.main.async {
						onError(nil);
					}
					return;
				}

				DispatchQueue.main.async {
					onSuccess(data, httpResponse);
				}
			});

			task.resume();
		}
	}

}