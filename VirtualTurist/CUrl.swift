//
//  CUrl.swift
//  UdacityOnTheMap
//
//  Created by apple on 12/11/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation


struct CUrl {
    var session : URLSession
    var request : URLRequest
    
    func cURLRepresentation() -> String {
        var components = ["$ curl -i"]
        
        guard let URL = request.url,
            let host = URL.host
            else {
                return "$ curl command could not be created"
        }
        
        if let HTTPMethod = request.httpMethod, HTTPMethod != "GET" {
            components.append("-X \(HTTPMethod)")
        }
        
        if let credentialStorage = session.configuration.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: URL.port ?? 0,
                protocol: URL.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )
            
            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    components.append("-u \(credential.user!):\(credential.password!)")
                }
            }
        }
        
        if session.configuration.httpShouldSetCookies {
            if let cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: URL), !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value );" }
                components.append("-b \"\(string.substring(to:string.endIndex))\"")
            }
        }
        
        var headers: [AnyHashable: Any] = [:]
        
        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
            for (field, value) in additionalHeaders where field.description != "Cookie"  {
                headers[field] = value
            }
        }
        
        if let headerFields = request.allHTTPHeaderFields {
            for (field, value) in headerFields where field.description != "Cookie"  {
                headers[field] = value
            }
        }
        
        for (field, value) in headers {
            components.append("-H \"\(field): \(value)\"")
        }
        
        if let HTTPBodyData = request.httpBody,
            let HTTPBody = String(data: HTTPBodyData, encoding: .utf8)
        {
            var escapedBody = HTTPBody.replacingOccurrences(of:"\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of:"\"", with: "\\\"")
            
            components.append("-d \"\(escapedBody)\"")
        }
        
        components.append("\"\(URL.absoluteString)\"")
        
        return components.joined(separator: " \\\n\t")
    }
}
