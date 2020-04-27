//
//  PersistCodable.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

typealias Completion<T:Codable> = (Result<T, Error>) -> Void

enum Accounts: String {
    case cash
    case credit
    case bank
}

protocol Persistable {
    func fetch<T: Decodable>(for key: Accounts, completionHandler: @escaping (Error?, T?) -> Void)
    func save<T: Encodable>(value: T, for key: Accounts, completionHandler: @escaping (Error?) -> Void)
}

final class PersistCodable: Persistable {
    
    fileprivate let diskManager: Diskable
    fileprivate var decoder: JSONDecoder
    fileprivate var enconder: JSONEncoder
    
    init(disk: Diskable, decoder: JSONDecoder, enconder: JSONEncoder) {
        self.diskManager = disk
        self.decoder = decoder
        self.enconder = enconder
    }
    
    func fetch<T:Decodable>(for key: Accounts,completionHandler: @escaping (Error?, T?) -> Void) {
        diskManager.fetchValue(for: key.rawValue) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(error, nil)
            case .success(let data):
                do {
                    let object:T =  try self.decoder.decode(T.self, from:data)
                    completionHandler(nil, object)
                } catch let error  {
                    completionHandler(CoreError(title: "Error decoding", message: "Could not decode object with error: \(error.localizedDescription)", errorType: .decoding), nil)
                }
            }
        }
    }
    
    func save<T:Encodable>(value: T, for key: Accounts, completionHandler: @escaping (Error?) -> Void)  {
        do {
            let data = try enconder.encode(value)
            diskManager.save(value: data, for: key.rawValue) { (error: Error?) in
                completionHandler(error)
            }
        } catch let error {
            completionHandler(CoreError(title: "Error Encoding", message: "Could not encode object with error: \(error.localizedDescription)", errorType: .encoding))
        }
    }
}
