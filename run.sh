rm hello.img
nasm ipl.asm -o ipl.bin 
nasm haribote.asm  -o harbote.sys

#这里使用dd命令，将两个文件合起来写入img中
dd if=ipl.bin of=hello.img conv=notrunc
dd if=harbote.sys of=hello.img seek=512 bs=512 conv=notrunc
#gcc ipl haribote -o hello.img
qemu-system-x86_64 hello.img
