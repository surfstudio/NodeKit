//
//  Method.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Describes HTTP methods.
///
/// - get: Requests a representation of the resource. Requests using this method can only retrieve data.
/// - head: Requests a resource like the GET method, but without the response body.
/// - post: Used to submit an entity to the specified resource. Often causes a change in state or some side effects on the server.
/// - put: Replaces all current representations of the resource with the data in the request.
/// - delete: Deletes the specified resource.
/// - connect: Establishes a "tunnel" to the server specified by the resource.
/// - options: Used to describe the communication options for the resource.
/// - trace: Performs a call to return a test message from the resource.
/// - patch: Used to apply partial modifications to a resource.
public enum Method: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}
