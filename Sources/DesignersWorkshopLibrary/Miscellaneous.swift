//
//  Miscellaneous.swift
//  
//
//  Created by Jeff Lebrun on 5/2/20.
//

#if canImport(Vapor)
import Vapor
#elseif canImport(CryptoSwift) || canImport(PostgresClientKit)
import PostgresClientKit
import CryptoSwift
#else
#error("Add either CryptoSwift or Vapor to your Package.swift.")
#endif

import Foundation
import SwiftyJSON

fileprivate let badChars = CharacterSet.alphanumerics.inverted

public extension String {
	var uppercasingFirst: String {
		return prefix(1).uppercased() + dropFirst()
	}
	
	var lowercasingFirst: String {
		return prefix(1).lowercased() + dropFirst()
	}
	
	var camelized: String {
		guard !isEmpty else {
			return ""
		}
		
		let parts = self.components(separatedBy: badChars)
		
		let first = String(describing: parts.first!).lowercasingFirst
		let rest = parts.dropFirst().map({String($0).uppercasingFirst})
		
		return ([first] + rest).joined(separator: "")
	}
}

public class Misc {
	public static let main = Misc()
	
	private init() {}
	
	public var config = PostgresClientKit.ConnectionConfiguration()
	
	public func getEnvs(fromFile file: URL = URL(fileURLWithPath: "../envs.json")) -> (dbURL: String, emailPassword: String, salt: String, location: String, site: String, email: String)? {
		
		var result: (dbURL: String, emailPassword: String, salt: String, location: String, site: String, email: String)? = nil
		
		do {
			
			var data = Data()
			
			#if os(iOS)
				data = try Data(contentsOf: Bundle.main.url(forResource: "envs", withExtension: "json")!)
			#else
				data = try Data(contentsOf: file)
			#endif
			
			let json = try JSON(data: data)
			
			result = (json["DB_URL"].string!, json["EMAIL_PASSWORD"].string!, json["SALT"].string!, json["LOCATION"].string!, json["SITE"].string!, json["EMAIL"].string!)
		}
		catch let error {
			print(error)
		}
		
		return result
	}
	
	/// Creates a hashed version of a provided password using the provided username and salt.
	/// - Parameters:
	///   - username: The username to append to the hash.
	///   - password: The password to hash.
	///   - salt: The salt to append to the hash.
	public func hashPassword(username: String, password: String, salt: String = ProcessInfo.processInfo.environment["SALT"] ?? "") -> String {
		var final: String = ""
		
		var gsalt = salt
		
		if salt.isEmpty {
			gsalt = getEnvs()!.salt
		}
		
		let saltFormatted = gsalt.data(using: .utf8)!
		
		let plainText = password.data(using: .utf8)!
		
		let usernameFormatted = username.data(using: .utf8)!
		
		// Vapor is used on the Designers Workshop's web server...
		#if canImport(Vapor)
		let a = SHA256.hash(data: saltFormatted).hexEncodedString()
		let b = SHA256.hash(data: usernameFormatted).hexEncodedString()
		let c = SHA256.hash(data: plainText).hexEncodedString()
		
		let password = a + b + c
		
		final = Insecure.MD5.hash(data: password.data(using: .utf8)!).hexEncodedString()
		
		return final
		
		// ...while CryptoSwift is used on Designers Workshop's iOS app.
		#elseif canImport(CryptoSwift)
		let a = saltFormatted.sha256().toHexString()
		let b = usernameFormatted.sha256().toHexString()
		let c = plainText.sha256().toHexString()
		
		let password = a + b + c
		
		final = password.md5()
		
		return final
		#endif
		
	}
	
	/*
	#if canImport(Vapor)
	/// Converts `User` to `FormUser`.
	/// - Parameter user: The user to be converted.
	public func toCodableUser(user: User?) -> FormUser? {
		
		guard user != nil else {
			return nil
		}
		
		return FormUser(id: user!.id, name: user!.name, email: user!.email, address: user!.address, username: user!.username, password: user!.password, dateTimeCreated: user!.dateTimeCreated.date, zone: user!.zone, isAdmin: user!.isAdmin, profilePic: user!.profilePic.data, forgotPasswordID: user!.forgotPasswordID)
	}
	
	public func extractLinkFromIframe(page: Page) -> String {
		var l: String!
		
		do {
			let html: String = page.contents!
			let doc: Document = try SwiftSoup.parse(html)
			let link: Element = try doc.select("iframe").first()!
			
			l = try link.attr("src")
			
		} catch Exception.Error(let type, let message) {
			print(message, type)
		} catch {
			print("error")
		}
		
		return l
	}
	
	public func extractText(page: Page) -> String {
		var text: String!
		
		do {
			let html: String = page.contents!
			let doc: Document = try SwiftSoup.parse(html)
			let t: Element = try doc.select("p").first()!
			
			text = try t.text()
			
		} catch Exception.Error(let type, let message) {
			print(message, type)
		} catch {
			print("error")
		}
		
		return text
	}
	
	/// Sends an email using the specified configuration.
	/// - Parameters:
	///   - to: The recipient of the email.
	///   - from: The sender of the email.
	///   - subject: The subject of the email.
	///   - message: The content of the email. HTML or plain text.
	///   - attachments: Files that will be attached to the email. Provide the full filename.
	public func sendEmail(usingRequest request: Request,
				   to: (name: String, address: String),
				   from: (name: String, address: String),
				   subject: String,
				   message: String,
				   attachments: [(name: String, contentType: String, data: Data)] = []) -> Error? {
		
		var error: Error? = nil
		
		var email = Email(from: EmailAddress(address: from.address, name: from.name),
						  to: [EmailAddress(address: to.address, name: to.name)],
						  subject: subject,
						  body: message, isBodyHtml: true)
		
		for a in attachments {
			email.addAttachment(Attachment(name: a.name, contentType: a.contentType, data: a.data))
		}
		
		request.send(email).map { result in
			switch result {
				case .success:
					print("Email has been sent")
				case .failure(let err):
					error = err
					print(error)
			}
		}
		
		return error
	}
	
	/// Convert an array of product names into an array of type `Product`.
	/// - Parameter productList: the array of product names.
	public func toProduct(productList: [String]) -> [Product] {
		
		var products: [Product] = []
		
		connect(&config)
		
		do {
			let connection = try PostgresClientKit.Connection(configuration: config)
			
			let statement = try connection.prepareStatement(text: "SELECT id FROM products WHERE name = $1;")
			
			for product in productList {
				
				let cursor = try statement.execute(parameterValues: [product])
				
				for row in cursor {
					let columns = try row.get().columns
					
					let id = try columns[0].int()
					
					let p = MDBF.main.getProduct(id: id)
					
					products.append(p)
				}
			}
		} catch let error {
			print(error)
		}
		
		return products
	}
	
	public func toCodableOrder(order: Order) -> CodableOrder {
		return CodableOrder(id: order.id, user: toCodableUser(user: order.user)!, productList: order.productList, orderDateTime: order.orderDateTime.date, zone: order.zone)
	}
	
	public func toCodableSketch(sketch: Sketch?) -> CodableSketch? {
		guard sketch != nil else {
			return nil
		}
		
		return CodableSketch(id: sketch!.id, user: toCodableUser(user: sketch!.user)!, name: sketch!.name, image: sketch!.image, dateTimeSubmitted: sketch!.dateTimeSubmitted.date, zone: sketch!.zone)
	}
	
	public func generateCSV(saveToFileAtPath path: String, append: Bool, headers: [String], orders: [Order]) {
		let stream = OutputStream(toFileAtPath: path, append: append)!
		
		let csv = try! CSVWriter(stream: stream)
		
		// Headers.
		try! csv.write(row: headers)
		csv.beginNewRow()
		
		for order in orders {
			
			var list = ""
			
			for product in order.productList {
				list += "\(product.name + String(format: ", $%.2f", product.price)),\r"
			}
			
			list.removeLast()
			
			try! csv.write(row: [order.user.name, order.user.email, order.user.address, list, fomatter(date: order.orderDateTime.date, format: "MM/dd/YY, hh:mm a")])
			
			csv.beginNewRow()
			
		}
		
		csv.stream.close()
	}
	
	public func eraseCSV(pathToCSV: String) {
		do {
			try "".write(to: URL(fileURLWithPath: pathToCSV), atomically: true, encoding: .utf8)
		}
		catch let error {
			print(error)
		}
	}
	
	public func c(request: Request) -> Response {
		var res: Response? = nil
		
		let orders = try! Folder.current.subfolder(at: "Resources/orders").file(named: "orders.csv")
		
		do {
			Misc.main.generateCSV(saveToFileAtPath: orders.path, append: false, headers: ["Name", "Email", "Address", "Products", "Date and Time"], orders: UDBF.main.getAllOrders(user: nil))
			
			let data = try! orders.readAsString().data(using: .utf8)!
			
			res = Response(status: .ok, version: HTTPVersion(major: 1, minor: 1), headers: HTTPHeaders([("Content-Type", "text/csv"), ("Content-Disposition", "attachment; filename=orders.csv")]), body: .init(data: data))
			
			Misc.main.eraseCSV(pathToCSV: orders.path)
			
		}
		catch let error {
			print(error)
		}
		
		return res!
	}
	
	public func fromCodableUser(codableUser: FormUser) -> User {
		
		var profilePic: Data = Data()
		
		do {
			if codableUser.profilePic == nil {
				profilePic = try Folder.current.subfolder(at: "Public/profilePics").file(named: "generic.PNG").read()
			}
		}
		catch let error {
			print(error)
		}
		
		return User(id: codableUser.id, name: codableUser.name, email: codableUser.email, address: codableUser.address, username: codableUser.username, password: codableUser.password, dateTimeCreated: codableUser.dateTimeCreated.postgresTimestampWithTimeZone, zone: codableUser.zone, isAdmin: codableUser.isAdmin, profilePic: PostgresByteA(data: codableUser.profilePic ?? profilePic), forgotPasswordID: codableUser.forgotPasswordID)
	}
	#endif
	*/
	
	public func convertTimezone(timezone: String, date: Date) -> Date {
		let fmt = DateFormatter()
		
		fmt.timeZone = TimeZone(abbreviation: timezone)
		
		fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		return fmt.date(from: fmt.string(from: date)) ?? Date()
	}
	
	public func fomatter(date: Date, format: String) -> String {
		let fmt = DateFormatter()
		
		fmt.dateFormat = format
		
		return fmt.string(from: date)
	}
	

}
