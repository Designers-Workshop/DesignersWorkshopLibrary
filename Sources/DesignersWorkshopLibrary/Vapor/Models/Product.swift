//
//  Product.swift
//  
//
//  Created by Jeff Lebrun on 5/8/20.
//

import Foundation

#if canImport(Vapor) && canImport(Fluent)
import Fluent
import Vapor

public final class Product: Model, Content {
	public static let schema = "products"
	
	@ID(key: .id)
	public var id: UUID?
	
	@Field(key: "name")
	public var name: String
	
	@Field(key: "price")
	public var price: Double
	
	public init() {}
	
	public init(id: UUID? = nil, name: String, price: Double) {
		self.id = id
		self.name = name
		self.price = price
	}
}
#endif
