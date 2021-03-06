//
//  PropertySetType.swift
//  Torch
//
//  Created by Filip Dolnik on 22.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol PropertySetType: PropertyType {
    
    associatedtype Element: Hashable
    
    var values: Set<Element> { get }
}

extension Set: PropertySetType {
    
    public var values: Set<Element> {
        return self
    }
}