; AYing.OS-ipl
; TAB=4

		CYLS	EQU		10				; �൱��C���Ե�#define
		ORG		0x7c00			



		JMP		entry
		DB		0x90
		DB		"AYing.OS"			;�������Ҫ8���ֽ�	
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
		MOV		DS,AX				;DS:���ݶμĴ���	�����ʵ�ʵ���˼��  MOV DS,[DS:AX];һ��Ԥ�ȸ�DS��ֵ0


;�����������һ��������д���̵ĺ���(C0-H0-S1  ����0����ͷ0������1����д)
		MOV		AX,0x0820			;�ۼӼĴ��� �൱��AX=0x0820
		MOV		ES,AX				;ES���ӶμĴ���
		MOV		CH,0				;�����(������0)&0xff		
		MOV		DH,0				;��ͷ��	
		MOV		CL,2				;������(������2---0��5λ)|(�����&0x300)>>2		
readloop:
		MOV		SI,0			
retry:
		MOV		AH,0x02				;AH = 0x02����;AH=0x03д��;0x04У��;0xcѰ����	
		MOV		AL,1				;1������(���ڴ�������������---ֻ��ͬ��������������)		
		MOV		BX,0
		MOV		DL,0x00				;��������	
		INT		0x13				;���ô���BIOS
		JNC		next					;JNC : ��תָ��,�����λ��־��0�Ļ�������ת			
		ADD		SI,1			
		CMP		SI,5			
		JAE		error				;JAE�����ڵ���0��ʱ����ת			
		MOV		AH,0x00
		MOV		DL,0x00			
		INT		0x13			
		JMP		retry
next:
		MOV		AX,ES			
		ADD		AX,0x0020
		MOV		ES,AX				; ��Ϊû��ADD ES,0x020 ָ����������Ƹ���
		ADD		CL,1				; CL+1 ��һ������
		CMP		CL,18				; CL��18���^
		JBE		readloop			; CL <= 18 ����ת��readloop
		MOV		CL,1	
		ADD		DH,1	
		CMP		DH,2	
		JB		readloop			; DH < 2 ����ת��readloop
		MOV		DH,0	
		ADD		CH,1	
		CMP		CH,CYLS	
		JB		readloop			; CH < CYLS ����ת��readloop  JB�����С�ڵĻ�����ת


		MOV		[0x0ff0],CH		; IPL���ɤ��ޤ��i����Τ�����
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
		HLT						; �Τ�����ޤ�CPU��ֹͣ������
		JMP		fin				; �o�ޥ�`��
msg:
		DB		0x0a, 0x0a		
		DB		"load error"
		DB		0x0a			
		DB		0

		RESB	0x7dfe-$		

		DB		0x55, 0xaa
