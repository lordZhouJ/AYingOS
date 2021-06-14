; AYing.OS-ipl
; TAB=4

		CYLS	EQU		10				; 相当于C语言的#define
		ORG		0x7c00			



		JMP		entry
		DB		0x90
		DB		"AYing.OS"			;这里必须要8个字节	
		DW		512				
		DB		1				
		DW		1				
		DB		2				
		DW		224				
		DW		2880			
		DB		0xf0			
		DW		9				
		DW		18				
		DW		2				
		DD		0				
		DD		2880			
		DB		0,0,0x29		
		DD		0xffffffff		
		DB		"AYing.OS "	
		DB		"FAT12   "		
		RESB	18				



entry:
		MOV		AX,0			
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX				;DS:数据段寄存器	这里的实际的意思是  MOV DS,[DS:AX];一般预先给DS赋值0


;下面这里就是一个整个读写磁盘的函数(C0-H0-S1  柱面0，磁头0，扇区1的缩写)
		MOV		AX,0x0820			;累加寄存器 相当于AX=0x0820
		MOV		ES,AX				;ES附加段寄存器
		MOV		CH,0				;柱面号(这里是0)&0xff		
		MOV		DH,0				;磁头号	
		MOV		CL,2				;扇区号(这里是2---0到5位)|(柱面号&0x300)>>2		
readloop:
		MOV		SI,0			
retry:
		MOV		AH,0x02				;AH = 0x02读盘;AH=0x03写盘;0x04校验;0xc寻道；	
		MOV		AL,1				;1个扇区(等于处理对象的扇区数---只能同处理连续的扇区)		
		MOV		BX,0
		MOV		DL,0x00				;驱动器号	
		INT		0x13				;调用磁盘BIOS
		JNC		next					;JNC : 跳转指令,如果进位标志是0的话，就跳转			
		ADD		SI,1			
		CMP		SI,5			
		JAE		error				;JAE：大于等于0的时候跳转			
		MOV		AH,0x00
		MOV		DL,0x00			
		INT		0x13			
		JMP		retry
next:
		MOV		AX,ES			
		ADD		AX,0x0020
		MOV		ES,AX				; 因为没有ADD ES,0x020 指令，所以这里绕个弯
		ADD		CL,1				; CL+1 下一个扇区
		CMP		CL,18				; CL与18比較
		JBE		readloop			; CL <= 18 则跳转到readloop
		MOV		CL,1	
		ADD		DH,1	
		CMP		DH,2	
		JB		readloop			; DH < 2 则跳转到readloop
		MOV		DH,0	
		ADD		CH,1	
		CMP		CH,CYLS	
		JB		readloop			; CH < CYLS 则跳转到readloop  JB：如果小于的话就跳转


		MOV		[0x0ff0],CH		; IPLがどこまで読んだのかをメモ
		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			
		MOV		BX,15			
		INT		0x10			
		JMP		putloop
fin:
		HLT						; 何かあるまでCPUを停止させる
		JMP		fin				; 無限ループ
msg:
		DB		0x0a, 0x0a		
		DB		"load error"
		DB		0x0a			
		DB		0

		RESB	0x7dfe-$		

		DB		0x55, 0xaa
