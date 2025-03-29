//
//  FlowLogging.swift
//  Flowie
//
//  Created by Daniel Fernandez Yopla on 29.03.2025.
//

public protocol FlowLogging {
    func log(_ message: String)
}

public nonisolated(unsafe) var logging: FlowLogging?
