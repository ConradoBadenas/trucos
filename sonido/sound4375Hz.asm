 ;sound4375Hz.asm (make a sound of 4375 Hz frequency)
 ;Date: 16:26:11 UTC 20 September 2025
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
; pasmo -d sound4375Hz.asm sound4375Hz.bin > sound4375Hz.log
; pasmo -d --tapbas sound4375Hz.asm sound4375Hz.tap

INICIO ORG 65280
       ld a,1       ;color inicial = BLUE
       di           ;que las interrupciones no interrumpan
LOOP   out (254),a  ;11 TS
       inc a        ; 4 TS
       jp LOOP      ;10 TS
END    INICIO       ;suma = 25 TS

; Ejecutar 32 veces el LOOP son 32*25 = 800 TS
; (16 veces con bit4 = 0, otras 16 veces con bit4 = 1).
; En 1 segundo (3.500.000 TS), se ejecutan 3.500.000/800 =
; = 4375 veces 32LOOPs, es decir, se genera una onda cuadrada
; de 4375 Hz, cerca del último DO de un piano de 88 teclas.
