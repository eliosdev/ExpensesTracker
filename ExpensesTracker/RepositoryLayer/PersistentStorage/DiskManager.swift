//
//  DiskManager.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

typealias Handler<T> = (Result<T, Error>) -> Void

protocol Diskable {
    func fetchValue(for key: String, handler: @escaping Handler<Data>)
    func save(value: Data, for key: String, handler: @escaping Handler<Data>)
}

final class DiskManager {
    fileprivate let pathToFolder: URL
    fileprivate let fileManager: FileManager
    fileprivate let queue: DispatchQueue
    
    init(path: URL, queue: DispatchQueue = .init(label: "DiskManager.Queue"), fileManager: FileManager = FileManager.default) {
        self.pathToFolder = path
        self.fileManager = fileManager
        self.queue = queue
    }
}

extension DiskManager: Diskable {
    
    func fetchValue(for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            handler(Result { try self.fetchValue(for: key) })
        }
    }
    
    func save(value: Data, for key: String, handler: @escaping Handler<Data>) {
        queue.async {
            do {
                try self.save(value: value, for: key)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
    
    fileprivate func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    fileprivate func save(value: Data, for key: String) throws {
        let url = pathToFolder.appendingPathComponent(key)
        do {
            try self.createFolders(in: url)
            try value.write(to: url, options: .atomic)
        } catch {
            
        }
    }
    
    fileprivate func fetchValue(for key: String) throws -> Data {
        let url = pathToFolder.appendingPathComponent(key)
        guard let data = fileManager.contents(atPath: url.path) else { throw CoreError(title: "No file found", message: "No file found in url path") }
        return data
    }
}
