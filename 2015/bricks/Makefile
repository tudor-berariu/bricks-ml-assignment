# Copyright (C) 2015 Tudor Berariu <tudor.berariu@google.com>

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SHELL := /bin/sh

# compile options
CC := gcc
CCFLAGS := -Wall -std=c++0x -Ofast
LIBS :=
LIBSTD := -lstdc++
LIBMMGTK := #`pkg-config gtkmm-3.0 --cflags --libs`
LIB := $(LIBS) $(LIBMMGTK) $(LIBSTD)

ifeq ($(MAKECMDGOALS),debug)
override CCFLAGS := -g $(CCFLAGS)
endif

C := $(CC) $(CCFLAGS)

# git
GITIGNORE=.gitignore


# sources and objects folders
SRC_DIR=src
BUILD_DIR=build

# source files
MAIN_SRC=$(wildcard $(SRC_DIR)/*.cc)
AUX_SRC=$(shell find $(SRC_DIR)/*/ -name *.cc 2> /dev/null)
HEADERS=$(shell find $(SRC_DIR)/*/ -name *.h 2> /dev/null)
SRC=$(MAIN_SRC) $(AUX_SRC)

# object files
OBJS=$(patsubst %.cc,%.o,$(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(SRC)))
AUX_OBJS=$(patsubst %.cc,%.o,$(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(AUX_SRC)))

# binaries
EXEC=$(patsubst $(SRC_DIR)/%,%,$(patsubst %.cc,%,$(MAIN_SRC)))

.PHONY: build debug clean run

build: $(EXEC)

debug: $(EXEC)

# Link object files
#  Add the following line to add executable to git ignore.

$(EXEC): %: $(BUILD_DIR)/%.o $(AUX_OBJS)
	(cat $(GITIGNORE) | grep -xq $@) || echo "$@" >> $(GITIGNORE)
	$(CC) $(CCFLAGS) -o $@ $+ $(LIB)

# Build object files from sources
$(OBJS): $(BUILD_DIR)/%.o: $(SRC_DIR)/%.cc $(HEADERS)
	mkdir -p $(patsubst %/$(lastword $(subst /, ,$@)),%,$@)
	$(CC) $(CCFLAGS) -I$(SRC_DIR) -c $(word 1,$+) -o $@ $(LIB)

# Remove all Emacs temporary files, objects and executable
clean:
	rm -rf $(EXEC) $(BUILD_DIR)/*
	find . -name '*~' -print0 | xargs -0 rm -f

# Run one executable
run: build
	./$(lastword $(EXEC))
