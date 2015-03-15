
# makefile for the regression tests that generate output which has to be
# compared with reference output

ifneq ($(shell echo),)
  CMD_EXE := 1
endif

CC65FLAGS := -t sim6502
SIM65FLAGS := -x 200000000

CL65 := $(if $(wildcard ../../bin/cl65*),../../bin/cl65,cl65)
SIM65 := $(if $(wildcard ../../bin/sim65*),../../bin/sim65,sim65)

ifdef CMD_EXE
RM := del /f
else
RM := rm -f
endif

WORKDIR := ../../testwrk

DIFF := $(WORKDIR)/bdiff

CFLAGS := -O2 -Wall -W -Wextra -fwrapv -fno-strict-overflow

.PHONY: all clean

SOURCES := $(wildcard *.c)
REFS := $(SOURCES:%.c=$(WORKDIR)/%.ref)
TESTS := $(foreach opt,. .o. .os. .osi. .osir. .osr. .oi. .oir. .or.,$(SOURCES:%.c=$(WORKDIR)/%$(opt)prg))

all: $(REFS) $(TESTS)

$(WORKDIR)/%.ref: %.c
	$(CC) $(CFLAGS) $< -o $(WORKDIR)/$*.host
	$(WORKDIR)/$*.host > $@

# Currently, the yacc tests fail if stack operations are optimized. Therefore,
# we prevent those particular optimizations when the yacc tests are built.
$(WORKDIR)/yacc%.prg: CC65FLAGS += -Wc --disable-opt,OptStackOps

define test_prg
$(eval option := $(1:.o%.=-O%))

# Remove the period (full stop) that passed through the above line.
$(eval option := $(option:.=))

$$(WORKDIR)/%$(1)prg: %.c $$(WORKDIR)/%.ref
	$$(CL65) $(option) $$(CC65FLAGS) $$< -o $$@
	$$(SIM65) $$(SIM65FLAGS) $$@ > $$(WORKDIR)/$$*.out
	$$(DIFF) $$(WORKDIR)/$$*.out $$(WORKDIR)/$$*.ref
endef

# Create a separate rule for each of the possible ways to optimize a program.
$(foreach opt,. .o. .os. .osi. .osir. .osr. .oi. .oir. .or.,$(eval $(call test_prg,$(opt))))

mostly-clean:
	@$(RM) $(TESTS)
	@$(RM) $(SOURCES:.c=.o)
	@$(RM) $(SOURCES:%.c=$(WORKDIR)/%.out)

clean: mostly-clean
	@$(RM) $(SOURCES:%.c=$(WORKDIR)/%.ref)
	@$(RM) $(SOURCES:%.c=$(WORKDIR)/%.host)
