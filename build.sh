#!/usr/bin/env sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
FAMC="$DIR/famc/bin/famc"

# Build the compiler if needed
if [ ! -f "$FAMC" ]; then
	echo "Building famc compiler..."
	(cd "$DIR/famc" && bash build.sh)
fi

compile() {
	(cat "$@"; printf '\004') | qemu-system-riscv32 \
		-machine virt \
		-cpu rv32i \
		-nographic \
		-bios none \
		-device loader,file="$FAMC",addr=0x80000000 \
		-serial mon:stdio 2>/dev/null
}

check() {
	local out="$1"
	local magic
	magic=$(head -c 4 "$out" | xxd -p)
	if [ "$magic" != "13000000" ]; then
		echo "FAILED: $out"
		cat "$out"
		exit 1
	fi
}

# Build bootloader
echo "Building boot.bin..."
compile "$DIR/lib/macros.fam" "$DIR/src/boot.fam" > "$DIR/bin/boot.bin"
check "$DIR/bin/boot.bin"

echo "Success!"
