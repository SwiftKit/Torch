//
//  PropertyRegistry.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreData

public class PropertyRegistry {
    // TODO Add rest of types
    private static let typesArray: [(Any.Type, NSAttributeType)] = [
        (Int.self, .Integer64AttributeType),
        (String.self, .StringAttributeType),
        (Float.self, .FloatAttributeType),
        (Double.self, .DoubleAttributeType),
        (Bool.self, .BooleanAttributeType)
        ]
    
    private static let types: [ObjectIdentifier: NSAttributeType] = typesArray.reduce([:]) { acc, item in
        var mutableAccumulator = acc
        mutableAccumulator[ObjectIdentifier(item.0)] = item.1
        return mutableAccumulator
    }
    
    private let entityRegistry: EntityRegistry
    
    private(set) var registeredProperties: [NSPropertyDescription] = []
    
    init(entityRegistry: EntityRegistry) {
        self.entityRegistry = entityRegistry
    }
    
    public func description<PARENT: TorchEntity, T: NSObjectConvertible>(of property: Property<PARENT, T>) {
        registerAttribute(property.torchName, type: T.self, optional: false)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyArrayType where T.Element: NSObjectConvertible>(of property: Property<PARENT, T>) {
        registerAttribute(property.torchName, type: T.self, optional: false, forceTransformable: true)
    }
    
    public func description<PARENT: TorchEntity, T: PropertySetType where T.Element: NSObjectConvertible>(of property: Property<PARENT, T>) {
        registerAttribute(property.torchName, type: T.self, optional: false, forceTransformable: true)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: NSObjectConvertible>(of property: Property<PARENT, T>) {
        registerAttribute(property.torchName, type: T.Wrapped.self, optional: true)
    }
    
    public func description<PARENT: TorchEntity, T: TorchEntity>(of property: Property<PARENT, T>) {
        registerRelationship(property.torchName, type: T.self, optional: false, minCount: 1, maxCount: 1)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyArrayType where T.Element: TorchEntity>(of property: Property<PARENT, T>) {
        registerRelationship(property.torchName, type: T.Element.self, optional: false, minCount: 0, maxCount: 0)
    }
    
    public func description<PARENT: TorchEntity, T: PropertyOptionalType where T.Wrapped: TorchEntity>(of property: Property<PARENT, T>) {
        registerRelationship(property.torchName, type: T.Wrapped.self, optional: true, minCount: 1, maxCount: 1)
    }
    
    private func registerAttribute<T>(name: String, type: T.Type, optional: Bool, forceTransformable: Bool = false) {
        let attributeType: NSAttributeType
        if forceTransformable {
            attributeType = .TransformableAttributeType
        } else {
            attributeType = PropertyRegistry.types[ObjectIdentifier(T)] ?? .TransformableAttributeType
        }
        
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = attributeType
        attribute.optional = optional
        registeredProperties.append(attribute)
    }
    
    private func registerRelationship<T: TorchEntity>(name: String, type: T.Type, optional: Bool, minCount: Int, maxCount: Int) {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.destinationEntity = entityRegistry.description(of: type, withState: .Partial)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.optional = optional
        relationship.minCount = minCount
        relationship.maxCount = maxCount
        relationship.ordered = true
        registeredProperties.append(relationship)
    }
}
