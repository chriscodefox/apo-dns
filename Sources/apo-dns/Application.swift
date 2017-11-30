//  apo-dns - Application.swift
//  Created by Kit on 11/29/17.
//  Copyright 2017 ___ORGANIZATIONNAME___. All rights reserved.



// MARK: Imports

import Foundation



// MARK: Implementations

class Application: NSObject {
    
    private(set) var runLoop: CFRunLoop?
    
    private(set) static var _instance: Application?
    public static var instance: Application {
        if _instance == nil {
            _instance = Application()
        }
        return _instance!
    }
    
    override private init() {
        super.init()
        print("[APP] Init")
    }
    
    func start(task: @escaping () -> ()) {
        
        print("[APP] Start")
        
        DispatchQueue.main.async(execute: task)
        
        runLoop = CFRunLoopGetCurrent()
        CFRunLoopRun()
    }
    
    func stop(exitCode: Int32 = 0) {
        
        print("[APP] Stop")
        
        CFRunLoopStop(runLoop!)
        exit(exitCode)
    }
    
    func async(_ queue: DispatchQueue, task: @escaping () -> ()) {
        queue.async(execute: task)
    }
    
    static func run(forever: Bool = false, task: @escaping (Application) throws -> ()) {
        let app = Application.instance
        app.start {
            
            do {
                try task(app)
            } catch {
                print("Fatal error: \(error.localizedDescription)")
                exit(1)
            }
            
            if !forever {
                app.stop()
            }
        }
    }
}
