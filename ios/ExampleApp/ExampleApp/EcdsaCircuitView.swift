//
//  EcdsaCircuitView.swift
//  ExampleApp
//
//  Created by Jason HUANG on 3/7/2024.
//

import SwiftUI
import moproFFI
import SwiftECC
import BigInt
import Digest

struct EcdsaCircuitView: View {
    @State private var textViewText = ""
    @State private var isProveButtonEnabled = true
    @State private var isVerifyButtonEnabled = false
    @State private var generatedProof: Data?
    @State private var publicInputs: Data?

    //let moproCircom = MoproCircom()

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Button("Init", action: runInitAction)
                Button("Prove", action: runProveAction).disabled(!isProveButtonEnabled)
                Button("Verify", action: runVerifyAction).disabled(!isVerifyButtonEnabled)
                ScrollView {
                    Text(textViewText)
                        .padding()
                }
                .frame(height: 200)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("ECDSA Example").font(.headline)
                        Text("Circom Circuit").font(.subheadline)
                    }
                }
            }
        }
    }
}

func generateGPowers(domain: Domain, keyPoint: Point) throws -> [String] {
    let STRIDE = 8
    let NUM_STRIDES = 256 / STRIDE
    var gPowers: [String] = [] // [32][256][2][4]
    // 32*256 = 8192 point multiplication
    for i in 0..<NUM_STRIDES {
        let power = BInt(2) ** (i * STRIDE)
        print(i)
        for j in 0..<(1 << STRIDE) {
            let l = BInt(j) * power
            let gPower = try domain.multiplyPoint(keyPoint, l)
            let x = gPower.x.asString(radix: 16)
            let y = gPower.y.asString(radix: 16)
            gPowers.append(x)
            gPowers.append(y)
        }
    }
    return gPowers
}

public func prove() throws -> (proof: Data, inputs: Data) {
    // Keygen, Sign, Verify
    let domain = Domain.instance(curve: .EC256k1)
    let (pk, sk) = domain.makeKeyPair()
    let message = "test".data(using: .utf8)!
    let sig = sk.sign(msg: message)
    assert (
       pk.verify(signature: sig, msg: message)
    )
    
    // Prepare circuit inputs
    // 1. Take computation out of the SNARK
    let r = BInt(magnitude: sig.r)
    let s = BInt(magnitude: sig.s)
    let R = try domain.multiplyPoint(domain.g, r)
    let rInv = r.modInverse(domain.order)
    // T = r^-1 * R
    let T = try domain.multiplyPoint(R, rInv)
    let md = MessageDigest(MessageDigest.Kind.SHA2_256)
    md.update(Bytes(message))
    let digest = md.digest()
    var msg = BInt(magnitude: digest)
    let d = digest.count * 8 - domain.order.bitWidth
    if d > 0 {
        msg >>= d
    }
    // U = (-r^-1 * msg * G)
    let U = try domain.multiplyPoint(domain.g, (-rInv * msg).mod(domain.order))
    // s*T + U = pk
    let left: Point = try domain.addPoints(try domain.multiplyPoint(T, s), U)
//                 assert (
//                    left == pk.w
//                 )
    
    // 2. Precomputing point multiples
    let TPowers = try generateGPowers(domain: domain, keyPoint: T)
    
    var inputs = [String: [String]]()
    inputs["TPreComputes"] = TPowers
    inputs["U"] = [U.x.asString(radix: 16), U.y.asString(radix: 16)]
    inputs["s"] = [s.asString(radix: 16)]

    // Generate Proof
    let generateProofResult = try generateProof2(circuitInputs: inputs)
    assert(!generateProofResult.proof.isEmpty, "Proof should not be empty")
    //FIXME: Difference between moproCircom.generateProof and generateProof2
    //assert(Data(expectedOutput) == generateProofResult.inputs, "Circuit outputs mismatch the expected outputs")
    return (generateProofResult.proof, generateProofResult.inputs)
}

extension EcdsaCircuitView {
    func runInitAction() {
        textViewText += "Initializing library... "
        Task {
            do {
                let start = CFAbsoluteTimeGetCurrent()
                try initializeMopro()
                let end = CFAbsoluteTimeGetCurrent()
                let timeTaken = end - start
                textViewText += "\(String(format: "%.3f", timeTaken))s\n"
                isProveButtonEnabled = true
            } catch {
                textViewText += "\nInitialization failed: \(error.localizedDescription)\n"
            }
        }
    }

    func runProveAction() {
         textViewText += "Generating proof... "
         Task {
             do {
                 let start = CFAbsoluteTimeGetCurrent()
                 // Store the generated proof and public inputs for later verification
                 let (generatedProof, publicInputs) = try prove()
                 let end = CFAbsoluteTimeGetCurrent()
                 let timeTaken = end - start
                 
                 textViewText += "\(String(format: "%.3f", timeTaken))s\n"
                 isVerifyButtonEnabled = true
             } catch {
                 textViewText += "\nProof generation failed: \(error.localizedDescription)\n"
             }
         }
     }

    func runVerifyAction() {
        guard let proof = generatedProof,
              let inputs = publicInputs else {
            textViewText += "Proof has not been generated yet.\n"
            return
        }

        textViewText += "Verifying proof... "
        Task {
             do {
                 let start = CFAbsoluteTimeGetCurrent()

                 let isValid = try verifyProof2(proof: proof, publicInput: inputs)
                 let end = CFAbsoluteTimeGetCurrent()
                 let timeTaken = end - start

                 if isValid {
                     textViewText += "\(String(format: "%.3f", timeTaken))s\n"

                 } else {
                     textViewText += "\nProof verification failed.\n"
                 }
                 isVerifyButtonEnabled = false // Optionally disable the verify button after verification
             } catch let error as MoproError {
                 print("\nMoproError: \(error)")
             } catch {
                 print("\nUnexpected error: \(error)")
             }
         }
    }
}

#Preview {
    EcdsaCircuitView()
}
