import Foundation

#if canImport(PostgresClientKit)
import PostgresClientKit

/// This struct represents the user that is current logged in.
public struct User {
	public let id: Int
	public let name: String
	public let email: String
	public let address: String
	public let username: String
	public var password: String
	public let dateTimeCreated: PostgresTimestampWithTimeZone
	public let zone: String
	public let isAdmin: Bool
	public let profilePic: PostgresByteA
	public var forgotPasswordID: String?
	
	public init(id: Int,
				name: String,
				email: String,
				address: String,
				username: String,
				password: String,
				dateTimeCreated: PostgresTimestampWithTimeZone,
				zone: String,
				isAdmin: Bool,
				profilePic: PostgresByteA,
				forgotPasswordID: String?) {
		self.id = id
		self.name = name
		self.email = email
		self.address = address
		self.username = username
		self.password = password
		self.dateTimeCreated = dateTimeCreated
		self.zone = zone
		self.isAdmin = isAdmin
		self.profilePic = profilePic
		self.forgotPasswordID = forgotPasswordID
	}
}

/// This struct represents a single order by a user.
public struct Order: Hashable {
	
	public static func == (lhs: Order, rhs: Order) -> Bool {
		lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public let id: Int
	public let user: User
	public var productList: [Product]
	public let orderDateTime: PostgresTimestampWithTimeZone
	public let zone: String
	
	public init(id: Int,
				user: User,
				productList: [Product],
				orderDateTime: PostgresTimestampWithTimeZone,
				zone: String) {
		self.id = id
		self.user = user
		self.productList = productList
		self.orderDateTime = orderDateTime
		self.zone = zone
	}
}

/// This struct represents a product in an order.
public struct Product: Codable, Hashable {
	public let id: Int
	public let name: String
	public let price: Double
	public let image: Data?
}

/// This struct represents a page on the "Activities" , "Projects",  and "About Us" tabs.
public struct Page: Codable, Hashable {
	public let id: Int
	public let title: String
	public let linkTitle: String
	public let contents: String?
	public let image: Data?
	public let dropdown: Dropdown
	public let type: String
	
	public init(id: Int,
				title: String,
				linkTitle: String,
				contents: String?,
				image: Data?,
				dropdown: Dropdown,
				type: String) {
		self.id = id
		self.title = title
		self.linkTitle = linkTitle
		self.contents = contents
		self.image = image
		self.dropdown = dropdown
		self.type = type
	}
}

public struct Dropdown: Codable, Hashable {
	public let id: Int
	public let name: String
	
	public init(id: Int, name: String) {
		self.id = id
		self.name = name
	}
}

/// This struct represents a sketch uploaded by a user.
public struct Sketch: Hashable {
	public static func == (lhs: Sketch, rhs: Sketch) -> Bool {
		lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public let id: Int
	public let user: User
	public let name: String
	public let image: Data
	public let dateTimeSubmitted: PostgresTimestampWithTimeZone
	public let zone: String
	
	public init(id: Int,
				user: User,
				name: String,
				image: Data,
				dateTimeSubmitted: PostgresTimestampWithTimeZone,
				zone: String) {
		self.id = id
		self.user = user
		self.name = name
		self.image = image
		self.dateTimeSubmitted = dateTimeSubmitted
		self.zone = zone
	}
}
#endif
