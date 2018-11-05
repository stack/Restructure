//
//  Bindable.swift
//  Restructure
//
//  Created by Stephen H. Gerstacker on 11/3/18.
//  Copyright © 2018 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

/// An empty protocol to define which data type can be bound to
public protocol Bindable { }

extension Int: Bindable { }
extension Int8: Bindable { }
extension Int16: Bindable { }
extension Int32: Bindable { }
extension Int64: Bindable { }

extension UInt: Bindable { }
extension UInt8: Bindable { }
extension UInt16: Bindable { }
extension UInt32: Bindable { }

extension Float: Bindable { }
extension Double: Bindable { }

extension Data: Bindable { }
extension Date: Bindable { }
extension String: Bindable { }
