import Foundation
import UIKit

/*
 * Executes a closure on the main thread after the specified delay.
 *
 * @param delay   The delay in seconds before executing the closure.
 * @param closure The block to execute after the delay.
 */
func delay(_ delay:Double, closure:@escaping ()->()) {
	let when = DispatchTime.now() + delay;
	DispatchQueue.main.asyncAfter(deadline: when, execute: closure);
}