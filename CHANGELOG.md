#  Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
-   `AutoVacuum` dictates the automatic vacuuming mode.
-   `JournalMode` dictates the journaling mode used by the database.
-   `SecureDelete` dictates the data deletion mode.
-   `incrementalVacuum` can be used with `AutoVacuum.incremental` to affect vacuuming.
-   `vacuum` causes a full database vacuum to occur.

### Changed
-   Restructure is now a SwiftPM project. All legacy build tools have been removed.
-   The `Restructure` constructor takes a defaulted parameter for a journal mode.

## 1.0.0 - 2019-06-20
### Added
-   Created the primary `Restructure` object for maintaining SQLite databases.
-   Created the `Statement` object for working with prepared SQLite statements.
-   Created the `Row` object for working with resultant rows from a `Statement`.
-   Created the `RowDecoder` and `StatementEncoder` for using Swift's `Decodable` protocols. 
