pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

// Evaluates a logical expression written in Reverse Polish Notation (RPN).
// Token mapping:
// 0 = FALSE
// 1 = TRUE
// 2 = AND
// 3 = OR
// 4 = NOT
// 5 = XOR
// 6 = EMPTY (padding)
template LogicalExpressionRPN(MAX_TOKENS) {
    signal input tokens[MAX_TOKENS];
    signal input exprLen;
    signal output out;

    // Stack machine state at each step i.
    signal sp[MAX_TOKENS + 1];
    signal stack[MAX_TOKENS + 1][MAX_TOKENS + 1];

    signal isFalse[MAX_TOKENS];
    signal isTrue[MAX_TOKENS];
    signal isAnd[MAX_TOKENS];
    signal isOr[MAX_TOKENS];
    signal isNot[MAX_TOKENS];
    signal isXor[MAX_TOKENS];
    signal isEmpty[MAX_TOKENS];

    signal isLiteral[MAX_TOKENS];
    signal isBinary[MAX_TOKENS];
    signal isActive[MAX_TOKENS];
    signal isInactive[MAX_TOKENS];

    signal ge1[MAX_TOKENS];
    signal ge2[MAX_TOKENS];

    signal selTop1[MAX_TOKENS][MAX_TOKENS + 1];
    signal selTop2[MAX_TOKENS][MAX_TOKENS + 1];
    signal selPush[MAX_TOKENS][MAX_TOKENS + 1];
    signal selWriteUnary[MAX_TOKENS][MAX_TOKENS + 1];
    signal selWriteBinary[MAX_TOKENS][MAX_TOKENS + 1];

    signal top1Term[MAX_TOKENS][MAX_TOKENS + 1];
    signal top2Term[MAX_TOKENS][MAX_TOKENS + 1];

    signal top1[MAX_TOKENS];
    signal top2[MAX_TOKENS];

    signal topMul[MAX_TOKENS];
    signal andValue[MAX_TOKENS];
    signal orValue[MAX_TOKENS];
    signal xorValue[MAX_TOKENS];
    signal notValue[MAX_TOKENS];
    signal literalValue[MAX_TOKENS];

    signal binaryTermAnd[MAX_TOKENS];
    signal binaryTermOr[MAX_TOKENS];
    signal binaryTermXor[MAX_TOKENS];
    signal binaryValue[MAX_TOKENS];

    signal pushPick[MAX_TOKENS][MAX_TOKENS + 1];
    signal pushKeep[MAX_TOKENS][MAX_TOKENS + 1];
    signal pushCandidate[MAX_TOKENS][MAX_TOKENS + 1];

    signal unaryPick[MAX_TOKENS][MAX_TOKENS + 1];
    signal unaryKeep[MAX_TOKENS][MAX_TOKENS + 1];
    signal unaryCandidate[MAX_TOKENS][MAX_TOKENS + 1];

    signal binaryPick[MAX_TOKENS][MAX_TOKENS + 1];
    signal binaryKeep[MAX_TOKENS][MAX_TOKENS + 1];
    signal binaryCandidate[MAX_TOKENS][MAX_TOKENS + 1];

    signal termLiteral[MAX_TOKENS][MAX_TOKENS + 1];
    signal termNot[MAX_TOKENS][MAX_TOKENS + 1];
    signal termBinary[MAX_TOKENS][MAX_TOKENS + 1];
    signal termEmpty[MAX_TOKENS][MAX_TOKENS + 1];

    signal spTermLiteral[MAX_TOKENS];
    signal spTermNot[MAX_TOKENS];
    signal spTermBinary[MAX_TOKENS];
    signal spTermEmpty[MAX_TOKENS];

    component lenLt = LessThan(32);

    component ltActive[MAX_TOKENS];
    component lt1[MAX_TOKENS];
    component lt2[MAX_TOKENS];

    component eqFalse[MAX_TOKENS];
    component eqTrue[MAX_TOKENS];
    component eqAnd[MAX_TOKENS];
    component eqOr[MAX_TOKENS];
    component eqNot[MAX_TOKENS];
    component eqXor[MAX_TOKENS];
    component eqEmpty[MAX_TOKENS];

    component eqTop1[MAX_TOKENS][MAX_TOKENS + 1];
    component eqTop2[MAX_TOKENS][MAX_TOKENS + 1];
    component eqPush[MAX_TOKENS][MAX_TOKENS + 1];
    component eqWriteUnary[MAX_TOKENS][MAX_TOKENS + 1];
    component eqWriteBinary[MAX_TOKENS][MAX_TOKENS + 1];

    // Circom requires components to be instantiated before being wired in constraints.
    for (var i = 0; i < MAX_TOKENS; i++) {
        ltActive[i] = LessThan(32);
        lt1[i] = LessThan(32);
        lt2[i] = LessThan(32);

        eqFalse[i] = IsEqual();
        eqTrue[i] = IsEqual();
        eqAnd[i] = IsEqual();
        eqOr[i] = IsEqual();
        eqNot[i] = IsEqual();
        eqXor[i] = IsEqual();
        eqEmpty[i] = IsEqual();

        for (var j = 0; j < MAX_TOKENS + 1; j++) {
            eqTop1[i][j] = IsEqual();
            eqTop2[i][j] = IsEqual();
            eqPush[i][j] = IsEqual();
            eqWriteUnary[i][j] = IsEqual();
            eqWriteBinary[i][j] = IsEqual();
        }
    }

    sp[0] <== 0;
    for (var j = 0; j < MAX_TOKENS + 1; j++) {
        stack[0][j] <== 0;
    }

    // 0 <= exprLen <= MAX_TOKENS
    lenLt.in[0] <== exprLen;
    lenLt.in[1] <== MAX_TOKENS + 1;
    lenLt.out === 1;

    for (var i = 0; i < MAX_TOKENS; i++) {
        // Mark whether this token index is part of the expression prefix.
        ltActive[i].in[0] <== i;
        ltActive[i].in[1] <== exprLen;
        isActive[i] <== ltActive[i].out;
        isInactive[i] <== 1 - isActive[i];

        // Decode tokens[i] into one-hot selector signals.
        eqFalse[i].in[0] <== tokens[i];
        eqFalse[i].in[1] <== 0;
        isFalse[i] <== eqFalse[i].out;

        eqTrue[i].in[0] <== tokens[i];
        eqTrue[i].in[1] <== 1;
        isTrue[i] <== eqTrue[i].out;

        eqAnd[i].in[0] <== tokens[i];
        eqAnd[i].in[1] <== 2;
        isAnd[i] <== eqAnd[i].out;

        eqOr[i].in[0] <== tokens[i];
        eqOr[i].in[1] <== 3;
        isOr[i] <== eqOr[i].out;

        eqNot[i].in[0] <== tokens[i];
        eqNot[i].in[1] <== 4;
        isNot[i] <== eqNot[i].out;

        eqXor[i].in[0] <== tokens[i];
        eqXor[i].in[1] <== 5;
        isXor[i] <== eqXor[i].out;

        eqEmpty[i].in[0] <== tokens[i];
        eqEmpty[i].in[1] <== 6;
        isEmpty[i] <== eqEmpty[i].out;

        isLiteral[i] <== isFalse[i] + isTrue[i];
        isBinary[i] <== isAnd[i] + isOr[i] + isXor[i];

        // Active indices must hold a real token, inactive indices must hold EMPTY.
        isActive[i] * ((isFalse[i] + isTrue[i] + isAnd[i] + isOr[i] + isNot[i] + isXor[i]) - 1) === 0;
        isInactive[i] * (1 - isEmpty[i]) === 0;

        lt1[i].in[0] <== sp[i];
        lt1[i].in[1] <== 1;
        ge1[i] <== 1 - lt1[i].out;

        lt2[i].in[0] <== sp[i];
        lt2[i].in[1] <== 2;
        ge2[i] <== 1 - lt2[i].out;

        // Operand availability checks.
        isNot[i] * (1 - ge1[i]) === 0;
        isBinary[i] * (1 - ge2[i]) === 0;

        for (var j = 0; j < MAX_TOKENS + 1; j++) {
            // Build selectors for reading top elements and writing back results.
            eqTop1[i][j].in[0] <== sp[i];
            eqTop1[i][j].in[1] <== j + 1;
            selTop1[i][j] <== eqTop1[i][j].out;

            eqTop2[i][j].in[0] <== sp[i];
            eqTop2[i][j].in[1] <== j + 2;
            selTop2[i][j] <== eqTop2[i][j].out;

            eqPush[i][j].in[0] <== sp[i];
            eqPush[i][j].in[1] <== j;
            selPush[i][j] <== eqPush[i][j].out;

            eqWriteUnary[i][j].in[0] <== sp[i];
            eqWriteUnary[i][j].in[1] <== j + 1;
            selWriteUnary[i][j] <== eqWriteUnary[i][j].out;

            eqWriteBinary[i][j].in[0] <== sp[i];
            eqWriteBinary[i][j].in[1] <== j + 2;
            selWriteBinary[i][j] <== eqWriteBinary[i][j].out;

            top1Term[i][j] <== selTop1[i][j] * stack[i][j];
            top2Term[i][j] <== selTop2[i][j] * stack[i][j];
        }

        // Selector-weighted sums emulate stack[top] and stack[top-1].
        var accTop1 = 0;
        var accTop2 = 0;
        for (var j = 0; j < MAX_TOKENS + 1; j++) {
            accTop1 += top1Term[i][j];
            accTop2 += top2Term[i][j];
        }
        top1[i] <== accTop1;
        top2[i] <== accTop2;

        top1[i] * (top1[i] - 1) === 0;
        top2[i] * (top2[i] - 1) === 0;

        // Compute operation results from selected operands.
        literalValue[i] <== isTrue[i];

        topMul[i] <== top2[i] * top1[i];
        andValue[i] <== topMul[i];
        orValue[i] <== top2[i] + top1[i] - topMul[i];
        xorValue[i] <== top2[i] + top1[i] - (2 * topMul[i]);
        notValue[i] <== 1 - top1[i];

        binaryTermAnd[i] <== isAnd[i] * andValue[i];
        binaryTermOr[i] <== isOr[i] * orValue[i];
        binaryTermXor[i] <== isXor[i] * xorValue[i];
        binaryValue[i] <== binaryTermAnd[i] + binaryTermOr[i] + binaryTermXor[i];

        for (var j = 0; j < MAX_TOKENS + 1; j++) {
            // Build candidate next-stack rows for each opcode family.
            pushPick[i][j] <== selPush[i][j] * literalValue[i];
            pushKeep[i][j] <== (1 - selPush[i][j]) * stack[i][j];
            pushCandidate[i][j] <== pushPick[i][j] + pushKeep[i][j];

            unaryPick[i][j] <== selWriteUnary[i][j] * notValue[i];
            unaryKeep[i][j] <== (1 - selWriteUnary[i][j]) * stack[i][j];
            unaryCandidate[i][j] <== unaryPick[i][j] + unaryKeep[i][j];

            binaryPick[i][j] <== selWriteBinary[i][j] * binaryValue[i];
            binaryKeep[i][j] <== (1 - selWriteBinary[i][j]) * stack[i][j];
            binaryCandidate[i][j] <== binaryPick[i][j] + binaryKeep[i][j];

            termLiteral[i][j] <== isLiteral[i] * pushCandidate[i][j];
            termNot[i][j] <== isNot[i] * unaryCandidate[i][j];
            termBinary[i][j] <== isBinary[i] * binaryCandidate[i][j];
            termEmpty[i][j] <== isEmpty[i] * stack[i][j];

            // Exactly one term is active, producing stack row i+1.
            stack[i + 1][j] <== termLiteral[i][j] + termNot[i][j] + termBinary[i][j] + termEmpty[i][j];
            stack[i + 1][j] * (stack[i + 1][j] - 1) === 0;
        }

        // Stack pointer transitions: literal +1, binary -1, NOT/EMPTY keep same.
        spTermLiteral[i] <== isLiteral[i] * (sp[i] + 1);
        spTermNot[i] <== isNot[i] * sp[i];
        spTermBinary[i] <== isBinary[i] * (sp[i] - 1);
        spTermEmpty[i] <== isEmpty[i] * sp[i];
        sp[i + 1] <== spTermLiteral[i] + spTermNot[i] + spTermBinary[i] + spTermEmpty[i];
    }

    // A valid expression must leave exactly one item in the stack.
    sp[MAX_TOKENS] === 1;
    out <== stack[MAX_TOKENS][0];
    out * (out - 1) === 0;
}

// Example with MAX_TOKENS = 8:
// tokens = [1, 0, 5, 1, 2, 6, 6, 6], exprLen = 5
// Trace (RPN): TRUE FALSE XOR TRUE AND
// i=0 token=1 (TRUE):   stack []          -> [1],      sp 0 -> 1
// i=1 token=0 (FALSE):  stack [1]         -> [1, 0],   sp 1 -> 2
// i=2 token=5 (XOR):    stack [1, 0]      -> [1],      sp 2 -> 1   (1 xor 0 = 1)
// i=3 token=1 (TRUE):   stack [1]         -> [1, 1],   sp 1 -> 2
// i=4 token=2 (AND):    stack [1, 1]      -> [1],      sp 2 -> 1   (1 and 1 = 1)
// i=5 token=6 (EMPTY):  stack [1]         -> [1],      sp 1 -> 1
// i=6 token=6 (EMPTY):  stack [1]         -> [1],      sp 1 -> 1
// i=7 token=6 (EMPTY):  stack [1]         -> [1],      sp 1 -> 1
// Final out = 1
component main {public [tokens, exprLen]} = LogicalExpressionRPN(8);
