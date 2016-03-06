//
//  LCArray.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 2/27/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud array type.

 It is a wrapper of Array type, used to store an array value.
 */
public class LCArray: LCType {
    public private(set) var value: NSArray?

    public required init() {
        super.init()
    }

    public convenience init(_ value: NSArray) {
        self.init()
        self.value = value
    }

    /**
     Append an element.

     - parameter element: The element to be appended.
     */
    public func append(element: AnyObject) {
        updateParent { (object, key) in
            object.addOperation(.Add, key, LCArray([element]))
        }
    }

    /**
     Append an element with unique option.

     This method will append an element based on the `unique` option.
     If `unique` is true, element will not be appended if it had already existed in array.
     Otherwise, the element will always be appended.

     - parameter element: The element to be appended.
     - parameter unique:  Unique or not.
     */
    public func append(element: AnyObject, unique: Bool) {
        updateParent { (object, key) in
            object.addOperation(.AddUnique, key, LCArray([element]))
        }
    }

    /**
     Concatenate objects.

     If unique is true, element in another array will not be concatenated if it had existed.

     - parameter another: Another array of objects to be concatenated.
     - parameter unique:  Unique or not.

     - returns: A new concatenated array.
     */
    func concatenateObjects(another: NSArray?, unique: Bool) -> NSArray? {
        guard let another = another else {
            return self.value
        }

        let result = NSMutableArray(array: self.value ?? [])

        if unique {
            another.forEach({ (element) in
                if !result.containsObject(element) {
                    result.addObject(element)
                }
            })
        } else {
            result.addObjectsFromArray(another as [AnyObject])
        }

        return result
    }

    /**
     Subtract objects.

     - parameter another: Another array of objects to be subtracted.

     - returns: A new subtracted array.
     */
    func subtractObjects(another: NSArray?) -> NSArray? {
        guard let minuend = self.value else {
            return nil
        }

        guard let subtrahend = another else {
            return minuend
        }

        let result = NSMutableArray(array: minuend)

        result.removeObjectsInArray(subtrahend as [AnyObject])

        return result
    }

    // MARK: Arithmetic

    override func add(another: LCType?) -> LCType? {
        return add(another, unique: false)
    }

    override func add(another: LCType?, unique: Bool) -> LCType? {
        guard let another = another as? LCArray else {
            /* TODO: throw an exception that one type cannot be appended to another type. */
            return nil
        }

        if let array = concatenateObjects(another.value, unique: unique) {
            return LCArray(array)
        } else {
            return LCArray()
        }
    }

    override func subtract(another: LCType?) -> LCType? {
        guard let another = another as? LCArray else {
            /* TODO: throw an exception that one type cannot be appended to another type. */
            return nil
        }

        if let array = subtractObjects(another.value) {
            return LCArray(array)
        } else {
            return LCArray()
        }
    }
}