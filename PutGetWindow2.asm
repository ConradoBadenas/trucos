 ;PutGetWindow2.asm (Put/Get a Window into/from screen, version 2)
 ;Programa/rutina para poner y coger Windows (trozos de pantalla)
 ;Es totalmente reubicable porque solo usa saltos relativos.
 ;Esta versión 2 es un poco más larga y más rápida que la primera versión.
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
; pasmo -d PutGetWindow2.asm PutGetWindow2.bin > PutGetWindow2.log

;Put Window into Screen
;FN P(X,Y,W,H,D)=USR DPUT

;Get Window from Screen
;FN G(X,Y,W,H,D)=USR DGET

;Screen = Display file + Attributes
;(chapter 24 of ZX Spectrum BASIC Programming manual)
;https://worldofspectrum.net/ZXBasicManual/zxmanchap24.html

;X = initial column (0-31)
;Y = initial row (0-23)
;W = width = number of columns (1-32)
;H = height = number of rows (1-24)
;D = data address (0-65535)

PROC
LOCAL ANTHRW,ANTHCH,SMTHRD
;Put Window into Screen
PUTWIN ld ix,(23563)
       ld e,(ix+12) ;row (0-23)
       ld a,e
       and %00011000;bits 4,3 = number of third
       or  %01000000;A = %010 b4b3 000
       ld d,a       ;High byte of display address
       ld a,e
       rrca
       rrca
       rrca
       ld c,a       ;C = %b2b1b0...b4b3
       and %11100000;A = %b2b1b0 00000
       or (ix+4)    ;column (0-31)
       ld e,a       ;Low byte of display address
       push de      ;DE = display address
       ld a,c       ;C = %b2b1b0...b4b3
       and %00000011;A = %000000 b4b3
       or  %01011000;A = %010110 b4b3
       ld c,a       ;High byte of attribute address
       ld l,(ix+36)
       ld h,(ix+37) ;HL = data address
       exx
;In this loop, B' is the counter for rows,
;and C' is the width (number of columns)
       ld b,(ix+28) ;height
       ld c,(ix+20) ;width
       pop ix       ;initial display address in IX
;Another Row
ANTHRW   ld a,c     ;width = number of columns
         exx
;In this loop, B is the counter for columns,
;IX is the display address at beginning of each row,
;C is the high byte for the attribute address at beginning of each row,
;DE is the actual screen (display/attribute) address,
;and HL is the data address.
         ld b,a     ;width = number of columns
         ld e,ixl
;Another Char in Screen
ANTHCH     ld d,ixh ;display address
           ld a,(hl)
           ld (de),a
           inc hl   ;1
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;2
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;3
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;4
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;5
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;6
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;7
           inc d
           ld a,(hl)
           ld (de),a
           inc hl   ;8
           ld d,c   ;attribute address
           ld a,(hl)
           ld (de),a
           inc hl   ;9
           inc e
           djnz ANTHCH
         ld a,ixl
         add a,32
         ld ixl,a   ;next row
         jr nc,SMTHRD;same third
           ld a,ixh ;change of third
           add a,8
           ld ixh,a
           inc c
SMTHRD   exx
         djnz ANTHRW
       exx
       ld b,h
       ld c,l   ;BC = 1 + last data address
       ret      ;USR = BC = 1 + last data address
ENDP

PROC
LOCAL ANTHRW,ANTHCH,SMTHRD
;Get Window from Screen
GETWIN ld ix,(23563)
       ld e,(ix+12) ;row (0-23)
       ld a,e
       and %00011000;bits 4,3 = number of third
       or  %01000000;A = %010 b4b3 000
       ld d,a       ;High byte of display address
       ld a,e
       rrca
       rrca
       rrca
       ld c,a       ;C = %b2b1b0...b4b3
       and %11100000;A = %b2b1b0 00000
       or (ix+4)    ;column (0-31)
       ld e,a       ;Low byte of display address
       push de      ;DE = display address
       ld a,c       ;C = %b2b1b0...b4b3
       and %00000011;A = %000000 b4b3
       or  %01011000;A = %010110 b4b3
       ld c,a       ;High byte of attribute address
       ld l,(ix+36)
       ld h,(ix+37) ;HL = data address
       exx
;In this loop, B' is the counter for rows,
;and C' is the width (number of columns)
       ld b,(ix+28) ;height
       ld c,(ix+20) ;width
       pop ix       ;initial display address in IX
;Another Row
ANTHRW   ld a,c     ;width = number of columns
         exx
;In this loop, B is the counter for columns,
;IX is the display address at beginning of each row,
;C is the high byte for the attribute address at beginning of each row,
;DE is the actual screen (display/attribute) address,
;and HL is the data address.
         ld b,a     ;width = number of columns
         ld e,ixl
;Another Char in Screen
ANTHCH     ld d,ixh ;display address
           ld a,(de)
           ld (hl),a
           inc hl   ;1
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;2
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;3
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;4
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;5
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;6
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;7
           inc d
           ld a,(de)
           ld (hl),a
           inc hl   ;8
           ld d,c   ;attribute address
           ld a,(de)
           ld (hl),a
           inc hl   ;9
           inc e
           djnz ANTHCH
         ld a,ixl
         add a,32
         ld ixl,a   ;next row
         jr nc,SMTHRD;same third
           ld a,ixh ;change of third
           add a,8
           ld ixh,a
           inc c
SMTHRD   exx
         djnz ANTHRW
       exx
       ld b,h
       ld c,l   ;BC = 1 + last data address
       ret      ;USR = BC = 1 + last data address
ENDP

