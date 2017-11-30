//  apo-dns - Application.swift
//  Created by Kit on 11/29/17.
//  Copyright 2017 ___ORGANIZATIONNAME___. All rights reserved.



// MARK: Imports

import Foundation
import Kitura



// MARK: Implementations

extension RouterRequest {
    typealias Subdomain = [String]
    // Extension to work arround broken .subdomains
    var subdomainComponents: Subdomain {
        return hostname.split(separator: ".").dropLast().map { String($0) }.filter { !$0.isEmpty }
    }
    var subdomainString: String { return subdomainComponents.joined(separator: ".") }
}


let router = Router()

router.get("/") { request, response, _ in
    print("[SRV] Received request")
    switch request.subdomainString {
    case let x where x.isEmpty:
        try response.status(.OK).send("Hello.").end()
    default:
        try response.status(.notFound).end()
    }
}

struct CLIParams {
    var port: UInt = 8080
    var ssl: UInt? = nil
}

func printHelp() {
    print("""
        apo-dns - Apotheca RDNS daemon

        Usage: apo-dns [-h|--help] [-p|--port PORT] [-s|--ssl PORT]
            Run the Apotheca Ring Domain Name System Daemon

        Visit https://apo-dns.com for more information.
        """)
}

func exitError(_ message: String, printHelp: Bool = false) -> Never {
    print("ERROR: \(message)")
    exit(1)
}


// MARK: Main

var params = CLIParams()
var iter = CommandLine.arguments.dropFirst().makeIterator()
while let arg = iter.next() {
    switch arg {
    case "-h", "--help":
        printHelp()
        exit(0)
    case "-p", "--port":
        guard let next = iter.next() else { exitError("Expected: PORT") }
        guard let port = UInt(next) else { exitError("Could not parse: PORT") }
        params.port = port
    case "-s","--ssl":
        guard let next = iter.next() else { exitError("Expected: SSLPORT") }
        guard let port = UInt(next) else { exitError("Could not parse: SSLPORT") }
        params.ssl = port
    default:
        print("ERROR: Unexpected argument: \(arg)")
        exit(1)
    }
}


Application.run(forever: true) { _ in
    Kitura.addHTTPServer(onPort: Int(params.port), with: router)
    if let sslPort = params.ssl {
        // TODO: Add HTTPS server on port 443
        //  https://developer.ibm.com/swift/2016/09/22/securing-kitura-part-1-enabling-ssltls-on-your-swift-server/
        // Kitura.addHTTPServer(onPort: Int(sslPort), with: router, withSSL: <#SSLConfig?#>)
    }
    print("[APP] Server starting...")
    Kitura.run()
}
