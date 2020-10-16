default:
	nasm -f bin -o outs/00000000 ldca.asm
	chmod +x outs/00000000
	xxd outs/00000000 > 00000000.xxd

run:
	cd outs && ./00000000 && cd ..
