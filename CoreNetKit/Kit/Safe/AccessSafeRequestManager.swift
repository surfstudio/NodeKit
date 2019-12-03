//
//  AccessSafeRequestManager.swift
//  GoLamaGo
//
//  Created by Alexander Kravchenkov on 15.11.17.
//  Copyright © 2017 Surf. All rights reserved.
//

import Foundation

public protocol AccessSafeManager {
    func addRequest(request: SafableRequest)
}

public protocol AccessSafeRequestManagerDelegate {

    /// If access refreshed successfully then pass true, otherwise false
    func refreshAccess(_ completion: @escaping (Bool) -> Void)
}

public enum AuthError: Error {
    /// Need relogin
    case badTokens
}

public protocol SafableRequest: NSObjectProtocol {

    typealias Completion = (Bool) -> Void

    /// Completion boolean flag is true if request complete successfully and false if auth token expired
    func perform(completion: @escaping Completion)

    /// Performed if we can't refresh access token with current refresh token
    func performBadTokenError()
}

public class ServiceSafeRequest<RequestModel>: NSObject, SafableRequest {

    public typealias ServiceCompletion = (ResponseResult<RequestModel>) -> Void

    private let request: BaseServerRequest<RequestModel>
    private let serviceCompletion: ServiceCompletion

    public init(request: BaseServerRequest<RequestModel>, serviceCompletion: @escaping ServiceCompletion) {
        self.request = request
        self.serviceCompletion = serviceCompletion
    }

    public func perform(completion: @escaping SafableRequest.Completion) {
        self.request.performAsync(with: { (result) in
            if case .failure(let error) = result,
                case BaseServerError.unauthorized = error {
                completion(false)
                return
            }
            completion(true)
            self.serviceCompletion(result)
        })
    }

    public func performBadTokenError() {
        self.serviceCompletion(.failure(AuthError.badTokens))
    }
}

/// Incapsulate safe performation token refresh requests.
public class AccessSafeRequestManager: AccessSafeManager {

    fileprivate var requests: [SafableRequest]

    fileprivate var isRefreshTokenRequestWasSended: Bool

    fileprivate let delegate: AccessSafeRequestManagerDelegate
    private let queue = DispatchQueue(label: "com.magnit.AccessSafeRequestManager", qos: .userInitiated)

    public init(delegate: AccessSafeRequestManagerDelegate) {
        self.requests = [SafableRequest]()
        self.isRefreshTokenRequestWasSended = false
        self.delegate = delegate
    }

    public func addRequest(request: SafableRequest) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.backgoundAddRequest(request: request)
        }
    }

    /// Tried reperform all waiting requests
    public func update() {
        self.successSafePerformation()
    }
}

// MARK: - Backround methods

private extension AccessSafeRequestManager {

    func backgoundAddRequest(request: SafableRequest) {
        queue.async {
            self.requests.append(request)
            // true if no need perform
            // false if perform needed
            guard !self.isRefreshTokenRequestWasSended else {
                return
            }
            self.requestPerformationWrapper(request: request)
        }
    }

    func requestPerformationWrapper(request: SafableRequest) {
        request.perform { (isCompletedWithoutUnauthorized) in
            self.queue.async {
                guard !isCompletedWithoutUnauthorized else {
                    self.successPerformation(request: request)
                    return
                }
                // true if no need perform
                // false if perform needed
                if self.isRefreshTokenRequestWasSended {
                    return
                }
                self.isRefreshTokenRequestWasSended = true
                self.safePerform(request: request)
            }
        }
    }

    private func safePerform(request: SafableRequest) {
        self.delegate.refreshAccess { (isSuccess) in
            guard isSuccess else {
                self.failedSafePerformation(request: request)
                return
            }

            request.perform(completion: { result in
                guard !result else {
                    self.successSafePerformation()
                    return
                }
                self.failedSafePerformation(request: request)
            })
        }
    }

    private func successPerformation(request: SafableRequest) {
        queue.async {
            if !self.isRefreshTokenRequestWasSended,
                let index = self.requests.index(where: { $0.isEqual(request) }) {
                self.requests.remove(at: index)
            }
        }
    }

    private func failedSafePerformation(request: SafableRequest?) {
        request?.performBadTokenError()
        self.requests.removeAll()
        self.isRefreshTokenRequestWasSended = false
    }

    func successSafePerformation(request: SafableRequest) {
        successPerformation(request: request)
        self.successSafePerformation()
    }

    func successSafePerformation() {
        queue.async {
            self.isRefreshTokenRequestWasSended = false
            for awaitedRequest in self.requests {
                self.requestPerformationWrapper(request: awaitedRequest)
            }
        }
    }

}
