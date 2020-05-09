//
//  User.swift
//
//
//  Created by Jeff Lebrun on 5/8/20.
//

#if canImport(Vapor) && canImport(Fluent)
import Fluent
import Vapor

public final class User: Model, Content {
    public static let schema = "users"
    
    @ID(key: .id)
   public  var id: UUID?

    @Field(key: "name")
    public var name: String
	
	@Field(key: "email")
	public var email: String
	
	@Field(key: "address")
	public var address: String
	
	@Field(key: "username")
	public var username: String
	
	@Field(key: "password")
	public var password: String
	
	@Timestamp(key: "created_at", on: .create)
	public var creationDate: Date?
	
	@Field(key: "is_admin")
	public var isAdmin: Bool
	
	@Field(key: "profile_pic")
	public var profilePic: Data
	
	@Field(key: "zone")
	public var zone: String
	
	@Field(key: "forgot_password_id")
	public var forgotPasswordID: String?
	
	@Children(for: \.$user)
	public var orders: [Order]

	@Children(for: \.$user)
	public var sketches: [Sketch]
	
	public init() {}

	public init(id: UUID? = nil,
		 name: String,
		 email: String,
		 address: String,
		 username: String,
		 password: String,
		 creationDate: Date?,
		 isAdmin: Bool,
		 profilePic: Data,
		 zone: String,
	forgotPasswordID: String? = nil) {
        self.id = id
		self.name = name
		self.email = email
		self.address = address
		self.username = username
		self.password = password
		self.creationDate = creationDate
		self.isAdmin = isAdmin
		self.profilePic = profilePic
		self.zone = zone
		self.forgotPasswordID = forgotPasswordID
    }
}
#endif
