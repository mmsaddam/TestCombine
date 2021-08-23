//
//  DataModel.swift
//  TestCombine
//
//  Created by Muzahidul on 22/8/21.
//

import Foundation

struct MyData: Decodable {
	struct Data: Decodable {
		var categories: [[String : String]]
	}
	var data: Data
}
