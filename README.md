#  Restructure

[![Build Status](https://travis-ci.org/stack/Restructure.svg?branch=develop)](https://travis-ci.org/stack/Restructure)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)

Restructure is a wrapper library for [SQLite](https://sqlite.org/index.html) for
iOS, macOS, and tvOS. It's fairly opinionated, as in, it does exactly what I
want it to do. Feel free to use it, fork it, or do what you would like with it.

## Installation

Adding this repository as a git submodule is the only way to use the library.

1.  Add this repository as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules).
2.  Check out the tag or branch you wish to use.
3.  Add the `Restructure.xcodeproj` project to your existing project.
4.  Add the appropriate framework to your Linked Frameworks and Libraries.

In the future, when the dust has settled from WWDC '19, support for Swift
Package Manager will be added.

## Usage

### Opening A Database

A database can be opened with either a file path or run completely in memory.

```swift
// File backed database
let restructure = try Restructure(path: "/path/to/data.db")

// Memory backed database
let restructure = try Restructure()

// Closing the database
restructure.close()
```

### Standard SQLite

Restructure supports the standard mechanisms of SQLite.

```swift
// Execute a statement
try restructure.execute(query: "CREATE TABLE foo (name TEXT, age INTEGER)")

// Insert data
let insertStatement = try restructure.prepare(query: "INSERT INTO foo (name, age) VALUES (:name, :age)")
insertStatement.bind(value: "Bar", for: "name")
insertStatement.bind(value: 42, for: "age")
try insertStatement.perform()

// Update data
let updateStatement = try restructure.prepare(query: "UPDATE foo SET age = :age WHERE name = :name")
updateStatement.bind(value: 43, for: "age")
updateStatement.bind(value: "Bar", for: "name")
try updateStatement.perform()

// Reuse a statement
updateStatement.reset()
updateStatement.bind(value: 44, for: "age")
updateStatement.bind(value: "Bar", for: "name")
try updateStatement.perform()

// Fetch Data
let selectStatement = try restructure.prepare(query: "SELECT name, age FROM foo")

if case let row(row) = selectStatement.step() {
    let name: String = row["name"]
    let age: Int = row["age"]
}
```

Note: Statements finalize themselves.

Data conversions are handled by the framework. When binding data, it is bound
using the closest datatype available to SQLite. When extracting values from a
row, the data is converted to the explicit type of the variable. Variable types
must be defined to extract the data. SQLite is then used to perform any [data
type conversion](https://www.sqlite.org/datatype3.html).

Restructure currently supports the following data types:

*   Bool
*   Int
*   Int8
*   Int16
*   Int32
*   Int64
*   UInt
*   UInt8
*   UInt16
*   UInt32
*   Float
*   Double
*   Data
*   Date
*   String
*   Array


### Statements Are Sequences

To help with fetching data, all statements are `Sequence` types and can be
iterated over. The iterator returns a row for every successful `step` that would
have been performed.

```swift
let statement = try restructure.prepare(query: "SELECT name, age FROM foo")

for row in statement {
    let name: String = row["name"]
    let age: Int = row["age"]
}
```

### Complex Data Types

Restructure supports storing arrays of data. This is done by encoding the data
and storing it like a normal value. Encoding can either be done with binary
plists or JSON.


```swift
// Make all arrays in Restructure binary plists
restructure.arrayStrategy = .bplist

// Make a specific statement use JSON
statement.arrayStrategy = .json

// Get and fetch an array of Integers
statement.bind(value:[1,2,3], for: "values")
let values: [Int] = row["values"]
```

Dates can be stored in the formats supported by SQLite. Typically this means:

*   Integers for UNIX epoch times in seconds.
*   Real for Julian days since January 1, 4713 BC.
*   Text for ISO 8601 dates.

```swift
// Make all dates in Restructure julian
restructure.arrayStrategy = .real

// Make a specific statement use epoch
statement.arrayStrategy = .integer

// Get and fetch a date
statement.bind(value: Date(), for: "date")
let date: Date = row["date"]
```

### Statements Are `Encodable`

You can prepare a statement with the `StatementEncoder` and `Encodable` data:

```swift
struct Foo: Encodable {
    let a: Int64?
    let b: String
    let c: Double
    let d: Int
    let e: Data
}

let foo = Foo(a: nil, b: "1", c: 2.0, d: 3, e: Data(bytes: [0x4, 0x5, 0x6], count: 3))

let statement = try! restructure.prepare(query: "INSERT INTO foo (b, c, d, e) VALUES (:b, :c, :d, :e)")
let encoder = StatementEncoder()
try encoder.encode(foo, to: statement)
```

### Rows are `Decodable`

You can extract data from a row with a `RowDecoder` and `Decodable` data:

```swift
struct Foo: Encodable {
    let a: Int64?
    let b: String
    let c: Double
    let d: Int
    let e: Data
}

let statement = try! restructure.prepare(query: "SELECT a, b, c, d, e FROM foo LIMIT 1")
let decoder = RowDecoder()
        
for row in statement }
    let foo = try! decoder.decode(Foo.self, from: row)
}

```

## Caveats

Restructure makes no guarantees about thread safety. It is as safe as the
underlying SQLite library.

The `Codable` support only supports single objects. Hierarchies of data are not
supported.

`UInt64` is not supported as a data type, as SQLite only supports signed 64-bit
integers.

