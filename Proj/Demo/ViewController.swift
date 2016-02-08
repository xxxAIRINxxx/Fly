//
//  ViewController.swift
//  Demo
//
//  Created by xxxAIRINxxx on 2016/01/27.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit
import Fly

enum DemoErrortype: ErrorType {
    case DemoError
}

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basics
        
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
        
        // Retry
        
        Fly.onFirst { result in
            // called first
            
            print("Retry onFirst")
            print(result)
            let count = (result as! Int)
            return FlyResult.Next(result: count)
            }.onNext(GCD.Default) { result in
                // called second
                
                print("Retry onNext")
                print(result)
                let count = (result as! Int)
                if count > 10 {
                    // call complete closure
                    return FlyResult.Finish(result: count)
                } else {
                    // call this closure
                    return FlyResult.Retry(result: count + 1)
                }
            }.onComplete(GCD.Background) { result in
                // called last
                
                print("Retry completion")
                print(result)
            }.fly(0)
        
        // Back
        
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
        
        // Restart
        
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
    }
}