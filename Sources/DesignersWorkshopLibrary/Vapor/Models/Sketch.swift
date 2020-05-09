//
//  Sketch.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent
import Vapor

public final class Sketch: Model, Content {
	public static let schema = "sketches"
	
	@ID(key: .id)
	public var id: UUID?
	
	@Parent(key: "user_id")
	public var user: User
	
	@Field(key: "name")
	public var name: String
	
	@Timestamp(key: "created_at", on: .create)
	public var uploadedOn: Date?
	
	@Field(key: "image")
	public var image: Data
	
	public init() {}
	
	public init(id: UUID? = nil, userID: UUID, name: String, image: Data) {
		self.id = id
		self.$user.id = userID
		self.name = name
		self.image = image
	}
}
#endif
