//
//  MultipartFormDataProtocol.swift
//  NodeKit
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Constructs `multipart/form-data` for uploads within an HTTP or HTTPS body. There are currently two ways to encode
/// multipart form data. The first way is to encode the data directly in memory. This is very efficient, but can lead
/// to memory issues if the dataset is too large. The second way is designed for larger datasets and will write all the
/// data to a single file on disk with all the proper boundary segmentation. The second approach MUST be used for
/// larger datasets such as video content, otherwise your app may run out of memory when trying to encode the dataset.
public protocol MultipartFormDataProtocol {
    
    /// The `Content-Type` header value containing the boundary used to generate the `multipart/form-data`
    var contentType: String { get set }
    
    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter data:     The data to encode into the multipart form data.
    /// - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the data in the `Content-Type` HTTP header.
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?)
    
    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// The filename in the `Content-Disposition` HTTP header is generated from the last path component of the
    /// `fileURL`. The `Content-Type` HTTP header MIME type is generated by mapping the `fileURL` extension to the
    /// system associated MIME type.
    ///
    /// - parameter fileURL: The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:    The name to associate with the file content in the `Content-Disposition` HTTP header.
    func append(_ fileURL: URL, withName name: String)
    
    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
    /// - Content-Type: #{mimeType} (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter fileURL:  The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:     The name to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the file content in the `Content-Type` HTTP header.
    func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String)
    
    /// Encodes all the appended body parts into a single `Data` value.
    ///
    /// It is important to note that this method will load all the appended body parts into memory all at the same
    /// time. This method should only be used when the encoded data will have a small memory footprint. For large data
    /// cases, please use the `writeEncodedData(to:))` method.
    ///
    /// - throws: An `AFError` if encoding encounters an error.
    ///
    /// - returns: The encoded `Data` if encoding is successful.
    func encode() throws -> Data
}

public extension MultipartFormDataProtocol {
    func append(_ data: Data, withName name: String) {
        append(data, withName: name, fileName: nil, mimeType: nil)
    }
}
