//
//  Connection.swift
//  
//
//  Created by Jeff Lebrun on 5/2/20.
//

import Foundation
import PostgresClientKit

/// Set the parameters for connecting to a database. In this case, the parameters are stored in environment variables.
public func createConnection(forConfig config: inout PostgresClientKit.ConnectionConfiguration) {
	var databaseURL: URLComponents? = nil
	
	let envs = Misc.main.getEnvs()
	
	if envs != nil {
		
		databaseURL = URLComponents(string: envs!.dbURL)
		
		var path1 = ""
		
		for path in databaseURL!.path {
			if path != "/" {
				path1 += String(path)
			}
		}
		
		config.host = (databaseURL?.host)!
		config.database = path1
		config.user = (databaseURL?.user)!
		config.credential = .md5Password(password: (databaseURL?.password)!)
		
	} else {
		
		databaseURL = URLComponents(string: ProcessInfo.processInfo.environment["DATABASE_URL"] ?? "")
		
		if let location = ProcessInfo.processInfo.environment["LOCATION"] {
			
			if location == "D" {
				databaseURL = URLComponents(string: ProcessInfo.processInfo.environment["DB_URL"] ?? "")
			} else {
				databaseURL = URLComponents(string: ProcessInfo.processInfo.environment["DATABASE_URL"] ?? "")
			}
			
		}
		
		var path1 = ""
		
		for path in databaseURL!.path {
			if path != "/" {
				path1 += String(path)
			}
		}
		
		config.host = (databaseURL?.host)!
		config.database = path1
		config.user = (databaseURL?.user)!
		config.credential = .md5Password(password: (databaseURL?.password)!)
		
	}
	
	
}

public let connect = createConnection(forConfig:)
