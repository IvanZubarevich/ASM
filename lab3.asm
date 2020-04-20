.model small
.stack 100h
.data
	i equ 3
	j equ 2
	numberSize equ 2
	array dw i*j dup(0)
	mulArray dw i dup(0)
	resultArray dw i dup(0)
	minus db 0
	enterredNum db 7, 7 dup('$')
	numBuffer dw 0
	msg1 db 10,13, "Enter number (-32768...32767): ", 10, 13, '$'
	msg2 db 10, 13, "Array: ", 10, 13, '$'
	msg3 db 10, 13, "Result: ", 10, 13, '$'
	msg4 db 10, 13, "Multiple Array: ", 10, 13, '$'
	errormsg db 10, 13, "Incorrect value!", 10, 13, '$'
	overflow db "Overflow $"
	space db " $"
	newLine db 10, 13, '$'
	numberTen dw 000Ah
	count dw ?
	x dw ?
	y dw ?
	flag dw 0	
.386
.code
main:

	mov ax, @data
	mov ds, ax
	mov es, ax
	xor ax, ax

	call inputArray
	call ShowArrayMsg
	call OutputArray
	call findMul
	lea dx, msg4
	call OutputString
	call printMul
	call findMaxMul
	lea dx, msg3
	call OutputString
	call printResult
	mov ax, 4C00h 
	int 21h 


   
inputArray proc

	xor si, si
	mov cx, i*j
	mov bx, offset array
    inputLoop:
	call ShowInputMsg
	push cx
	call inputNumbers
	pop cx
	mov array[bx], ax

	add bx, numberSize
	
    loop inputLoop
	ret
inputArray endp



ShowInputMsg proc                     
    push ax
    push dx                      
                                  
    mov ah,09h                    
    lea dx, msg1           
    int 21h   
    
    pop dx
    pop ax                    
    ret                           
ShowInputMsg endp


ShowArrayMsg proc                     
    push ax
    push dx                      
                                  
    mov ah,09h                    
    lea dx, msg2           
    int 21h   
    
    pop dx
    pop ax                    
    ret                           
ShowArrayMsg endp



inputNumbers proc                                     
    push bx
again:
    xor ax, ax
    xor cx, cx
    
    mov al, 7
    
    mov [enterredNum], al         
    mov [enterredNum+1], 0
    lea dx, enterredNum
    call input
    
    mov cl, [enterredNum+1]
    lea si, enterredNum
    add si, 2
    mov numBuffer, 0
    
    xor ax, ax 
    xor bx, bx
    xor dx, dx
    mov dx, 10        
    
    NextSym:
         xor ax, ax
         lodsb
         cmp bl, 0
         je checkMinus
    
    checkSym:
         
         cmp al, '0'
         jl invalidNum
         cmp al, '9'
         jg invalidNum
         
         sub ax, '0'
         mov bx, ax
         mov ax, numBuffer
         
         imul dx
         jo invalidNum
         cmp minus, 1
         je doSub
         add ax, bx

comeBack:
         jo invalidNum
         mov numBuffer, ax
         mov bx, 1
         mov dx, 10
         
    loop NextSym 
    
    mov ax, numBuffer 
    mov minus,0
    mov numBuffer, 0	
    pop bx
                          
    ret 

doSub:
    sub ax, bx
    jmp comeBack  
     
checkMinus:
    inc bl
    cmp al, '-'
    
    je SetMinus
    
    jmp checkSym
                  
SetMinus:
    mov minus,1
    dec cx
    cmp cx,0
    je invalidNum
    jmp NextSym
    
invalidNum:
    mov minus, 0
    call ErrorInput
    mov numBuffer, 0
    jmp again                            
endp



input proc 
    mov ah,0Ah
    int 21h
    ret
input endp



ErrorInput proc                   
    lea dx, errormsg      
    mov ah, 09h                   
    int 21h                       
    ret                           
endp 

outputString proc
    mov ah, 09h
    int 21h    
ret
outputString endp


OutputArray proc
    mov x, 0000h
    mov y, 0000h
    lea si, array
    jmp loop2  
loop1:      
    lea dx, newLine
    call outputString
    mov x, 0000h
    inc y 
    mov cx, y
    cmp cx, i
    je loop2return
loop2: 
    mov ax, [si]
    add si, numberSize    
    lea di, enterredNum[2]
    call numberToString
    lea dx, enterredNum[2]
    call outputString
    lea dx, space
    call outputString
    inc x
    mov cx, x
    cmp cx , j
    jne loop2 
    jmp loop1
loop2return:    
ret
endp 


numberToString proc
    push 0          
    push 0024h  
    add ax, 0000h      
    js numberIsNegative  
numberToStringLoop:    
    xor dx, dx
    div numberTen
    add dx, '0'
    push dx
    cmp ax, 0h
    jne numberToStringLoop   
moveNumberToBuffer:
    pop ax
    cmp al, '$'
    je endConverting
    mov [di], al
    inc di
    jmp moveNumberToBuffer
endConverting:
    pop ax
    mov byte ptr [di], '$'
ret

numberIsNegative:
    mov byte ptr [di], '-'
    inc di
    not ax          
    inc ax 
    jmp NumberToStringLoop 
numberToString endp    



findMul proc
    lea di, mulArray      
    lea si, array 
    mov x, 0000h
    mov y, 0000h
    xor ax, ax
    inc ax
    jmp mulLoop2  
mulLoop1:                               ;цикл по строкам
    mov [di], ax                        ;заносим в массив произведение строки
    add di, numberSize                  ;переход к следующему элементу массива, хранящего произведение строк                
    xor ax, ax
    inc ax 
    mov y, 0000h
    inc x 
    mov cx, x
    cmp cx, i
    je mulLoop2return
mulLoop2:                               ;цикл по элементам строки
    imul word ptr [si]                  ;умножение содержимого ax на число из массива
    jo overflowMul
     
mulLoop2next:
    add si, numberSize                ;переход к следующему элементу массива
    inc y
    mov cx, y
    cmp cx , j
    jne mulLoop2 
    jmp mulLoop1
mulLoop2return:    
ret
findMul endp


    
overflowMul: 
    mov word ptr [si], 0
    lea dx, overflow 
    call outputString
    xor ax, ax
    jmp mulLoop2next


printMul proc
    lea si, mulArray
    mov x, 0000h
    
startPrintMul:   
    mov ax, [si]     
    
    lea di, enterredNum[2]
    call numberToString

    lea dx, enterredNum[2]
    call outputString   
    
    lea dx, space
    call OutputString

nextPrint:    
    inc x
    add si, numberSize
    mov cx, x
    cmp cx, i
    jne startPrintMul 
ret
printMul endp

    

printNewLine proc
    lea dx, newLine
    call outputString
ret
printNewLine endp


findMaxMul proc
	lea di, mulArray
	lea si, resultArray
	mov x, 0000h
	mov cx, i-1               ;количество циклов
	mov count, 1              ;счетчик для подсчета номера строки
	xor ax, ax
	xor bx, bx
	mov ax, word ptr [di]     ;запоминаем произведение первой строки
	mov bx, count             ;запоминаем номер строки
	add di, numberSize
    findMax:
	jcxz eend
	
	add count, 1             ;увеличиваем значение строки
	dec cx                   
	cmp ax, word ptr [di]    ;сравниваем максимальное произведение с текущим произведением
	jl setRes1               
	jg setRes
	je setRes2
    setRes:
	mov [si], bx           ;заносим в массив результата номер строки с максимальным произведением
	add di, numberSize
	cmp cx, 0
	jne findMax
	je eend
    setRes1:
	mov bx, count                 ;запоминаем номер строки
	mov ax, word ptr [di]         ;запоминаем новое максимальное произведение
	mov [si], bx                  ;заносим в массив номер строки
	add di, numberSize            
	cmp cx, 0
	jne findMax
	je eend
    setRes2:                     ;если произведения строк равны
	cmp flag, 1
	je setRes22
	jne setRes21
	  setRes21:
		mov [si], bx              ;заносим номер строки с предыдущим максимальным произведением
		add si, numberSize       
		mov bx, count             ;запоминаем номер новой строки
		mov [si], bx              ;заносим номер строки в массив результата
		add di, numberSize
		add si, numberSize
		jmp endsetRes2
	   setRes22:
		mov bx, count             ;запоминаем номер новой строки
		mov [si], bx              ;заносим номер строки в массив результата
		add di, numberSize
		add si, numberSize
		jmp endsetRes2
        endsetRes2:
	   mov flag, 1
	   cmp cx, 0
	   jne findMax
	   je eend
   eend:
	ret
endp

printResult proc
    lea si, resultArray
    mov x, 0000h
    
startPrintArray:   
    mov ax, [si]     
    cmp ax, 0
    je endPrint 
    lea di, enterredNum[2]
    call numberToString

    lea dx, enterredNum[2]
    call outputString   
    lea dx, space
	call OutputString

next_Print:    
    inc x
    add si, numberSize
    mov cx, x
    cmp cx, i
    jne startPrintArray 
endPrint:
ret
printResult endp


end main                       