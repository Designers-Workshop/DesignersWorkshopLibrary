import Foundation
import PostgresClientKit

// MARK: - Global Structs.
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
}

/// This struct represents a single order by the user.
public struct Order {
	public let id: Int
	public let user: User
	public var productList: [Product]
	public let orderDateTime: PostgresTimestampWithTimeZone
	public let zone: String
}

/// This struct represents a product in an order.
public struct Product: Codable {
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
}

public struct Dropdown: Codable, Hashable {
	public let id: Int
	public let name: String
}

/// This struct represents a sketch uploaded by a user.
public struct Sketch {
	public let id: Int
	public let user: User
	public let name: String
	public let image: Data
	public let dateTimeSubmitted: PostgresTimestampWithTimeZone
	public let zone: String
}
