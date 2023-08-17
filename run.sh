rm hello.img
nasm hello.asm -o hello.img
qemu-system-x86_64 hello.img
