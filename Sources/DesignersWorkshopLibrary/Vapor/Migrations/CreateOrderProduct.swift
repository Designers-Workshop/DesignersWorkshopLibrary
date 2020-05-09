//
//  CreateOrderProduct.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent

public struct CreateOrderProduct: Migration {
	public func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("order_product")
			.id()
			.field("order_id", .uuid, .required, .references("orders", "id"))
			.field("product_id", .uuid, .required, .references("products", "id"))
			.create()
	}
	
	public func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("order_product").delete()
	}
	
	public init() {}
}
#endif
