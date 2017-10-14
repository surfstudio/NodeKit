//
//  SampleURL.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation

class GoLamaGoURLs {

    public static let baseUrl = "http://lama.api.surfstudio.ru:11114/"// 

    public static let Authentication = "users"
    public static let Authorization = "connect/token"
    public static let Shops = "shops"
    public static let ComercialNetwork = "shopgroups"

    public static let orders = "orders"

    public static let user = "user"
    public static let profile = "\(user)/profile"
    public static let address = "\(profile)/address"

    public static let cart = "cart"

    /// Make URL path to current shop's cart
    ///
    /// - Parameter id: shop id
    public static func shopCart(id: String) -> String { return "\(cart)/\(id)" }

    /// Make URL path to set address for cart.
    ///
    /// - Parameter id: shop id
    public static func shopCartAddress(id: String) -> String { return "\(shopCart(id: id))/delivery" }

    /// Make URL path to current shops's items in cart
    ///
    /// - Parameter id: shop id
    public static func shopCartAddItem(id: String) -> String { return "\(shopCart(id: id))/items" }

    /// Make URL path to modife item in current shop's cart
    ///
    /// - Parameters:
    ///   - shopId: shop id
    ///   - itemId: item id
    public static func shopCartModifyItem(shopId: String, itemId: String) -> String { return "\(shopCartAddItem(id: shopId))/\(itemId)" }

    public static func availableDeliveryDates(shopId: String) -> String {
        return "\(cart)/\(shopId)/delivery/times"
    }

    public static func checkInUrl(orderId: String) -> String {
        return "\(orders)/\(orderId)/checkin"
    }

    public static func confirmUrl(orderId: String) -> String {
        return "\(orders)/\(orderId)/confirmation"
    }

    public static func denyFormItem(orderId: String) -> String {
        return "\(orders)/\(orderId)/deny"
    }

    public static func removeMissingItem(orderId: String, itemId: String) -> String {
        return "\(orders)/\(orderId)/items/\(itemId)"
    }

    public static func replaceOrderItem(orderId: String, itemId: String) -> String {
        return "\(orders)/\(orderId)/items/\(itemId)"
    }
}
