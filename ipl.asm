; hello-os
; TAB=4
CYLS	EQU		10				; �ǂ��܂œǂݍ��ނ�

        ORG             0x7c00                  ; 程序装载的位置
;以下的记述用于标准FAT12格式的软盘
        JMP             entry
        DB              0x90


        ;DB             0xeb, 0x4e, 0x90
        DB              "HELLOIPL"              ; ブートセクタの名前を自由に書いてよい（8バイト）
        DW              512                             ; 1セクタの大きさ（512にしなければいけない）
        DB              1                               ; クラスタの大きさ（1セクタにしなければいけない）
        DW              1                               ; FATがどこから始まるか（普通は1セクタ目からにする）
        DB              2                               ; FATの個数（2にしなければいけない）
        DW              224                             ; ルートディレクトリ領域の大きさ（普通は224エントリにする）
        DW              2880                    ; このドライブの大きさ（2880セクタにしなければいけない）
        DB              0xf0                    ; メディアのタイプ（0xf0にしなければいけない）
        DW              9                               ; FAT領域の長さ（9セクタにしなければいけない）
        DW              18                              ; 1トラックにいくつのセクタがあるか（18にしなければいけない）
        DW              2                               ; ヘッドの数（2にしなければいけない）
        DD              0                               ; パーティションを使ってないのでここは必ず0
        DD              2880                    ; このドライブ大きさをもう一度書く
        DB              0,0,0x29                ; よくわからないけどこの値にしておくといいらしい
        DD              0xffffffff              ; たぶんボリュームシリアル番号
        DB              "HELLO-OS   "   ; ディスクの名前（11バイト）
        DB              "FAT12   "              ; フォーマットの名前（8バイト）
        RESB    18                              ; とりあえず18バイトあけておく

entry:
        MOV             AX,0                    ; 初始化寄存器
        MOV             SS,AX
        MOV             SP,0x7c00
        MOV             DS,AX
        MOV             ES,AX

        MOV             SI,msg
; 读磁盘
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2
readloop:
        MOV     SI,0            ; 记录失败次数的寄存器
retry:
		MOV		AH,0x02			; AH=0x02 读入磁盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器

		INT		0x13			; 调用磁盘BIOS


		JNC		fin				; 没出错的话，跳转到fin
		ADD		SI,1			; 往SI加1
		CMP		SI,5			; 比较SI与5
		JAE		error			; SI >= 5 条转到error
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JMP		retry

next:
		MOV		AX,ES			; 把内存地址后移0x200
		ADD		AX,0x0020
		MOV		ES,AX			; 因为没有ADD ES,0x020指令，所以这里稍微绕个弯
		ADD		CL,1			; 往CL里加1
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; 如果CL <= 18 则跳转到readloop

        MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 如果DH < 2 ，则跳转到readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; 如果CH < CYLS 责跳转到readloop

fin:
        HLT                                             ; 让CPU停止，等待指令
        JMP             fin                             ; 无限循环

error:
		MOV		SI,msg


putloop:
        MOV             AL,[SI]
        ADD             SI,1                    ; 给SI加1
        CMP             AL,0
        JE              fin
        MOV             AH,0x0e                 ; 显示一个文字
        MOV             BX,15                   ; 制定字符颜色
        INT             0x10                    ; 调用显卡BIOS
        JMP             putloop

msg:
        DB              0x0a, 0x0a              ; 换行两次
        DB              "hello, world"
        DB              0x0a                    ; 换行
        DB              0


        RESB    0x1fe-($-$$)    ;RESB 0x1fe-(− -−$)             ;RESB   0x1fe-$                 ; 0x001feまでを0x00で埋める命令

        DB              0x55, 0xaa