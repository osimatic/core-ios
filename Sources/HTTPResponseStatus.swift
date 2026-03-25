import Foundation

/*
 * Constants for common HTTP response status codes.
 */
class HTTPResponseStatus {
	public static var OK = 200;
	public static var CREATED = 201;
	public static var ACCEPTED = 202;
	public static var NO_CONTENT = 204;
	public static var PARTIAL_CONTENT = 206;
	public static var BAD_REQUEST = 400;
	public static var UNAUTHORIZED = 401;
	public static var FORBIDDEN = 403;
	public static var NOT_FOUND = 404;
	public static var METHOD_NOT_ALLOWED = 405;
	public static var NOT_ACCEPTABLE = 406;
}