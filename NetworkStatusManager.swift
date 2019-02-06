//
//  NetworkStatusManager.swift
//  NetworkStatus
//
//  Created by Raphaël Wach on 06/02/2019.
//  Copyright © 2019 Raphaël Wach. All rights reserved.
//

import Foundation
import SystemConfiguration

fileprivate var singletonNetworkStatusManager: NetworkStatusManager? = nil

func callBack(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
	print(flags)
	NetworkStatusManager.shared.flags = flags
}

public final class NetworkStatusManager {
	
	var networkReachability: SCNetworkReachability! = nil
	var flags: SCNetworkReachabilityFlags? = nil
	let queue = DispatchQueue(label: "NetworkingStatusQueue", qos: .utility)
	
	public static var shared: NetworkStatusManager {
		if singletonNetworkStatusManager == nil {
			singletonNetworkStatusManager = NetworkStatusManager()
		}
		return singletonNetworkStatusManager!
	}
	
	public func monitore() {
		var address = sockaddr_in()
		address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		address.sin_family = sa_family_t(AF_INET)
		guard let result: SCNetworkReachability = withUnsafePointer(to: address, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
				SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
			})
		}) else {
			fatalError("NetworkStatusManager encountered a fatal error")
		}
		self.networkReachability = result
		SCNetworkReachabilitySetCallback(self.networkReachability!, callBack, nil)
		SCNetworkReachabilitySetDispatchQueue(self.networkReachability, self.queue)
	}
	
	// MARK: - Life cycle
	
	private init() {
		
	}
	
}
