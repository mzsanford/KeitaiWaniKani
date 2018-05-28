//
//  SubjectAmalgamationsTable+BulkDatabaseCodable.swift
//  WaniKaniKit
//
//  Copyright © 2018 Chris Laverty. All rights reserved.
//

import FMDB

private let table = Tables.subjectAmalgamations

struct SubjectAmalgamation: BulkDatabaseCodable {
    static func read(from database: FMDatabase, id: Int) throws -> [Int] {
        let query = """
        SELECT \(table.amalgamationSubjectID)
        FROM \(table)
        WHERE \(table.subjectID) = ?
        ORDER BY \(table.index)
        """
        
        let resultSet = try database.executeQuery(query, values: [id])
        defer { resultSet.close() }
        
        var items = [Int]()
        while resultSet.next() {
            items.append(resultSet.long(forColumn: table.amalgamationSubjectID.name))
        }
        
        return items
    }
    
    static func read(from database: FMDatabase, ids: [Int]) throws -> [Int: [Int]] {
        var items = [Int: [Int]]()
        items.reserveCapacity(ids.count)
        
        for id in ids {
            items[id] = try read(from: database, id: id)
        }
        
        return items
    }
    
    static func write(items: [Int], to database: FMDatabase, id: Int) throws {
        try database.executeUpdate("DELETE FROM \(table) WHERE \(table.subjectID) = ?", values: [id])
        
        let query = """
        INSERT OR REPLACE INTO \(table)
        (\(table.subjectID.name), \(table.index.name), \(table.amalgamationSubjectID.name))
        VALUES (?, ?, ?)
        """
        
        for (index, item) in items.enumerated() {
            let values: [Any] = [
                id, index, item
            ]
            try database.executeUpdate(query, values: values)
        }
    }
}
