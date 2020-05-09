//
//  CreateOrder.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation
#if canImport(Vapor) && canImport(Fluent)
import Fluent

public struct CreateOrder: Migration {
	public func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("orders")
			.id()
			.field("user_id", .uuid, .required, .references("users", "id"))
			.field("order_date_time", .datetime, .required)
			.field("zone", .string, .required)
			.create()
	}
	
	public func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("orders").delete()
	}
	
	public init() {}
}
#endif
