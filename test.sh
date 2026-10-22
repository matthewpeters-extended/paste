#!/bin/sh
# Command Line Tools ship Swift Testing outside SwiftPM's default search path.
F=/Library/Developer/CommandLineTools/Library/Developer/Frameworks
LIB=/Library/Developer/CommandLineTools/Library/Developer/usr/lib
exec swift test -Xswiftc -F$F -Xlinker -F$F -Xlinker -rpath -Xlinker $F -Xlinker -rpath -Xlinker $LIB "$@"
