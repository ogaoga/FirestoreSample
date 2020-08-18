//
//  DetailViewController.swift
//  FirestoreSample
//
//  Created by Tsutomu Ogasawara on 2020/08/18.
//  Copyright © 2020 ogaoga. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var detailDescriptionLabel: UILabel!

  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
      if let label = detailDescriptionLabel {
        label.text = detail.date
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    configureView()
  }
  
  var detailItem: Task? {
    didSet {
      // Update the view.
      configureView()
    }
  }
}
