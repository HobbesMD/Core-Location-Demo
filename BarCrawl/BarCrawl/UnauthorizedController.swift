//
//  UnauthorizedController.swift
//  BarCrawl
//
//  Created by Michael B. Dykema on 11/29/21.
//

import Foundation
import UIKit

class UnauthorizedController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    @IBAction func permissionsEnabled(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

