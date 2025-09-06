 ;PutGetWindow.asm (Put/Get a Window into/from screen)
 ;Programa/rutina para poner y coger Windows (trozos de pantalla)
 ;Es totalmente reubicable porque solo usa saltos relativos.
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
; pasmo -d PutGetWindow.asm PutGetWindow.bin > PutGetWindow.log

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
       or  %01000000
       ld d,a
       ld a,e
       and %00000111;bits 2,1,0 = row within a third
       rrca
       rrca
       rrca         ;A = %b2b1b0.....
       or (ix+4)    ;column (0-31)
       ld e,a       ;DE = display address
       ld c,(ix+20) ;width
       ld a,(ix+28) ;height
       ld h,(ix+37)
       ld l,(ix+36) ;HL = data address
       ld ixh,d
       ld ixl,e     ;initial display address saved in IX
ANTHRW   ex af,af'  ;another row
         ld e,ixl
         ld b,c     ;width
ANTHCH     ld d,ixh ;another char (+attr)
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
           ld a,d
           and %00011000;bits 4,3 = number of third
           rrca
           rrca
           rrca
           or  %01011000;attribute address
           ld d,a   ;4+7+4+4+4+7+4 = 34 T-states
;          ld d,registry = 4 or 8 T-states
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
SMTHRD   ex af,af'
         dec a
         jr nz,ANTHRW
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
       or  %01000000
       ld d,a
       ld a,e
       and %00000111;bits 2,1,0 = row within a third
       rrca
       rrca
       rrca         ;A = %b2b1b0.....
       or (ix+4)    ;column (0-31)
       ld e,a       ;DE = screen address
       ld c,(ix+20) ;width
       ld a,(ix+28) ;height
       ld h,(ix+37)
       ld l,(ix+36) ;HL = data address
       ld ixh,d
       ld ixl,e     ;initial screen address saved in IX
ANTHRW   ex af,af'  ;another row
         ld e,ixl
         ld b,c     ;width
ANTHCH     ld d,ixh ;another char (+attr)
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
           ld a,d
           and %00011000;bits 4,3 = number of third
           rrca
           rrca
           rrca
           or  %01011000;attribute address
           ld d,a   ;4+7+4+4+4+7+4 = 34 T-states
;          ld d,registry = 4 or 8 T-states
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
SMTHRD   ex af,af'
         dec a
         jr nz,ANTHRW
       ld b,h
       ld c,l   ;BC = 1 + last data address
       ret      ;USR = BC = 1 + last data address
ENDP

