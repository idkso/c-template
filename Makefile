SRC_ROOT := src
HEADER_ROOT := include
SRC := $(shell fd -e c . $(SRC_ROOT))
HEADERS := $(shell fd -e h . $(HEADER_ROOT))
OBJ := $(SRC:%.c=%.o)
WARNINGS := -Wall -Wextra -Wpedantic -Wsuggest-attribute=pure -Wsuggest-attribute=noreturn -Wsuggest-attribute=cold -Walloca -Wduplicated-branches -Wduplicated-cond -Wfloat-equal -Wlarger-than=4KiB -Wpointer-arith
OUT ?= main
CFLAGS ?= -std=c99 -pipe
INCLUDE := -Iinclude
LIB :=

all: $(OUT) compile_flags.txt

.DEFAULT_GOAL = debug

debug: CC = gcc
debug: CFLAGS += -Og -ggdb3
debug: all

analyze: CC = gcc
analyze: CFLAGS += -fanalyzer
analyze: debug

release: CC = clang
release: CFLAGS += -O2 -flto=thin
release: all

format: $(SRC) $(HEADERS)
	clang-format -i $(SRC) $(HEADERS)

debugger: debug
	gdb $(OUT)

$(OUT): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIB)

%.o: %.c $(HEADERS)
	$(CC) -c -o $@ $(INCLUDE) $(CFLAGS) $<

compile_flags.txt: Makefile
	rm -f compile_flags.txt
	for flag in $(WARNINGS) $(CFLAGS) $(INCLUDE); do \
		echo $$flag >> $@; \
	done

clean: $(OUT) $(OBJ) compile_flags.txt
	rm -rf $^
