default:
	nasm -f bin boot.asm -o boot.bin
	qemu-system-x86_64 boot.bin

replicate:
	nasm -f bin -o 00000000 ldca.asm
	chmod +x 00000000
	xxd 00000000 > 00000000.xxd

run:
	./00000000
	./10000000
	./20000000
	./30000000
	./40000000

clean:
	rm 00000000 10000000 20000000 30000000 40000000
