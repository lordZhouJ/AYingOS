# AYingOS

第二天
; hello-os
; TAB=4

		ORG		0x7c00			;告诉nask，在开始执行时，把这些机器语言指令装载到内存那个地址。（另外有了这条指令，美元符$:他不在是输出文件的第几个字节而是代表要读入的内存地址）
								;启动区内容的装载地址0x7c00-0x00007dff

;一下的记述用于标注FAT12格式的软盘
		JMP		entry
		DB		0x90

;核心部分
		DB		"AYing-OS-IPL"			; 启动区的名称可以是任意的字符串（8字节）
		DW		512						; ?个扇区（sector）的大小（必??512字?）
		DB		1						; 簇（cluster）的大小（必??1个扇区）
		DW		1				    	; FAT的起始位置（一般从第一个扇区?始）
		DB		2				    	; FAT的个数（必??2）
		DW		224				    	; 根目?的大小（一般?成224?）
		DW		2880					; 该磁盘大小（必须是2880扇区）
		DB		0xf0					; 磁盘种类（必须是0xf0）
		DW		9				    	; FAT的?度（必?是9扇区）
		DW		18				    	; 1个磁道（track）有几个扇区（必须是18）
		DW		2				    	; 磁头数（必须是2）
		DD		0				    	; 不使用分区，必须是0
		DD		2880			    	    ; 重写一次磁盘大小
		DB		0,0,0x29			    ; 意义不明，固定
		DD		0xffffffff			    ;（可能是）卷标号码                              	                            
		DB		"AYing-OS   "	; ディスクの名前（11バイト）
		DB		"FAT12	"				    ; 磁盘格式名称（8字?）
		RESB	18				    	; 先空出18字节

; 程序主体

entry:
		MOV		AX,0					; 初始化寄存器（可以理解为copy指令）;AX（累加寄存器）、SI（源变址寄存器）、SS（栈段寄存器）。
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg					;SI = msg
putloop:
		MOV		AL,[SI]					;[]表示内存地址，传递给AL； AL：累加寄存器低位。
										;MOV BYTE [678],123 将地址为678的位赋值123。其中，BYTE是8位，WORD16位
										;MOV AL， BYTE [SI]  将SI地址的一个字节写入到AL
		ADD		SI,1					; 给SI＋1  C语言的SI=SI+1
		CMP		AL,0
		JE		fin						;这里是比较指令，如果上面AL==0；那么这里就跳转到fin位置
		MOV		AH,0x0e					; 显示一个文字;这里是BIOS手册里面看到的，原著中提供的BIOS手册，并不能看到。（后期需要在这里填补下知识空白
		MOV		BX,15					; 制定字符颜色
		INT		0x10					; 调用显卡BIOS （不同的数字代表不同的调用不同的函数，这里调用0x10函数，他的功能时候控制显卡。）;好了，到这里位置是调用显卡。坐着说着这里不知道为什么不显示白色，粗虐的来看是AL没有赋值，（猜测，不一定对）
		JMP		putloop
fin:
		HLT								; 让CPU停止，等待指令。进入待机状态（这里作者说全世界估计只有他在使用，现在来看不是，我在公司看到的单片机用到的不少啊）
		JMP		fin						; 无线循环

msg:
		DB		0x0a, 0x0a				; 换行两次
		DB		"AYingOS"
		DB		0x0a					; 换行
		DB		0

		RESB	0x7dfe-$				; 填写0x00直到0x7dfe；之前是到0x1fe-$	

		DB		0x55, 0xaa
