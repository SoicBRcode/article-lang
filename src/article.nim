import os
import parser
import runtime


# This facilitates debug in my setup (~SoicBRcode)
const
    READING_DEBUG_FILE = false
    MODE_STR_WHEN_DEBUG = "1"
    DEBUG_LOG_STR_WHEN_DEBUG = "true"
    SOURCE_FILE_WHEN_DEBUG = "samples/debug.artl"



proc printUsage() =
    echo "|------------------------------------------------------------------------------|"
    echo "|               ARTICLE INTERPRETER 2.0                                        |"
    echo "|------------------------------------------------------------------------------|"
    echo "| Usage:                                                                       |"
    echo "|   article <source file name> <behavior mode> <enable debug log>              |"
    echo "|------------------------------------------------------------------------------|"
    echo "| Available behavior modes (please read the documentation for more info):      |"
    echo "|     0  - Modern Mode, recommended. Might break code that was written for the |"
    echo "|          old interpreter.                                                    |"
    echo "|     1  - Legacy Mode - Behaves exactly like the old interpreter would.       |"
    echo "|------------------------------------------------------------------------------|"
    echo "| If you want to enable logging for debug purposes, use true for \"true\" for    |"
    echo "| <enable debug log> (use false if you do not).                                |"
    echo "|------------------------------------------------------------------------------|"


proc main() =
    when not READING_DEBUG_FILE:
        if paramCount() != 3:
            echo "Invalid argument count! (", paramCount(), ")"
            printUsage()
            return
    
    let
        srcPath = when READING_DEBUG_FILE: SOURCE_FILE_WHEN_DEBUG else: paramStr(1)
        modeStr = when READING_DEBUG_FILE: MODE_STR_WHEN_DEBUG else: paramStr(2)
        logStr = when READING_DEBUG_FILE: DEBUG_LOG_STR_WHEN_DEBUG else: paramStr(3)

    var
        legacyMode = false
        debugLogEnabled = false

    if modeStr == "1":
        legacyMode = true
    elif modeStr != "0":
        echo "Second argument (", modeStr, ") is not a valid mode."
        printUsage()
        return

    if logStr == "true":
        debugLogEnabled = true
    elif logStr != "false":
        echo "Third argument (", logStr, ") is not valid."
        printUsage()
        return
    
    let phraseGenerationResult = generatePhrasesFromFile(srcPath, legacyMode)

    if not phraseGenerationResult.success:
        return

    runProgram(legacyMode, phraseGenerationResult.phrases, debugLogEnabled)


main()