//
//  CreateProducts.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent

public struct CreateProduct: Migration {
	public func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("products")
			.id()
			.field("name", .string, .required)
			.field("price", .double, .required)
			.create()
	}
	
	public func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("products").delete()
	}
}
#endif
