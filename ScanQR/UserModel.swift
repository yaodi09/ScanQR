//
//  UserModel.swift
//  ScanQR
//
//  Created by DD on 2022/3/17.
//

import Foundation

struct User: Codable {
    var id: Int
    var name: String
    var sex: Bool
    var isCheckin: Bool
}

func getUsers() -> [User] {
    guard let data = UserDefaults.standard.data(forKey: "user") else {
        return []
    }
    do {
        let decoder = JSONDecoder()
        let users = try decoder.decode([User].self, from: data)
        return users
    }  catch {
        return []
    }
}

func saveUser(_ user: User) {
    var users = getUsers()
    users.append(user)
    let encoder = JSONEncoder()
    do {
        let str = try encoder.encode(users)
        UserDefaults.standard.set(str, forKey: "user")
    } catch {
        
    }
}

func setUserChecked(_ user: User, isChecked: Bool) {
    let users = getUsers()
    var newArr: [User] = []
    for u in users {
        if user.id == u.id {
            newArr.append(User(id: u.id, name: u.name, sex: u.sex, isCheckin: isChecked))
        } else {
            newArr.append(user)
        }
    }
    let encoder = JSONEncoder()
    do {
        let str = try encoder.encode(users)
        UserDefaults.standard.set(str, forKey: "user")
    } catch {
        
    }
}

func resetAll() {
    let users = getUsers()
    var newArr: [User] = []
    for u in users {
        newArr.append(User(id: u.id, name: u.name, sex: u.sex, isCheckin: false))
    }
    let encoder = JSONEncoder()
    do {
        let str = try encoder.encode(users)
        UserDefaults.standard.set(str, forKey: "user")
    } catch {
        
    }
}
