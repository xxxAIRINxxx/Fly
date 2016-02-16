//
//  Fly.swift
//  Fly
//
//  Created by xxxAIRINxxx on 2016/02/02.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation

public typealias FlyNextClosure = (AnyObject? -> FlyResult)
public typealias FlyErrorClosure = (ErrorType -> Void)
public typealias FlyCompletionClosure = (AnyObject? -> Void)
public typealias FlyCancelClosure = (Void -> Void)

public enum FlyType {
    
    case Next(closure: FlyNextClosure)
    case Error(closure: FlyErrorClosure)
    case Completion(closure: FlyCompletionClosure)
    case Cancel(closure: FlyCancelClosure)
    
    var isNextType: Bool {
        if case .Next(_) = self { return true }
        return false
    }
}

public enum FlyResult {
    
    case Next(result: AnyObject?)
    case Retry(result: AnyObject?)
    case Back(result: AnyObject?)
    case Restart(result: AnyObject?)
    case Error(Error: ErrorType)
    case Finish(result: AnyObject?)
    case Cancel
}

public final class Fly {
    
    private var elements: [FlyPoint] = []
    
    private func nextPoints() -> [FlyPoint] {
        return self.elements.filter() { $0.type.isNextType }
    }
    
    private func flyPointsAtIndex(index: Int) -> FlyPoint? {
        return self.nextPoints()
            .enumerate()
            .filter() { $0.index == index }
            .map() { return $0.element }
            .first
    }
    
    private func previousFlyPoint(currentFlyPoint: FlyPoint) -> FlyPoint? {
        let index = self.nextPoints()
            .enumerate()
            .filter() { $0.element === currentFlyPoint }
            .map() { return $0.index - 1 }
            .first
        
        return index != nil ? self.flyPointsAtIndex(index!) : nil
    }
    
    private func nextFlyPoint(currentFlyPoint: FlyPoint) -> FlyPoint? {
        let index = self.nextPoints()
            .enumerate()
            .filter() { $0.element === currentFlyPoint }
            .map() { return $0.index + 1 }
            .first
        
        return index != nil ? self.flyPointsAtIndex(index!) : nil
    }
    
    private func runCompletion(obj: AnyObject?) {
        self.elements.forEach() { if case .Completion(let f) = $0.type { dispatch_async($0.gcd.queue) { f(obj) } }}
    }
    
    private func fly(previousResult: FlyResult, _ previousFlyPoint: FlyPoint?) {
        let flyPoint = previousFlyPoint ?? self.flyPointsAtIndex(0)
        guard let _flyPoint = flyPoint else {
            self.runCompletion(nil)
            return
        }
        
        switch previousResult {
        case .Next(let result):
            guard let _nextFlyPoint = self.nextFlyPoint(_flyPoint) else {
                self.runCompletion(result)
                return
            }
            if case .Next(let f) = _nextFlyPoint.type { dispatch_async(_nextFlyPoint.gcd.queue) { self.fly(f(result), _nextFlyPoint) }}
        case .Retry(let result):
            if case .Next(let f) = _flyPoint.type { dispatch_async(_flyPoint.gcd.queue) { self.fly(f(result), _flyPoint) }}
        case .Back(let result):
            guard let _nextFlyPoint = self.previousFlyPoint(_flyPoint) else {
                self.runCompletion(result)
                return
            }
            if case .Next(let f) = _nextFlyPoint.type { dispatch_async(_nextFlyPoint.gcd.queue) { self.fly(f(result), _nextFlyPoint) } }
        case .Restart(let result):
            self.fly(.Retry(result: result), nil)
        case .Error(let error):
            self.elements.forEach() { if case .Error(let f) = $0.type { dispatch_async($0.gcd.queue) { f(error) } }}
            self.runCompletion(nil)
        case .Finish(let result):
            self.runCompletion(result)
        case .Cancel:
            self.elements.forEach() { if case .Cancel(let f) = $0.type { dispatch_async($0.gcd.queue) { f() } }}
            self.runCompletion(nil)
        }
    }
}

// MARK: - FlyPoint

private final class FlyPoint {
    
    private let gcd: GCD
    private let type: FlyType
    
    private init(_ gcd: GCD, _ type: FlyType) {
        self.gcd = gcd
        self.type = type
    }
}

// MARK: - Fly away

extension Fly {
    
    public final func fly(obj: AnyObject? = nil) {
        self.fly(.Retry(result: obj), nil)
    }
}

// MARK: - Fly Static Functions

extension Fly {
    
    public static func onFirst(gcd: GCD = GCD.Main, closure: FlyNextClosure) -> Fly {
        let fly = Fly()
        fly.elements.append(FlyPoint(gcd, .Next(closure: closure)))
        return fly
    }
}

// MARK: - Fly Instance Functions

extension Fly {
    
    public final func onNext(gcd: GCD = GCD.Main, _ closure: FlyNextClosure) -> Fly {
        self.elements.append(FlyPoint(gcd, .Next(closure: closure)))
        return self
    }
    
    public final func onError(gcd: GCD = GCD.Main, _ closure: FlyErrorClosure) -> Fly {
        self.elements.append(FlyPoint(gcd, .Error(closure: closure)))
        return self
    }
    
    public final func onComplete (gcd: GCD = GCD.Main, _ closure: FlyCompletionClosure) -> Fly {
        self.elements.append(FlyPoint(gcd, .Completion(closure: closure)))
        return self
    }
    
    public final func onCancel(gcd: GCD = GCD.Main, _ closure: FlyCancelClosure) -> Fly {
        self.elements.append(FlyPoint(gcd, .Cancel(closure: closure)))
        return self
    }
}