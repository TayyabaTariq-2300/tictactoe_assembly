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
    
    box_top db "+-+-+-+", 13, 10, "$"
box_bottom db "+-+-+-+", 13, 10, "$"

        
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
 
                
        lea dx, box_top
        call print

        lea dx, game_draw
        call print
        lea     dx, new_line
        call    print
 
        lea dx, box_bottom
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
        call    clear_screen   
        
        lea     dx, game_start_message 
        call    print
        
        lea     dx, new_line
        call    print                          
        
        lea     dx, game_draw
        call    print    
        
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
    

    after_print_name: 
    
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