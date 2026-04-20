 ;explorador-graficos.asm (2024-01-30 15:15:25)
 ;Programa para explorar por pantalla los gráficos cargados en RAM
 ;
 ;  Copyright (C) 2024 Conrado Badenas <conbamen@gmail.com>
 ;
 ;  This program is free software: you can redistribute it and/or modify
 ;  it under the terms of the GNU General Public License as published by
 ;  the Free Software Foundation, either version 3 of the License, or
 ;  (at your option) any later version.
 ;
 ;  This program is distributed in the hope that it will be useful,
 ;  but WITHOUT ANY WARRANTY; without even the implied warranty of
 ;  MERCHANTABILITY or FITNESS FOR A PARTICULARPURPOSE.  See the
 ;  GNU General Public License for more details.
 ;
 ;  You should have received a copy of the GNU General Public License
 ;  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ;
 ;FIN DEL TEXTO SUGERIDO EN https://www.gnu.org/licenses/gpl-howto.html

; La licencia GNU GPLv3 restringe el uso de este fichero de código fuente (.asm) de ciertas formas,
; pero no restringe de ninguna forma el uso y productos derivados del código objeto (.bin).
; Usted puede hacer lo que quiera con explorador-graficos.bin (576 bytes)

; Sugerencia de compilación para obtener el código objeto:
; pasmo -d --alocal explorador-graficos.asm explorador-graficos.bin > explorador-graficos.log

        ORG 16384;      = inicio del 1er tercio de pantalla
BEGIN   di
        ld a,7
        ld hl,0x2000
        ld (VEN_cm),hl; cm = 0, cols = 0x20 = 32
        ld hl,22528;    HL = inicio de los atributos
        ld de,22529
        ld (hl),a
        ld bc,767
        ldir;           HL=23295, DE=23296
        and %00111000
        rra
        rra
        rra
        out (254),a
;        ld a,255
;        ex af,af';      A' = %11111111 (ninguna tecla pulsada)
        inc hl

_BUCLE  ld (VENTANA),hl
        exx
        call VENTPAN
        exx
        push hl
        call PRINTHL
        ld a,-15;       espacio
        call PRINTA
        ld hl,(VEN_cs)
        ld h,0
        call PRINT00
        pop hl

_TECLAS ld bc,0xfefe;   ...VCXZcaps
        in a,(c)
        rra;            caps
        rl d
        ld bc,0x7ffe;   ...BNMsymbolspace
        in a,(c)
        rra;            space
        rl d
        rra;            symbol
        rl d
        ld bc,0xfbfe;   ...TREWQ
        in a,(c)
        rra;            Q
        rl e
        rra;            W
        rl e
        ld bc,0xfdfe;   ...GFDSA
        in a,(c)
        rra;            A
        rl e
        rra;            S
        rl e
        ld bc,0xdffe;   ...YUIOP
        in a,(c)
        rra;            P
        rl e
        rra;            O
        rl e
        ld bc,0xbffe;   ...HJKLenter
        in a,(c)
        rra;            enter
        rra;            L
        rl e
        rra;            K
        rl e;           este valor de E se usa para muchas cosas

        ld b,0;         B = 0 en general
        ld a,d;         D tiene la sí/no pulsación de 3 teclas
        cpl
        and %00000111;  A = 0 sii las 3 teclas no están pulsadas
        jr z,_ETIQUE
        dec b;          B = 255 sii alguna tecla especial pulsada
_ETIQUE ex af,af';      A' tiene el valor de antes
        ld d,a;         DE = teclas, D = antes, E = ahora
        ld a,e;         QWASPOLK
        or b;           olvidamos QWASPOLK si alguna tecla especial pulsada
;        or %10100000;   la próxima vez pensaremos que Q,A no estaban pulsadas
        ex af,af';      A' pasa a tener el valor de ahora (+QA no pulsadas)
        ld a,e;         bit = 0 (pulsada), 1 (no pulsada)
        cpl;            bit = 1 (pulsada), 0 (no pulsada)
        and d;          D = A' de antes (no de ahora)
        ld d,a;         bit = 1 (pulsada ahora y no pulsada antes)
        ld a,e
        cp 255
        jr z,_TECLAS;   volvemos a leer teclas si no había NINGUNA pulsada

        bit 7,d;        Q
        call nz,_ARRIBA
        bit 5,d;        A
        call nz,_ABAJO
        bit 6,d;        W
        call nz,_1ARRIB
        bit 4,d;        S
        call nz,_1ABAJO
        bit 2,d;        O
        call nz,_IZQUIE
        bit 3,d;        P
        call nz,_DERECH
        bit 0,d;        K
        call nz,_1IZQUI
        bit 1,d;        L
        call nz,_1DEREC
        jp _BUCLE

_ARRIBA ld a,(VEN_cs);  cs = 32,31,...,1
        add a,a
        add a,a;        = 128,124,...,4
        add a,a;        = 256,248,...,8
        ld c,a;         = 0,248,...,8
        ld a,0
        adc a,a;        = 1,0,...,0
        ld b,a;         BC = 8*cs
        add hl,bc;      HL = HL + 8*cs
        ret
_ABAJO  ld a,(VEN_cs);  cs = 32,31,...,1
        add a,a
        add a,a;        = 128,124,...,4
        add a,a;        = 256,248,...,8
        ld c,a;         = 0,248,...,8
        ld a,0
        adc a,a;        = 1,0,...,0
        ld b,a;         BC = 8*cs
        sbc hl,bc;      HL = HL - 8*cs (CF=0 por el ADC de antes)
        ret
_1ARRIB ld a,(VEN_cs);  cs = 32,31,...,1
        ld c,a
        xor a
        ld b,a
        add hl,bc
        ret
_1ABAJO ld a,(VEN_cs);  cs = 32,31,...,1
        ld c,a
        xor a
        ld b,a
        sbc hl,bc;      (CF=0 por el XOR de antes)
        ret
_IZQUIE ld a,(VEN_cs);  cs = 32,...,2,1
        dec a
        ret z
        ld (VEN_cm),a;  cm = 31,...,1
        ld c,a
        ld a,1
        ld (VEN_cs),a
        exx
        ld hl,CEROS
        ld (VENTANA),hl
        call VENTPAN
        exx
        ld a,c
        ld (VEN_cs),a;  cs = 31,...,1
        xor a
        ld (VEN_cm),a;  cm = 0
        ret
_DERECH ld a,(VEN_cs);  cs = 32,31,...,1
        cp 32
        ret z
        inc a
        ld (VEN_cs),a;  cs = 32,...,2
        ret
_1IZQUI inc hl
        ret
_1DEREC dec hl
        ret

;ym=64
;ys=168
; Esta rutina transfiere el contenido de VENTANA a PANTALLA
VENTPAN ld bc,(VEN_ym); C=ym, B=ys
        ld hl,(VEN_cm); L=cm, H=cs
        ld a,c;         A = %xxyyyzzz = ym = L0
        rrca
        rrca
        rrca
        and %00011000;  A = %000xx000
        or  %01000000;  A = %010xx000
        ld d,a
        ld a,c;         A = %xxyyyzzz = ym = L0
        and %00000111;  A = %00000zzz
        or d;           A = %010xxzzz
        ld d,a;         xx=00(1er tercio),01(2do),10(3er), zzz=L0mod8
        ld a,c;         A = %xxyyyzzz = ym = L0
        rlca
        rlca
        and %11100000;  A = %yyy00000
        or l;           columna inicial C0
        ld e,a; E = %yyyccccc, yyy=0-7(línea/8 MOD 8), ccccc=0-31(columna)

        ld a,h
        ld (_NUEVAL+1),a
        ld (_SUB0+1),a
        ld hl,(VENTANA)
        ld ixh,b
        ld b,0
_NUEVAL ld c,0;         BC = cols
        ldir;           21 T-estados/Byte
        ld a,e
_SUB0   sub 0;          sub cols
        ld e,a
        ccf
        ld a,d
        adc a,0
        ld d,a
        and %00000111
        jr z,_NUEVAF;   salta a _NUEVAF 1 de cada 8 veces
        dec ixh
        jp nz,_NUEVAL
        ret
_NUEVAF ld a,e
        add a,32
        ld e,a
        jr c,_NUEVOT
        ld a,d
        sub 8
        ld d,a
_NUEVOT dec ixh
        jp nz,_NUEVAL
        ret

; Definimos una ventana dando valores a estos parámetros:
VENTANA defw 0;         aquí se guarda la dirección de memoria de la ventana
VEN_cm  defb 0;         columna izquierda (mínima) de la ventana
VEN_cs  defb 0;         columnas de la ventana
VEN_ym  defb 64;        línea superior (mínima) de la ventana
VEN_ys  defb 128;       líneas de la ventana

PRINTHL ld de,16384+2*256+7*32
        xor a;  A=0, CF=0
        ld bc,10000
_BUCLE1 sbc hl,bc
        inc a
        jr nc,_BUCLE1; salta si HL era >= 10000
        add hl,bc; ahora HL<10000 (HL<=9999)
        call PRINTA
        xor a;  A=0, CF=0
        ld bc,1000
_BUCLE2 sbc hl,bc
        inc a
        jr nc,_BUCLE2; salta si HL era >= 1000
        add hl,bc; ahora HL<1000 (HL<=999)
        call PRINTA
        xor a;  A=0, CF=0
        ld bc,100
_BUCLE3 sbc hl,bc
        inc a
        jr nc,_BUCLE3; salta si HL era >= 100
        add hl,bc; ahora HL<100 (HL<=99)
        call PRINTA
PRINT00 xor a;  A=0, CF=0
        ld bc,10
_BUCLE4 sbc hl,bc
        inc a
        jr nc,_BUCLE4; salta si HL era >= 10
        add hl,bc; ahora HL<10 (HL<=9)
        call PRINTA
        ld a,l; 0<=L<=9
        inc a;  1<=A<=10
        call PRINTA
        ret

PRINTA  push hl;        A = 1,2,3,...,10
        add a,a
        add a,a
        add a,a;        A = 8,16,...,80
        ld hl,0x3d79;   HL = 15737
        add a,l
        ld l,a;         HL = 15745,...,15817
        ld c,d
        ld b,6
_BUCLE0 ld a,(hl)
;        rrca
;        or (hl)
        ld (de),a
        inc hl
        inc d
        djnz _BUCLE0
        ld d,c
        inc e
        pop hl
        ret

CEROS   defs 128;       128 ceros

END     BEGIN

