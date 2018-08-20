//
//  MultipartData.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation

public struct MultipartData {
    public let data: Data
    public let name: String
    public let fileName: String
    public let mimeType: String

    ///Instantiates multipart data struct
    ///
    /// - Parameters:
    /// - data: data representation of an object
    /// - name: name of object
    /// - fileName: name of file to be created
    /// - mimeType: type of content
    public init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
