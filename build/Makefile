
asm1:
	..\public_tools\nask.exe 		../source/ipl.nas 		../output/ipl.bin 		../output/ipl.lst
	
asm2:	
	..\public_tools\nask.exe		../source/haribote.nas 	../output/haribote.bin 	../output/haribote.lst





img:	
	..\public_tools\edimg.exe   \
				imgin:../public_tools/fdimg0at.tek   \
				wbinimg src:../output/ipl.bin len:512 from:0 to:0  \
				copy from:../output/haribote.sys to:@:  \
				imgout:../output/AYingOS.img







run:
	copy ..\output\AYingOS.img ..\public_tools\qemu\fdimage0.bin	
	..\public_tools\make.exe -C ../public_tools/qemu

