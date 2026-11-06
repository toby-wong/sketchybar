# Build for the machine's real CPU, not the shell's. hw.optional.arm64 is a
# hardware capability so it still reports 1 inside a Rosetta shell, whereas
# `uname -m` would report x86_64 and produce a translated binary.
ARCH := $(shell sysctl -n hw.optional.arm64 2>/dev/null | grep -q 1 && echo arm64 || echo x86_64)

helper: helper.c cpu.h memory.h sketchybar.h
	clang -std=c99 -O3 -arch $(ARCH) helper.c -o helper

.PHONY: clean
clean:
	rm -f helper
