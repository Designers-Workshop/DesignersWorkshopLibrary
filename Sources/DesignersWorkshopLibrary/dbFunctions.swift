//
//  UDBF.swift
//  
//
//  Created by Jeff Lebrun on 5/2/20.
//

import Foundation
import PostgresClientKit

/// This class contains functions for accessing user information in a database.
public struct UDBF {
	public static var main = UDBF()
	
	public var config = PostgresClientKit.ConnectionConfiguration()
	
	/// Converts a `Date` object to a `PostgresTimestamp` object.
	public func currentDate() -> PostgresTimestampWithTimeZone {
		let i = Date()
		
		let td = PostgresTimestampWithTimeZone(date: i)
		
		return td
	}

	/// Add a user to the database, then returns a instance of the user class, with the placeholders filled in.
	/// - Parameters:
	///   - name: The name of the user.
	///   - email: The user's email.
	///   - address: The user's address.
	///   - username: The user's username.
	///   - password: The user's password.
	///   - dateTimeCreated: The time and date this account was created.
	public mutating func signUp(name: String, email: String, address: String, username: String, password: String, profilePic: Data, dateTimeCreated: PostgresTimestampWithTimeZone, zone: String) -> User? {
		connect(&config)
		
		var user: User!
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			var statement = try connection.prepareStatement(text: "INSERT INTO users(name, email, address, username, password, date_time_created, is_admin, profile_pic, zone) VALUES($1, $2, $3, $4, $5, $6, FALSE, $7, $8);")
			
			try statement.execute(parameterValues: [name, email, address, username, password, dateTimeCreated, PostgresByteA(data: profilePic), zone])
			
			statement = try connection.prepareStatement(text: "SELECT * FROM users WHERE username = $1 AND password = $2;")
			
			let cursor = try statement.execute(parameterValues: [username, password])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let name1 = try columns[1].string()
				let email1 = try columns[2].string()
				let address1 = try columns[3].string()
				let username1 = try columns[4].string()
				let password1 = try columns[5].string()
				let dateTimeCreated1 = try columns[6].timestampWithTimeZone()
				let isAdmin = try columns[8].bool()
				let pPic = try columns[9].byteA()
				let zone = try columns[10].string()
				
				
				user = User(id: id, name: name1, email: email1, address: address1, username: username1, password: password1, dateTimeCreated: Misc.main.convertTimezone(timezone: zone, date: dateTimeCreated1.date).postgresTimestampWithTimeZone, zone: zone, isAdmin: isAdmin, profilePic: pPic, forgotPasswordID: nil)
			}
			
			cursor.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
		return user
		
	}
	
	/// Retrieves a user from the database, then returns a instance of the user class, with the user's onformation filled in.
	/// - Parameters:
	///   - username: The user's username is used to find a user in the database.
	///   - password: The user's password is used in conjunction with the username to find a user.
	public mutating func logIn(username: String, password: String) -> User? {
		connect(&config)
		
		var u: User!
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM users WHERE username = $1 AND password = $2;")
			defer {
				statement.close()
			}
			
			let cursor = try statement.execute(parameterValues: [username, password])
			defer {
				cursor.close()
			}
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let name = try columns[1].string()
				let email = try columns[2].string()
				let address = try columns[3].string()
				let username = try columns[4].string()
				let password = try columns[5].string()
				let dateTimeCreated = try columns[6].timestampWithTimeZone()
				let isAdmin = try columns[8].bool()
				let pPic = try columns[9].byteA()
				let zone = try columns[10].string()
				let fpID = try columns[11].optionalString()
				
				let user = User(id: id, name: name, email: email, address: address, username: username, password: password, dateTimeCreated: Misc.main.convertTimezone(timezone: zone, date: dateTimeCreated.date).postgresTimestampWithTimeZone, zone: zone, isAdmin: isAdmin, profilePic: pPic, forgotPasswordID: fpID)
				
				u = user
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
		return u
		
	}
	
	/// Updates a user's informatrion in a database.
	/// - Parameters:
	///   - user: The updated information, stored as a User struct.
	///   - oldID: the ID user to search for the old information to replace.
	public mutating func changeUserInfo(user: User, oldID: Int) -> User {
		connect(&config)
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "UPDATE users SET name = $1, email = $2, address = $3, username = $4, password = $5, profile_pic = $6, fp_id = $7 WHERE id = $8;")
			
			try statement.execute(parameterValues: [user.name, user.email, user.address, user.username, user.password, user.profilePic, user.forgotPasswordID, oldID])
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
		return user
	}
	
	public mutating func updatePassword(password: String, email: String) {
		var user = getUserByEmail(email: email)
		
		if user != nil {
			
			user!.password = password
			
			let _ = changeUserInfo(user: user!, oldID: user!.id)
		}
	}
	
	/// Deletes a user from the database.
	/// - Parameter user: The user who wishes for their account to be deleted.
	public mutating func deleteUser(user: User) {
		connect(&config)
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			var statement = try connection.prepareStatement(text: "DELETE FROM order_list WHERE order_id IN (SELECT id FROM ordera WHERE user_id = $1);")
			
			try statement.execute(parameterValues: [user.id])
			
			statement = try connection.prepareStatement(text: "DELETE FROM users WHERE username = $1 AND password = $2;")
			
			try statement.execute(parameterValues: [user.username, user.password])
			
			statement.close()
			connection.close()
			
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
	}
	
	/// Retrieves a user from a database using their ID.
	/// - Parameter id: The ID with which to retrieve the user.
	public mutating func getUserByID(id: Int) -> User? {
		connect(&config)
		
		var u: User?
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM users WHERE id = $1;")
			defer {
				statement.close()
			}
			
			let cursor = try statement.execute(parameterValues: [id])
			defer {
				cursor.close()
			}
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let name = try columns[1].string()
				let email = try columns[2].string()
				let address = try columns[3].string()
				let username = try columns[4].string()
				let password = try columns[5].string()
				let dateTimeCreated = try columns[6].timestampWithTimeZone()
				let isAdmin = try columns[8].bool()
				let pPic = try columns[9].byteA()
				let zone = try columns[10].string()
				let fpID = try columns[11].optionalString()
				
				let user = User(id: id, name: name, email: email, address: address, username: username, password: password, dateTimeCreated: Misc.main.convertTimezone(timezone: zone, date: dateTimeCreated.date).postgresTimestampWithTimeZone, zone: zone, isAdmin: isAdmin, profilePic: pPic, forgotPasswordID: fpID)
				
				u = user
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return u
	}
	
	public mutating func getUserByEmail(email: String) -> User? {
		connect(&config)
		
		var u: User?
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM users WHERE email = $1;")
			defer {
				statement.close()
			}
			
			let cursor = try statement.execute(parameterValues: [email])
			defer {
				cursor.close()
			}
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let name = try columns[1].string()
				let email = try columns[2].string()
				let address = try columns[3].string()
				let username = try columns[4].string()
				let password = try columns[5].string()
				let dateTimeCreated = try columns[6].timestampWithTimeZone()
				let isAdmin = try columns[8].bool()
				let pPic = try columns[9].byteA()
				let zone = try columns[10].string()
				let fpID = try columns[11].optionalString()
				
				let user = User(id: id, name: name, email: email, address: address, username: username, password: password, dateTimeCreated: Misc.main.convertTimezone(timezone: zone, date: dateTimeCreated.date).postgresTimestampWithTimeZone, zone: zone, isAdmin: isAdmin, profilePic: pPic, forgotPasswordID: fpID)
				
				u = user
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return u
	}
	
	public mutating func getUserByKey(key: String) -> User? {
		connect(&config)
		
		var u: User?
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM users WHERE fp_id = $1;")
			defer {
				statement.close()
			}
			
			let cursor = try statement.execute(parameterValues: [key])
			defer {
				cursor.close()
			}
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				
				u = getUserByID(id: id)
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return u
	}
	
	/// Get all of the current user's orders from the databse.
	/// - Parameter user: The user that is currently logged in.
	public mutating func getAllOrders(user: User?) -> [Order] {
		connect(&config)
		
		var orderList: [Order] = []
		
		if user == nil {
			
			do {
				
				let connection = try PostgresClientKit.Connection(configuration: config)
				
				let statement = try connection.prepareStatement(text: "SELECT id, user_id FROM ordera;")
				
				let cursor = try statement.execute()
				
				for row in cursor {
					let columns = try row.get().columns
					
					let id = try columns[0].int()
					
					let user_id = try columns[1].int()
					
					let user1 = getUserByID(id: user_id)
					
					let order = getOrder(id: id, user: user1!)
					
					orderList.append(order!)
				}
				
				statement.close()
				connection.close()
			}
			catch let error {
				print("AGAIN??!! Grr, looks like ANOTHER error:\n")
				
				print(error)
			}
			
			return orderList
			
		}
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM ordera WHERE user_id = $1;")
			
			let cursor = try statement.execute(parameterValues: [user!.id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				
				let order = getOrder(id: id, user: user!)
				
				orderList.append(order!)
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return orderList
	}
	
	/// Gets an order from a databse.
	/// - Parameters:
	///   - id: The id of the user who's retriving the order.
	///   - user: The user who's retriving the order
	/// - Returns: The obtained order, if one was found. Otherwise, nil.
	public mutating func getOrder(id: Int, user: User) -> Order? {
		connect(&config)
		
		var order: Order?
		var pList: [Product] = []
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM ordera WHERE id = $1 AND user_id = $2 ORDER BY order_date_time;")
			
			let cursor = try statement.execute(parameterValues: [id, user.id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let orderDateTime = try columns[2].timestampWithTimeZone()
				
				let zone = try columns[4].string()
				
				order = Order(id: id, user: user, productList: [], orderDateTime: Misc.main.convertTimezone(timezone: zone, date: orderDateTime.date).postgresTimestampWithTimeZone, zone: zone)
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM order_list WHERE order_id = $1;")
			
			let cursor = try statement.execute(parameterValues: [id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let pID = try columns[2].int()
				
				pList.append(MDBF.main.getProduct(id: pID))
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		if order != nil {
			order?.productList = pList
		}
		
		return order
	}
	
	
	/// Uploads a file to a database.
	/// - Parameters:
	///   - user: The user who's uploading the sketch.
	///   - file: The file the user is uploading.
	public mutating func uploadFile(user: User, file: Data, timestamp: PostgresTimestampWithTimeZone, zone: String, name: String) {
		
		connect(&config)
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "INSERT INTO sketches(user_id, sketch, date_time_submitted, zone, name) VALUES($1, $2, $3, $4, $5);")
			
			try statement.execute(parameterValues: [user.id, PostgresByteA(data: file), timestamp, zone, name])
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
	}
	
	public mutating func getAllSketches(user: User?) -> [Sketch] {
		connect(&config)
		
		var sketches: [Sketch] = []
		
		if user == nil {
			do {
				
				let connection = try PostgresClientKit.Connection(configuration: config)
				
				let statement = try connection.prepareStatement(text: "SELECT id FROM sketches;")
				
				let cursor = try statement.execute()
				
				for row in cursor {
					sketches.append(getSketch(user: nil, id: try row.get().columns[0].int()))
				}
				
				statement.close()
				connection.close()
			}
			catch let error {
				print("AGAIN??!! Grr, looks like ANOTHER error:\n")
				
				print(error)
			}
			
			return sketches
		}
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM sketches WHERE user_id = $1;")
			
			let cursor = try statement.execute(parameterValues: [user!.id])
			
			for row in cursor {
				sketches.append(getSketch(user: user!, id: try row.get().columns[0].int()))
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return sketches
	}
	
	/// Retrieves a sketch from a database.
	/// - Parameters:
	///   - user: The user who is requesting the sketch.
	///   - id: the ID of the requested sketch.
	public mutating func getSketch(user: User?, id: Int) -> Sketch {
		var sketch: Sketch!
		
		connect(&config)
		
		if user == nil {
			do {
				
				let connection = try PostgresClientKit.Connection(configuration: config)
				
				let statement = try connection.prepareStatement(text: "SELECT * FROM sketches WHERE id = $1 ORDER BY date_time_submitted;")
				
				let cursor = try statement.execute(parameterValues: [id])
				
				for row in cursor {
					let columns = try row.get().columns
					let user_id = try columns[1].int()
					let byteA = try columns[2].byteA()
					let dateTimeSubmitted = try columns[3].timestampWithTimeZone()
					let zone = try columns[5].string()
					let name = try columns[6].string()
					
					let aUser = getUserByID(id: user_id)
					
					sketch = Sketch(id: id, user: aUser!, name: name, image: byteA.data, dateTimeSubmitted: Misc.main.convertTimezone(timezone: zone, date: dateTimeSubmitted.date).postgresTimestampWithTimeZone, zone: zone)
				}
				
				statement.close()
				connection.close()
			}
			catch let error {
				print("AGAIN??!! Grr, looks like ANOTHER error:\n")
				
				print(error)
			}
			
			return sketch
		}
		
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * FROM sketches WHERE id = $1 AND user_id = $2;")
			
			let cursor = try statement.execute(parameterValues: [id, user!.id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let byteA = try columns[2].byteA()
				let dateTimeSubmitted = try columns[3].timestampWithTimeZone()
				let zone = try columns[5].string()
				let name = try columns[6].string()
				
				sketch = Sketch(id: id, user: user!, name: name, image: byteA.data, dateTimeSubmitted: dateTimeSubmitted, zone: zone)
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		return sketch
	}
	
	/// "Buys" product(s) from a database.
	/// - Parameters:
	///   - productList: The list of products to be bought
	///   - user: The user who is buying the products.
	public mutating func buyProducts(productList: [Product], user: User, zone: String) -> Order? {
		connect(&config)
		
		var order: Order!
		var orderID: Int!
		let timestamp = PostgresTimestampWithTimeZone(date: Date())
		
		// Preform order.
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "INSERT INTO ordera(user_id, order_date_time, zone) VALUES($1, $2, $3);")
			
			try statement.execute(parameterValues: [user.id, timestamp, zone])
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		// Retrieve the order.
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM ordera WHERE order_date_time = $1;")
			
			let cursor = try statement.execute(parameterValues: [timestamp])
			
			for row in cursor {
				let columns = try row.get().columns
				
				orderID = try columns[0].int()
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		// Finish the order.
		do {
			
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "INSERT INTO order_list(order_id, product_id) VALUES($1, $2);")
			
			for p in productList {
				try statement.execute(parameterValues: [orderID, p.id])
			}
			
			statement.close()
			connection.close()
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:\n")
			
			print(error)
		}
		
		order = getOrder(id: orderID, user: user)
		
		if order != nil {
			return order
		} else {
			return nil
		}
	}
	
	/// Delets a sketch from a database.
	/// - Parameters:
	///   - user:The user who wishes to delete the sketch.
	///   - sketchID: The ID of the sketch.
	public mutating func deleteSketch(user: User, sketchID: Int) {
		connect(&config)
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statment = try connection.prepareStatement(text: "DELETE FROM sketches WHERE id = $1 AND user_id = $2;")
			
			try statment.execute(parameterValues: [sketchID, user.id])
		} catch let error {
			print(error)
		}
	}
}

/// Miscellaneous function preformed on the database.
public struct MDBF {
	public static var main = MDBF()
	
	public var config = PostgresClientKit.ConnectionConfiguration()
	
	/// Converts a `Date` object to a `PostgresTimestamp` object.
	public func currentDate() -> PostgresTimestamp {
		let i = Date()
		
		let td = PostgresTimestamp(date: i, in: .autoupdatingCurrent)
		
		return td
	}
	
	/// Gets a dropdown from the database and returns an `Dropdown` object.
	/// - Parameter dropdownID: The ID that will be used to search for the dropdown.
	public mutating func getDropdown(dropdownID: Int) -> Dropdown? {
		connect(&config)
		
		var dropdown: Dropdown?
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id, title FROM dropdowns WHERE id = $1;")
			
			let cursor = try statement.execute(parameterValues: [dropdownID])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let title = try columns[1].string()
				
				dropdown = Dropdown(id: id, name: title)
			}
		} catch let error {
			print(error)
		}
		
		return dropdown
	}
	
	public mutating func getAllDropdowns() -> [Dropdown]? {
		connect(&config)
		
		var dropdowns: [Dropdown]? = nil
		
		var array: [Dropdown] = []
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM dropdowns;")
			
			let cursor = try statement.execute()
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				
				let dropdown = getDropdown(dropdownID: id)!
				
				array.append(dropdown)
				
			}
		} catch let error {
			print(error)
		}
		
		if !array.isEmpty {
			dropdowns = array
		}
		
		return dropdowns
	}
	
	public mutating func createDropdown(name: String) -> Dropdown {
		connect(&config)
		
		var dropdown: Dropdown = Dropdown(id: 0, name: "")
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "INSERT INTO dropdowns(title) VALUES($1);")
			
			try statement.execute(parameterValues: [name])
			
		} catch let error {
			print(error)
		}
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM dropdowns WHERE title = $1;")
			
			let cursor = try statement.execute(parameterValues: [name])
			
			for row in cursor {
				
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				
				dropdown = getDropdown(dropdownID: id)!
				
			}
			
		} catch let error {
			print(error)
		}
		
		return dropdown
	}
	
	/// Queries the database for all pages, then appends them the pages to an array, then returns that array.
	public mutating func getAllPages() -> [Page] {
		connect(&config)
		
		var pageArray: [Page] = []
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id, page_title, link_title, page_contents, dropdown, type, image FROM html;")
			
			let cursor = try statement.execute()
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[2].string()
				let pageContents = try columns[3].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				
				pageArray.append(p)
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
		return pageArray
	}
	
	public mutating func createPage(title: String, dropdown: Dropdown, contents: String, image: Data? = nil) {
		connect(&config)
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "INSERT INTO html(page_title, link_title, page_contents, dropdown, type, image) VALUES($1, $2, $3, $4, 'text', $5);")
			
			if image != nil {
				try statement.execute(parameterValues: [title, dropdown.name.lowercased() + "/" + title.camelized, contents, dropdown.id, PostgresByteA(data: image!)])
			} else {
				try statement.execute(parameterValues: [title, dropdown.name.lowercased() + "/" + title.camelized, contents, dropdown.id, nil])
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
	}
	
	/// Gets a product from the database using the specified ID.
	/// - Parameter id: The product ID.
	public mutating func getProduct(id: Int) -> Product {
		connect(&config)
		
		var product: Product!
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id, name, price::numeric, image FROM products WHERE id = $1;")
			
			let cursor = try statement.execute(parameterValues: [id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let name = try columns[1].string()
				let price = try columns[2].double()
				let data = try columns[3].optionalByteA()
				
				product = Product(id: id, name: name, price: price, image: data?.data)
			}
		} catch let error {
			print(error)
		}
		
		return product
	}
	
	/// Gets a list of products from the database and returns them.
	public mutating func getProducts() -> [Product] {
		connect(&config)
		var plist: [Product] = []
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM products;")
			
			let cursor = try statement.execute()
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				
				let product = getProduct(id: id)
				
				plist.append(product)
			}
		} catch let error {
			print(error)
		}
		
		return plist
	}
	
	/// Gets a `Page` from a database.
	/// - Parameter title: The title which will be used to search for the page.
	public mutating func getPageByTitle(title: String) -> Page? {
		connect(&config)
		
		var page: Page? = nil
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id, page_title, link_title, page_contents, dropdown, type, image FROM html WHERE link_title = $1;")
			
			let cursor = try statement.execute(parameterValues: [title])
			
			for row in cursor {
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[2].string()
				let pageContents = try columns[3].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				
				page = p
			}
		}
		catch let error {
			print("AGAIN??!! Grr, looks like ANOTHER error:")
			
			print(error)
		}
		
		return page
	}
	
	/// Gets a `Page` from the database.
	/// - Parameter id: The ID to use to search for the page.
	/// - Returns: The `Page` that was found, otherwise, `nil`.
	public mutating func getPageByID(id: Int) -> Page? {
		connect(&config)
		
		var page: Page? = nil
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT link_title FROM html WHERE id = $1;")
			
			let cursor = try statement.execute(parameterValues: [id])
			
			for row in cursor {
				let columns = try row.get().columns
				
				page = getPageByTitle(title: try columns[0].string())
			}
		}
		catch let error {
			print(error)
		}
		
		return page
	}
	
	public mutating func modifyPage(withID id: Int, valuesToReplace values: (title: String, contents: String)) {
		connect(&config)
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "UPDATE html SET page_title = $1, page_contents = $2 WHERE id = $3;")
			
			try statement.execute(parameterValues: [values.title, values.contents, id])
			
		}
		catch let error {
			print(error)
		}
		
	}
	
	/// Searches a database for a list of pages based on a title it is provided.
	/// - Parameter query: The page title to search for.
	public mutating func searchForPages(query: String) -> [Page]? {
		connect(&config)
		var pageArray: [Page]? = nil
		
		var array: [Page] = []
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT * from html WHERE page_title LIKE $1;")
			
			let cursorNormal = try statement.execute(parameterValues: ["%" + query + "%"])
			
			
			let connection2 = try PostgresClientKit.Connection(configuration: config)
			
			let statement2 = try connection2.prepareStatement(text: "SELECT * from html WHERE page_title LIKE $1;")
			
			let cursorLowercase = try statement2.execute(parameterValues: ["%" + query.lowercased() + "%"])
			
			
			let connection3 = try PostgresClientKit.Connection(configuration: config)
			
			let statement3 = try connection3.prepareStatement(text: "SELECT * from html WHERE page_title LIKE $1;")
			
			let cursorUppercase = try statement3.execute(parameterValues: ["%" + query.uppercased() + "%"])
			
			
			let connection4 = try PostgresClientKit.Connection(configuration: config)
			
			let statement4 = try connection4.prepareStatement(text: "SELECT * from html WHERE page_title LIKE $1;")
			
			let cursorCapitalized = try statement4.execute(parameterValues: ["%" + query.capitalized + "%"])
			
			for row in cursorNormal {
				
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[3].string()
				let pageContents = try columns[2].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				array.append(p)
				
			}
			
			for row in cursorLowercase {
				
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[3].string()
				let pageContents = try columns[2].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				array.append(p)
				
			}
			
			for row in cursorUppercase {
				
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[3].string()
				let pageContents = try columns[2].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				array.append(p)
				
			}
			
			for row in cursorCapitalized {
				
				let columns = try row.get().columns
				
				let id = try columns[0].int()
				let pageTitle = try columns[1].string()
				let linkTitle = try columns[3].string()
				let pageContents = try columns[2].string()
				let dropdownID = try columns[4].int()
				let dropdown = getDropdown(dropdownID: dropdownID)!
				let type = try columns[5].string()
				let data = try columns[6].optionalByteA()
				
				let p = Page(id: id, title: pageTitle, linkTitle: linkTitle, contents: pageContents, image: data?.data, dropdown: dropdown, type: type)
				array.append(p)
				
			}
			
			connection.close()
			cursorCapitalized.close()
			cursorUppercase.close()
			cursorLowercase.close()
			cursorNormal.close()
			
		} catch let error {
			print(error)
		}
		
		if array.isEmpty != true {
			pageArray = array
			
			pageArray!.removeDuplicates()
		}
		
		return pageArray
	}
}
