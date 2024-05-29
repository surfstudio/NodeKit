import Foundation

/// Model for sending multipart requests.
/// Allows transmitting both files and simple data.
open class MultipartModel<T> {

    /// Regular data for the request.
    public let payloadModel: T
    /// Files for the request.
    public let files: [String: MultipartFileProvider]

    /// Main constructor.
    ///
    /// - Parameters:
    ///   - payloadModel: Regular data for the request.
    ///   - files: Files for the request.
    public required init(payloadModel: T, files: [String: MultipartFileProvider]) {
        self.payloadModel = payloadModel
        self.files = files
    }

    /// Additional constructor. Initializes the object with an empty set of files.
    ///
    /// - Parameter payloadModel: Regular data for the request.
    public convenience init(payloadModel: T) {
        self.init(payloadModel: payloadModel, files: [String: MultipartFileProvider]())
    }
}
