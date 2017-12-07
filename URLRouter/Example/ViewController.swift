//
//  ViewController.swift
//  URLRouter
//
//  Created by YZF on 29/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    var dataSource: [(String, Selector)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [("defaultMatchTestA", #selector(defaultMatchTestA)),
                      ("defaultMatchTestB", #selector(defaultMatchTestB)),
                      ("defaultMatchTestC", #selector(defaultMatchTestC)),
                      ("regexMatcheTest", #selector(regexMatcheTest)),
                      ("contextTest", #selector(contextTest)),
                      ("pushViewControllerTestA", #selector(pushViewControllerTestA)),
                      ("pushViewControllerTestB", #selector(pushViewControllerTestB)),
                      ("objectTest", #selector(objectTest)),
                      ("customMatcherTest", #selector(customMatcherTest))]
        
        URLRouter.shared.register("URLRouter://<path>") { [weak self] (url, parameters, context) in
            self?.log("URLRouter://<path>", url, parameters, context)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func defaultMatchTestA() {
        let registerURL = "URLRouter://user/<name>"
        let openURL     = "URLRouter://user/Tommy?age=22"
        URLRouter.shared.register(registerURL) { [weak self] (url, parameters, context) in
            self?.log(registerURL, url, parameters, context)
        }
        URLRouter.shared.open(openURL, context: nil)
    }
    
    @objc func defaultMatchTestB() {
        let registerURL = "URLRouter://user/<name>/<path>"
        let openURL     = "URLRouter://user/Tommy/lalala/22"
        URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }
        URLRouter.shared.open(openURL, context: nil)
    }
    
    @objc func defaultMatchTestC() {
        let registerURL = "URLRouter://user/<name>?<age,sex>"
        let openURL     = "URLRouter://user/Tommy?age=22&sex=boy"
        URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }
        URLRouter.shared.open(openURL, context: nil)
    }
    
    @objc func regexMatcheTest() {
        let registerURL = "URLRouter://user/\\w+\\?age=\\d+&sex=\\w+"
        let openURL     = "URLRouter://user/Tommy?age=22&sex=boy"
        URLRouter.shared.register(registerURL) { [weak self] in self?.log(registerURL, $0, $1, $2) }
        
        // ⚠️⚠️⚠️⚠️⚠️⚠️
        URLRouter.shared.urlMatcher = .regex
        URLRouter.shared.open(openURL, context: nil)
        
        URLRouter.shared.urlMatcher = .`default`
    }
    
    @objc func contextTest() {
        let openURL     = "URLRouter://user/Tommy"
        URLRouter.shared.open(openURL, context: Person(name: "Xixi"))
    }
    
    @objc func pushViewControllerTestA() {
        let registerURL = "URLRouter://pushViewController"
        let openURL     = "URLRouter://pushViewController?backgroudColor=red"
        URLRouter.shared.register(registerURL) { [weak self] in
            self?.log(registerURL, $0, $1, $2)
            let vc = UIViewController()
            if $1["backgroudColor"] == "red" {
                vc.view.backgroundColor = .red
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        URLRouter.shared.open(openURL, context: nil)
    }
    
    @objc func pushViewControllerTestB() {
        let registerURL = "URLRouter://viewControler"
        let openURL     = "URLRouter://viewControler?backgroudColor=blue"
        URLRouter.shared.registerObject(registerURL) { [weak self] in
            self?.log(registerURL, $0, $1, $2)
            let vc = UIViewController()
            if $1["backgroudColor"] == "blue" {
                vc.view.backgroundColor = .blue
            }
            return vc
        }
        
        if let viewController: UIViewController = URLRouter.shared.object(for: openURL) {
            textView.text = textView.text! + "\nviewController: \(viewController)"
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func objectTest() {
        let registerURL = "URLRouter://object/user/<name>"
        let openURL     = "URLRouter://object/user/Tommy"
        URLRouter.shared.registerObject(registerURL) { [weak self] in
            self?.log(registerURL, $0, $1, $2)
            return Person(name: $1["name"]!)
        }
        
        if let user: Person = URLRouter.shared.object(for: openURL) {
            textView.text = textView.text! + "\nobject: \(user)"
        }
    }
    
    @objc func customMatcherTest() {
        let registerURL = "A://"
        let openURL     = "A://object/user/Tommy"
        URLRouter.shared.register(registerURL) { [weak self] in
            self?.log(registerURL, $0, $1, $2)
        }
        
        // ⚠️⚠️⚠️⚠️⚠️⚠️
        URLRouter.shared.urlMatcher = .custom(CustomURLMatcher())
        URLRouter.shared.open(openURL)
        
        URLRouter.shared.urlMatcher = .`default`
    }
    
    func log(_ registeredURL: String,_ url: String, _ parameters: [String: String], _ context: Any?) {
        let log = """
        \(registeredURL)
        \(url)
        
        parameters: \(parameters)
        context: \(context ?? "nil")
        """
        
        textView.text = log
        print(log)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = dataSource[indexPath.row].0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSelector(onMainThread: dataSource[indexPath.row].1, with: nil, waitUntilDone: true)
    }
}

