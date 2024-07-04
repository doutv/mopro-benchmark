//
//  ECDSACircuit.swift
//  ExampleAppTests
//
//  Created by Jason HUANG on 4/7/2024.
//

import XCTest
import SwiftECC
import BigInt
import secp256k1
import secp256k1_bindings
@testable import ExampleApp

final class EcdsaCircuitViewTests: XCTestCase {
    func testProveSuccess() {
        let ecdsaCircuitView = EcdsaCircuitView() // Assuming `prove()` is in this class
        ecdsaCircuitView.runInitAction()
        ecdsaCircuitView.runProveAction()
    }
}

class PerformanceTests: XCTestCase {
    
    func testPointMultiplication() {
        // Prepare test data
        let domain = Domain.instance(curve: .EC256k1)
        let (pk, sk) = domain.makeKeyPair()
        let point = pk.w
        let scalar = BInt(0).randomTo(domain.p)
        print(scalar)
        
        measure {
            try! domain.multiplyPoint(point, scalar)
        }
    }
    
    func testSwiftECCVerify() {
        let domain = Domain.instance(curve: .EC256k1)
        let (pk, sk) = domain.makeKeyPair()
        let message = "test".data(using: .utf8)!
        let sig = sk.sign(msg: message)
        
        measure {
            pk.verify(signature: sig, msg: message)
        }
    }
    
    func testFFIVerify() {
        let sk = try! secp256k1.Signing.PrivateKey()
        let pk = sk.publicKey

        // ECDSA
        let messageData = "We're all Satoshi.".data(using: .utf8)!
        let signature = try! sk.signature(for: messageData)
        
        measure {
            pk.isValidSignature(signature, for: messageData)
        }
    }
}
