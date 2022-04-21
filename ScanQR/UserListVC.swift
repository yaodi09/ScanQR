//
//  UserListVC.swift
//  ScanQR
//
//  Created by DD on 2022/3/17.
//

import UIKit

class UserListVC: UIViewController {
    var users: [User] = []
    lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.register(UserCell.self, forCellReuseIdentifier: "usercell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = getUsers()
        view.addSubview(table)
        table.reloadData()
        
        let item=UIBarButtonItem(title: "reset", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tap))
        self.navigationItem.rightBarButtonItem=item
    }
    
    @objc func tap() {
        resetAll()
        table.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.backgroundColor = UIColor.white
        table.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
}

extension UserListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell")
        if let cell = cell as? UserCell{
            cell.setupWithModel(users[indexPath.row])
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
}
