import os
import strutils


type Phrase* = object
    phraseTokens*: seq[string]
    wordCount*: int32 # we need this because wordCount might not be equal to len(phraseTokens) in some cases
    lastValidWordIndex*: int # useful for branching when not in legacy mode

# If a token doesn't contain any of these, it isn't a word
const
    WORD_CHARACTERS = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
    'x', 'y', 'z', char(167), char(160), char(161), char(169), char(173), char(179), char(186), char(162), char(170),
    char(174), char(180), char(187)]

    SEPARATOR = '.'

    WHITESPACE_CHARACTERS = {'\t', '\n', ' '}

    HEX_TABLE = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]

    FIGURE_OFFSET = 5


proc isAWord*(token: string): bool =
    for character in WORD_CHARACTERS:
        if character in token:
            return true
    return false


proc getLastValidWordIndex(phrase: Phrase): int = 
    
    result = len(phrase.phraseTokens)
    if result == 0:
        return

    var foundWord = false
    while not foundWord:
        dec result
        foundWord = isAWord(phrase.phraseTokens[result])
    
    return


proc generatePhrasesFromFile*(filePath: string, legacyMode: bool): tuple[phrases: seq[Phrase], success: bool] =
    
    if not fileExists(filePath):
        echo "File \"", filePath, "\" does not exist."
        return
    
    result.success = true

    let srcFile = readFile(filePath).toLower

    let phrasesText = srcFile.split(SEPARATOR)
    for phraseText in phrasesText:

        var newPhrase: Phrase

        let tokens = phraseText.split(WHITESPACE_CHARACTERS)
        for token in tokens:

            if isAWord(token):
                inc newPhrase.wordCount

                # We need to do this because line endings in Windows might contain '\r' because Windows
                var mutableToken = token
                mutableToken.removeSuffix('\r')

                newPhrase.phraseTokens.add(mutableToken)
        
        if not legacyMode:
            newPhrase.lastValidWordIndex = getLastValidWordIndex(newPhrase)
        
        result.phrases.add(newPhrase)

    
    result.phrases.del(len(result.phrases) - 1)

    return


proc numberIsProperDigit*(number: Phrase): bool =
    if number.wordCount < FIGURE_OFFSET or number.wordCount > 0x0f + FIGURE_OFFSET:
        result = false
    else: 
        result = true
    return


proc parseNumber*(firstDigit: Phrase, lastDigit: Phrase): uint8 = 
    
    let digit1 = uint8(HEX_TABLE[firstDigit.wordCount - FIGURE_OFFSET])
    let digit2 = uint8(HEX_TABLE[lastDigit.wordCount - FIGURE_OFFSET])

    return digit1 * 0x10 + digit2


