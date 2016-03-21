# Fly

[![Swift 2.1+](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Xcode 7.1+](https://img.shields.io/badge/Xcode-7.1+-blue.svg?style=flat)](https://developer.apple.com/swift/)

Fly is inspired by [Async](https://github.com/duemunk/Async).

## Features

- Execution control of chained closures (next, cancel, complete, error, back, retry, restart).
- Can select the executed queue of GCD (Grand Central Dispatch).
- Pass the object to the next queue.
- Less code indentation.

## Exsamples

### Basics

```swift
Fly.onFirst { result in
    // called first
    // called at main thread queue

    print("Basics onFirst")
    print(result)
    let count = (result as! Int)
    return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Background) { result in
        // called second
        // called at background qos class thread queue

        print("Basics onNext1")
        print(result)
        let count = (result as! Int)
        return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Default) { result in
        // called third
        // called at default qos class thread queue

        print("Basics onNext2")
        print(result)
        if (result as! Int) > 10 {
            // call complete closure
            return FlyResult.Finish(result: result)
        } else {
            // call cancel closure
            return FlyResult.Cancel
        }
    }.onCancel(GCD.Utility) {
        // called fourth
        // called at utility qos class thread queue

        print("Basics cancel")
    }.onComplete { result in
        // called last
        // called at main thread queue

        print("Basics completion")
        print(result)
    }.fly(0)
}
```

### Retry

```swift
Fly.onFirst { result in
    // called first

    print("Retry onFirst")
    print(result)
    let count = (result as! Int)
    return FlyResult.Next(result: conut)
    }.onNext(GCD.Default) { result in
        // called second

        print("Retry onNext")
        print(result)
        let count = (result as! Int)
        if count > 10 {
            // call complete
            return FlyResult.Finish(result: conut)
        } else {
            // call this closure
            return FlyResult.Retry(result: count + 1)
        }
    }.onComplete(GCD.Background) { result in
        // called last

        print("Retry completion")
        print(result)
    }.fly(0)
```

### Back

```swift

Fly.onFirst { result in
    // called first

    print("Back onFirst")
    print(result)
    let count = (result as! Int)
    return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Background) { result in
        // called second

        print("Back onNext1")
        print(result)
        let count = (result as! Int)
        return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Default) { result in
        // called third

        print("Back onNext2")
        print(result)
        if (result as! Int) > 10 {
            // call complete closure
            return FlyResult.Finish(result: result)
        } else {
            // call previous closure
            return FlyResult.Back(result: result)
        }
    }.onComplete(GCD.Background) { result in
        // called last

        print("Back completion")
        print(result)
    }.fly(0)
}
```

### Restart

```swift
Fly.onFirst { result in
    // called first

    print("Restart onFirst")
    print(result)
    let count = (result as! Int)
    return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Background) { result in
        // called second

        print("Restart onNext1")
        print(result)
        let count = (result as! Int)
        return FlyResult.Next(result: count + 1)
    }.onNext(GCD.Default) { result in
        // called third

        print("Restart onNext2")
        print(result)
        if (result as! Int) > 10 {
            // call complete closure
            return FlyResult.Finish(result: result)
        } else {
            // call first closure
            return FlyResult.Restart(result: result)
        }
    }.onComplete(GCD.Background) { result in
        // called last

        print("Restart completion")
        print(result)
    }.fly(0)
```

## Requirements

* Xcode 7.1+
* iOS 8.0+
* Swift 2.1+

## Installation

### CocoaPods

Fly is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!

pod "Fly"
```

### Carthage

To integrate Chain into your Xcode project using Carthage, specify it in your Cartfile:

```ruby
github "xxxAIRINxxx/Fly"
```

## License

MIT license. See the LICENSE file for more info.
