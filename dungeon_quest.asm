.MODEL SMALL
.STACK 100H

.DATA
    ; ========== GAME TITLE AND MENUS ==========
    TITLE_MSG DB 13,10,'====================================',13,10
              DB '   DUNGEON QUEST - Adventure Game',13,10
              DB '====================================',13,10,'$'
    
    MENU_MSG DB 13,10,'--- MAIN MENU ---',13,10
             DB '1. Start New Game',13,10
             DB '2. Load Saved Game',13,10
             DB '3. Exit',13,10
             DB 'Choice: $'
    
    GAME_MENU DB 13,10,'--- GAME MENU ---',13,10
              DB '1. Move (W/A/S/D)',13,10
              DB '2. View Inventory',13,10
              DB '3. Combat',13,10
              DB '4. Solve Puzzle',13,10
              DB '5. Talk to NPC',13,10
              DB '6. Save Game',13,10
              DB '7. Back to Main Menu',13,10
              DB 'Choice: $'
    
    ; ========== PLAYER STATUS ==========
    PLAYER_X DB 1           ; Player X position (0-4)
    PLAYER_Y DB 1           ; Player Y position (0-4)
    PLAYER_HP DB 100        ; Player health (max 100)
    PLAYER_GOLD DB 50       ; Player gold
    
    ; ========== MAP DATA ==========
    ; 5x5 grid: 0=Empty, 1=Wall, 2=Enemy, 3=Treasure, 4=NPC, 5=Puzzle
    MAP_DATA DB 1,1,1,1,1
             DB 1,0,2,0,1
             DB 1,0,1,3,1
             DB 1,4,0,5,1
             DB 1,1,1,1,1
    
    ; ========== INVENTORY SYSTEM ==========
    ; Stack-based inventory (Max 10 items)
    ; Item IDs: 0=Empty, 1=Sword, 2=Potion, 3=Key, 4=Shield, 5=Gold
    INVENTORY DB 10 DUP(0)
    INV_TOP DB 0            ; Stack pointer (0-9)
    
    ; ========== QUEST AND GAME STATE ==========
    QUEST_STATUS DB 0       ; 0=Not started, 1=In Progress, 2=Completed
    PUZZLE_SOLVED DB 0      ; 0=Not solved, 1=Solved
    
    ; ========== MOVEMENT MESSAGES ==========
    MOVE_MSG DB 13,10,'Move (W=Up, S=Down, A=Left, D=Right, Q=Back): $'
    POS_MSG DB 13,10,'Position: ($'
    COMMA_MSG DB ',$'
    BRACKET_MSG DB ')$'
    WALL_MSG DB 13,10,'Cannot move! Wall ahead!',13,10,'$'
    MOVED_MSG DB 13,10,'Moved successfully!',13,10,'$'
    
    ; ========== TILE ENCOUNTER MESSAGES ==========
    ENCOUNTER_ENEMY DB 'An enemy appears!',13,10,'$'
    FIGHT_PROMPT DB 'Fight? (1=Yes, 2=No): $'
    ENCOUNTER_TREASURE DB 'Found a treasure chest! +30 Gold and Shield!',13,10,'$'
    ENCOUNTER_NPC DB 'You meet a village elder.',13,10,'$'
    TALK_PROMPT DB 'Talk? (1=Yes, 2=No): $'
    ENCOUNTER_PUZZLE DB 'You found a mysterious puzzle!',13,10,'$'
    SOLVE_PROMPT DB 'Solve puzzle? (1=Yes, 2=No): $'
    
    ; ========== INVENTORY MESSAGES ==========
    INV_MSG DB 13,10,'--- INVENTORY ---',13,10,'$'
    INV_EMPTY DB 'Inventory is empty!',13,10,'$'
    INV_ITEM1 DB 'Sword$'
    INV_ITEM2 DB 'Health Potion$'
    INV_ITEM3 DB 'Golden Key$'
    INV_ITEM4 DB 'Shield$'
    INV_ITEM5 DB 'Gold Coins$'
    INV_FULL DB 13,10,'Inventory is full!',13,10,'$'
    
    ; ========== COMBAT SYSTEM ==========
    ENEMY_HP DB 50          ; Enemy health points
    ENEMY_ATK DB 15         ; Enemy attack damage
    
    COMBAT_MSG DB 13,10,'--- COMBAT ---',13,10
               DB 'Enemy Health: $'
    
    COMBAT_MENU DB 13,10,'1. Attack  2. Defend  3. Run',13,10,'Choice: $'
    
    ATTACK_MSG DB 13,10,'You attacked! Enemy HP: $'
    ENEMY_ATTACK_MSG DB 13,10,'Enemy attacked! Your HP: $'
    WIN_MSG DB 13,10,'Victory! Found Sword!',13,10,'$'
    LOSE_MSG DB 13,10,'Defeated! Game Over!',13,10,'$'
    RUN_MSG DB 13,10,'Escaped from battle!',13,10,'$'
    
    ; ========== PUZZLE SYSTEM ==========
    PUZZLE_MSG DB 13,10,'--- PUZZLE ---',13,10
               DB 'What is 5 + 7? (Enter answer): $'
    CORRECT_MSG DB 13,10,'Correct! Found Golden Key!',13,10,'$'
    WRONG_MSG DB 13,10,'Wrong answer! Try again later.',13,10,'$'
    
    ; ========== NPC AND QUEST SYSTEM ==========
    NPC_MSG DB 13,10,'--- NPC: Village Elder ---',13,10
            DB 'Elder: Greetings, adventurer!',13,10
            DB '1. Accept Quest (Find Golden Key)',13,10
            DB '2. Complete Quest (Need Golden Key)',13,10
            DB '3. Leave',13,10
            DB 'Choice: $'
    
    QUEST_ACCEPT DB 13,10,'Quest accepted! Find the Golden Key.',13,10,'$'
    QUEST_COMPLETE DB 13,10,'Quest completed! +100 Gold!',13,10,'$'
    NO_KEY_MSG DB 13,10,'You dont have the Golden Key!',13,10,'$'
    
    ; ========== SAVE/LOAD SYSTEM ==========
    SAVE_MSG DB 13,10,'Game saved successfully!',13,10,'$'
    LOAD_MSG DB 13,10,'Game loaded successfully!',13,10,'$'
    
    ; Saved game state variables
    SAVED_X DB 1
    SAVED_Y DB 1
    SAVED_HP DB 100
    SAVED_GOLD DB 50
    SAVED_INV DB 10 DUP(0)
    SAVED_INV_TOP DB 0
    SAVED_QUEST DB 0
    
    ; ========== STATUS DISPLAY ==========
    HP_MSG DB 13,10,'Health: $'
    GOLD_MSG DB ' Gold: $'
    
    ; ========== UTILITY ==========
    NEWLINE DB 13,10,'$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
MAIN_MENU:
    ; Display title
    LEA DX, TITLE_MSG
    CALL PRINT_STRING
    
    ; Display main menu
    LEA DX, MENU_MSG
    CALL PRINT_STRING
    
    ; Get choice
    CALL GET_INPUT
    
    CMP AL, '1'
    JE START_GAME
    CMP AL, '2'
    JE LOAD_GAME
    CMP AL, '3'
    JE EXIT_GAME
    JMP MAIN_MENU
    
START_GAME:
    CALL GAME_LOOP
    JMP MAIN_MENU
    
LOAD_GAME:
    CALL LOAD_GAME_PROC
    CALL GAME_LOOP
    JMP MAIN_MENU
    
EXIT_GAME:
    MOV AH, 4CH
    INT 21H
MAIN ENDP   

; ========== GAME LOOP PROCEDURE ==========
; This procedure handles the main game menu and dispatches to game features
GAME_LOOP PROC
GAME_LOOP_START:
    ; Display game menu
    LEA DX, GAME_MENU
    CALL PRINT_STRING
    
    ; Get player's choice
    CALL GET_INPUT
    
    ; Check which option was selected
    CMP AL, '1'
    JE MENU_MOVE
    CMP AL, '2'
    JE MENU_INVENTORY
    CMP AL, '3'
    JE MENU_COMBAT
    CMP AL, '4'
    JE MENU_PUZZLE
    CMP AL, '5'
    JE MENU_NPC
    CMP AL, '6'
    JE MENU_SAVE
    CMP AL, '7'
    JE MENU_EXIT
    
    ; Invalid input, loop back
    JMP GAME_LOOP_START
    
MENU_MOVE:
    CALL MOVE_PLAYER
    JMP GAME_LOOP_START
    
MENU_INVENTORY:
    CALL VIEW_INVENTORY
    JMP GAME_LOOP_START
    
MENU_COMBAT:
    CALL COMBAT_SYSTEM
    JMP GAME_LOOP_START
    
MENU_PUZZLE:
    CALL SOLVE_PUZZLE
    JMP GAME_LOOP_START
    
MENU_NPC:
    CALL NPC_INTERACTION
    JMP GAME_LOOP_START
    
MENU_SAVE:
    CALL SAVE_GAME_PROC
    JMP GAME_LOOP_START
    
MENU_EXIT:
    ; Exit game loop and return to main menu
    RET
GAME_LOOP ENDP

; ========== FEATURE 1: PLAYER MOVEMENT SYSTEM ==========
MOVE_PLAYER PROC
    MOVEMENT_LOOP:
        ; Display current position
        CALL DISPLAY_POSITION
        CALL DISPLAY_STATUS
        
        ; Display move prompt
        LEA DX, MOVE_MSG
        CALL PRINT_STRING
        
        ; Get direction
        CALL GET_INPUT
        
        ; Convert to uppercase
        CMP AL, 'a'
        JL CHECK_MOVE
        CMP AL, 'z'
        JG CHECK_MOVE
        SUB AL, 32
        
    CHECK_MOVE:
        CMP AL, 'W'
        JE MOVE_UP
        CMP AL, 'S'
        JE MOVE_DOWN
        CMP AL, 'A'
        JE MOVE_LEFT
        CMP AL, 'D'
        JE MOVE_RIGHT
        CMP AL, 'Q'
        JE MOVE_END
        JMP MOVEMENT_LOOP
        
    MOVE_UP:
        MOV AL, PLAYER_Y
        CMP AL, 0
        JE CANT_MOVE
        DEC AL
        MOV BL, AL
        MOV AL, PLAYER_X
        CALL CHECK_COLLISION
        CMP CL, 1
        JE CANT_MOVE
        DEC PLAYER_Y
        JMP MOVE_SUCCESS
    
    MOVE_DOWN:
        MOV AL, PLAYER_Y
        CMP AL, 4
        JE CANT_MOVE
        INC AL
        MOV BL, AL
        MOV AL, PLAYER_X
        CALL CHECK_COLLISION
        CMP CL, 1
        JE CANT_MOVE
        INC PLAYER_Y
        JMP MOVE_SUCCESS
    
    MOVE_LEFT:
        MOV AL, PLAYER_X
        CMP AL, 0
        JE CANT_MOVE
        DEC AL
        MOV BL, PLAYER_Y
        CALL CHECK_COLLISION
        CMP CL, 1
        JE CANT_MOVE
        DEC PLAYER_X
        JMP MOVE_SUCCESS
    
    MOVE_RIGHT:
        MOV AL, PLAYER_X
        CMP AL, 4
        JE CANT_MOVE
        INC AL
        MOV BL, PLAYER_Y
        CALL CHECK_COLLISION
        CMP CL, 1
        JE CANT_MOVE
        INC PLAYER_X
        JMP MOVE_SUCCESS
    
    CANT_MOVE:
        LEA DX, WALL_MSG
        CALL PRINT_STRING
        JMP MOVEMENT_LOOP
    
    MOVE_SUCCESS:
        LEA DX, MOVED_MSG
        CALL PRINT_STRING
        
        ; Check what's at the new position
        CALL CHECK_TILE_EVENT
        
        JMP MOVEMENT_LOOP
    
    MOVE_END:
        RET
MOVE_PLAYER ENDP

; Check collision with walls
CHECK_COLLISION PROC
    ; Input: AL = X coordinate, BL = Y coordinate
    ; Output: CL = 1 if wall, 0 otherwise
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    
    ; Save X coordinate
    MOV DH, AL
    
    ; Calculate offset: Y * 5 + X
    MOV AL, BL
    MOV AH, 0
    MOV CL, 5
    MUL CL
    
    ; Add X coordinate
    MOV BL, DH
    MOV BH, 0
    ADD AX, BX
    
    ; Get map value
    LEA SI, MAP_DATA
    ADD SI, AX
    MOV AL, [SI]
    
    ; Check if wall
    CMP AL, 1
    JE IS_WALL
    MOV CL, 0
    JMP CHECK_END
    
IS_WALL:
    MOV CL, 1
    
CHECK_END:
    POP SI
    POP DX
    POP BX
    POP AX
    RET
CHECK_COLLISION ENDP

; Check what tile the player is on and trigger events
CHECK_TILE_EVENT PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    ; Calculate map offset: Y * 5 + X
    MOV AL, PLAYER_Y
    MOV AH, 0
    MOV BL, 5
    MUL BL
    
    MOV BL, PLAYER_X
    MOV BH, 0
    ADD AX, BX
    
    ; Get tile value
    LEA SI, MAP_DATA
    ADD SI, AX
    MOV AL, [SI]
    
    ; Check tile type
    CMP AL, 2
    JE FOUND_ENEMY
    CMP AL, 3
    JE FOUND_TREASURE
    CMP AL, 4
    JE FOUND_NPC
    CMP AL, 5
    JE FOUND_PUZZLE
    JMP TILE_END
    
FOUND_ENEMY:
    LEA DX, NEWLINE
    CALL PRINT_STRING
    LEA DX, ENCOUNTER_ENEMY
    CALL PRINT_STRING
    
    ; Ask if player wants to fight
    LEA DX, FIGHT_PROMPT
    CALL PRINT_STRING
    CALL GET_INPUT
    
    CMP AL, '1'
    JNE TILE_END
    
    ; Start combat
    CALL COMBAT_SYSTEM
    
    ; Clear enemy from map after combat
    MOV BYTE PTR [SI], 0
    JMP TILE_END

FOUND_TREASURE:
    LEA DX, NEWLINE
    CALL PRINT_STRING
    LEA DX, ENCOUNTER_TREASURE
    CALL PRINT_STRING
    
    ; Add gold
    MOV AL, PLAYER_GOLD
    ADD AL, 30
    JNC GOLD_OK
    MOV AL, 255
GOLD_OK:
    MOV PLAYER_GOLD, AL
    
    ; Add shield to inventory
    MOV AL, 4
    CALL ADD_TO_INVENTORY
    
    ; Clear treasure from map
    MOV BYTE PTR [SI], 0
    JMP TILE_END

FOUND_NPC:
    LEA DX, NEWLINE
    CALL PRINT_STRING
    LEA DX, ENCOUNTER_NPC
    CALL PRINT_STRING
    
    ; Ask if player wants to talk
    LEA DX, TALK_PROMPT
    CALL PRINT_STRING
    CALL GET_INPUT
    
    CMP AL, '1'
    JNE TILE_END
    
    CALL NPC_INTERACTION
    JMP TILE_END

FOUND_PUZZLE:
    LEA DX, NEWLINE
    CALL PRINT_STRING
    LEA DX, ENCOUNTER_PUZZLE
    CALL PRINT_STRING
    
    ; Ask if player wants to solve
    LEA DX, SOLVE_PROMPT
    CALL PRINT_STRING
    CALL GET_INPUT
    
    CMP AL, '1'
    JNE TILE_END
    
    CALL SOLVE_PUZZLE
    
    ; Clear puzzle from map after solving
    MOV AL, PUZZLE_SOLVED
    CMP AL, 1
    JNE TILE_END
    MOV BYTE PTR [SI], 0

TILE_END:
    POP SI
    POP BX
    POP AX
    RET
CHECK_TILE_EVENT ENDP

; Display player's current position
DISPLAY_POSITION PROC
    LEA DX, POS_MSG
    CALL PRINT_STRING
    
    ; Display X coordinate
    MOV AL, PLAYER_X
    ADD AL, 30H
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Display comma
    LEA DX, COMMA_MSG
    CALL PRINT_STRING
    
    ; Display Y coordinate
    MOV AL, PLAYER_Y
    ADD AL, 30H
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Display closing bracket
    LEA DX, BRACKET_MSG
    CALL PRINT_STRING
    
    RET
DISPLAY_POSITION ENDP

; ========== FEATURE 2: INVENTORY MANAGEMENT SYSTEM ==========
VIEW_INVENTORY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Print inventory header
    LEA DX, INV_MSG
    CALL PRINT_STRING
    
    ; Check if inventory is empty
    MOV AL, INV_TOP
    CMP AL, 0
    JE INVENTORY_EMPTY
    
    ; Display all items
    MOV CL, 0
    LEA SI, INVENTORY
    
    DISPLAY_ITEMS:
        CMP CL, INV_TOP
        JGE INVENTORY_END
        
        MOV BL, [SI]
        
        ; Print item number
        MOV DL, CL
        ADD DL, 31H
        MOV AH, 02H
        INT 21H
        
        MOV DL, '.'
        MOV AH, 02H
        INT 21H
        
        MOV DL, ' '
        MOV AH, 02H
        INT 21H
        
        ; Print item name
        CMP BL, 1
        JE SHOW_SWORD
        CMP BL, 2
        JE SHOW_POTION
        CMP BL, 3
        JE SHOW_KEY
        CMP BL, 4
        JE SHOW_SHIELD
        CMP BL, 5
        JE SHOW_GOLD
        JMP NEXT_ITEM
        
        SHOW_SWORD:
            LEA DX, INV_ITEM1
            CALL PRINT_STRING
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP NEXT_ITEM
            
        SHOW_POTION:
            LEA DX, INV_ITEM2
            CALL PRINT_STRING
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP NEXT_ITEM
            
        SHOW_KEY:
            LEA DX, INV_ITEM3
            CALL PRINT_STRING
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP NEXT_ITEM
            
        SHOW_SHIELD:
            LEA DX, INV_ITEM4
            CALL PRINT_STRING
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP NEXT_ITEM
            
        SHOW_GOLD:
            LEA DX, INV_ITEM5
            CALL PRINT_STRING
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP NEXT_ITEM
        
        NEXT_ITEM:
            INC SI
            INC CL
            JMP DISPLAY_ITEMS
    
    INVENTORY_EMPTY:
        LEA DX, INV_EMPTY
        CALL PRINT_STRING
    
    INVENTORY_END:
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
VIEW_INVENTORY ENDP

ADD_TO_INVENTORY PROC
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DX
    
    MOV BL, INV_TOP
    CMP BL, 10
    JGE INV_IS_FULL
    
    LEA SI, INVENTORY
    MOV BH, 0
    ADD SI, BX
    
    MOV [SI], AL
    
    INC INV_TOP
    
    POP DX
    POP SI
    POP BX
    POP AX
    RET
    
    INV_IS_FULL:
        LEA DX, INV_FULL
        CALL PRINT_STRING
        POP DX
        POP SI
        POP BX
        POP AX
        RET
ADD_TO_INVENTORY ENDP

CHECK_INVENTORY PROC
    PUSH SI
    PUSH CX
    PUSH AX
    
    MOV CL, 0
    LEA SI, INVENTORY
    
    CHECK_LOOP:
        CMP CL, INV_TOP
        JE NOT_FOUND
        
        CMP [SI], AL
        JE FOUND_ITEM
        
        INC SI
        INC CL
        JMP CHECK_LOOP
    
    FOUND_ITEM:
        MOV BL, 1
        POP AX
        POP CX
        POP SI
        RET
    
    NOT_FOUND:
        MOV BL, 0
        POP AX
        POP CX
        POP SI
        RET
CHECK_INVENTORY ENDP

; ========== FEATURE 3: COMBAT SYSTEM ==========
COMBAT_SYSTEM PROC
    MOV ENEMY_HP, 50
    
    COMBAT_LOOP:
        LEA DX, COMBAT_MSG
        CALL PRINT_STRING
        
        MOV AL, ENEMY_HP
        CALL PRINT_NUMBER
        
        LEA DX, COMBAT_MENU
        CALL PRINT_STRING
        
        CALL GET_INPUT
        
        CMP AL, '1'
        JE PLAYER_ATTACK
        CMP AL, '2'
        JE PLAYER_DEFEND
        CMP AL, '3'
        JE PLAYER_RUN
        JMP COMBAT_LOOP
        
        PLAYER_ATTACK:
            MOV AL, ENEMY_HP
            CMP AL, 20
            JLE ENEMY_DIES
            
            SUB AL, 20
            MOV ENEMY_HP, AL
            
            LEA DX, ATTACK_MSG
            CALL PRINT_STRING
            
            MOV AL, ENEMY_HP
            CALL PRINT_NUMBER
            
            LEA DX, NEWLINE
            CALL PRINT_STRING
            
            MOV AL, PLAYER_HP
            CMP AL, 15
            JLE PLAYER_DIES
            SUB AL, 15
            MOV PLAYER_HP, AL
            
            LEA DX, ENEMY_ATTACK_MSG
            CALL PRINT_STRING
            
            MOV AL, PLAYER_HP
            CALL PRINT_NUMBER
            
            LEA DX, NEWLINE
            CALL PRINT_STRING
            
            JMP COMBAT_LOOP
        
        ENEMY_DIES:
            MOV ENEMY_HP, 0
            LEA DX, ATTACK_MSG
            CALL PRINT_STRING
            MOV AL, 0
            CALL PRINT_NUMBER
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP COMBAT_WIN
        
        PLAYER_DIES:
            MOV PLAYER_HP, 0
            LEA DX, ENEMY_ATTACK_MSG
            CALL PRINT_STRING
            MOV AL, 0
            CALL PRINT_NUMBER
            LEA DX, NEWLINE
            CALL PRINT_STRING
            JMP COMBAT_LOSE
        
        PLAYER_DEFEND:
            MOV AL, PLAYER_HP
            ADD AL, 10
            CMP AL, 100
            JLE HEAL_OK
            MOV AL, 100
            HEAL_OK:
            MOV PLAYER_HP, AL
            
            MOV AL, PLAYER_HP
            CMP AL, 10
            JLE PLAYER_DIES
            SUB AL, 10
            MOV PLAYER_HP, AL
            
            LEA DX, ENEMY_ATTACK_MSG
            CALL PRINT_STRING
            
            MOV AL, PLAYER_HP
            CALL PRINT_NUMBER
            
            LEA DX, NEWLINE
            CALL PRINT_STRING
            
            JMP COMBAT_LOOP
        
        PLAYER_RUN:
            LEA DX, RUN_MSG
            CALL PRINT_STRING
            JMP COMBAT_END
        
        COMBAT_WIN:
            LEA DX, WIN_MSG
            CALL PRINT_STRING
            
            MOV AL, 1
            CALL ADD_TO_INVENTORY
            
            JMP COMBAT_END
        
        COMBAT_LOSE:
            LEA DX, LOSE_MSG
            CALL PRINT_STRING
            MOV PLAYER_HP, 100
    
    COMBAT_END:
        RET
COMBAT_SYSTEM ENDP

; ========== FEATURE 4: PUZZLE SOLVING ==========
SOLVE_PUZZLE PROC
    ; Check if already solved
    MOV AL, PUZZLE_SOLVED
    CMP AL, 1
    JE PUZZLE_ALREADY_SOLVED
    
    LEA DX, PUZZLE_MSG
    CALL PRINT_STRING
    
    ; Get answer
    CALL GET_INPUT
    
    ; Check answer (should be '12' but we'll accept single digit for simplicity)
    CMP AL, '1'
    JNE PUZZLE_WRONG
    
    CALL GET_INPUT
    CMP AL, '2'
    JNE PUZZLE_WRONG
    
    ; Correct answer
    LEA DX, CORRECT_MSG
    CALL PRINT_STRING
    
    MOV AL, 3  ; Golden Key
    CALL ADD_TO_INVENTORY
    
    MOV PUZZLE_SOLVED, 1
    JMP PUZZLE_END
    
    PUZZLE_WRONG:
        LEA DX, WRONG_MSG
        CALL PRINT_STRING
        JMP PUZZLE_END
    
    PUZZLE_ALREADY_SOLVED:
        LEA DX, NEWLINE
        CALL PRINT_STRING
        LEA DX, CORRECT_MSG
        CALL PRINT_STRING
    
    PUZZLE_END:
        RET
SOLVE_PUZZLE ENDP

; ========== FEATURE 5: NPC INTERACTION & QUEST SYSTEM ==========
NPC_INTERACTION PROC
    LEA DX, NPC_MSG
    CALL PRINT_STRING
    
    CALL GET_INPUT
    
    CMP AL, '1'
    JE ACCEPT_QUEST
    CMP AL, '2'
    JE COMPLETE_QUEST
    CMP AL, '3'
    JE NPC_END
    JMP NPC_INTERACTION
    
    ACCEPT_QUEST:
        MOV QUEST_STATUS, 1
        LEA DX, QUEST_ACCEPT
        CALL PRINT_STRING
        JMP NPC_END
    
    COMPLETE_QUEST:
        ; Check if player has key
        MOV AL, 3  ; Golden Key ID
        CALL CHECK_INVENTORY
        CMP BL, 1
        JNE NO_KEY
        
        ; Complete quest
        MOV QUEST_STATUS, 2
        MOV AL, PLAYER_GOLD
        ADD AL, 100
        MOV PLAYER_GOLD, AL
        
        LEA DX, QUEST_COMPLETE
        CALL PRINT_STRING
        JMP NPC_END
        
        NO_KEY:
            LEA DX, NO_KEY_MSG
            CALL PRINT_STRING
    
    NPC_END:
        RET
NPC_INTERACTION ENDP

; ========== FEATURE 6: SAVE/LOAD GAME STATE ==========
SAVE_GAME_PROC PROC
    ; Save player position
    MOV AL, PLAYER_X
    MOV SAVED_X, AL
    MOV AL, PLAYER_Y
    MOV SAVED_Y, AL
    
    ; Save player stats
    MOV AL, PLAYER_HP
    MOV SAVED_HP, AL
    MOV AL, PLAYER_GOLD
    MOV SAVED_GOLD, AL
    
    ; Save inventory
    MOV CL, 0
    LEA SI, INVENTORY
    LEA DI, SAVED_INV
    
    SAVE_INV_LOOP:
        CMP CL, 10
        JE SAVE_INV_DONE
        MOV AL, [SI]
        MOV [DI], AL
        INC SI
        INC DI
        INC CL
        JMP SAVE_INV_LOOP
    
    SAVE_INV_DONE:
    MOV AL, INV_TOP
    MOV SAVED_INV_TOP, AL
    
    ; Save quest status
    MOV AL, QUEST_STATUS
    MOV SAVED_QUEST, AL
    
    LEA DX, SAVE_MSG
    CALL PRINT_STRING
    
    RET
SAVE_GAME_PROC ENDP

LOAD_GAME_PROC PROC
    ; Load player position
    MOV AL, SAVED_X
    MOV PLAYER_X, AL
    MOV AL, SAVED_Y
    MOV PLAYER_Y, AL
    
    ; Load player stats
    MOV AL, SAVED_HP
    MOV PLAYER_HP, AL
    MOV AL, SAVED_GOLD
    MOV PLAYER_GOLD, AL
    
    ; Load inventory
    MOV CL, 0
    LEA SI, SAVED_INV
    LEA DI, INVENTORY
    
    LOAD_INV_LOOP:
        CMP CL, 10
        JE LOAD_INV_DONE
        MOV AL, [SI]
        MOV [DI], AL
        INC SI
        INC DI
        INC CL
        JMP LOAD_INV_LOOP
    
    LOAD_INV_DONE:
    MOV AL, SAVED_INV_TOP
    MOV INV_TOP, AL
    
    ; Load quest status
    MOV AL, SAVED_QUEST
    MOV QUEST_STATUS, AL
    
    LEA DX, LOAD_MSG
    CALL PRINT_STRING
    
    RET
LOAD_GAME_PROC ENDP

; ========== UTILITY PROCEDURES ==========
DISPLAY_STATUS PROC
    LEA DX, HP_MSG
    CALL PRINT_STRING
    
    MOV AL, PLAYER_HP
    CALL PRINT_NUMBER
    
    LEA DX, GOLD_MSG
    CALL PRINT_STRING
    
    MOV AL, PLAYER_GOLD
    CALL PRINT_NUMBER
    
    LEA DX, NEWLINE
    CALL PRINT_STRING
    
    RET
DISPLAY_STATUS ENDP

PRINT_STRING PROC
    MOV AH, 09H
    INT 21H
    RET
PRINT_STRING ENDP

GET_INPUT PROC
    MOV AH, 01H
    INT 21H
    RET
GET_INPUT ENDP

PRINT_NUMBER PROC
    ; Input: AL = number to print (0-255)
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CL, 0
    MOV BL, 10
    
    DIVIDE_LOOP:
        MOV AH, 0
        DIV BL
        PUSH AX
        INC CL
        CMP AL, 0
        JNE DIVIDE_LOOP
    
    PRINT_DIGITS:
        POP AX
        MOV DL, AH
        ADD DL, 30H
        MOV AH, 02H
        INT 21H
        DEC CL
        CMP CL, 0
        JNE PRINT_DIGITS
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

END MAIN