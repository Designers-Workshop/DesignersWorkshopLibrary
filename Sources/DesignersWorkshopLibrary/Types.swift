import Foundation
import PostgresClientKit

// MARK: - Global Structs.
/// This struct represents the user that is current logged in.
public struct User {
	let id: Int
	let name: String
	let email: String
	let address: String
	let username: String
	var password: String
	let dateTimeCreated: PostgresTimestampWithTimeZone
	let zone: String
	let isAdmin: Bool
	let profilePic: PostgresByteA
	var forgotPasswordID: String?
}

/// This struct represents a single order by the user.
public struct Order {
	let id: Int
	let user: User
	var productList: [Product]
	let orderDateTime: PostgresTimestampWithTimeZone
	let zone: String
}

/// This struct represents a product in an order.
public struct Product: Codable {
	let id: Int
	let name: String
	let price: Double
	let image: Data?
}

/// This struct represents a page on the "Activities" , "Projects",  and "About Us" tabs.
public struct Page: Codable, Hashable {
	let id: Int
	let title: String
	let linkTitle: String
	let contents: String?
	let image: Data?
	let dropdown: Dropdown
	let type: String
}

public struct Dropdown: Codable, Hashable {
	let id: Int
	let name: String
}

/// This struct represents a sketch uploaded by a user.
public struct Sketch {
	let id: Int
	let user: User
	let name: String
	let image: Data
	let dateTimeSubmitted: PostgresTimestampWithTimeZone
	let zone: String
}
