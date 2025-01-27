//
//  ResponseDataParserNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Errors for the ``ResponseDataParserNode``.
///
/// - cantDeserializeJson: Occurs if `Json` cannot be obtained from the server response.
/// - cantCastDesirializedDataToJson: Occurs if `JSON` cannot be serialized from `Data`.
public enum ResponseDataParserNodeError: Error {
    case cantDeserializeJson(String)
    case cantCastDesirializedDataToJson(String)
}

/// Performs the transformation of "raw" data into `Json`.
open class ResponseDataParserNode: AsyncNode {

    /// The next node for processing.
    public var next: (any ResponsePostprocessorLayerNode)?

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: (any ResponsePostprocessorLayerNode)? = nil) {
        self.next = next
    }

    /// Parses the response and passes control to the next node in case of success.
    ///
    /// - Parameter data: The server response model.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            await parse(with: data, logContext: logContext)
                .asyncFlatMap { json, logMessage in
                    let logMsg = logMessage + .lineTabDeilimeter
                    var log = LogChain(logMsg, id: objectName, logType: .info, order: LogOrder.responseDataParserNode)

                    guard let next = next else {
                        await logContext.add(log)
                        return .success(json)
                    }

                    let networkResponse = URLProcessedResponse(dataResponse: data, json: json)

                    await logContext.add(log)
                    await next.process(networkResponse, logContext: logContext)

                    return .success(json)
                }
        }
    }

    /// Retrieves `json` from the server response model.
    /// Contains all the parsing logic.
    ///
    /// - Parameter responseData: The server response model.
    /// - Returns: The Json that was successfully parsed.
    /// - Throws:
    ///     - `ResponseDataParserNodeError.cantCastDesirializedDataToJson`
    ///     - `ResponseDataParserNodeError.cantDeserializeJson`
    open func json(from responseData: URLDataResponse) throws -> (Json, String) {

        var log = ""

        guard responseData.data.count != 0 else {
            log += "Response data is empty -> returns empty json"
            return (Json(), log)
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData.data, options: .allowFragments) else {
            log += "Cant deserialize \(String(describing: String(data: responseData.data, encoding: .utf8)))"
            throw ResponseDataParserNodeError.cantCastDesirializedDataToJson(log)
        }

        let anyJson = { () -> Json? in
            if let result = jsonObject as? [Any] {
                return [MappingUtils.arrayJsonKey: result]
            } else if let result = jsonObject as? Json {
                return result
            } else {
                return nil
            }
        }()

        guard let json = anyJson else {
            log += "After parsing get nil json"
            throw ResponseDataParserNodeError.cantDeserializeJson(log)
        }

        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            log += "Result:" + .lineTabDeilimeter
            log += String(data: data, encoding: .utf8) ?? "CURRUPTED"
        }

        return (json, log)
    }

    // MARK: - Private Methods

    private func parse(
        with data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<(Json, String)> {
        do {
            let result = try json(from: data)
            return .success(result)
        } catch {
            var log = LogChain("", id: objectName, logType: .failure, order: LogOrder.responseDataParserNode)
            switch error {
            case ResponseDataParserNodeError.cantCastDesirializedDataToJson(let logMsg), 
                ResponseDataParserNodeError.cantDeserializeJson(let logMsg):
                log += logMsg
            default:
                log += "Catch \(error)"
            }
            await logContext.add(log)
            return .failure(error)
        }
    }
}
