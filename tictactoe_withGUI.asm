.model small
    
    
data segment
    
    
    m1 db "Current Time:$"
    m2 db 10,13,"Current Date:$"
    hr db   ?   
    min db  ?
    day db  ?
    month db    ?
    year dw     ?
    
    
    new_line db 13, 10, "$"
        
    game_draw    db "_|_|_", 13, 10
                  db "_|_|_", 13, 10
                  db "_|_|_", 13, 10, "$"
        
                      
    game_pointer db 9 DUP(?)  
        
        win_flag db 0 
        player db "0$" 

        player0_name db 20 dup('$')
        player1_name db 20 dup('$')
        
        game_over_message db "GAME ENDS!!", 13, 10, "$"    
        game_start_message db "COAL PROJECT", 13, 10, "$"
          
        player_message  db "PLAYER=$"
        player_message0 db "PLAYER 0=$"
        player_message1 db "PLAYER 1=$" 
          
        win_message db " Wins!$"   
        type_message db "Type a position: $"
        
        menu_message db "1. Start Game", 13, 10
                     db "2. Exit", 13, 10
                     db "Enter your choice: $"
                     
        enter_player1 db "Enter Player 1 name: $"
        enter_player2 db "Enter Player 2 name: $"
        
        ; Graphics mode variables
        old_video_mode db ?
        
ends
    
stack segment
        dw   128  dup(?)
ends         
    
    extra segment
        
    ends
    
code segment
start:
        mov     ax, data
        mov     ds, ax
        mov     ax, extra
        mov     es, ax
       
       
main_menu:
        call    clear_screen 
       
        lea     dx, game_start_message     ;coal_project
        call    print
    
        lea     dx, new_line
        call    print
    
        lea     dx, menu_message            ;print menu
        call    print
    
        call    read_keyboard               ;input choice
        sub     al, '0'
    
        cmp     al, 1
        je      begin_game
    
        cmp     al, 2
        je      fim
    
        jmp     main_menu



begin_game:
    call get_player_names
    call set_game_pointer    

    lea dx, new_line
    call print

    lea dx, player_message0
    call print
    lea dx, player0_name + 2
    call print
    lea dx, new_line
    call print

    lea dx, player_message1
    call print
    lea dx, player1_name+2
    call print
    lea dx, new_line
    call print

                
main_loop:            
        
        lea     dx, new_line
        call    print                      
        
        lea     dx, player_message
        call    print
        
        lea     dx, player
        call    print  
        
        lea     dx, new_line
        call    print    
 
        ; Print the game board        
        lea dx, game_draw
        call print
        
        lea     dx, new_line
        call    print    
        
        lea     dx, type_message    
        call    print            
                            
        call    read_keyboard                   
        sub     al, 49               
        mov     bh, 0
        mov     bl, al                                  
                                      
        call    update_draw                                    
                                                              
        call    check  
                            
        cmp     win_flag, 1  
        je      game_over  
        
        call    change_player 
                
        jmp     main_loop   
    
    change_player:   
        lea     si, player    
        xor     ds:[si], 1 
        
        ret
          
     
    update_draw:
        mov     bl, game_pointer[bx]
        mov     bh, 0
        
        lea     si, player
        cmp     ds:[si], "0"
        je      draw_x  
                         
        cmp     ds:[si], "1"
        je      draw_o              
                      
        draw_x:
        mov     cl, "x"
        jmp     update
    
    draw_o:          
        mov     cl, "o"  
        jmp     update    
              
        update:         
        mov     ds:[bx], cl
          
        ret 
           
check:
    call check_line
    ret 
           
check_line:
        mov     cx, 0
        
        check_line_loop:     
        cmp     cx, 0
        je      first_line
        
        cmp     cx, 1
        je      second_line
        
        cmp     cx, 2
        je      third_line  
        
        call    check_column
        ret    
            
        first_line:    
        mov     si, 0   
        jmp     do_check_line   
    
        second_line:    
        mov     si, 3
        jmp     do_check_line
        
        third_line:    
        mov     si, 6
        jmp     do_check_line        
    
    do_check_line:
        inc     cx
      
        mov     bh, 0
        mov     bl, game_pointer[si]
        mov     al, ds:[bx]
        cmp     al, "_"
        je      check_line_loop
        
        inc     si
        mov     bl, game_pointer[si]    
        cmp     al, ds:[bx]
        jne     check_line_loop 
          
        inc     si
        mov     bl, game_pointer[si]  
        cmp     al, ds:[bx]
        jne     check_line_loop
                     
        mov     win_flag, 1
        ret         
           
    check_column:
        mov     cx, 0
        
        check_column_loop:     
        cmp     cx, 0
        je      first_column
        
        cmp     cx, 1
        je      second_column
        
        cmp     cx, 2
        je      third_column  
        
        call    check_diagonal
        ret    
            
        first_column:    
        mov     si, 0   
        jmp     do_check_column   
    
        second_column:    
        mov     si, 1
        jmp     do_check_column
        
        third_column:    
        mov     si, 2
        jmp     do_check_column        
    
    do_check_column:
        inc     cx
      
        mov     bh, 0
        mov     bl, game_pointer[si]
        mov     al, ds:[bx]
        cmp     al, "_"
        je      check_column_loop
        
        add     si, 3
        mov     bl, game_pointer[si]    
        cmp     al, ds:[bx]
        jne     check_column_loop 
          
        add     si, 3
        mov     bl, game_pointer[si]  
        cmp     al, ds:[bx]
        jne     check_column_loop
                     
        mov     win_flag, 1
        ret        
    
    
    check_diagonal:
        mov     cx, 0
        
        check_diagonal_loop:     
        cmp     cx, 0
        je      first_diagonal
        
        cmp     cx, 1
        je      second_diagonal                         
        
        ret    
            
        first_diagonal:    
        mov     si, 0                
        mov     dx, 4 
        jmp     do_check_diagonal   
    
        second_diagonal:    
        mov     si, 2
        mov     dx, 2
        jmp     do_check_diagonal       
    
    do_check_diagonal:
        inc     cx
      
        mov     bh, 0
        mov     bl, game_pointer[si]
        mov     al, ds:[bx]
        cmp     al, "_"
        je      check_diagonal_loop
        
        add     si, dx
        mov     bl, game_pointer[si]    
        cmp     al, ds:[bx]
        jne     check_diagonal_loop 
          
        add     si, dx
        mov     bl, game_pointer[si]  
        cmp     al, ds:[bx]
        jne     check_diagonal_loop
                     
        mov     win_flag, 1
        ret  
               
    game_over:        
        ; Show celebration window first
        call    show_celebration_window
        
        call    clear_screen   
        
        lea     dx, game_start_message 
        call    print
        
        lea     dx, new_line
        call    print                          
        
        lea dx, game_draw
        call print
        
        lea     dx, new_line
        call    print
    
        lea     dx, game_over_message
        call    print 
        
        lea     dx, player_message
        call    print
        
        lea     dx, player
        call    print

        lea     dx, win_message
        call    print
    
        lea     dx, new_line
        call    print

        lea     dx, new_line
        call    print
        lea     dx, new_line
        call    print
    
        lea     dx, menu_message
        call    print
        call    read_keyboard
        sub     al, '0'
        cmp     al, 1
        je      begin_game
        jmp     fim
      
    set_game_pointer:
        lea     si, game_draw
        lea     bx, game_pointer          
                  
        mov     cx, 9   
        
    loop_1:
        cmp     cx, 6
        je      add_1                
        
        cmp     cx, 3
        je      add_1
        
        jmp     add_2 
        
    add_1:
        add     si, 1
        jmp     add_2     
          
    add_2:                                
        mov     ds:[bx], si 
        add     si, 2
                            
        inc     bx               
        loop    loop_1 
     
        ret  

    ; Save current video mode
    save_video_mode:
        mov ah, 0Fh        ; Get current video mode
        int 10h
        mov old_video_mode, al
        ret
    
    ; Restore previous video mode
    restore_video_mode:
        mov ah, 00h
        mov al, old_video_mode
        int 10h
        ret
             
    print:      
        mov     ah, 9
        int     21h   
        
        ret 
        
   clear_screen:
    mov ah, 06h  ; Scroll up function
    mov al, 00h  ; Scroll entire screen
    mov bh, 1Eh  ; **Background Blue (1) + Text Yellow (E)**
    mov cx, 0000h ; Top-left corner
    mov dx, 184Fh ; Bottom-right corner
    int 10h       ; Call BIOS interrupt

    ret
   ; Fast graphics celebration window - replace the graphics procedures

; Show celebration window when game ends

       
show_celebration_window:
    ; Save current video mode
    call save_video_mode
    
    ; Switch to graphics mode (320x200, 256 colors)
    mov ah, 00h
    mov al, 13h
    int 10h
    
   
    
    ; Draw celebration elements directly (no background clearing)
    call draw_celebration_border
    call draw_smiley_face
    call draw_stars
    call draw_celebration_text
    
    ; Wait for key press
    mov ah, 00h
    int 16h
    
    ; Restore text mode
    call restore_video_mode
    ret

; Draw colorful border (much simpler and faster)
draw_celebration_border:
    ; Top border - single line
    mov dx, 50         ; Y coordinate
    mov cx, 50         ; Start X
    
top_border_loop:
    mov ah, 0Ch        ; Set pixel
    mov al, 14         ; Yellow color
    int 10h
    inc cx
    cmp cx, 270
    jle top_border_loop
    
    ; Bottom border
    mov dx, 150        ; Y coordinate
    mov cx, 50         ; Start X
    
bottom_border_loop:
    mov ah, 0Ch
    mov al, 14         ; Yellow color
    int 10h
    inc cx
    cmp cx, 270
    jle bottom_border_loop
    
    ; Left border
    mov cx, 50         ; X coordinate
    mov dx, 50         ; Start Y
    
left_border_loop:
    mov ah, 0Ch
    mov al, 14         ; Yellow color
    int 10h
    inc dx
    cmp dx, 150
    jle left_border_loop
    
    ; Right border
    mov cx, 270        ; X coordinate
    mov dx, 50         ; Start Y
    
right_border_loop:
    mov ah, 0Ch
    mov al, 14         ; Yellow color
    int 10h
    inc dx
    cmp dx, 150
    jle right_border_loop
    
    ret

; Draw a simple smiley face
draw_smiley_face:
    ; Face outline (circle approximation - much simpler)
    mov cx, 160        ; Center X
    mov dx, 80         ; Center Y
    mov al, 14         ; Yellow color
    call draw_simple_circle
    
    ; Left eye
    mov cx, 150
    mov dx, 75
    mov al, 0          ; Black color
    call draw_eye
    
    ; Right eye
    mov cx, 170
    mov dx, 75
    mov al, 0          ; Black color
    call draw_eye
    
    ; Simple smile
    mov cx, 155        ; Start X
    mov dx, 85         ; Y coordinate
    mov al, 0          ; Black color
    
smile_loop:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 165
    jle smile_loop
    
    ret

; Draw simple circle (much faster approximation)
draw_simple_circle:
    push cx
    push dx
    
    ; Draw horizontal lines to approximate circle
    mov bx, 8          ; Radius approximation
    
circle_outer_loop:
    push bx
    mov dx, 80         ; Reset to center Y
    sub dx, bx         ; Top part
    
    mov cx, 152        ; Left side
    add cx, bx
    mov si, 168        ; Right side  
    sub si, bx
    
circle_inner_loop:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, si
    jle circle_inner_loop
    
    ; Bottom part
    mov dx, 80         ; Center Y
    add dx, bx         ; Bottom part
    mov cx, 152
    add cx, bx
    
circle_inner_loop2:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, si
    jle circle_inner_loop2
    
    pop bx
    dec bx
    jnz circle_outer_loop
    
    pop dx
    pop cx
    ret

; Draw simple eye
draw_eye:
    mov ah, 0Ch
    int 10h            ; Center pixel
    inc cx
    int 10h            ; Right pixel
    dec cx
    dec cx
    int 10h            ; Left pixel
    inc cx
    inc dx
    int 10h            ; Bottom pixel
    ret

; Draw decorative stars (much simpler)
draw_stars:
    ; Star 1
    mov cx, 80
    mov dx, 60
    call draw_simple_star
    
    ; Star 2
    mov cx, 240
    mov dx, 60
    call draw_simple_star
    
    ; Star 3
    mov cx, 90
    mov dx, 140
    call draw_simple_star
    
    ; Star 4
    mov cx, 230
    mov dx, 140
    call draw_simple_star
    
    ret

; Draw simple star (just a cross)
draw_simple_star:
    push cx
    push dx
    
    mov al, 15         ; White color
    mov ah, 0Ch
    
    ; Center
    int 10h
    
    ; Horizontal line
    dec cx
    int 10h
    inc cx
    inc cx
    int 10h
    dec cx             ; Back to center
    
    ; Vertical line
    dec dx
    int 10h
    inc dx
    inc dx
    int 10h
    
    pop dx
    pop cx
    ret

; Draw bigger celebration text and emoji
draw_celebration_text:
    ; Draw trophy emoji first
    call draw_trophy_emoji
    
    ; Draw "WINNER!" as bigger block letters
    call draw_big_W
    call draw_big_I
    call draw_big_N1
    call draw_big_N2
    call draw_big_E
    call draw_big_R
    call draw_big_exclamation
    ret

; Draw trophy emoji
draw_trophy_emoji:
    ; Trophy cup (yellow)
    mov cx, 160
    mov dx, 65
    mov al, 14         ; Yellow
    mov ah, 0Ch
    
    ; Cup outline
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Cup sides
    dec cx
    dec cx
    dec cx
    inc dx
    int 10h
    add cx, 3
    int 10h
    
    ; Cup bottom
    dec cx
    dec cx
    inc dx
    int 10h
    inc cx
    int 10h
    
    ; Base (brown/red)
    mov al, 4          ; Red color for base
    inc dx
    dec cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ret

; Big block letter drawing (double size)
draw_big_W:
    mov cx, 80         ; Start position (moved left for bigger text)
    mov dx, 110
    mov al, 15         ; White color
    mov ah, 0Ch
    
    ; Left vertical line (double height)
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Middle bottom points
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Right vertical line
    inc cx
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    
    ret

draw_big_I:
    mov cx, 95
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Top horizontal
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Middle vertical
    dec cx
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Bottom horizontal
    dec cx
    inc dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ret

draw_big_N1:
    mov cx, 110
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Left vertical (double height)
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Diagonal
    dec dx
    inc cx
    int 10h
    dec dx
    inc cx
    int 10h
    
    ; Right vertical
    inc cx
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ret

draw_big_N2:
    mov cx, 125
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Left vertical
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Right vertical
    add cx, 3
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    
    ret

draw_big_E:
    mov cx, 140
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Vertical line (double height)
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Top horizontal
    dec dx
    dec dx
    dec dx
    dec dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Middle horizontal
    dec cx
    dec cx
    inc dx
    inc dx
    int 10h
    inc cx
    int 10h
    
    ; Bottom horizontal
    dec cx
    inc dx
    inc dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ret

draw_big_R:
    mov cx, 155
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Vertical line (double height)
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Top horizontal
    dec dx
    dec dx
    dec dx
    dec dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Middle horizontal  
    dec cx
    dec cx
    inc dx
    inc dx
    int 10h
    inc cx
    int 10h
    
    ; Diagonal leg
    inc dx
    int 10h
    inc cx
    inc dx
    int 10h
    
    ret

draw_big_exclamation:
    mov cx, 175
    mov dx, 110
    mov al, 15
    mov ah, 0Ch
    
    ; Vertical line (bigger)
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Dot (bigger)
    inc dx
    inc dx
    int 10h
    inc cx
    int 10h
    dec cx
    inc dx
    int 10h
    inc cx
    int 10h
    
    ret
           
    read_keyboard:  
        mov     ah, 1       
        int     21h  
        
        ret      
    
    get_player_names:
        lea dx, new_line
        call print
        lea dx, enter_player1
        call print
        lea dx, player0_name
        call read_string
        lea dx, new_line
        call print
    
        lea dx, enter_player2
        call print
        lea dx, player1_name
        call read_string
    
        lea dx, new_line
        call print
        ret
    
    read_string:
        mov ah, 0Ah
        int 21h
        ret
    
    fim:
        mov ah,4ch
        int 21h 
        
                  
    code ends
    end start