//
//  ViewModel.swift
//  TestCombine
//
//  Created by Muzahidul on 22/8/21.
//

import UIKit
import Combine

protocol ViewModelDelegate: AnyObject {
	func dataLoadingDidFinished()
}

final class ViewModel {
	private var apiClient = NetworkManager.shared
	private(set) var list = [String]()
	private var cancelables: Set<AnyCancellable> = Set<AnyCancellable>()
	weak var delegate: ViewModelDelegate?
	
	func getData() {
		let url = "https://pastebin.com/raw/A0CgArX3"
		
		apiClient.getData(from: url, type: MyData.self)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
			self?.delegate?.dataLoadingDidFinished()
			print(completion)
		} receiveValue: { [weak self]  data in
			self?.list = data.data.categories.map { $0["name"] ?? "" }
		}
		.store(in: &cancelables)
		
	}
	
}


