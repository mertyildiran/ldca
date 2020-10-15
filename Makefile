default:
	nasm -f bin boot.asm -o boot.bin
	qemu-system-x86_64 boot.bin

replicate:
	nasm -f bin -o asr asr.asm
	chmod +x asr
	xxd asr > asr.xxd

run:
	./asr
	./bsr
	./csr
	./dsr
	./esr

clean:
	rm asr bsr csr dsr esr fsr
