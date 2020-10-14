default:
	nasm -f bin boot.asm -o boot.bin
	qemu-system-x86_64 boot.bin

asr:
	nasm -f bin -o asr asr.asm && chmod +x asr
