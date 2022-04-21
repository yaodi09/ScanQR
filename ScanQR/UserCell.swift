//
//  UserCell.swift
//  ScanQR
//
//  Created by DD on 2022/3/17.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    
    var user: User?
    
    lazy var idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var sexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var checkBox: UIButton = {
       let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(idLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(sexLabel)
        contentView.addSubview(checkBox)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        checkBox.addGestureRecognizer(gesture)
    }
    
    @objc func tap() {
        guard var user = user else {
            return
        }
        let newUser = User(id: user.id, name: user.name, sex: user.sex, isCheckin: !user.isCheckin)
        setUserChecked(user, isChecked: newUser.isCheckin)
        checkBox.setImage(newUser.isCheckin ? UIImage(named: "tick") : nil, for: .normal)
        self.user = newUser
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        idLabel.frame = CGRect(x: 0, y: 5, width: 20, height: 20)
        nameLabel.frame = CGRect(x: 30, y: 5, width: 100, height: 20)
        sexLabel.frame = CGRect(x: 150, y: 5, width: 80, height: 20)
        checkBox.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: 5, width: 30, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithModel(_ user: User) {
        self.user = user
        idLabel.text = "\(user.id)"
        idLabel.sizeToFit()
        nameLabel.text = user.name
        nameLabel.sizeToFit()
        sexLabel.text = user.sex ? "Male" : "Female"
        sexLabel.sizeToFit()
        checkBox.setImage(user.isCheckin ? UIImage(named: "tick") : nil, for: .normal)
    }
}
