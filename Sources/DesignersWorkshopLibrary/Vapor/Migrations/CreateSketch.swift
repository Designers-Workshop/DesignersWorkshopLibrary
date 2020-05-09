//
//  CreateSketch.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent

public struct CreateSketch: Migration {
	public func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("sketches")
			.id()
			.field("user_id", .uuid, .required, .references("users", "id"))
			.field("created_at", .datetime, .required)
			.field("name", .string, .required)
			.field("image", .data, .required)
			.create()
	}
	
	public func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("sketches").delete()
	}
}
#endif
