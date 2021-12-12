# New ARTICLE interpreter

The old one had several problems: poorly written, not open-source, not cross-plataform, etc. So I made a new one, this
time in Nim and with extra features. Please keep in mind that this was my first time writting code in the Nim
programming language, so the way I did some things may not be the best one available on this language, as I still don't
know much about it.

If you found a bug, feel free to open an issue and/or make a pull request.


# Building from source

There are releases for Windows and Linux. But if you are on other plataforms and/or you want to tinker with the source
code, you need to build from source (which is easy to do).


## Requirements

Nim Compiler (tested with version 1.6.0).


## Compiling

To download the source code and compile the interpreter, type the following commands:
```
git clone https://github.com/SoicBRcode/article-lang.git
cd article-lang
nim c --out:bin/article -d:release src/article.nim
```