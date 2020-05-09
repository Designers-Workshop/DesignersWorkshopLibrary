//
//  Order.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent
import Vapor

public final class Order: Model, Content {
	public static let schema = "orders"
	
	@ID(key: .id)
	public var id: UUID?
	
	@Parent(key: "user_id")
	public var user: User
	
	@Timestamp(key: "order_date_time", on: .create)
	public var orderedOn: Date?
	
	@Field(key: "zone")
	public var zone: String
	
	@Siblings(through: OrderProduct.self, from: \.$order, to: \.$product)
	public var products: [Product]
	
	public init() {}
	
	public init(id: UUID? = nil, userID: UUID, orderedOn: Date?, zone: String) {
		self.id = id
		self.$user.id = userID
		self.orderedOn = orderedOn
		self.zone = zone
	}
}
#endif
