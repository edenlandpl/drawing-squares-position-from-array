format MZ
stack stk:256
entry codseg:main
VideoB_Seg EQU 0A000h; Okrelenie segmentu buforu Video
;------------------ Segment danych ---------------------------
segment sdat use16
yg dw 100
xk dw 200
kol db 01h
tablica db 100, 105, 90
tablicaKolorow db 02h, 04h, 01h
iteracja db 0
;--------------- Koniec segmentu danych ***
;----------------- Segment stosu -----------------------------
segment stk use16
db 256 dup (?)
;----------------- Koniec segmentu stosu
;----------------- Segment programu -------------------------
segment codseg use16
main: push ds
push bx
mov bx,sdat
mov ds,bx
; Wywoanie funkcji BIOS'u w celu zmiany trybu pracy monitora na graficzny
mov ah,0
mov al,10h; Tryb 640 X 350 ilo kolorw 16
int 10h

mov cx, 4
petlazew1:
push cx

call BB

push bx 		       ; reset i zapamietanie wcze�niejszych informacji na rejestrach
xor bx, bx
push dx
xor dx, dx

mov dl, [iteracja]		;przeniesienie wartosci iteracji do rejestru
add bl, [tablica+edx]		; dodajemy do adresu tablicy iteracje, kolejna wartosc z tabeli [edx to wieksza czesc dl ]
add [xk], bx			; przenosimy nowa wartosc do xk

xor bx, bx
add bl, [tablicaKolorow+edx]
mov  [kol],bl

inc [iteracja]			; zwiekszamy wartosc iteracji o 1
pop dx
pop bx

pop cx
loop petlazew1

pop bx
pop ds
mov ah,1
int 21h
mov ax,0003h
int 10h
mov ah,1
int 21h
mov ax,4c00h
int 21h
ret
AA:
push bp ; Zachowanie wartoci rejestru BP na stosie
; określenie wsprzdnych pixel'a i obliczenie jego adresu
mov ax,[yg]; okrelenie wsprzdnej Y pixel'a (w dół)
mov bx,[xk]; okrelenie wsplrzdnej X pixel'a (w bok)
mov cl,bl ; mniej znaczcy bajt wsprzdnej X do BX
push dx
mov dx,80; wprowadznie do DX iloci blokw pixel'i w jednej linii
mul dx; (dx,ax)<-dx*ax
;przesunicie o AX 1-go bloku potrzebnej linii o wsprzdnej Y
pop dx
shr bx,1;
shr bx,1;
shr bx,1; przesunicie BX o trzy pozycje w prawo
add bx,ax; w BX znajduje si przesunicie bloku,
; który zawiera potrzebny pixel
mov ax,VideoB_Seg; adowanie do AX adresu segmentu buforu Video
mov es,ax; rejestr ES bdzie zawiera adres segmentu buforu Video
and cl,7 ; wyodrbnienie numeru pixel'a w bloku
xor cl,7 ; inwersja bitu
mov ah,1 ; przygotowanie maski bitu
shl ah,cl; przesunicie maski na odpowiedni pozycj
; mov ah,0FFh
; obsuga rejestrw kontrolera graficznego
mov dx,3CEh; zadanie adresu portu kontrolera graficznego
mov al,8 ; okrelenie numeru rejestru bitowej maski
out dx,ax ; zmiana rejestru maski bitowej
mov ax,0005h;
out dx,ax ; zadanie wartoci rejestru trybu
mov ah,0 ;
mov al,3 ;
out dx,ax ; zadanie wartoci rejestru cyklicznego przesunicia
;mov ax,0D00h;
mov al,00h
mov ah,[kol]  ;kolor
out dx,ax ; zadanie wartoci rejestru ustawi/resetowa
mov ax,0F01h;
out dx,ax ; zadanie wartoci rejestru ustawi/resetowa
; zmiana wartoci pixel'a

mov cx,51
or [es:bx],al;
pop bp
ret

BB:

push [xk]
mov cx, 50
petla1:
	push cx
	push [yg]
		petla2:
			push cx
			call AA
			inc [yg]
			pop cx
		loop petla2
	inc [xk]
	pop [yg]
	pop cx
loop petla1
pop [xk]

push [xk]
mov cx, 50
petla3:
	push cx
	push [yg]
		petla4:
			push cx
			call AA
			inc [yg]
			pop cx
		loop petla4
	dec [xk]
	pop [yg]
	pop cx
loop petla3
pop [xk]

mov [yg], 100
push [xk]
mov cx, 50
petla5:
	push cx
	push [yg]
		petla6:
			push cx
			call AA
			dec [yg]
			pop cx
		loop petla6
	inc [xk]
	pop [yg]
	pop cx
loop petla5
pop [xk]

mov [yg], 100
push [xk]
mov cx, 50
petla7:
	push cx
	push [yg]
		petla8:
			push cx
			call AA
			dec [yg]
			pop cx
		loop petla8
	dec [xk]
	pop [yg]
	pop cx
loop petla7
pop [xk]
ret