import Foundation

/// File provider for multipart requests.
///
/// - data: Provides a file as binary data, including name and type.
/// - url: Provides a file as a file path. It will be uploaded later. The original name and type will be used for the request.
/// - customWithURL: Similar to `url`, except that you can specify the file name and file type yourself.
public enum MultipartFileProvider {
    case data(data: Data, filename: String, mimetype: String)
    case url(url: URL)
    case customWithURL(url: URL, filename: String, mimetype: String)
}
