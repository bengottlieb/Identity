//
//  Email.swift
//  IdentityTesting
//
//  Created by Ben Gottlieb on 9/29/18.
//  Copyright © 2018 Stand Alone, inc. All rights reserved.
//

import Foundation

public class Email: Service {
	public static let instance = Email()
	public override var isAvailable: Bool { return true }
	
	public override func signIn(from sourceController: UIViewController?, completion: @escaping LoginCompletion) {
		completion(nil, nil)
	}
}

