from stack import nil
import parser
import strutils
import op_info



proc makeStringForPhrase*(phrase: Phrase): string =
    
    for i, word in phrase.phraseTokens:
        result &= word
        if i < len(phrase.phraseTokens) - 1:
            result &= " "

    return


proc makeStringForStackTrace*(): string =
    
    for value in stack.data:
        result &= "    "
        result &= "Decimal: "
        if value < 100: result &= "0"
        result &= $(value) & ", hex: 0x" & value.toHex & ", ASCII character: 「" & char(value) & "」\n"
    
    if len(stack.data) == 0:
        result &= "    [Empty]"

    return


proc makeStringForOpcode*(phrase: Phrase): string =

    if phrase.wordCount < MIN_OPCODE or phrase.wordCount > MAX_OPCODE:
        result &= "invalid opcode -> "
    
    if phrase.wordCount < 100: result &= "0"
    result &= $(phrase.wordCount)
    result &= "(0x" & uint8(phrase.wordCount).toHex & ")"

    return


proc crash*(programCounter: int, phrase: Phrase, reason: string) =

    echo "|------------------------------------------------------------------------------|"
    echo "|                   ARTICLE INTERPRETER                                        |"
    echo "|------------------------------------------------------------------------------|"
    echo "| Oh no! An exception has happened! The program has crashed. Debug info below. |"
    echo "|------------------------------------------------------------------------------|\n"
    echo "Program crashed when program counter was equal to ", programCounter, "."
    echo "Phrase: \"", makeStringForPhrase(phrase), "\"."
    echo "Opcode: ", makeStringForOpcode(phrase), "."
    echo "Reason: ", reason, "."
    echo "Stack trace:\n", makeStringForStackTrace()

    quit(1)