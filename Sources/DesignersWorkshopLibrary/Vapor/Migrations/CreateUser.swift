//
//  CreateUser.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent

public struct CreateUser: Migration {
	public func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("users")
			.id()
			.field("name", .string, .required)
			.field("email", .string, .required)
			.field("address", .string, .required)
			.field("username", .string, .required)
			.field("password", .string, .required)
			.field("created_at", .datetime, .required)
			.field("is_admin", .bool, .required)
			.field("profile_pic", .data, .required)
			.field("zone", .string, .required)
			.field("forgot_password_id", .string)
			.create()
	}
	
	public func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("users").delete()
	}
}
#endif
