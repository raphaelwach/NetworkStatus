//
//  NetworkStatusObserver.swift
//  NetworkStatus
//
//  Created by Raphaël Wach on 07/02/2019.
//

import Foundation

public protocol NetworkStatusObserver {

	func changed(networkStatus: Network.Status)
	
}
