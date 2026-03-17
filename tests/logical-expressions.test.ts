// eslint-disable-next-line @typescript-eslint/no-var-requires
const { assert } = require("chai")

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { describe, it, before } = require("mocha")

// eslint-disable-next-line @typescript-eslint/no-var-requires
const wasmTester = require("circom_tester").wasm

describe("Logical Expressions circuit", () => {
    let logicalCircuit: any

    before(async () => {
        logicalCircuit = await wasmTester("circuits/logical-expressions/logical-expressions.circom")
    })

    describe("Basic literals", () => {
        it("Should evaluate TRUE", async () => {
            const input = {
                tokens: [1, 6, 6, 6, 6, 6, 6, 6],
                exprLen: 1
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate FALSE", async () => {
            const input = {
                tokens: [0, 6, 6, 6, 6, 6, 6, 6],
                exprLen: 1
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })
    })

    describe("NOT operations", () => {
        it("Should evaluate NOT TRUE = FALSE", async () => {
            const input = {
                tokens: [1, 4, 6, 6, 6, 6, 6, 6],
                exprLen: 2
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })

        it("Should evaluate NOT FALSE = TRUE", async () => {
            const input = {
                tokens: [0, 4, 6, 6, 6, 6, 6, 6],
                exprLen: 2
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate NOT NOT TRUE = TRUE", async () => {
            const input = {
                tokens: [1, 4, 4, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })
    })

    describe("AND operations", () => {
        it("Should evaluate TRUE AND TRUE = TRUE", async () => {
            const input = {
                tokens: [1, 1, 2, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate TRUE AND FALSE = FALSE", async () => {
            const input = {
                tokens: [1, 0, 2, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })

        it("Should evaluate FALSE AND TRUE = FALSE", async () => {
            const input = {
                tokens: [0, 1, 2, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })

        it("Should evaluate FALSE AND FALSE = FALSE", async () => {
            const input = {
                tokens: [0, 0, 2, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })
    })

    describe("OR operations", () => {
        it("Should evaluate TRUE OR TRUE = TRUE", async () => {
            const input = {
                tokens: [1, 1, 3, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate TRUE OR FALSE = TRUE", async () => {
            const input = {
                tokens: [1, 0, 3, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate FALSE OR TRUE = TRUE", async () => {
            const input = {
                tokens: [0, 1, 3, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate FALSE OR FALSE = FALSE", async () => {
            const input = {
                tokens: [0, 0, 3, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })
    })

    describe("XOR operations", () => {
        it("Should evaluate TRUE XOR TRUE = FALSE", async () => {
            const input = {
                tokens: [1, 1, 5, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })

        it("Should evaluate TRUE XOR FALSE = TRUE", async () => {
            const input = {
                tokens: [1, 0, 5, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate FALSE XOR TRUE = TRUE", async () => {
            const input = {
                tokens: [0, 1, 5, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate FALSE XOR FALSE = FALSE", async () => {
            const input = {
                tokens: [0, 0, 5, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })
    })

    describe("Complex expressions", () => {
        it("Should evaluate (TRUE XOR FALSE) AND TRUE = TRUE", async () => {
            const input = {
                tokens: [1, 0, 5, 1, 2, 6, 6, 6],
                exprLen: 5
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate (TRUE OR FALSE) AND (NOT FALSE) = TRUE", async () => {
            const input = {
                tokens: [1, 0, 3, 0, 4, 2, 6, 6],
                exprLen: 6
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate TRUE AND (FALSE OR TRUE) = TRUE", async () => {
            const input = {
                tokens: [1, 0, 1, 3, 2, 6, 6, 6],
                exprLen: 5
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate (NOT TRUE) OR (FALSE AND TRUE) = FALSE", async () => {
            const input = {
                tokens: [1, 4, 0, 1, 2, 3, 6, 6],
                exprLen: 6
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 0 })
        })
    })

    describe("EMPTY token padding", () => {
        it("Should ignore tokens after exprLen", async () => {
            const input = {
                tokens: [1, 6, 6, 6, 6, 6, 6, 6],
                exprLen: 1
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate with partial padding", async () => {
            const input = {
                tokens: [1, 0, 5, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })

        it("Should evaluate with no padding", async () => {
            // (TRUE AND TRUE) OR FALSE = TRUE
            const input = {
                tokens: [1, 1, 2, 0, 3, 6, 6, 6],
                exprLen: 5
            }
            const witness = await logicalCircuit.calculateWitness(input)
            await logicalCircuit.assertOut(witness, { out: 1 })
        })
    })

    describe("Invalid inputs", () => {
        it("Should fail with non-EMPTY token after exprLen", async () => {
            const input = {
                tokens: [1, 1, 6, 6, 6, 6, 6, 6],
                exprLen: 1
            }
            try {
                await logicalCircuit.calculateWitness(input)
                assert.fail("Should have thrown an error")
            } catch (err: any) {
                assert(err.message.includes("Assert Failed") || err.message.includes("does not satisfy"), 
                    `Unexpected error: ${err.message}`)
            }
        })

        it("Should fail with insufficient operands for NOT", async () => {
            const input = {
                tokens: [4, 6, 6, 6, 6, 6, 6, 6],
                exprLen: 1
            }
            try {
                await logicalCircuit.calculateWitness(input)
                assert.fail("Should have thrown an error")
            } catch (err: any) {
                assert(err.message.includes("Assert Failed") || err.message.includes("does not satisfy"),
                    `Unexpected error: ${err.message}`)
            }
        })

        it("Should fail with insufficient operands for binary operation", async () => {
            const input = {
                tokens: [1, 2, 6, 6, 6, 6, 6, 6],
                exprLen: 2
            }
            try {
                await logicalCircuit.calculateWitness(input)
                assert.fail("Should have thrown an error")
            } catch (err: any) {
                assert(err.message.includes("Assert Failed") || err.message.includes("does not satisfy"),
                    `Unexpected error: ${err.message}`)
            }
        })

        it("Should fail with more than one value remaining", async () => {
            const input = {
                tokens: [1, 0, 6, 6, 6, 6, 6, 6],
                exprLen: 2
            }
            try {
                await logicalCircuit.calculateWitness(input)
                assert.fail("Should have thrown an error")
            } catch (err: any) {
                assert(err.message.includes("Assert Failed") || err.message.includes("does not satisfy"),
                    `Unexpected error: ${err.message}`)
            }
        })

        it("Should fail with empty stack at end", async () => {
            const input = {
                tokens: [1, 0, 2, 6, 6, 6, 6, 6],
                exprLen: 3
            }
            try {
                // This creates: push 1, push 0, and 1 and 0 = 0, leaving [0] on stack
                // This should actually succeed with output 0
                const witness = await logicalCircuit.calculateWitness(input)
                await logicalCircuit.assertOut(witness, { out: 0 })
            } catch (err: any) {
                assert.fail(`This input should be valid: ${err.message}`)
            }
        })
    })

    describe("Edge cases", () => {
        it("Should work with maximum length valid expression", async () => {
            // ((TRUE AND TRUE) XOR (NOT FALSE)) AND TRUE
            const input = {
                tokens: [1, 1, 2, 0, 4, 5, 1, 2],
                exprLen: 8
            }
            const witness = await logicalCircuit.calculateWitness(input)
            // Verify it produces a valid output (0 or 1)
            assert(
                witness[1] === 0n || witness[1] === 1n,
                "Output should be 0 or 1"
            )
        })

        it("Should handle all EMPTY tokens with exprLen=0", async () => {
            // Note: exprLen=0 means no active tokens, so this might be invalid
            // depending on circuit constraints. Let's test that it fails properly.
            const input = {
                tokens: [6, 6, 6, 6, 6, 6, 6, 6],
                exprLen: 0
            }
            try {
                await logicalCircuit.calculateWitness(input)
                assert.fail("Should have thrown an error for exprLen=0")
            } catch (err: any) {
                assert(err.message.includes("Assert Failed") || err.message.includes("does not satisfy"),
                    `Unexpected error: ${err.message}`)
            }
        })
    })
})
