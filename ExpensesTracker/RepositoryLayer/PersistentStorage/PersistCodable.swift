//
//  PersistCodable.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol Persistable {
    func fetch<T: Decodable>(for key: String) throws -> T
    func save<T: Encodable>(_ value: T, for key: String) throws
}

final class PersistCodable: Persistable {
    
    fileprivate let diskManager: Diskable
    fileprivate var decoder: JSONDecoder = .init()
    fileprivate var enconder: JSONEncoder = .init()
    
    init(disk: Diskable, decoder: JSONDecoder, enconder: JSONEncoder) {
        self.diskManager = disk
        self.decoder = decoder
        self.enconder = enconder
    }
    
    func fetch<T: Decodable>(for key: String) throws -> T {
        var codableData: Data?
        var diskError: Error?
        diskManager.fetchValue(for: key) { (result) in
            switch result {
            case .failure(let error):
                diskError = error
            case .success(let data):
                codableData = data
            }
        }
        guard let data = codableData else { throw CoreError(title: "Fetch Error", message: "Could not get data from disk with error \(diskError?.localizedDescription ?? "")") }
        return try decoder.decode(T.self, from: data)
    }
    
    func save<T:Encodable>(_ value: T, for key: String) throws {
        let data = try enconder.encode(value)
        var diskError: Error?
        diskManager.save(value: data, for: key) { (result) in
            switch result {
            case .failure(let error):
                diskError = error
            case .success(_):
                break
            }
        }
        if diskError != nil { throw CoreError(title: "Saving Error", message: "Could not save data in disk with error \(diskError?.localizedDescription ?? "")") }
    }
}
