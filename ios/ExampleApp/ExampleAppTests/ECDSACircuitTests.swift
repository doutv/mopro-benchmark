//
//  ECDSACircuit.swift
//  ExampleAppTests
//
//  Created by Jason HUANG on 4/7/2024.
//

import XCTest
import SwiftECC
import BigInt
@testable import ExampleApp

final class EcdsaCircuitViewTests: XCTestCase {
    func testProveSuccess() {
        let ecdsaCircuitView = EcdsaCircuitView() // Assuming `prove()` is in this class

        XCTAssertNoThrow(try {
            ecdsaCircuitView.runInitAction()
            ecdsaCircuitView.runProveAction()
        }())
    }
}

class PerformanceTests: XCTestCase {
    
    func testPointMultiplication() {
        // Prepare test data
        let domain = Domain.instance(curve: .EC256k1)
        let (pk, sk) = domain.makeKeyPair()
        let point = pk.w
        
        measure {
            // Code to be measured
            for i in 0..<100 {
                try! domain.multiplyPoint(point, BInt(0).randomTo(domain.order))
            }
        }
    }
}
