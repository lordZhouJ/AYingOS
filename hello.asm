; hello-os
; TAB=4

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
putloop:
                MOV             AL,[SI]
                ADD             SI,1                    ; 给SI加1
                CMP             AL,0
                JE              fin
                MOV             AH,0x0e                 ; 显示一个文字
                MOV             BX,15                   ; 制定字符颜色
                INT             0x10                    ; 调用显卡BIOS
                JMP             putloop
fin:
                HLT                                             ; 让CPU停止，等待指令
                JMP             fin                             ; 无限循环

msg:
                DB              0x0a, 0x0a              ; 换行两次
                DB              "hello, world"
                DB              0x0a                    ; 换行
                DB              0


                RESB    0x1fe-($-$$)    ;RESB 0x1fe-(− -−$)             ;RESB   0x1fe-$                 ; 0x001feまでを0x00で埋める命令

                DB              0x55, 0xaa