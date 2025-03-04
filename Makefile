# Copyright (c) 2021 Anton Zhiyanov, MIT License
# https://github.com/nalgeon/sqlean

.PHONY: prepare-dist download-sqlite download-external compile-linux compile-windows compile-macos test test-all

prepare-dist:
	mkdir -p dist
	rm -f dist/*

download-sqlite:
	curl -L http://sqlite.org/$(SQLITE_RELEASE_YEAR)/sqlite-amalgamation-$(SQLITE_VERSION).zip --output src.zip
	unzip src.zip
	mv sqlite-amalgamation-$(SQLITE_VERSION)/* src

download-external:
	curl -L https://github.com/sqlite/sqlite/raw/branch-$(SQLITE_BRANCH)/ext/misc/json1.c --output src/sqlite3-json1.c
	curl -L https://github.com/mackyle/sqlite/raw/branch-$(SQLITE_BRANCH)/src/test_windirent.h --output src/test_windirent.h

compile-linux:
	gcc -fPIC -shared src/sqlite3-crypto.c src/crypto/*.c -o dist/crypto.so
	gcc -fPIC -shared src/sqlite3-fileio.c -o dist/fileio.so
	gcc -fPIC -shared src/sqlite3-fuzzy.c src/fuzzy/*.c -o dist/fuzzy.so
	gcc -fPIC -shared src/sqlite3-ipaddr.c -o dist/ipaddr.so
	gcc -fPIC -shared src/sqlite3-json1.c -o dist/json1.so
	gcc -fPIC -shared src/sqlite3-math.c -o dist/math.so -lm
	gcc -fPIC -shared src/sqlite3-re.c src/re.c -o dist/re.so
	gcc -fPIC -shared src/sqlite3-stats.c -o dist/stats.so -lm
	gcc -fPIC -shared src/sqlite3-text.c -o dist/text.so
	gcc -fPIC -shared src/sqlite3-unicode.c -o dist/unicode.so
	gcc -fPIC -shared src/sqlite3-uuid.c -o dist/uuid.so
	gcc -fPIC -shared src/sqlite3-vsv.c -o dist/vsv.so -lm

compile-windows:
	gcc -shared -I. src/sqlite3-crypto.c src/crypto/*.c -o dist/crypto.dll
	gcc -shared -I. src/sqlite3-fileio.c -o dist/fileio.dll
	gcc -shared -I. src/sqlite3-fuzzy.c src/fuzzy/*.c -o dist/fuzzy.dll
	gcc -shared -I. src/sqlite3-json1.c -o dist/json1.dll
	gcc -shared -I. src/sqlite3-math.c -o dist/math.dll -lm
	gcc -shared -I. src/sqlite3-re.c src/re.c -o dist/re.dll
	gcc -shared -I. src/sqlite3-stats.c -o dist/stats.dll -lm
	gcc -shared -I. src/sqlite3-text.c -o dist/text.dll
	gcc -shared -I. src/sqlite3-unicode.c -o dist/unicode.dll
	gcc -shared -I. src/sqlite3-uuid.c -o dist/uuid.dll
	gcc -shared -I. src/sqlite3-vsv.c -o dist/vsv.dll -lm

compile-macos:
	gcc -fPIC -dynamiclib -I src src/sqlite3-crypto.c src/crypto/*.c -o dist/crypto.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-fileio.c -o dist/fileio.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-fuzzy.c src/fuzzy/*.c -o dist/fuzzy.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-ipaddr.c -o dist/ipaddr.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-json1.c -o dist/json1.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-math.c -o dist/math.dylib -lm
	gcc -fPIC -dynamiclib -I src src/sqlite3-re.c src/re.c -o dist/re.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-stats.c -o dist/stats.dylib -lm
	gcc -fPIC -dynamiclib -I src src/sqlite3-text.c -o dist/text.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-unicode.c -o dist/unicode.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-uuid.c -o dist/uuid.dylib
	gcc -fPIC -dynamiclib -I src src/sqlite3-vsv.c -o dist/vsv.dylib -lm

test-all:
	make test suite=crypto
	make test suite=fileio
	make test suite=fuzzy
	make test suite=ipaddr
	make test suite=json1
	make test suite=math
	make test suite=re
	make test suite=stats
	make test suite=text
	make test suite=unicode
	make test suite=uuid
	make test suite=vsv

# fails if grep does find a failed test case
# https://stackoverflow.com/questions/15367674/bash-one-liner-to-exit-with-the-opposite-status-of-a-grep-command/21788642
test:
	@sqlite3 < test/$(suite).sql > test.log
	@cat test.log | (! grep -Ex "[0-9]+.[^1]")
