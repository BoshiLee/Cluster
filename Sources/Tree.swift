//
//  Tree.swift
//  Cluster
//
//  Created by Lasha Efremidze on 4/13/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import MapKit

let rootNode = Node(mapRect: MKMapRectWorld)

open class Tree {
    
    // - Insertion
    
    @discardableResult
    func insert(_ annotation: MKAnnotation, to node: Node = rootNode) -> Bool {
        guard node.mapRect.contains(annotation.coordinate) else { return false }
        
        if node.canAppendAnnotation() {
            node.annotations.append(annotation)
            return true
        }
        
        let siblings = node.siblings ?? node.makeSiblings()
        
        for node in siblings.all {
            if insert(annotation, to: node) {
                return true
            }
        }
        return false
    }
    
    // - Enumeration
    
    func enumerate(rootNode node: Node = rootNode, in mapRect: MKMapRect = rootNode.mapRect, callback: (MKAnnotation) -> Void) {
        guard node.mapRect.intersects(mapRect) else { return }
        
        for annotation in node.annotations where mapRect.contains(annotation.coordinate) {
            callback(annotation)
        }
        
        guard let siblings = node.siblings else { return }
        
        for node in siblings.all {
            enumerate(rootNode: node, in: mapRect, callback: callback)
        }
    }
    
}

open class Node {
    
    let mapRect: MKMapRect
    
    init(mapRect: MKMapRect) {
        self.mapRect = mapRect
    }
    
    // - Annotations
    
    private let max = 8
    
    var annotations = [MKAnnotation]()
    
    func canAppendAnnotation() -> Bool {
        return annotations.count < max
    }
    
    // - Siblings
    
    struct Siblings {
        let northWest: Node
        let northEast: Node
        let southWest: Node
        let southEast: Node
        var all: [Node] {
            return [northWest, northEast, southWest, southEast]
        }
        init(mapRect: MKMapRect) {
            self.northWest = Node(mapRect: MKMapRect(minX: mapRect.minX, minY: mapRect.minY, maxX: mapRect.midX, maxY: mapRect.midY))
            self.northEast = Node(mapRect: MKMapRect(minX: mapRect.midX, minY: mapRect.minY, maxX: mapRect.maxX, maxY: mapRect.midY))
            self.southWest = Node(mapRect: MKMapRect(minX: mapRect.minX, minY: mapRect.midY, maxX: mapRect.midX, maxY: mapRect.maxY))
            self.southEast = Node(mapRect: MKMapRect(minX: mapRect.midX, minY: mapRect.midY, maxX: mapRect.maxX, maxY: mapRect.maxY))
        }
    }
    
    var siblings: Siblings?
    
    func makeSiblings() -> Siblings {
        let siblings = Siblings(mapRect: mapRect)
        self.siblings = siblings
        return siblings
    }
    
}
