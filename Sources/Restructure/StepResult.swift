//
//  StepResult.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 2018-11-04.
//  SPDX-License-Identifier: MIT
//

import Foundation

/// The results of the `step` function of a `Statement`.
public enum StepResult {
    /// The database busy, meaning the call to `step` may be tried again later.
    case busy

    /// The statement has finished executing. `step` should not be called again.
    case done

    /// An error occurred attempting to get the next result.
    case error(RestructureError)

    /// `step` was used in an invalid way, like after a statement was finalized.
    case misuse

    /// The next row was returned from the statement.
    case row(Row)
}
