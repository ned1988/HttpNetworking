//
//  ViewController.swift
//  HTTPNetworking
//
//  Created by ned1988@gmail.com on 03/25/2018.
//  Copyright (c) 2018 ned1988@gmail.com. All rights reserved.
//

import UIKit
import HTTPNetworking

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.github.com/users/ned1988")!
        let request = URLRequest(url: url)
        HTTPNetwork.instance.load(request) { (data, response, error) in
            print("Data: \(String(describing: data)), response: \(String(describing: response)), \(String(describing: error))")
        }
        
        HTTPNetwork.instance.loadJSON(request) { (data, response, error) in
            print("Data: \(String(describing: data)), response: \(String(describing: response)), \(String(describing: error))")
        }
    }
}

