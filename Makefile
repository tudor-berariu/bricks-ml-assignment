# Copyright (C) 2014 Tudor Berariu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

.PHONY: clean

NAME=$(lastword $(subst /, ,$(shell pwd)))

# compile options
CC=dmd
CCFLAGS=-w -O -g -unittest -debug
LIB=

# sources and object folders
SRC_DIR=src
BUILD_DIR=build

# source files
MAIN_SRC=$(wildcard $(SRC_DIR)/*.d)
AUX_SRC=$(shell find $(SRC_DIR)/*/ -name *.d 2> /dev/null)
INTERFACES=$(shell find $(SRC_DIR)/*/ -name *.di 2> /dev/null)
SRC=$(MAIN_SRC) $(AUX_SRC)

# object files
OBJS=$(patsubst %.d,%.o,$(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(SRC)))
AUX_OBJS=$(patsubst %.d,%.o,$(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(AUX_SRC)))

# binaries
EXEC=$(patsubst $(SRC_DIR)/%,%,$(patsubst %.d,%,$(MAIN_SRC)))
RUNEXEC=$(lastword $(EXEC))

# build object files from sources
$(OBJS): $(BUILD_DIR)/%.o: $(SRC_DIR)/%.d
	mkdir -p $(patsubst %/$(lastword $(subst /, ,$@)),%,$@)
	(cd $(SRC_DIR) ; $(CC) $(CCFLAGS) -c $(patsubst $(SRC_DIR)/%,%,$+) -of../$@ $(LIB))

$(EXEC): %: $(OBJS) $(INTERFACES)
	$(CC) $(CCFLAGS) -of$@ $(BUILD_DIR)/$@.o $(AUX_OBJS) $(LIB)

build: $(EXEC)

# Remove all Emacs temporary files, objects and executables
clean:
	rm -rf $(EXEC) $(BUILD_DIR)/*
	find . -name '*~' -print0 | xargs -0 rm -f

# Run one executable
run: build
	./$(RUNEXEC)
