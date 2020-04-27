//
// AuthenticationChallengeResolver
// Robologs
//
// Created by Vladislav Maltsev on 02.04.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Describes how RemoteLogger connection will resolve URLAuthenticationChallenge for it's connection.
public protocol AuthenticationChallengePolicy {
    /// Requests credentials from the delegate in response to a session-level authentication request from the remote server.
    /// Signature and semantic the same as
    /// https://developer.apple.com/documentation/foundation/urlsessiondelegate/1409308-urlsession
    /// Additional information:
    /// https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge
    /// - Parameters:
    ///  - session: The session containing the task that requested authentication.
    ///  - challenge: An object that contains the request for authentication.
    ///  - completionHandler: A handler that your delegate method must call.
    ///  This completion handler takes the following parameters:
    ///        disposition — One of several constants that describes how the challenge should be handled.
    ///        credential — The credential that should be used for authentication if disposition
    ///            is NSURLSessionAuthChallengeUseCredential, otherwise NULL.
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}

/// Default system wide authentication challenge policy.
public struct DefaultChallengePolicy: AuthenticationChallengePolicy {
    /// Create new instance of `DefaultChallengePolicy`
    public init() {}

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
    ) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}

/// Authentication challenge policy that allows self signed certificates.
public struct AllowSelfSignedChallengePolicy: AuthenticationChallengePolicy {
    /// Create new instance of `AllowSelfSignedChallengePolicy`
    public init() {}

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
    ) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
