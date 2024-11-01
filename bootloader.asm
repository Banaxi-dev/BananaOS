[BITS 16]
[ORG 7C00h]

jmp main

main:
    xor ax, ax            ; DS=0
    mov ds, ax
    cld                   ; DF=0 for LODSB
    mov ax, 0012h         ; Set 640x480 16-color graphics mode
    int 10h
    mov si, string
    mov bl, 1Eh           ; Yellow text on blue background
    call printstr

    ; Setup for user input with backspace support
    mov cx, 0             ; Initialize text position counter
    
readloop:
    mov ah, 00h           ; BIOS: Keyboard input without echo
    int 16h               ; Wait for key press
    cmp al, 08h           ; Check if Backspace is pressed
    je backspace_handler
    cmp al, 13            ; Check if Enter is pressed
    je newline_handler

    ; Display character
    mov ah, 0Eh           ; BIOS teletype function
    mov bl, 1Eh           ; Yellow on blue background
    int 10h
    inc cx                ; Move position forward
    jmp readloop          ; Loop to continue reading keys

backspace_handler:
    cmp cx, 0             ; Check if there's something to delete
    je readloop           ; If at start, ignore backspace
    dec cx                ; Move position back
    mov ah, 0Eh
    mov al, ' '           ; Replace last character with space
    int 10h
    dec cx                ; Move cursor back again after space
    mov ah, 0Eh           ; Reset character in AL
    int 10h
    jmp readloop

newline_handler:
    ; Move cursor to next line
    mov al, 13            ; Carriage return
    int 10h
    mov al, 10            ; Line feed
    int 10h
    mov cx, 0             ; Reset position counter for new line
    jmp readloop

printstr:
    mov bh, 0             ; DisplayPage
print:
    lodsb
    cmp al, 0
    je done
    mov ah, 0Eh           ; BIOS teletype function
    mov bl, 1Eh           ; Yellow on blue background
    int 10h
    jmp print
done:
    ret

string db "This is The Banana OS", 13, 10, "If you look at this screen, you're probably testing my new OS", 13, 10, "This is my first experience with NASM.", 13, 10, "...", 13, 10, "You Can Download more of my Projects on github.com/Banaxi-dev", 13, 10, "... and yeah, that's all :).", 13, 10, "Is The Yellow Color Cool?",13, 10, "", 13, 10, "", 13, 10, "But always remember! Banaxi is here...!"

times 510 - ($-$$) db 0
dw 0AA55h
