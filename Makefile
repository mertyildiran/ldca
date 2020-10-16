default:
	nasm -f bin boot.asm -o boot.bin
	qemu-system-x86_64 boot.bin

replicate:
	nasm -f bin -o asr asr.asm
	chmod +x asr
	xxd asr > asr.xxd

run:
	./asr
	./100
	./200
	./300
	./400

clean:
	rm asr 100 200 300 400
