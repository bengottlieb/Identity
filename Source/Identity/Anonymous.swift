//
//  Anonymous.swift
//  Identity_iOS
//
//  Created by Ben Gottlieb on 7/2/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation

@available(iOSApplicationExtension 10.0, *)
public class Anonymous: Service {
	public static let instance = Anonymous()
	
	enum Error: String, Swift.Error { case unableToFetchVendorID }
	
	public override func signIn(from sourceController: UIViewController?, completion: @escaping LoginCompletion) {
		CloudKit.instance.signInAnonymously(from: sourceController) { ckInfo, error in
			if let info = ckInfo {
				self.userInformation = info
				completion(info, nil)
			} else {
				Device.instance.signIn(from: sourceController) { deviceInfo, error in
					self.userInformation = deviceInfo
					completion(deviceInfo, nil)
				}
			}
		}
	}
}

