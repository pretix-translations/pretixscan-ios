//
//  DataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Stores large amounts of relational data
///
/// - Note: All `store*` methods will completely overwrite all existing data, without any merging. This is because we expect data to
///         always come from the server, which has the canonical truth.
///         For performance reasons, implementations might do a comparison first and not update unchanged items.
public protocol DataStore: class {
    // MARK: Metadata
    func storeLastSynced(_ data: [String: String])
    func retrieveLastSynced() -> [String: String]

    // MARK: - Storing
    func store<T: Model>(_ resources: [T], for event: Event)

    /// Store a list of `ItemCategory` instances.
    func store(_ itemCategories: [ItemCategory], for event: Event)

    /// Store a list of `Item` instances.
    func store(_ items: [Item], for event: Event)

    /// Store a list of `Order` instances.
    func store(_ orders: [Order], for event: Event)
}
