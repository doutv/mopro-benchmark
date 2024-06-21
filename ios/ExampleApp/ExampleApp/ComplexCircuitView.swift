//
//  ComplexCircuitView.swift
//  ExampleApp
//
//  Created by Jason HUANG on 21/6/2024.
//

import SwiftUI
import moproFFI

struct ComplexCircuitView: View {
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
                        Text("Complex Circuit Benchmark").font(.headline)
                        Text("Circom Circuit").font(.subheadline)
                    }
                }
            }
        }
    }
}

extension ComplexCircuitView {
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
                 
                 // Prepare inputs
                 var inputs = [String: [String]]()
                 let a = 42
                 inputs["a"] = [String(a)]
                 
                 let start = CFAbsoluteTimeGetCurrent()

                 // Generate Proof
                 let generateProofResult = try generateProof2(circuitInputs: inputs)
                 assert(!generateProofResult.proof.isEmpty, "Proof should not be empty")

                 let end = CFAbsoluteTimeGetCurrent()
                 let timeTaken = end - start

                 // Store the generated proof and public inputs for later verification
                 generatedProof = generateProofResult.proof
                 publicInputs = generateProofResult.inputs

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

                 // Convert proof to Ethereum compatible proof
                 let ethereumProof = toEthereumProof(proof: proof)
                 let ethereumInputs = toEthereumInputs(inputs: inputs)
                 assert(ethereumProof.a.x.count > 0, "Proof should not be empty")
                 assert(ethereumInputs.count > 0, "Inputs should not be empty")

                 print("Ethereum Proof: \(ethereumProof)\n")
                 print("Ethereum Inputs: \(ethereumInputs)\n")

                 if isValid {
                     textViewText += "\(String(format: "%.3f", timeTaken))s\n"

                 } else {
                     textViewText += "\nProof verification failed.\n"
                 }
                 isVerifyButtonEnabled = false
             } catch let error as MoproError {
                 print("\nMoproError: \(error)")
             } catch {
                 print("\nUnexpected error: \(error)")
             }
         }
    }
}

#Preview {
    ComplexCircuitView()
}
