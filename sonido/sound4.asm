 ;sound4.asm (make a sound of any audible frequency by using interrupts)
 ;Date: 11:10:32 UTC, 1 October 2025
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
; pasmo -d sound4.asm sound4.bin > sound4.log
; pasmo -d --tapbas sound4.asm sound4.tap

       ORG $FD00    ;tabla de vectores de interrupción
       DEFS 257,$FE ;todos señalan a $FEFE

ESPERA DEFW 0       ;tiempo de espera, 1 unidad = 16 TS
SEMICI DEFW 497     ;LA3 = 220Hz, 3.500.000/220 = 15909,1 TS un ciclo
                    ;semiciclo = 7954,5 TS = 497,2 veces 16TS
DURACI DEFB 3       ;3 semiciclos = (3/2/220)*50 = 0,34 = 34% frame
; (ESPERA) varía entre 0 y 2*(SEMICI) (entre 0 y 994 para LA3), por lo que
; la duración total será entre 3 y 5 semiciclos (entre 34% y 57% de un frame).
; El valor de (DURACI) ha de ser impar para poder generar sonido.

; Cambiar parámetros desde BASIC:
; POKE 65025,esperaL: POKE 65026,esperaH
; POKE 65027,semiciL: POKE 65028,semiciH
; POKE 65029,duraci

       ORG $FE80
INICIO ld a,$fd
       ld i,a
       im 2
       ret

; Se supone que fuera de la ISR no se usa el altavoz,
; por lo que su membrana ahora mismo está dentro.
ISR    push af
       push bc
       push de
       push hl
       ld a,(DURACI)
       ld e,a
       rra
       jr nc,EXIT   ;no generamos sonido si (DURACI) es par (por ejemplo, 0)
       ld a,($5C48)
       rrca
       rrca
       rrca
       and %00000111;color del borde
       or  %00011000;speaker on, MIC off
       ld bc,5      ;Este número es CONSTANTE, para TODOS los sonidos
; En sound3.asm se usaba BC=6 porque allí LOOP1 se controlaba con un contador
; de 16 bits (el registro DE) con un código largo (4+6+4+4+4 = 22 TS), pero
; aquí el contador de 8 bits (registro E) solo necesita 4 TS (18 TS menos).
       ld hl,(SEMICI)
       sbc hl,bc    ;HL = HighLow = (TS de semiciclo)/16 - 5
       inc h        ;m  = 1+High
       inc l        ;n0 = 1+Low
       ld bc,(ESPERA);BC = 0,1,2,3,...,65535 (en la práctica nunca llegará)
       inc b        ;M  = 1,2,3,4,...,256   (en la práctica nunca llegará)
       inc c        ;N0 = 1,2,3,4,...,256

; =============================================================================
; Aquí está el punto de referencia de cada frame, unos cuantos TSs
; (entre 223 y más de 230) después de que la ULA produzca la señal INT.

                    ;Cuenta de TSs de la espera:
LOOP0  dec c        ; M*  4*N
       jr nz,LOOP0  ; M*(12*N - 5)
       ld c,255     ; M* 7
       dec b        ; M* 4
       jp nz,LOOP0  ; M*10
; suma = 16*N*M + 16*M = 16*N0 + 16*255*(M-1) + 16*M =
; = 16*( 1+N0 +256*(M-1) ) = 16*( 2 + (N0-1) +256*(M-1) )
; sumaMIN = suma(N0=1,M=1) = 16*2 = 32 TS

; -----------------------------------------------------------------------------
; Aquí han pasado 32+16*(ESPERA) TSs desde el punto de referencia.

                    ;Cuenta de TSs del sonido:
LOOP1  out (254),a  ;11 impar pero imprescindible
; Si esta es la primera (o la 3ª, 5ª, 7ª,...) vez que pasamos por aquí,
; acabamos de poner la membrana del altavoz fuera.
; Si es la 2ª,4ª,... vez que pasamos por aquí, acabamos de ponerla dentro.
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
       nop
       nop          ; 8 (relleno de TSs para tener múltiplo de 16)
       dec e        ; 4 para contar E
       jp nz,LOOP1  ;10     11+4+4+7+8+4+10 = 48 = 16*3
; Cuando no es NZ y no salta a LOOP1, también tarda 10 TS
; en ir a la siguiente instrucción, que habrá de ser OUT(254),a

; suma TOTAL = 16*( 3+1+n0 +256*(m-1) ) = 16*( 5+(n0-1) +256*(m-1) )
; TOTAL/16 - 5 = (n0-1) +256*(m-1) es claramente un número de 16 bits
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
; Ergo, si TOTAL/16 se mete en un registro de 16bits, y se le resta 5,
; el resultado es High=m-1, Low=n0-1, por lo que m=1+High, n0=1+Low.
; Es decir, HL = (TOTAL/16) - 5, m = INC H, n0 = INC L.

; Hasta aquí la membrana del altavoz se ha sacado y metido un número
; impar de veces, por lo que ahora la membrana está fuera.
       out (254),a
; La hemos metido y la dejamos metida hasta la próxima INT.

; -----------------------------------------------------------------------------
; Aquí ha terminado la generación de sonido.

; Si saltamos a EXIT (descomentando la siguiente línea), es como si ESPERA
;      jp EXIT
; no existiera (suena mal, como la versión de la semana pasada de sound4.asm).

; Ahora calculamos qué ESPERA hará falta el próximo frame.
       ld hl,(SEMICI)
       add hl,hl    ;CarryFlag = 0 porque (SEMICI) es pequeño
       ex de,hl     ;DE = tiempo de 1 ciclo (en unidades de 16TS)
       ld hl,4368   ;HL = tiempo de 1 frame = 69888 TS = 4368 veces 16TS
                    ; = tiempo entre el punto de referencia de este frame
                    ;   y el punto de referencia del próximo frame
       ld bc,(ESPERA);BC = tiempo de espera (en unidades de 16TS)
       sbc hl,bc    ;HL = tiempo entre el primer OUT de este frame
                    ;     y el punto de referencia del próximo frame
LOOP3  sbc hl,de    ;le quitamos 1 ciclo al tiempo que queda
       jr z,METEHL  ;no queda nada de tiempo
       jr nc,LOOP3  ;todavía queda algo de tiempo
; Aquí HL<0, y abs(HL) es el tiempo que hay que esperar
; después del punto de referencia del próximo frame
       ex de,hl
       xor a        ;CarryFlag = 0, A = 0
       ld h,a
       ld l,a       ;HL = 0
       sbc hl,de    ;HL = tiempo que habrá que esperar en el próximo frame
METEHL ld (ESPERA),hl

EXIT   pop hl
       pop de
       pop bc
       pop af
       jp $38       ;RST 38h

       ORG $FEFE
       jr ISR
END    INICIO

