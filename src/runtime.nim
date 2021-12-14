from stack import nil
import repeat_until
import exceptions
import strutils
import op_info
import parser


var
    accumulator: uint8 = 0
    pc: int32 = 0 # Program counter

type Direction = enum previous, next

const DEBUG_LOG_FILE = "debug.log"



proc ensureStackHasEnoughValuesForInstruction(minimumValues: int, phrase: Phrase) =
    if len(stack.data) < minimumValues:
        crash(pc, phrase, "stack does not have enough values for executing this instruction")


proc ensureProperNumberWasGiven(phrases: seq[Phrase]) =
    
    if len(phrases) <= pc + 2:
        crash(pc, phrases[pc], "not enough phrases for this operation")
    
    if not numberIsProperDigit(phrases[pc + 1]) or not numberIsProperDigit(phrases[pc + 2]):
        crash(pc, phrases[pc], "invalid number for this instruction")


proc getCharWithoutCarriageReturn(): char =
    result = stdin.readChar()
    if result == '\r':
        result = char(0)
    return


proc getSinglecharFromConsole(): char =

    result = getCharWithoutCarriageReturn()

    while stdin.readChar() != '\n': discard # Clears buffer
    return


# i_ prefix means instruction
proc i_stackReverseOrder() =
    stack.reverseOrder()
        

proc i_stackPushFromAccumulator() =
    stack.push(accumulator)


proc i_stackPopToAccumulator(phrase: Phrase) =
    ensureStackHasEnoughValuesForInstruction(1, phrase)
    accumulator += stack.pop()


proc i_stackSwapFirstTwoValues(phrase: Phrase) =
    ensureStackHasEnoughValuesForInstruction(2, phrase)

    let v1 = stack.pop()
    let v2 = stack.pop()

    stack.push(v1)
    stack.push(v2)


proc i_popFromStackAndCompareToAccumulator(phrase: Phrase) =
    ensureStackHasEnoughValuesForInstruction(1, phrase)

    let item = stack.pop()

    if item != accumulator:
        accumulator = 0


proc i_popFromStackIndexTheValueIndexAsCurrentValueOfTheAccumulatorToTheAccumulator(phrase: Phrase) =
    ensureStackHasEnoughValuesForInstruction(int(accumulator + 1), phrase)
    accumulator += stack.pop(int(accumulator))


proc i_pushToStackIndexTheValueOfAccumulatorAfterPoppingIndexAndUsingThisValueAsIndex(phrase: Phrase) =
    ensureStackHasEnoughValuesForInstruction(2, phrase)
    let i = int(stack.pop())
    ensureStackHasEnoughValuesForInstruction(i - 1, phrase)
    stack.push(accumulator, i)


proc i_accumulatorAdd(phrases: seq[Phrase]) =
    ensureProperNumberWasGiven(phrases)
    accumulator += parseNumber(phrases[pc + 1], phrases[pc + 2])
    pc += 2


proc i_accumulatorSubstract(phrases: seq[Phrase]) =
    ensureProperNumberWasGiven(phrases)
    accumulator -= parseNumber(phrases[pc + 1], phrases[pc + 2])
    pc += 2


proc i_accumulatorInput(legacyMode: bool) =

    var character: char

    if legacyMode:
        stdout.write "\n>"
        character = getSinglecharFromConsole()
    else:
        character = getCharWithoutCarriageReturn()
    
    #[
        This check is done because getCharWithoutCarriageReturn() will return char(0) if the character from
        stdin.readChar is '\r'. And we don't want to set the accumulator to '\r' so ARTICLE code is portable.
    ]#
    if character != char(0):
        accumulator = uint8(character)


proc i_accumulatorOutput() =
    stdout.write char(accumulator)


proc i_branchToOccurenceOfWord(phrases: seq[Phrase], direction: Direction, legacyMode: bool) =

    let incValue: int32 = if direction == Direction.next: 1 else: -1

    if pc == len(phrases):
        crash(pc, phrases[pc], "no label found for branch operation")

    var word = ""
    if legacyMode:
        word = phrases[pc + 1].phraseTokens[BRANCH_LABEL_INDEX]
    else:
        let i = phrases[pc + 1].lastValidWordIndex
        word = phrases[pc + 1].phraseTokens[i]

    let intialPhrase = phrases[pc]

    if direction == Direction.next:
        inc pc
    
    var foundWord = false
    repeatUntil foundWord or pc > len(phrases) or pc < 0:
        pc += incValue
        let testWord = phrases[pc].phraseTokens
        foundWord = testWord.contains(word)
    
    if not foundWord:
        crash(pc, intialPhrase,
            "could not find the " &
            (if direction == Direction.next: "next" else: "previous") &
            " phrase where the word 「" & word & "」appeared")
    

proc i_branchOccurenceOfWordIfValueOfAccumulatorNotZero(phrases: seq[Phrase], direction: Direction, legacyMode: bool) =
    
    if accumulator != 0:
        i_branchToOccurenceOfWord(phrases, direction, legacyMode)
    else:
        inc pc


proc runProgram*(legacyMode: bool, phrases: seq[Phrase], debugLogEnabled: bool) =
    
    # NL = newline
    const CONSOLE_BAR_WITH_NL = "|------------------------------------------------------------------------------|\n"
    
    if debugLogEnabled:
        var file = open(DEBUG_LOG_FILE, FileMode.fmWrite)

        var toWrite = CONSOLE_BAR_WITH_NL & "            INSTRUCTION PRINTING START\n" & CONSOLE_BAR_WITH_NL

        for phrase in phrases:
            toWrite &= "Phrase: 「" & makeStringForPhrase(phrase) & "」\n"
            toWrite &= "Word count: " & $(phrase.wordCount) & "\n"   
            toWrite &= CONSOLE_BAR_WITH_NL
        
        toWrite &= "\n\n" & CONSOLE_BAR_WITH_NL & "            INSTRUCTION PRINTING END\n" & CONSOLE_BAR_WITH_NL
        toWrite &= "\n\n\n\n" & CONSOLE_BAR_WITH_NL & "            STEP PRINTING START\n" & CONSOLE_BAR_WITH_NL
        file.write(toWrite)
        file.close()

    while pc < len(phrases):

        case phrases[pc].wordCount
        of 0x03: discard # NOP
        of 0x04: i_stackReverseOrder()
        of 0x05: i_stackPushFromAccumulator()
        of 0x06: i_stackPopToAccumulator(phrases[pc])
        of 0x07: i_stackSwapFirstTwoValues(phrases[pc])
        of 0x08: i_popFromStackAndCompareToAccumulator(phrases[pc])
        of 0x09: i_popFromStackIndexTheValueIndexAsCurrentValueOfTheAccumulatorToTheAccumulator(phrases[pc])
        of 0x0A: i_pushToStackIndexTheValueOfAccumulatorAfterPoppingIndexAndUsingThisValueAsIndex(phrases[pc])
        of 0x0B: i_accumulatorAdd(phrases)
        of 0x0C: i_accumulatorSubstract(phrases)
        of 0x0D: i_accumulatorInput(legacyMode)
        of 0x0E: i_accumulatorOutput()
        of 0x0F: i_branchToOccurenceOfWord(phrases, Direction.next, legacyMode)
        of 0x10: i_branchToOccurenceOfWord(phrases, Direction.previous, legacyMode)
        of 0x11: i_branchOccurenceOfWordIfValueOfAccumulatorNotZero(phrases, Direction.next, legacyMode)
        of 0x12: i_branchOccurenceOfWordIfValueOfAccumulatorNotZero(phrases, Direction.previous, legacyMode)
        elif not legacyMode:
            crash(pc, phrases[pc], "invalid opcode")
        
        if debugLogEnabled:
            var file = open(DEBUG_LOG_FILE, FileMode.fmAppend)

            var toWrite = ""
            toWrite &= "Program counter: " & $(pc) & "\n"
            toWrite &= ("Accumulator -> Decimal: " &
                $(accumulator) & ", hex: 0x" & accumulator.toHex & ", ASCII char: 「" & char(accumulator) & "」\n")
            toWrite &= "Phrase: 「" & makeStringForPhrase(phrases[pc]) & "」\n"
            toWrite &= "Opcode: " & makeStringForOpcode(phrases[pc]) & "\n"
            toWrite &= "Stack Trace:\n" & makeStringForStackTrace() & "\n"
            toWrite &= CONSOLE_BAR_WITH_NL
            file.write(toWrite)

            file.close()


        inc pc