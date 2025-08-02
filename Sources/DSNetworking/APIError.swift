//
//  APIError.swift
//  SampleMVVM
//
//  Created by Dhritiman Saha on 23/07/25.
//

import Foundation

public enum APIError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}
