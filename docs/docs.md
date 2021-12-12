# Words
A word is a string separated by '\t', '\n' and ' '. A string will not count as a word if it doesn't contain at least one
of the following characters:
```
'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
'y', 'z', 'ç', 'à', 'á', 'é', 'í', 'ó', 'ú', 'â', 'ê', 'î', 'ô', 'û'.
```


# Phrases

The OPcode is defined by the number of words in a phrase (a phrase is a set of words separated by '.'). Some
instructions require using extra phrases as arguments.

The phrase pointer (the program counter) used in the official interpreter is a signed 32-bit integer. The language uses
0-based indexing.


# Numbers

Any time that an instruction asks for a number, the next two phrases will be the number. Each figure at a time,
in hexadecimal. The digit is defined by:
```
Number of words in the phrase - 5
```
Example: if you want to write 0x1a, do:
```
 [6 words]. [15 words].
```
Note: invalid numbers will make the program crash.


# The Stack

A.R.T.I.C.L.E. has an ifinite stack, which the value of the accumulator (seen later) can be pushed to the stack or the
stack can be popped and the value added to the accumulator.


# The accumulator

The accumulator is special variable which you can add or subtract numbers to it. It is where all the calculations
happen. Branching is based on the its current value.

Note: the accumulator is an unsigned 8-bit integer.


# Instructions

## [04 words] - Stack Reverse Order (SRO)

Invert the order of the values that are are currently in the stack. Nothing will happen if the stack has less than two
values.


## [05 words] - Stack Push From Accumulator (SPFA)

Pushes the current value of the accumulator to the stack.


## [06 words] - Stack Pop to Accumulator (SPA)

Removes a value from the stack and adds it to the accumulator. If the stack is empty, the program will crash.


## [07 words] - Stack Swap First Two Values (SSFTV)

Swaps the first two values of the stack. The program will crash if there are less than two values in the stack.


## [08 words] - Pop From Stack and Compare to Accumulator (PFSCA)

Removes the first item of the stack(SI), and compares it to the accumulator(A). If A equals to SI, nothing happens,
else, A = 0. If the stack is empty, the program will crash.


## [09 words] - Pop From Stack Index the Value Index as Current Value of the Accumulator to the Accumulator
(PFSIVWICVAA)

Uses the accumulator as index and pops from stack at specified index.


## [10 words] - Push to Stack Index the Value of the Accumulator After Popping the Index and Using This Value as Index
(PSIVAAPIUTVI)

This is the most complicated instruction in the whole language. Let us break it down: it pops the first value of the
stack to use it as an index then stores at index the current value of the accumulator.

Note: the program will crash if the index is bigger than the current stack size + 1.


## [11 words] {Number} - Accumulator Add (AA)

Adds the specified number to the Accumulator.


## [12 words] {Number} - Accumulator Subtract (AS)

Subtract the specified number from the Accumulator.


## [13 words] - Accumulator Input (AI)

Asks the user to input a char and store it to the accumulator (the char will be stored as an ASCII value).


## [14 words] - Accumulator Output (AO)

Outputs an ASCII character based on the current value of the accumulator.

Note: you need to manually add a newline (ASCII 0x0A / 10)


## [15 words] [4 words + (word to jump)] - Branch to Next Ocurrence of Word (BNOW)

Jumps the program execution to the next phrase that the specified word appears (NOT case-sensitive). If the word is not
found, the program crashes.


## [16 words] [4 words + (word to jump)] - Branch to Previous Ocurrence of Word (BPOW)

The same as BNOW, but it jumps to the previous word instead.


## [17 words] [4 words + (word to jump)] - Branch to Next Ocurrence of Word if the Value of the Accumulator is
Different From Zero (BNOWVADFZ)

The same as BNOW, but only works if A is different from 0.


## [18 words] [4 words + (word to jump)] - Branch to Previous Ocurrence of Word if the Value of the Accumulator is
Different From Zero (BPOWVADFZ)

The same as BPOW, but only works if A is diffrent from 0.


# Interpreter


## Usage

```
article <source file name> <behavior mode: 0 for modern or 1 for legacy> <enable debug log: true or false>
```


## Behavior modes


### Legacy Mode

Behaves exactly like the would interpreter would.


### Modern Mode

Modern Mode contains a few quality of like changes that make it more convenient.
* In AI, the input stream will not be cleared after its execution, similarly to C's getchar(). This has the advantage of
  making the user experience better for programs that require long strings as input (e.g. interpreters for other
  esolangs). Can cause weird behavior in old programs that weren't made with this in mind.
* The program will crash whenever an invalid OPcode is used. This may prevent bugs caused by accidentally entering an
  invalid Opcode. A new instruction (NOP, OPcode 3) was added so making phrases that act purely as labels still is
  possible. Can break some old programs.
* There was a bug in the branching logic where an invalid word could be used as an label (word to jump). This affects
  the BNOW, BPOW, BNOWVADFZ and BPOWVADFZ instructions. Now it is fixed. However, this may break old programs.

