import Foundation

/*
 * Utility class for performing HTTP requests with optional JWT bearer authentication
 * and automatic token refresh on 401 responses.
 */
class HTTPClient {

	/*
	 * Sends an HTTP request and delivers the response on the main thread.
	 *
	 * @param httpMethod              The HTTP method (GET, POST, PATCH, DELETE).
	 * @param url                     The endpoint URL string.
	 * @param requestParams           The request parameters (appended as query string for GET,
	 *                                or as body for other methods).
	 * @param onSuccess               Called on the main thread with the response data and HTTP response.
	 * @param onError                 Called on the main thread with the error if the request fails.
	 * @param addditionalHttpHeaders  Extra headers to include in the request.
	 * @param asJson                  If true, encodes the body as JSON instead of form-urlencoded.
	 * @param userSession             If provided, attaches a Bearer token and handles token refresh.
	 */
	static func request(httpMethod: String, url: String, requestParams: [String: Any], onSuccess: @escaping(Data?, HTTPURLResponse) -> Void, onError: @escaping(Error?) -> Void, addditionalHttpHeaders: [String: String] = [:], asJson: Bool = false, userSession: UserSession? = nil) {
		var urlWithRequestParams = url;
		if (HTTPMethod.GET == httpMethod) {
			urlWithRequestParams += "?"+URLQueryString.getQueryStringFromArray(requestParams);
		}
		NSLog("HTTPClient.request. Method: %@, URL: %@", httpMethod, urlWithRequestParams);

		let urlObj = URL(string: urlWithRequestParams)!;
		var request = URLRequest(url: urlObj);

		// HTTP Headers
		for (key, value) in getHttpHeaders(httpMethod: httpMethod, addditionalHttpHeaders: addditionalHttpHeaders, accessToken: userSession?.getAccessToken(), asJson: asJson) {
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
				guard error == nil, let httpResponse = httpResponse else {
					NSLog("HTTP Request error: %@ ; URL: %@", error?.localizedDescription ?? "unknown error", urlObj.absoluteString);
					DispatchQueue.main.async {
						onError(error);
					}
					return;
				}

				let httpResponse = httpResponse as! HTTPURLResponse;
				NSLog("HTTP status: %d ; URL: %@", httpResponse.statusCode, urlObj.absoluteString);

				if let userSession = userSession, isExpiredToken(httpResponse.statusCode, data) {
					refreshToken(
						userSession: userSession,
						onSuccess: {
							NSLog("Retry HTTP request after token refresh");
							HTTPClient.request(httpMethod: httpMethod, url: url, requestParams: requestParams, onSuccess: onSuccess, onError: onError, addditionalHttpHeaders: addditionalHttpHeaders, asJson: asJson, userSession: userSession);
						}
					);
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
	 *
	 * @param httpMethod             The HTTP method (typically GET).
	 * @param url                    The endpoint URL string.
	 * @param requestParams          The request parameters.
	 * @param fileName               The local file name used when saving to the documents directory.
	 * @param onSuccess              Called on the main thread with the HTTP response on success.
	 * @param onError                Called on the main thread with the error if the download fails.
	 * @param addditionalHttpHeaders Extra headers to include in the request.
	 * @param userSession            If provided, attaches a Bearer token.
	 */
	static func downloadFile(httpMethod: String, url: String, requestParams: [String: Any], fileName: String, onSuccess: @escaping(HTTPURLResponse) -> Void, onError: @escaping(Error?) -> Void, addditionalHttpHeaders: [String: String] = [:], userSession: UserSession? = nil) {
		DispatchQueue.global(qos: .userInitiated).async {
			var urlWithRequestParams = url;
			if (HTTPMethod.GET == httpMethod) {
				urlWithRequestParams += "?"+URLQueryString.getQueryStringFromArray(requestParams);
			}
			NSLog("HTTPClient.downloadFile. Method: %@, URL: %@", httpMethod, urlWithRequestParams);

			let urlObj = URL(string: urlWithRequestParams)!;
			var request = URLRequest(url: urlObj);

			// HTTP Headers
			for (key, value) in getHttpHeaders(httpMethod: httpMethod, addditionalHttpHeaders: addditionalHttpHeaders, accessToken: userSession?.getAccessToken()) {
				request.setValue(value, forHTTPHeaderField: key);
			}

			// Data
			request.httpMethod = httpMethod;

			if (HTTPMethod.GET != httpMethod) {
				request.httpBody = Data(URLQueryString.getQueryStringFromArray(requestParams).utf8);
				NSLog("Data : %@", URLQueryString.getQueryStringFromArray(requestParams).utf8.description);
			}

			let downloadTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: request) { (tempLocalUrl, httpResponse, error) in
				guard let tempLocalUrl = tempLocalUrl, error == nil, let httpResponse = httpResponse else {
					NSLog("HTTP Request error: %@ ; URL: %@", error?.localizedDescription ?? "unknown error", urlObj.absoluteString);
					DispatchQueue.main.async {
						onError(error);
					}
					return;
				}

				let httpResponse = httpResponse as! HTTPURLResponse;
				NSLog("HTTP status: %d ; URL: %@", httpResponse.statusCode, urlObj.absoluteString);

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
						onSuccess(httpResponse);
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
	static func getHttpHeaders(httpMethod: String, addditionalHttpHeaders: [String: String] = [:], accessToken: String? = nil, asJson: Bool = false) -> [String: String] {
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

	static var refreshTokenStarted = false;
	static var listCompleteCallbackAfterRefreshTokenStarted: [() -> Void] = [];

	/*
	 * Refreshes the access token using the stored refresh token.
	 * Queues all pending retry callbacks and executes them once the refresh succeeds.
	 * Concurrent refresh requests are de-duplicated: only one refresh call is made at a time.
	 *
	 * @param userSession The session holding the refresh token and receiving the new tokens.
	 * @param onSuccess   Called after the token has been refreshed successfully.
	 */
	static func refreshToken(userSession: UserSession, onSuccess: @escaping () -> Void = {}) -> Void {
		listCompleteCallbackAfterRefreshTokenStarted.append(onSuccess);

		if (refreshTokenStarted) {
			return;
		}

		refreshTokenStarted = true;

		var formData: [String: Any] = [:];
		formData["refresh_token"] = userSession.getRefreshToken();
		HTTPClient.request(httpMethod: HTTPMethod.POST, url: Api.URL_REFRESH_TOKEN, requestParams: formData,
			onSuccess: { data, httpResponse in
				guard httpResponse.statusCode == HTTPResponseStatus.OK, let data = data else {
					HTTPClient.logErrorDataNil("URL_REFRESH_TOKEN", httpResponse.statusCode);
					refreshTokenStarted = false;
					listCompleteCallbackAfterRefreshTokenStarted = [];
					return;
				}

				do {
					if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
						let accessToken = Json.getString(json["token"]);
						NSLog("Token refresh succeeded. New access token: %@", accessToken);
						userSession.setAccessToken(accessToken);
						userSession.setRefreshToken(Json.getString(json["refresh_token"]));

						refreshTokenStarted = false;

						for callback in listCompleteCallbackAfterRefreshTokenStarted {
							callback();
						}
						listCompleteCallbackAfterRefreshTokenStarted = [];
					}
					else {
						HTTPClient.logErrorDecodingData("URL_REFRESH_TOKEN", nil);
						refreshTokenStarted = false;
						listCompleteCallbackAfterRefreshTokenStarted = [];
					}
				}
				catch let error {
					HTTPClient.logErrorDecodingData("URL_REFRESH_TOKEN", error);
					refreshTokenStarted = false;
					listCompleteCallbackAfterRefreshTokenStarted = [];
				}
			},
			onError: { error in
				NSLog("Token refresh error: %@", error?.localizedDescription ?? "<nil>");
				refreshTokenStarted = false;
				listCompleteCallbackAfterRefreshTokenStarted = [];
			},
			asJson: true
		);
	}

	/*
	 * Returns true if the HTTP response indicates an expired JWT token.
	 *
	 * @param responseCode The HTTP status code.
	 * @param data         The raw response body.
	 */
	static func isExpiredToken(_ responseCode: Int, _ data: Data?) -> Bool {
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
	static func isInvalidToken(_ responseCode: Int, _ data: Data?) -> Bool {
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
	static func logSuccess(_ url: String, _ responseCode: Int, _ json: Any? = nil) -> Void {
		NSLog("Success %@ : status code ok (%d)", url, responseCode);
		print(json ?? "<json nil>");
	}

	/* Logs an error caused by nil data or an unexpected status code. */
	static func logErrorDataNil(_ url: String, _ responseCode: Int) -> Void {
		NSLog("Error %@ : data null or status code not ok (%d)", url, responseCode);
	}

	/* Logs an error response that includes a JSON body. */
	static func logErrorWithData(_ url: String, _ responseCode: Int, _ json: Any) -> Void {
		NSLog("Error %@ : status code not ok (%d)", url, responseCode);
		print(json);
	}

	/* Logs a JSON decoding error. */
	static func logErrorDecodingData(_ url: String, _ error: Error? = nil) -> Void {
		if let error = error {
			NSLog("Error %@ : decoding data exception with message %@", url, error.localizedDescription);
			return;
		}
		NSLog("Error %@ : decoding data", url);
	}

}