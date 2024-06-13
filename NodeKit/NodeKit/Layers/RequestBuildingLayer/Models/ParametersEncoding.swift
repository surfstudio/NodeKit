//
//  ParametersEncoding.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Request parameter encoding.
///
/// - json: Attempts to encode the data in JSON format and puts it in the request body.
/// - jsonArray: For encoding arrays in JSON. Used if you need to get JSON like `[ {}, {}, ...]`
/// - formURL: Attempts to encode the data in FormURL format and puts it in the request body.
/// - urlQuery: Gets a string from the data, encodes it into a URL string, and adds it to the request URL.
public enum ParametersEncoding {
    case json
    case formURL
    case urlQuery
}
