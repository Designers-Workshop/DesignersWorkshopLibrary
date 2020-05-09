//
//  OrderProduct.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent
import Vapor

public final class OrderProduct: Model, Content {
	public static let schema = "order_product"
	
	@ID(key: .id)
	public var id: UUID?
	
	@Parent(key: "order_id")
	public var order: Order
	
	@Parent(key: "product_id")
	public var product: Product
	
	public init() {}
	
	public init(id: UUID? = nil, orderID: UUID, productID: UUID) {
		self.id = id
		self.$order.id = orderID
		self.$product.id = productID
	}
}
#endif
