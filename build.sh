#!/usr/bin/env sh
# Bootstrap build. Each stage compiles the next from source using only the
# previous stage's binary. No external tools other than QEMU.
set -e
run() {
	(cat "$2"; printf '\004') | qemu-system-riscv32 \
		-machine virt \
		-cpu rv32i \
		-nographic \
		-bios none \
		-device loader,file="$1",addr=0x80000000 \
		-serial mon:stdio 2>/dev/null
}
run ../famc/bin/famc ./src/boot.fam > ./bin/boot

echo "Success!";
