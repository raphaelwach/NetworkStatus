# NetworkStatus

NetworkStatus allows to simply monitore the reachability of the network in Swift

## Usage

You access the tool threw the instance *Network.shared*.

First, you need to implement the protocol NetworkStatusObserver somewhere in your app

```swift
import NetworkStatus

extension MyClass: NetworkStatusObserver {
	
	func changed(networkStatus: Network.Status) {
		if networkStatus == .reachable {
			// Do something, the network is reachable...
		} else if networkStatus == .unreachable {
			// Do something else, the network is unreachable...
		}
	}
	
}
```

To start monitoring the network and getting notified when it changes, you need to register at least one observer and to start monitoring

```swift

Network.shared.add(observer: myObserver)
Network.shared.monitore()

```

That's it !

Bonus, you can also synchronously ask for the current network status anytime without having registered an observer

```swift

let status: Network.Status = Network.shared.currentStatus()

```

Author: Raphaël Wach  
[@raphaelwach](https://twitter.com/raphaelwach)
