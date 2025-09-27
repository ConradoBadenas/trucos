 ;sound3.asm (make a sound of any audible frequency)
 ;Date: 10:55:41 UTC 25 September 2025
 ;
 ;  Copyright (C) 2025 Conrado Badenas <conbamen@gmail.com>
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

; compílese con Pasmo:
; pasmo -d sound3.asm sound3.bin > sound3.log
; pasmo -d --tapbas sound3.asm sound3.tap

INICIO ORG 65280
       di           ;que las interrupciones no interrumpan
       ld a,($5C48)
       rrca
       rrca
       rrca
       and %00000111;color del borde
       or  %00011000;speaker on, MIC off
       ld bc,6      ;Este número es CONSTANTE, para TODOS los sonidos
LDHL   ld hl,497    ;LA3 = 220Hz, 3.500.000/220 = 15909 TS un ciclo
                    ;medio ciclo = 7954,5 TS = 497,2 veces 16TS
LDDE   ld de,1000   ;1000 semiciclos = 500 ciclos / 220Hz = 2,27 segundos
       sbc hl,bc    ;HL = HighLow = (TS de semiciclo)/16 - 6
       inc h        ;m  = 1+High
       inc l        ;n0 = 1+Low

                    ;Cuenta de TSs:
LOOP1  out (254),a  ;11 impar pero imprescindible
       ld b,h       ; 4     m
       ld c,l       ; 4     n0 (n inicial)
LOOP2  dec c        ; m*  4*n
       jr nz,LOOP2  ; m*(12*n - 5)
                    ;       m*(4*n + 12*n - 5) = m*16*n + m*(-5)
       ld c,255     ; m* 7  7 y -5 son impares pero se compensan
       dec b        ; m* 4
       jp nz,LOOP2  ; m*10  a partir de ahora, n = 255
                    ;       n=255 (m-1)veces, n=n0 1vez
; suma con m y n: m*16*n + m*(-5) + m*(7+4+10) = m*16*n + m*16 =
; [n=255 en m-1, n=n0 en 1] = (m-1)*16*255 + 1*16*n0 + m*16 =
; = 16*( (m-1)*255 + n0 + m-1+1 ) = 16*( 1+n0 +256*(m-1) )

       xor $10      ; 7 impar para compensar el impar de OUT(254),A
       inc bc       ; 6 (relleno de TSs para tener múltiplo de 16)
       ld c,a       ; 4 para contar DE
       dec de       ; 6 para contar DE
       ld a,d       ; 4 para contar DE
       or e         ; 4 para contar DE
       ld a,c       ; 4 para contar DE
       jp nz,LOOP1  ;10     11+4+4+7+6+4+6+4+4+4+10 = 64 = 16*4
; suma TOTAL = 16*( 4+1+n0 +256*(m-1) ) = 16*( 6+(n0-1) +256*(m-1) )
; TOTAL/16 - 6 = (n0-1) +256*(m-1) es claramente un número de 16 bits
; que se mete en un registro de 16 bits, con High = m-1 y Low = n0-1.
;
; ¿Por qué m-1? ¡Es evidente! ¡Porque así sale en la fórmula!
; Además, m=0 es un caso patológico (JP NZ,LOOP1 256 veces), por lo que
; se necesita m>=1, con lo que m-1 (que es >=0) puede variar de 0 a 255.
;
; ¿Por qué n0-1? Si n0=0 entonces LOOP2 se ejecutaría inicialmente 256 veces,
; y las cuentas estarían mal, por lo que es necesario que n0>=1,
; y entonces n0-1 (que es >=0) puede variar libremente de 0 a 255.
; Si n0-1=255, entonces LOOP2 se ejecuta inicialmente 256 veces (correcto).
;
; Ergo, si TOTAL/16 se mete en un registro de 16bits, y se le resta 6,
; el resultado es High=m-1, Low=n0-1, por lo que m=1+High, n0=1+Low.
; Es decir, HL = (TOTAL/16) - 6, m = INC H, n0 = INC L.

       ei           ;para volver al Basic
       ret
END INICIO

; Otros valores de TOTAL/16 (número que se mete en HL):
;Nota Freq(Hz) HL  Freq(Hz) error(cents de semitono)
; A3   220,00  497  220,07   0,6
; B3   246,94  443  246,90  -0,3
; C4   261,63  418  261,66   0,2
; D4   293,66  372  294,02   2,1
; E4   329,63  332  329,44  -1,0
; F4   349,23  313  349,44   1,1
; G4   392,00  279  392,03   0,1
; A4   440,00  249  439,26  -2,9
; B4   493,88  221  494,91   3,6
; C5   523,25  209  523,33   0,2
;       20    5469   20,00  -0,1
;       40    2734   40,01   0,2
;       80    1367   80,01   0,2
;      160     684  159,90  -1,0
;      320     342  319,81  -1,0
;      640     171  639,62  -1,0
;     1280      85 1286,76   9,1
;     2560      43 2543,60 -11,1
;     5120      21 5208,33  29,6
;    10240      11         -50,9
;    20480       5         114,1
;Si usted cambia el valor de HL (p.e., POKEando en 65295 y 65296),
;recuerde cambiar también el valor de DE (p.e., POKEando en 65298,65299).

