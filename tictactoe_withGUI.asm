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

; Show celebration window when game ends
show_celebration_window:
    ; Save current video mode
    call save_video_mode
    
    ; Switch to graphics mode (320x200, 256 colors)
    mov ah, 00h
    mov al, 13h
    int 10h
    
    ; Clear screen with black background
    call clear_graphics_screen
    
    ; Draw celebration elements
    call draw_celebration_border
    call draw_multiple_trophies
    call draw_multiple_stars
    call draw_celebration_text
    
    ; Wait for key press
    mov ah, 00h
    int 16h
    
    ; Restore text mode
    call restore_video_mode
    ret

; Clear graphics screen - much faster method
clear_graphics_screen:
    ; Use BIOS function to clear screen in graphics mode
    mov ah, 00h        ; Set video mode (clears screen automatically)
    mov al, 13h        ; 320x200, 256 colors
    int 10h
    ret

; Draw colorful border (simplified and faster)
draw_celebration_border:
    ; Top border - single thick line
    mov dx, 10         ; Y coordinate
    mov cx, 10         ; Start X
    mov al, 14         ; Yellow color
    mov ah, 0Ch        ; Set pixel
    
top_border_loop:
    int 10h
    inc cx
    cmp cx, 310
    jl top_border_loop
    
    ; Bottom border
    mov dx, 180        ; Y coordinate
    mov cx, 10         ; Start X
    
bottom_border_loop:
    int 10h
    inc cx
    cmp cx, 310
    jl bottom_border_loop
    
    ; Left border
    mov cx, 10         ; X coordinate
    mov dx, 10         ; Start Y
    
left_border_loop:
    int 10h
    inc dx
    cmp dx, 180
    jl left_border_loop
    
    ; Right border
    mov cx, 310        ; X coordinate
    mov dx, 10         ; Start Y
    
right_border_loop:
    int 10h
    inc dx
    cmp dx, 180
    jl right_border_loop
    
    ret

; Draw multiple trophies
draw_multiple_trophies:
    ; Large central trophy
    mov cx, 140
    mov dx, 30
    call draw_large_trophy
    
    ; Left trophy
    mov cx, 60
    mov dx, 35
    call draw_medium_trophy
    
    ; Right trophy
    mov cx, 220
    mov dx, 35
    call draw_medium_trophy
    
    ret

; Draw large trophy
draw_large_trophy:
    push cx
    push dx
    
    ; Trophy handles (left and right)
    mov al, 6          ; Brown color for handles
    mov ah, 0Ch
    
    ; Left handle
    sub cx, 8
    add dx, 5
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    dec cx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    
    ; Right handle
    pop dx
    pop cx
    push cx
    push dx
    add cx, 20
    add dx, 5
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc cx
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    
    ; Trophy cup (large)
    pop dx
    pop cx
    push cx
    push dx
    
    mov al, 14         ; Yellow/gold color
    mov ah, 0Ch
    
    ; Cup outline - larger
    mov bx, 8          ; Width counter
    
trophy_cup_loop:
    int 10h
    inc cx
    dec bx
    jnz trophy_cup_loop
    
    ; Cup sides - multiple lines for height
    pop dx
    pop cx
    push cx
    push dx
    
    mov bx, 6          ; Height counter
    
trophy_sides_loop:
    int 10h            ; Left side
    add cx, 12
    int 10h            ; Right side
    sub cx, 12
    inc dx
    dec bx
    jnz trophy_sides_loop
    
    ; Cup bottom
    mov bx, 8
    
trophy_bottom_loop:
    int 10h
    inc cx
    dec bx
    jnz trophy_bottom_loop
    
    ; Trophy base
    pop dx
    pop cx
    add dx, 8
    sub cx, 2
    
    mov al, 4          ; Red color for base
    mov bx, 12
    
trophy_base_loop:
    int 10h
    inc cx
    dec bx
    jnz trophy_base_loop
    
    ; Base bottom line
    sub cx, 12
    inc dx
    mov bx, 12
    
trophy_base_bottom_loop:
    int 10h
    inc cx
    dec bx
    jnz trophy_base_bottom_loop
    
    ret

; Draw medium trophy
draw_medium_trophy:
    push cx
    push dx
    
    ; Trophy cup (medium)
    mov al, 14         ; Yellow/gold color
    mov ah, 0Ch
    
    ; Cup outline
    mov bx, 6          ; Width counter
    
med_trophy_cup_loop:
    int 10h
    inc cx
    dec bx
    jnz med_trophy_cup_loop
    
    ; Cup sides
    pop dx
    pop cx
    push cx
    push dx
    
    mov bx, 4          ; Height counter
    
med_trophy_sides_loop:
    int 10h            ; Left side
    add cx, 8
    int 10h            ; Right side
    sub cx, 8
    inc dx
    dec bx
    jnz med_trophy_sides_loop
    
    ; Cup bottom
    mov bx, 6
    
med_trophy_bottom_loop:
    int 10h
    inc cx
    dec bx
    jnz med_trophy_bottom_loop
    
    ; Base
    pop dx
    pop cx
    add dx, 5
    sub cx, 1
    
    mov al, 4          ; Red color
    mov bx, 8
    
med_trophy_base_loop:
    int 10h
    inc cx
    dec bx
    jnz med_trophy_base_loop
    
    ret

; Draw multiple stars around the screen
draw_multiple_stars:
    ; Top stars
    mov cx, 30
    mov dx, 25
    call draw_large_star
    
    mov cx, 280
    mov dx, 25
    call draw_large_star
    
    ; Side stars
    mov cx, 25
    mov dx, 80
    call draw_medium_star
    
    mov cx, 285
    mov dx, 80
    call draw_medium_star
    
    ; Bottom stars
    mov cx, 40
    mov dx, 160
    call draw_medium_star
    
    mov cx, 270
    mov dx, 160
    call draw_medium_star
    
    ; Additional decorative stars
    mov cx, 80
    mov dx, 20
    call draw_small_star
    
    mov cx, 230
    mov dx, 20
    call draw_small_star
    
    mov cx, 20
    mov dx, 120
    call draw_small_star
    
    mov cx, 290
    mov dx, 120
    call draw_small_star
    
    ret

; Draw large star
draw_large_star:
    push cx
    push dx
    
    mov al, 15         ; White color
    mov ah, 0Ch
    
    ; Center cross (larger)
    int 10h
    
    ; Horizontal line (longer)
    dec cx
    int 10h
    dec cx
    int 10h
    inc cx
    inc cx
    inc cx
    int 10h
    inc cx
    int 10h
    sub cx, 2          ; Back to center
    
    ; Vertical line (longer)
    dec dx
    int 10h
    dec dx
    int 10h
    inc dx
    inc dx
    inc dx
    int 10h
    inc dx
    int 10h
    sub dx, 2          ; Back to center
    
    ; Diagonals
    dec cx
    dec dx
    int 10h
    inc cx
    inc cx
    int 10h
    dec cx
    inc dx
    inc dx
    int 10h
    dec cx
    int 10h
    
    pop dx
    pop cx
    ret

; Draw medium star
draw_medium_star:
    push cx
    push dx
    
    mov al, 11         ; Cyan color
    mov ah, 0Ch
    
    ; Center
    int 10h
    
    ; Cross pattern
    dec cx
    int 10h
    inc cx
    inc cx
    int 10h
    dec cx
    
    dec dx
    int 10h
    inc dx
    inc dx
    int 10h
    dec dx
    
    ; Small diagonals
    dec cx
    dec dx
    int 10h
    inc cx
    inc cx
    int 10h
    dec cx
    inc dx
    inc dx
    int 10h
    dec cx
    int 10h
    
    pop dx
    pop cx
    ret

; Draw small star
draw_small_star:
    mov al, 13         ; Magenta color
    mov ah, 0Ch
    
    ; Simple cross
    int 10h
    dec cx
    int 10h
    inc cx
    inc cx
    int 10h
    dec cx
    dec dx
    int 10h
    inc dx
    inc dx
    int 10h
    
    ret

; Draw celebration text - LARGE and CENTERED
draw_celebration_text:
    ; Draw "WINNER!" with letters centered in 320px width
    ; Total text width is approximately 110 pixels
    ; Starting position: (320-110)/2 = 105
    call draw_large_W
    call draw_large_I
    call draw_large_N1
    call draw_large_N2
    call draw_large_E
    call draw_large_R
    call draw_large_exclamation
    ret

; Large letter W (centered)
draw_large_W:
    mov cx, 105        ; Centered start position
    mov dx, 120
    mov al, 15         ; White color
    mov ah, 0Ch
    
    ; Left vertical line
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Bottom middle point
    inc cx
    int 10h
    inc cx
    dec dx
    int 10h
    inc cx
    dec dx
    int 10h
    
    ; Right vertical line
    inc cx
    sub dx, 6
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ret

; Large letter I (centered)
draw_large_I:
    mov cx, 120        ; Adjusted for centering
    mov dx, 120
    mov al, 15
    mov ah, 0Ch
    
    ; Top horizontal
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Middle vertical
    sub cx, 2          ; Center
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
    inc dx
    int 10h
    
    ; Bottom horizontal
    sub cx, 2
    inc dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ret

; Large letter N (first - centered)
draw_large_N1:
    mov cx, 135        ; Adjusted for centering
    mov dx, 120
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Diagonal
    sub dx, 4
    inc cx
    int 10h
    inc cx
    inc dx
    int 10h
    inc cx
    inc dx
    int 10h
    
    ; Right vertical
    inc cx
    sub dx, 6
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
    inc dx
    int 10h
    inc dx
    int 10h
    
    ret

; Large letter N (second - centered)
draw_large_N2:
    mov cx, 150        ; Adjusted for centering
    mov dx, 120
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Diagonal
    sub dx, 4
    inc cx
    int 10h
    inc cx
    inc dx
    int 10h
    inc cx
    inc dx
    int 10h
    
    ; Right vertical
    inc cx
    sub dx, 6
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
    inc dx
    int 10h
    inc dx
    int 10h
    
    ret

; Large letter E (centered)
draw_large_E:
    mov cx, 165        ; Adjusted for centering
    mov dx, 120
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Top horizontal
    sub dx, 8
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Middle horizontal
    sub cx, 4
    add dx, 4
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Bottom horizontal
    sub cx, 3
    add dx, 4
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ret

; Large letter R (centered)
draw_large_R:
    mov cx, 180        ; Adjusted for centering
    mov dx, 120
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
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Top horizontal
    sub dx, 8
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Right top vertical
    inc dx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    
    ; Middle horizontal
    dec cx
    dec cx
    dec cx
    inc dx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    
    ; Diagonal leg
    inc dx
    int 10h
    inc cx
    inc dx
    int 10h
    inc cx
    inc dx
    int 10h
    
    ret

; Large exclamation mark (centered)
draw_large_exclamation:
    mov cx, 200        ; Adjusted for centering
    mov dx, 120
    mov al, 15
    mov ah, 0Ch
    
    ; Vertical line
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
    
    ; Gap
    inc dx
    inc dx
    
    ; Dot
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
