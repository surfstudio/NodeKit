import Foundation
import XCTest

/// Проверяет:
/// 1. Если у URL нет query, то вернется тот же самый URL
/// 2. Для двух URL с разным порядком query вернется одна и та же строка
final class URLWithOrderedQuery: XCTestCase {

    /// Если у URL нет query, то вернется тот же самый URL
    func testURLDoesntHaveQuery() throws {
        // Arrange

        let url = try XCTUnwrap(URL(string: "https://test.test"))

        // Act

        let res = url.withOrderedQuery()

        // Assert

        XCTAssertEqual(url.absoluteString,
                       res,
                       "Result should be equal to given url, but res: \(res ?? "nil") and given: \(url.absoluteString)")
    }

    // Для двух URL с разным порядком query вернется одна и та же строка
    func testURLWithDifferentParamsOrder() throws {
        // Arrange

        // кол-во парамтров в URL
        let capacity = 100

        var params = [String: String]()

        (0...capacity).forEach { params["q\($0)"] = "\($0)" }

        let base = "https://test.test/test"

        let urls = try (0...capacity).map { _ -> URL in
            var localParams = params
            var query = [URLQueryItem]()
            // пока список с парамтерами не опустеет
            while !localParams.isEmpty {
                // получаем слуайный параметр
                let (key, value) = try XCTUnwrap(localParams.randomElement())
                // добавляем его в query
                query.append(.init(name: key, value: value))
                // удаляем параметр чтоб в следующий раз он не вернулся из `randomElement`
                localParams.removeValue(forKey: key)
            }
            var cmp = try XCTUnwrap(URLComponents(string: base))
            cmp.queryItems = query
            return try XCTUnwrap(cmp.url)
        }

        print(urls)

        // Act

        let res = urls.map { $0.withOrderedQuery() }
        print(res)
        // Assert

        res.forEach { url in
            res.forEach { XCTAssertEqual(url, $0) }
        }
    }
}
