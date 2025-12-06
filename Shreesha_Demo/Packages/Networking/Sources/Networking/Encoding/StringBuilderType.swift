//
//  File.swift
//  
//
//  Created by Shreesha Kedlaya on 09/08/24.
//

import Foundation

@resultBuilder
public struct StringBuilderType {
    public static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "\n")
    }
    
    public static func buildOptional(_ component: String?) -> String {
        component ?? ""
    }
    
    public static func buildEither(first component: String) -> String {
        component
    }
    
    public static func buildEither(second component: String) -> String {
        component
    }
    
    public static func buildArray(_ components: [String]) -> String {
        components.joined(separator: "\n")
    }
}

public extension String {
    static func buildString(@StringBuilderType _ content: () -> String) -> String {
        return content()
    }
}
