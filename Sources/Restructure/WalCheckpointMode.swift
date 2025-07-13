//
//  WalCheckpointMode.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2024-06-25.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SQLite3

/// The mode to use when commiting a WAL checkpoint
public enum WalCheckpointMode {
    /// A full checkpoint as defined by `SQLITE_CHECKPOINT_FULL`
    case full

    /// A passive checkpoint as defined by `SQLITE_CHECKPOINT_PASSIVE`
    case passive

    /// A full checkpoint that blocks readers until completion as defined by `SQLITE_CHECKPOINT_RESTART`
    case restart

    /// A full checkpoint like `restart`that also trucates the log as defined by `SQLITE_CHECKPOINT_TRUNCATE`
    case truncate

    var value: Int32 {
        switch self {
        case .passive:
            SQLITE_CHECKPOINT_PASSIVE
        case .full:
            SQLITE_CHECKPOINT_FULL
        case .restart:
            SQLITE_CHECKPOINT_RESTART
        case .truncate:
            SQLITE_CHECKPOINT_TRUNCATE
        }
    }
}
