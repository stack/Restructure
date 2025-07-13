# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- DocC support.

### Changed

- Implemented SwiftLint for the main source code.
- Supported version numbers have been updated to modern versions.
- Package specification has been updated to 6.1.

## 2.1.3 2024-06-20

### Fixed

- Columns are now properly set to nil when a statement is reused.

## 2.1.2 2023-09-07

### Fixed

- Closing a file-backed database no longer deletes the underlying file.
- In WAL journal mode, closing the database causes a WAL checkpoint.

## 2.1.1 2023-09-07

### Fixed

- Storing a `Statement` no longer causes a crash when cleaning up.
- The `UPPER` function properly handles memory management of strings.

## 2.1.0 2020-08-16

### Added

- `sqliteVersion` fetches the underlying SQLite version string.
- Dynamic member lookup is enabled for `Row`, allowing for direct access to values via property notation.

### Removed

- `JournalMode.off` has been removed because of defensive configs.

## 2.0.0 - 2019-09-12

### Added

- `AutoVacuum` dictates the automatic vacuuming mode.
- `JournalMode` dictates the journaling mode used by the database.
- `SecureDelete` dictates the data deletion mode.
- `incrementalVacuum` can be used with `AutoVacuum.incremental` to affect vacuuming.
- `vacuum` causes a full database vacuum to occur.

### Changed

- Restructure is now a SwiftPM project. All legacy build tools have been removed.
- The `Restructure` constructor takes a defaulted parameter for a journal mode.

## 1.0.0 - 2019-06-20

### Added

- Created the primary `Restructure` object for maintaining SQLite databases.
- Created the `Statement` object for working with prepared SQLite statements.
- Created the `Row` object for working with resultant rows from a `Statement`.
- Created the `RowDecoder` and `StatementEncoder` for using Swift's `Decodable` protocols. 
