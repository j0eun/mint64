[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07c0:START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MINT64 OS에 관련된 환경 설정 값
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TOTALSECTORCOUNT: dw 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 코드 영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	mov ax, 0x07c0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x0000
	mov ss, ax
	mov sp, 0xfffe
	mov bp, 0xfffe

	; 화면을 모두 지우고 속성값을 녹색으로 변경
	mov si, 0

.SCREENCLEARLOOP:
	mov byte [es:si], 0
	mov byte [es:si+1], 0x0a

	add si, 2

	cmp si, 80*25*2

	jl .SCREENCLEARLOOP

	; 화면 상단에 메시지 출력
	push MESSAGE1
	push 0
	push 0
	call PRINTMESSAGE
	add sp, 6

	push IMAGELOADINGMESSAGE
	push 1
	push 0
	call PRINTMESSAGE
	add sp, 6

	; 디스크에서 OS 이미지 로딩
	; pass

	; 디스크를 읽기 전에 먼저 리셋
RESETDISK:	; 디스크 리셋 코드 시작
	mov ax, 0
	mov dl, 0	; 서비스 번호(0), 플로피 디스크(0)
	int 0x13	; Low Level Disk Service 호출
	jc HANDLEDISKERROR	; 에러 발생 시 예외 처리

	; 디스크에서 섹터 읽음
	mov si, 0x1000
	mov es, si
	mov bx, 0x0000

	mov di, word [TOTALSECTORCOUNT]
	
READDATA:
	cmp di, 0	; 모든 섹터를 다 읽었는지 확인
	je READEND
	sub di, 1

	mov ah, 2
	mov al, 1
	mov ch, byte [TRACKNUMBER]
	mov cl, byte [SECTORNUMBER]
	mov dh, byte [HEADNUMBER]
	mov dl, 0
	int 0x13
	jc HANDLEDISKERROR

	add si, 0x0020
	mov es, si

	mov al, byte [SECTORNUMBER]
	add al, 1
	mov byte [SECTORNUMBER], al
	; 예제 코드에선 섹터 개수가 18개라고 소개되었지만, QEMU 버전이 업그레이드되면서 
	; 에뮬레이터의 플로피 디스크가 1.44MB FD에서 2.88MB FD로 변경 됨.
	; 따라서 트랙 당 섹터의 개수가 18개에서 36개로 증가했으므로 그에 따라 수정.
	cmp al, 37
	jl READDATA

	xor byte [HEADNUMBER], 1
	mov byte [SECTORNUMBER], 1

	cmp byte [HEADNUMBER], 0
	jne READDATA

	add byte [TRACKNUMBER], 1
	jmp READDATA
READEND:
	push LOADINGCOMPLETEMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	add sp, 6

	jmp 0x1000:0x0000	; 로딩한 가상 이미지 실행

HANDLEDISKERROR:
	push DISKERRORMESSAGE
	push 1
	push 20
	call PRINTMESSAGE

	jmp $	; 현재 위치에서 무한 루프

PRINTMESSAGE:
	push bp
	mov bp, sp

	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xb800
	mov es, ax

	mov ax, word [bp+6]
	mov si, 160
	mul si
	mov di, ax

	mov ax, word [bp+4]
	mov si, 2
	mul si
	add di, ax

	mov si, word [bp+8]
	
.MESSAGELOOP:
	mov cl, byte [si]

	cmp cl, 0
	je .MESSAGEEND

	mov byte [es:di], cl

	add si, 1
	add di, 2

	jmp .MESSAGELOOP

.MESSAGEEND:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

MESSAGE1:				db 'MINT64 OS Boot Loader Start~!!',0
DISKERRORMESSAGE:		db 'DISK ERROR~!!',0
IMAGELOADINGMESSAGE:	db 'OS Image Loading...',0
LOADINGCOMPLETEMESSAGE:	db 'Complete~!!',0

SECTORNUMBER:	db 0x02
HEADNUMBER:		db 0x00
TRACKNUMBER:	db 0x00

times 510 - ($ - $$) db 0x00
db 0x55
db 0xaa

