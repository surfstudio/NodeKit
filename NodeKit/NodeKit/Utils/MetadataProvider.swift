import Foundation

/// Interface for any metadata (headers) provider.
/// Can be used, for example, to supply a token in a request without creating a custom node.
public protocol MetadataProvider {
    /// Returns a header with a token.
    func metadata() -> [String: String]
}
