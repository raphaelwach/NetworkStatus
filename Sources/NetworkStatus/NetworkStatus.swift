//
//  NetworkStatus.swift
//  NetworkStatus
//
//  Created by Raphaël Wach on 07/02/2019.
//

import SystemConfiguration

fileprivate var singletonNetwork: Network? = nil

func callBack(target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    Network.shared.flags = flags
    let status: Network.Status = flags.contains(.reachable) ? .reachable : .unreachable
    Network.shared.observers.forEach { (observer) in
        observer.changed(networkStatus: status)
    }
}

public final class Network {
    
	// Network reachability status
    public enum Status {
		/// Reachable network detected
        case reachable
		/// No  reachable network detected
        case unreachable
    }
    
    var networkReachability: SCNetworkReachability! = nil
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
    let queue = DispatchQueue(label: "NetworkingStatusQueue", qos: .utility)
    
    fileprivate var observers: [NetworkStatusObserver] = []
    
    public func add(observer: NetworkStatusObserver) {
        self.observers.append(observer)
    }
    
	/// Unique instance of Network
    public static var shared: Network {
        if singletonNetwork == nil {
            singletonNetwork = Network()
        }
        return singletonNetwork!
    }
    
	/// Start monitoring the network
    public func monitore() {
        SCNetworkReachabilitySetCallback(self.networkReachability!, callBack, nil)
        SCNetworkReachabilitySetDispatchQueue(self.networkReachability, self.queue)
    }
    
	/// Get the current network status immediately
    public func currentStatus() -> Status {
        SCNetworkReachabilityGetFlags(self.networkReachability, &(self.flags))
        return self.flags.contains(.reachable) ? .reachable : .unreachable
    }
    
    private func reachabilityZeroAddress() -> SCNetworkReachability {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        guard let networkReachability: SCNetworkReachability = withUnsafePointer(to: address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            })
        }) else {
            fatalError("NetworkStatus encountered a fatal error")
        }
        return networkReachability
    }
    
    // MARK: - Life cycle
    
    private init() {
        self.networkReachability = self.reachabilityZeroAddress()
    }
    
}
