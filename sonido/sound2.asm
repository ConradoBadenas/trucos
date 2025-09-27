 ;sound2.asm (make a sound of frequency larger than 523 Hz)
 ;Date: 09:01:46 UTC 25 September 2025
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
; pasmo -d sound2.asm sound2.bin > sound2.log
; pasmo -d --tapbas sound2.asm sound2.tap

INICIO ORG 65280
       di           ;que las interrupciones no interrumpan
       ld a,($5C48)
       rrca
       rrca
       rrca
       and %00000111;color del borde
       or  %00011000;speaker on, MIC off
       ld c,$10     ;cambiar speaker
       ld d,255
LOOP1  out (254),a  ;11 TS
       ld b,d       ; 4 TS
LOOP2  djnz LOOP2   ;13*N-5 TS
       xor c        ; 4 TS
       jr LOOP1     ;12 TS
END    INICIO       ;suma = 26 + 13*N = 13*(N+2)

; Con N+2=257 (D=255), cada LOOP1 se ejecuta en 3341 TS
; Son 3341 con bit4=1 y 3341 con bit4=0 (total = 6682 TS).
; En 1 segundo (3.500.000 TS), se ejecutan 3.500.000/6682 =
; = 523,80 ciclos completos, es decir, se genera una onda cuadrada
; de 523,80 Hz, casi igual a un C5 (= 523,25 Hz).

; Otros valores de N+2 para una escala de DO mayor a partir de C5:
;Nota Freq(Hz) N+2 Freq(Hz) error(cents de semitono)
; C5   523,25  257  523,80   1,8
; D5   587,33  229  587,84   1,5
; E5   659,26  204  659,88   1,6
; F5   698,46  193  697,49  -2,4
; G5   783,99  172  782,65  -3,0
; A5   880,00  153  879,84  -0,3
; B5   987,77  136  989,82   3,6
; C6  1046,50  129 1043,53  -4,9
