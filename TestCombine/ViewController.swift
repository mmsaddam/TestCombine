//
//  ViewController.swift
//  TestCombine
//
//  Created by Muzahidul on 22/8/21.
//

import UIKit
import Combine

final class ViewController: UIViewController, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!
	private var viewModel = ViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		viewModel.delegate = self
		
		viewModel.getData()
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		cell.textLabel?.text = viewModel.list[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.list.count
	}
	
}

extension ViewController: ViewModelDelegate {
	func dataLoadingDidFinished() {
		tableView.reloadData()
	}
}
