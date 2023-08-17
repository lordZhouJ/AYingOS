rm hello.img
nasm ipl.asm -o hello.img
qemu-system-x86_64 hello.img
