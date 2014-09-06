global lista_crear
global nodo_crear
global lista_borrar
global lista_concatenar
global lista_colgar_descendiente
global lista_imprimir
global lista_filtrar
global lista_colapsar

global tiene_ceros_en_decimal
global parte_decimal_mayor_que_un_medio
global tiene_numeros
global raiz_cuadrada_del_producto
global raiz_de_la_suma
global revolver_primeras_5

global nodo_acceder
global nodo_borrar_con_hijos
global nodo_ultimo
global nodo_ultimo_hijo
global nodo_concatenar
global valor_imprimir
global nodo_imprimir_columna
global nodo_colapsar


extern malloc
extern free
extern strlen
extern strncpy
extern fopen
extern fputs
extern fclose
extern fprintf
extern fwrite
extern snprintf
extern strchr
extern fabs
extern trunc
extern nearbyint
; auxiliares ...


; cambiar las xxx por su valor correspondiente

%define TAM_LISTA 8
%define TAM_NODO 28
; %define TAM_dato_int xxx
; %define TAM_dato_double xxx
; %define TAM_puntero xxx
; %define TAM_value xxx
; %define offset_primero   xxx
%define offset_tipo	0
%define offset_siguiente 4
%define offset_hijo	12
%define offset_valor 20
%define ENUM_int 0
%define ENUM_double	1
%define ENUM_string	2

%define NULL 0

section .data

	append: db 'a',0
	vacia: db '<vacia>',0
	abrirCorchete: db '{ '
	cerrarCorchete: db ' }'
	abrirParentesis: db '[ '
	cerrarParentesis: db ' ]'
	formatoString: db '%s',0
	formatoDouble: db '%f',0
	formatoInt: db '%d',0
	unMedio: dq 0.5
	nuevaLinea: db 10
	espacio: db 32

section .text

;------------------------------------------------------------------------
; ~ lista_colgante_t* lista_crear();
lista_crear:
	
	push rbp
	mov rbp, rsp	

	mov rdi, TAM_LISTA		;Cantidad de bytes que voy a pedir
	call malloc
	mov QWORD [rax], NULL
	
	pop rbp
	;rax contiene la direccion de memoria donde comienzan los 8 bytes.

	ret


;------------------------------------------------------------------------
; ~ nodo_t* nodo_crear(tipo_elementos tipo, valor_elemento value)
	
	;edi = tipo_elemento
	;rsi = valor
	
nodo_crear:

	push rdx
	push rdi
	push rsi		;malloc lo modifica
	
	mov rdi, TAM_NODO		;Cantidad de bytes que quiero pedir
	call malloc		
	
	;Los 28 bytes estan divididos de la siguiente manera:
	;Los bytes 0..3 corresponden al campo tipo del struct
	;Los bytes 4..11 corresponden al campo siguiente del struct
	;Los bytes 12..19 corresponden al campo hijo del struct
	;Los bytes 20..27 corresponden al campo valor
	
	pop rsi
	pop rdi
	
	mov DWORD [rax+offset_tipo], edi
	mov QWORD [rax+offset_siguiente], NULL
	mov QWORD [rax+offset_hijo], NULL
	mov QWORD [rax+offset_valor], rsi		;Copio el puntero al string en el campo valor
		
	pop rdx

	ret


;------------------------------------------------------------------------
; ~ void lista_borrar(lista_colgante_t* self);

lista_borrar:
	;rdi = puntera a lista_colgante_t
	
	push rbp
	mov rbp, rsp
	push rdi
	push r15
	
	mov rdi, [rdi]			;rdi = "primero"
	cmp QWORD rdi, NULL
	je .fin
	
.borrar:

	mov r15, [rdi+offset_siguiente]			;r15 apunta al siguiente nodo a borrar
	call nodo_borrar_con_hijos				;Borro toda la columna
	mov rdi, r15							;rdi apunta al siguiente nodo a borrar
	cmp QWORD r15, NULL						;Se fija si hay siguiente nodo a borrar; si no lo hay, salgo
	jne .borrar
	
	
.fin:
	
	pop r15
	pop rdi
	call free					;Libero la lista_colgante_t
	pop rbp
	
	ret
	
	
;------------------------------------------------------------------------
; ~ void lista_concatenar(lista_colgante_t* self, nodo_t* siguiente)
lista_concatenar:
	;rdi = puntero a lista colgante
	;rsi = puntero al nodo siguiente
	;rdi contiene un puntero a lista_colgante_t, que a su vez tiene un puntero a nodo
	;por lo tanto, rdi = nodo_t**
	
	push rbp
	mov rbp, rsp
	push rdi
	
	cmp QWORD rdi, NULL
	je .fin
	
	call nodo_ultimo
	mov rdi, rax
	call nodo_concatenar
	
.fin:
	
	pop rdi
	pop rbp
		
	ret
	
	
	
;------------------------------------------------------------------------
; ~ void lista_colgar_descendiente(lista_colgante_t* self, uint posicion, nodo_t* hijo)
lista_colgar_descendiente:
	;rdi = lista colgante
	;esi = posicion
	;rdx = nodo hijo

	push rbp
	mov rbp, rsp
	push rdi
	push rsi
	push rdx
	
	cmp QWORD [rdi], NULL				;Si no hay nodos, llamo a concatenar.
	je .concatenar
	jmp .seguir
	
.concatenar:
	
	mov rsi, rdx						;rsi = puntero a nodo
	call nodo_concatenar
	jmp .fin

.seguir:	
	mov rdi, [rdi]						;rdi apunta al primer nodo
	call nodo_acceder
	mov rdi, rax						;rdi = puntero al nodo base al cual le quiero añadir un descendiente
	call nodo_ultimo_hijo
										;rax = puntero al ultimo hijo del nodo base al cual le quiero colgar un descendiente
	mov QWORD [rax+offset_hijo], rdx 	;a este ultimo nodo le agrego un puntero al nodo hijo

.fin:	
	
	pop rdx
	pop rsi
	pop rdi
	pop rbp
	
	ret



;------------------------------------------------------------------------
; ~ void lista_filtrar(lista_colgante_t* self, nodo_bool_method test_method)
	
	lista_filtrar:

	;rdi = puntero a lista_borrar
	;rsi = puntero a funcion
	push r13
	push r14
	push r15
	push rdi
	push rsi
	
	cmp QWORD [rdi], NULL  	;Me fijo que hayan nodos
	je .fin
	
	mov r13, rdi			;En r13 mantengo un nodo_t**, que es un puntero al puntero que apunta al nodo previo al apuntado
							;actualmente por rdi. O sea, rdi = puntero al nodo actual, r13 = puntero al puntero al nodo previo
	mov rdi, [rdi]			;Apunto al primer nodo
	

.evaluar:
	
	cmp QWORD rdi, NULL
	je .fin

	mov r15, rsi
	call rsi				;Llamo a la función que testea un nodo
	mov rsi, r15
	cmp QWORD rax, 1		;Si da true, aplico el filtro, sino, solo muevo los punteros
	je .aplicarFiltro
	
	mov r14, [r13]
	lea r13, [r14+offset_siguiente]	;Muevo r13
	mov rdi, [rdi+offset_siguiente]
	jmp .evaluar
	

.aplicarFiltro:
	
	mov r14, rdi					;r14 = puntero al nodo actual
	mov r15, rsi					;r15 = puntero a la funcion
	
	mov rdi, r13					;rdi = puntero al puntero al nodo previo al apuntado por rdi
	mov rsi, [r14+offset_siguiente]	;rsi = puntero al siguiente nodo del apuntado por rdi (puede ser NULL)
	call nodo_concatenar
	 
	mov rdi, r14					;Recupero rdi
	call nodo_borrar_con_hijos		;borro toda la columna
	mov rdi, rsi					;rdi = puntero al proximo nodo.
	mov rsi, r15					;rsi = puntero a la funcion
	
	jmp .evaluar
	


.fin:
	
	pop rsi
	pop rdi
	pop r15
	pop r14
	pop r13
	
	ret


;------------------------------------------------------------------------
; ~ void lista_colapsar(lista_colgante_t* self, nodo_bool_method test_method, nodo_value_method join_method);

lista_colapsar:
	
	;rdi = puntero a lista
	;rsi = puntero a funcion de test
	;rdx = puntero a funcion de join
	push rdi
	push rsi
	push rdx
	push r11
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	cmp QWORD [rdi], NULL  	;Me fijo que hayan nodos
	je .fin
	
	mov r13, rdi			;r13 = nodo_t**
	
.evaluar: 
	
	mov rdi, [r13]						;rdi = nodo_t*

	cmp QWORD rdi, NULL
	je .fin
	
	cmp QWORD [rdi+offset_hijo], NULL 	;Me fijo si el nodo base tiene hijos
	je .avanzar
	
	mov r15, rdi						;r15 = nodo_t*
	mov r14, rsi						;r14 = puntero a funcion test
	mov r12, rdx						;r12 = puntero a funcion join
	call rsi							;Veo si tengo que colapsar
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12

	cmp QWORD rax, 1
	je .crearNodoYColapsar
	
.avanzar:
	mov r15, [r13]
	lea r13, [r15+offset_siguiente]		;Avanzo r13
	jmp .evaluar
	
.crearNodoYColapsar:
	
	mov r14, rsi							;r14 = funcion test
	mov r15, rdi							;r15 = nodo_t*
	mov r12, rdx							;r12 = funcion join
	
	cmp DWORD [r15+offset_tipo], ENUM_string
	je .crearNodoString
	jmp .crearNodo
	

.crearNodo:
							
	mov rdi, [r15+offset_tipo]
	mov rsi, [r15+offset_valor]
	call nodo_crear
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12
	jmp .colapsar


.crearNodoString:

	mov rdi, [r15+offset_valor]
	call strlen
	inc rax
	mov rbx, rax
	mov rdi, rax
	call malloc
	mov rdi, rax
	mov rsi, [r15+offset_valor]
	mov rdx, rbx
	call strncpy
	mov rdi, [r15+offset_tipo]
	mov rsi, rax
	call nodo_crear
	mov rdi, r15
	mov rsi, r14
	mov rdx, r12

	
	jmp .colapsar



.colapsar:

	mov r15, rdi 						;Me guardo el puntero al nodo_t
	mov r14, rsi						;Me guardo el puntero a la funcion de test
	mov r12, rdx						;Me guardo el puntero a la funcion de join
	
	
	mov rdi, r13						;rdi = nodo_t**
	mov rsi, rdx						;rsi = funcion de join
	mov rdx, rax						;rdx = puntero al nuevo nodo
	call nodo_colapsar					;Colapso el nodo base
	
	mov rdi, r15						;Recupero todo
	mov rsi, r14
	mov rdx, r12
	
	mov r15, [r13]
	lea r13, [r15+offset_siguiente]		;Avanzo r13
	jmp .evaluar


.fin:

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rdx
	pop rsi
	pop rdi

	ret




;------------------------------------------------------------------------
;   void nodo_colapsar(nodo_t** self_pointer, nodo_value_method join_method)


nodo_colapsar:

	push rdi
	push rsi
	push rdx
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	;rdx = puntero al nuevo nodo donde voy a almacenar el resultado de colapsar todo
	mov rdi, [rdi]								;rdi = puntero a nodo base
	mov rbx, rdi								;Me guardo en rbx el puntero al inicio de la columna, para despues poder borrarla
												;con nodo_borrar_con_hijos
	
	mov r12, QWORD [rdi+offset_siguiente]		;Basicamente saco la columna anterior y pongo en su lugar el nuevo nodo
	mov QWORD [rdx+offset_siguiente], r12
	mov r12, r13
	mov QWORD [r12], rdx

	
	mov r14, [rdi+offset_hijo]					;r14 = puntero al primer hijo
	
.evaluar:
	
	cmp QWORD r14, NULL
	je .fin
	
	mov r12, rdx								;Me guardo el puntero al nodo base (al nuevo que cree)
	mov r13, rsi								;Me guardo el puntero a la funcion de join
	mov r15, rsi
	
	mov rdi, [r12+offset_valor]					;rdi = valorA
	mov rsi, [r14+offset_valor]					;rsi = valorB
	call r15									;Llamo a la funcion
	mov rdx, r12								;Recupero los punteros
	
	;Actualizo el nuevo nodo base
	cmp DWORD [rdx+offset_tipo], ENUM_string
	je .actualizarCasoString
	jmp .actualizarOtroCaso	
	
	
.actualizarOtroCaso	:
	
	mov QWORD [rdx+offset_valor], rax			;Guardo el resultado de la funcion

	jmp .continuar
	
.actualizarCasoString:
	
	mov r12, rax								;Guardo el puntero al nuevo string
	mov r15, rdx								;Guardo el puntero al nuevo nodo
	mov rdi, [rdx+offset_valor]
	call free									;Libero el viejo string
	mov rax, r12
	mov rdx, r15
	mov [rdx+offset_valor], rax					;Guardo el puntero al nuevo string

	jmp .continuar
	
	
	
.continuar:
	
	mov r14, [r14+offset_hijo]					;Apunto al proximo hijo
	mov rsi, r13								;Recupero el puntero a la funcion join
 	
 	jmp .evaluar
	
.fin:

	mov rdi, rbx
	call nodo_borrar_con_hijos					;Libero toda la columna vieja

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rdx
	pop rsi
	pop rdi	

	ret



;-------------------------------------------------------------
;	void nodo_borrar_con_hijos(nodo_t* self)
nodo_borrar_con_hijos:
	
	;rdi = puntero a nodo_t
	;Si el puntero no es NULL, lo borro y me muevo a su hijo.
	;Si el puntero es NULL, termino.
	
	push rdi
	push rsi	
	push rdx
	push rbx
	push r11
	push r12
	push r13
	push r14
	push r15
		
	cmp rdi, NULL
	je .fin
	
.seguirEvaluando:

	mov QWORD r15, [rdi+offset_hijo]		;r15 = hijo del nodo apuntado por rdi
	cmp DWORD [rdi+offset_tipo], ENUM_string
	je .conString
	jmp .sinString

.conString:
	
	mov r14, rdi
	mov QWORD rdi, [rdi+offset_valor]
	call free					;Libero el string
	mov rdi, r14
	call free					;Libero el nodo self
	mov rdi, r15				;rdi ahora apunta al hijo del nodo al que apuntaba previamente
	cmp r15, NULL				;Comparo el puntero al hijo con NULL
	jne .seguirEvaluando
	jmp .fin

.sinString:
	
	call free					;Libero el nodo padre
	mov rdi, r15				;rdi ahora apunta al hijo del nodo al que apuntaba previamente
	cmp r15, NULL				;Comparo el puntero al hijo con NULL
	jne .seguirEvaluando
	jmp .fin
	
.fin:
		
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rbx
	pop rdx
	pop rsi
	pop rdi

	ret



;-------------------------------------------------------------
;	nodo_t* nodo_ultimo_hijo(nodo_t* self)
nodo_ultimo_hijo:
	
	;rdi = puntero a nodo_t
	;Chequeo que el puntero no sea null, de no ser asi comparo el campo hijo con NULL
	;Si es NULL, guardo en rax un puntero al nodo actual
	;Sino, actualizo a rdi para que apunte al hijo del nodo actual
	push rdi
	cmp rdi, NULL
	jnz .seguirEvaluando
	jmp .fin
	
.seguirEvaluando:
	
	cmp QWORD [rdi+offset_hijo], NULL
	je .fin									;Si el campo hijo es NULL, salto a .fin	
	mov rdi, QWORD [rdi+offset_hijo]		;Sino, self = self->hijo
	jmp .seguirEvaluando


.fin:

	mov rax, rdi
	
	pop rdi
	
	ret
	

;-------------------------------------------------------------
;   nodo_t* nodo_acceder(nodo_t* self, uint posicion)
nodo_acceder:

	push rdi
	push rsi

	cmp QWORD rdi, NULL
	je .fin
	
	cmp esi, 0				;Si posicion = 0, devuelvo self
	je .fin
	
.Continuar:
	
	cmp QWORD rdi, NULL
	je .fin
	mov rdi, [rdi+offset_siguiente]
	sub esi, 1
	cmp esi, 0
	jne .Continuar
	
	
.fin:

	mov rax, rdi	
	
	pop rsi
	pop rdi
	
	ret


;-------------------------------------------------------------
;   void nodo_concatenar(nodo_t** self, nodo_t* siguiente)
nodo_concatenar:
	
	mov QWORD [rdi], rsi
		
	ret

;-------------------------------------------------------------
;   nodo_t** nodo_ultimo(nodo_t** self)
nodo_ultimo:

	push rdi
	push r15
	
	mov rax, rdi
	mov rdi, [rdi]				;rdi = primero
	cmp QWORD rdi, NULL
	je .fin
	
.seguirBuscando:

	lea r15, [rdi+offset_siguiente]
	mov rax, r15
	cmp QWORD [r15], NULL
	je .fin
	mov QWORD rdi, [r15]
	jmp .seguirBuscando
	
	
.fin:

	pop r15
	pop rdi
	
	ret
	
	

;------------------------------------------------------------------------
; ~ void lista_imprimir(lista *self, char *archivo)
lista_imprimir:
	
	push rbp
	mov rbp, rsp
	push r14
	push r15
	push r13
	push r12
	
	mov r14, rdi
	mov r15, rsi
	
	mov rdi, rsi			;rdi = nombre del archivo
	mov rsi, append 		;rsi = modo
	call fopen		
							;rax = puntero a FILE*
	mov rdi, r14
	mov r13, rax			;Me guardo el puntero al principio del stream, para poder cerrar el archivo despues	
	mov rsi, rax			;rsi = puntero a stream

	
	cmp QWORD [rdi], NULL	;Me fijo si hay nodos
	je .lista_vacia
	mov rdi, [rdi]			;Me paro en "primero"
	jmp .lista_con_nodos
	
.lista_vacia:

	mov r14, rdi			;r14 = puntero a lista
	mov r15, rsi			;r15 = puntero a archivo

	mov rdi, vacia
	mov rsi, rax			;rsi = FILE* stream
	call fputs
			
	jmp .fin
	
	
.lista_con_nodos:
	
	mov rsi, r13							;rsi = FILE*
	call nodo_imprimir_columna
	cmp QWORD [rdi+offset_siguiente], NULL	;Me fijo si hay mas nodos base
	je .fin
	
	mov r12, rdi
	mov rdi, espacio						;rdi = ' '
	mov esi, 1
	mov edx, 1
	mov rcx, r13
	call fwrite
	
	mov rdi, r12
	
	mov rdi, [rdi+offset_siguiente]			;Apunto al proximo nodo
	jmp .lista_con_nodos
	

.fin:
	
	mov rdi, nuevaLinea		;rdi = "\n"
	mov esi, 1				;rsi = FILE* original
	mov edx, 1
	mov rcx, r13
	call fwrite
	
	mov rdi, r13			;rdi = FILE* original
	call fclose
	
	mov rdi, r14
	mov rsi, r15
	
	pop r12
	pop r13
	pop r15
	pop r14
	pop rbp
	
	ret
	
	
	
	
;-------------------------------------------------------------
;   void nodo_imprimir_columna(nodo_t* self, FILE* stream)
nodo_imprimir_columna:
	
	;rdi = puntero a nodo_t
	;rsi = puntero al archivo
	push rbp
	push r14
	push r15
	push rdi
	push rdx
	
	mov r15, rdi				;Me guardo el puntero a nodo_t
	mov r14, rsi				;puntero a stream original
	
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx
		
	mov rdi, abrirCorchete		;Quiero imprimir en el archivo un '{ '
	mov esi, 1
	mov edx, 2
	mov rcx, r14
	call fwrite	
	
	cmp QWORD rdi, NULL			;Chequeo que haya un nodo
	je .fin
	

.seguirImprimiendo:
	
	xor rdi, rdi
	xor rsi, rsi
	mov edi, [r15+offset_tipo]
	mov rsi, [r15+offset_valor]
	mov rdx, r14						;rdx = puntero al stream
	call valor_imprimir					;Imprimo el nodo apuntado por self
	mov rdi, r15						;Recupero el puntero al nodo_t
	cmp QWORD [rdi+offset_hijo], NULL	;Si el puntero a nodo_t es NULL, termino. Sino, paso a apuntar a su hijo
	je .fin
	mov rdi, [rdi+offset_hijo]			;Me muevo al hijo
	mov r15, rdi
	jmp .seguirImprimiendo
	
.fin:
	
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx

	mov rdi, cerrarCorchete			;rdi = ' }'
	mov esi, 1
	mov edx, 2
	mov rcx, r14
	call fwrite					;Imprimo un ' }' para cerrar la columna
	
	mov rsi, r14

	pop rbx
	pop rdi
	pop r15
	pop r14
	pop rbp	
	
	ret
	
	
;-------------------------------------------------------------
;   void valor_imprimir(tipo_elementos tipo, valor_elemento valor, FILE* stream)
valor_imprimir:
	
	push rbp
	mov rbp, rsp
	push r13
	push r14
	push r15
	push rdx
	
	mov r13, rdi				;r13 = tipo
	mov r14, rsi				;r14 = valor_imprimir
	mov r15, rdx				;r15 = puntero al stream
	
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx
	mov rdi, abrirParentesis	
	mov esi, 1					
	mov edx, 2
	mov rcx, r15
	call fwrite				;Imprimo el corchete en el archivo
	
	cmp QWORD r13, ENUM_string		;Veo que tipo de dato tengo que imprimir
	je .imprimirString
	cmp QWORD r13, ENUM_double
	je .imprimirDouble
	jmp .imprimirInt
	

.imprimirString:

	mov rdi, r15				;rdi = puntero al stream
	mov rsi, formatoString		;rsi = "%s"
	mov rdx, r14				;rdx = puntero al string
	mov rax, 1
	call fprintf
	
	jmp .fin
	

.imprimirDouble:

	mov rdi, r15				;puntero al stream
	mov rsi, formatoDouble		;rsi = "%f"
	pxor xmm0, xmm0
	movq xmm0, r14				;xmm0 = valor a imprimir
	mov rax, 1
	call fprintf
	
	jmp .fin

.imprimirInt:
	
	xor rdx, rdx
	mov rdi, r15				;rdi = puntero al stream
	mov rsi, formatoInt			;rsi = "%d"
	mov edx, r14d				;rcx = valor a imprimir
	mov rax, 1
	call fprintf

	jmp .fin
	
	
.fin:

	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx
	mov rdi, cerrarParentesis	
	mov esi, 1					
	mov edx, 2
	mov rcx, r15
	call fwrite

	pop rdx
	pop r15
	pop r14
	pop r13
	pop rbp
	
	ret




;-------------------------------------------------------------
;   boolean tiene_ceros_en_decimal(nodo_t* n)
tiene_ceros_en_decimal:
	
	push r11
	push r14
	push rdi
	push rsi
	sub rsp, 8
	
	xor r14, r14
	mov r14d, [rdi+offset_valor]

	cmp DWORD r14d, 0
	je .noHayCero
	
	lea rdi, [rbp-24]		;rdi = puntero a buffer en el stack
	mov rsi, 8				;rsi = tam buffer
	mov rdx, formatoInt		;rdx = "%d"
	mov rcx, r14			;rcx = numero
	call snprintf			;Convierto el numero en string

	
	lea rdi, [rbp-24]		;rdi = puntero al buffer
	mov rsi, 48				;0 en ascii
	call strchr				;Recorro el string para ver si tiene un cero
	
	cmp QWORD rax, NULL		;Si el puntero no es null, quiere decir que encontro un cero
	jne .hayCero

.noHayCero:
	;abarca el caso en que el numero es un 0 solo, en cuyo caso hago de cuenta que no hay cero
	mov rax, 0
	jmp .fin
	
.hayCero:
	
	mov rax, 1
	
.fin:
	
	add rsp, 8
	pop rsi
	pop rdi
	pop r14
	pop r11
	
	ret



;-------------------------------------------------------------
;   boolean parte_decimal_mayor_que_un_medio(nodo_t* n)
parte_decimal_mayor_que_un_medio:

	push r11
	push rdi
	push rcx
	push r15
	sub rsp, 8
	
	movq xmm1, [rdi+offset_valor]
	movsd xmm0, xmm1			;xmm0 = valor
	call fabs					;xmm0 = |valor|
	movsd xmm1, xmm0			;xmm1 = |valor|
	movsd xmm2, xmm0			;xmm2 = |valor|
	call trunc					
	movsd xmm1, xmm0			;xmm1 = [|valor|]
	movsd xmm0, xmm2			;xmm0 = |valor|
	subsd xmm2, xmm1			;xmm2 = |valor| - [|valor|]
	cvttsd2si rcx, xmm2			;trunco xmm2, es decir, me quedo con la parte entera
	mov r15, rcx
	movsd xmm0, xmm2 
	call fabs					;Aplico valor absoluto, por si la resta anterior me quedo negativa
	call nearbyint				;Por otro lado, lo redondeo al entero mas cercano (si xmm0 <= 0.5 ===> xmm0 = 0.0)
	mov rcx, r15
	cvttsd2si rbx, xmm0			;trunco xmm0, es decir, me quedo con la parte entera
	cmp rbx, rcx				;Si son distintos, la parte decimal es mayor a un medio; sino, menor.
	jne .mayor_un_medio
	mov rax, 0
	jmp .fin
	
.mayor_un_medio:

	mov rax, 1
	
.fin:

	add rsp, 8
	pop r15
	pop rcx
	pop rdi
	pop r11
	
	ret


;-------------------------------------------------------------	
;valor_elemento raiz_cuadrada_del_producto(valor_elemento valorA, valor_elemento valorB)

raiz_cuadrada_del_producto:
	
	push rdx
	push r11
	push r14
	
	xor rax, rax
	mov eax, edi
	imul esi
	cmp eax, 0
	jle .negativoOCero
	
	cvtsi2ss xmm0, eax			;xmm0 = valorA * valorB
	movss xmm1, xmm0			;xmm1 = xmm0
	sqrtss xmm0, xmm1			;xmm0 = sqrt(xmm1)
	cvttss2si eax, xmm0			;eax = xmm0 (parte entera)
	
	jmp .fin
	
.negativoOCero:

	mov eax, 0
	
.fin:
	
	pop r14
	pop r11
	pop rdx
	
	ret

	

;-------------------------------------------------------------	
;  boolean tiene_numeros(nodo_t* n)
tiene_numeros:
	
	push r11
	push r13
	push r14
	push r15
	push rdi
	
	xor rcx, rcx
	mov rcx, 10						;Cantidad de veces que voy a iterar
	mov rdi, [rdi+offset_valor]		;rdi = puntero al string
	mov r14, rdi
	mov rsi, 47						

.seguirBuscando:
	
	mov rdi, r14
	inc rsi							;Busco si tiene un cero
	mov r15, rsi					;Guardo el numero de caracter que estoy buscando
	mov r13, rcx					;Guardo el contador						
	call strchr
	mov rcx, r13					
	mov rsi, r15
	cmp rax, NULL
	jne .hayNumeros
	loop .seguirBuscando
	
	mov rax, 0
	jmp .fin
	
.hayNumeros:

	mov rax, 1
	jmp .fin
	
.fin:

	pop rdi
	pop r15
	pop r14
	pop r13
	pop r11
	
	ret



;-------------------------------------------------------------	
;   valor_elemento raiz_de_la_suma(valor_elemento valorA, valor_elemento valorB)

raiz_de_la_suma:

	;rdi = valorA
	;rsi = valorB

	movq xmm0, rdi
	movq xmm1, rsi
	addsd xmm0, xmm1	;xmm0 = xmm0 + xmm1
	cvttsd2si rax, xmm0	;rax = xmm0
	sqrtsd xmm1, xmm0	;xmm1 = sqrt(xmm0)
	movq rax, xmm1		;rax = xmm1 convertido a entero signado
	jmp .fin

.ceroONegativo:

	mov rax, 0

.fin:

	ret


;-------------------------------------------------------------	
;   valor_elemento revolver_primeras_5(valor_elemento vA, valor_elemento vB);
revolver_primeras_5:

	;edi = valorA
	;esi = valorB
	push rdi
	push rsi
	push r11
	push r12			;Buffer temporal para los caracteres
	push r13
	push r14
	push r15
	push rbx			;Aca guardo la cantidad de caracteres que voy a terminar copiando
	sub rsp, 8
	
	xor rbx, rbx		
	
	mov r13, rdi		;r13 = valorA
	mov r14, rsi		;r14 = valorB
	mov rdi, 11			;Tamaño del nuevo string
	call malloc
	mov r15, rax		;r15 = nuevo string (res)
	
	;Calculo la cantidad de caracteres que voy a terminar copiando
	mov rdi, r13
	call strlen
	
	add rbx, rax
	mov rdi, r14
	call strlen

	add rbx, rax
	mov rax, 10
	cmp rbx, rax
	jg .copiarSolo10
	jmp .seguir
	
	
.copiarSolo10:
	mov rbx, 10			;Si entre los 2 strings hay mas de 10 caracteres, la longitud final va a ser 10
	
.seguir:
	xor rcx, rcx
	mov rcx, 5		
	;Chequeo que ambos string tengan caracteres. De ser asi, pongo en r15 
	;un caracter de cada uno, avanzo los punteros y sigo evaluando.
	;Si alguno de los 2 esta vacio, directamente vuelco lo que queda del 
	;otro string en r15.
.evaluar:

	cmp BYTE [r13], NULL
	je .stringAVacio
	cmp BYTE [r14], NULL
	je .stringBVacio
	
	mov r12b, BYTE [r13]
	mov BYTE [r15], r12b		;Copio 1 caracter del string A
	mov r12b, BYTE [r14]
	mov BYTE [r15+1], r12b		;Copio 1 caracter del string B
	add r15, 2					;Avanzo el puntero de res
	add r13, 1					;Avanzo el puntero del string A
	add r14, 1					;Avanzo el puntero del string B
	
	loop .evaluar				;Como mucho itero 5 veces, asi que como mucho meto 10 caracteres en r15
		
	jmp .fin
	
	
.stringAVacio:
	
	;rcx = cantidad de caracteres que me faltan copiar
	;Entonces, rcx + 2 * cant. iteraciones realizadas = cantidad de caracteres copiados en total
	;Ahora, realizo esa cuenta

	mov rax, 5
	sub rax, rcx				;rax = cantidad de iteraciones que hice
	shl rax, 1					;rax = cantidad de caracteres que copie hasta el momento
	mov rcx, rbx
	sub rcx, rax				;rcx = cantidad de caracteres que me faltan copiar
	

.evaluarB:

	cmp QWORD rcx, 0
	je .fin
	cmp BYTE [r14], NULL		;Chequeo que hayan caracteres para copiar
	je .fin
	
	mov r12b, BYTE [r14]
	mov BYTE [r15], r12b		;Copio 1 caracter del string B
	add r15, 1					;Avanzo los punteros
	add r14, 1
	sub rcx, 1

	jmp .evaluarB
	
	
.stringBVacio:	


	;rcx = cantidad de caracteres que me faltan copiar
	;Entonces, rcx + 2 * cant. iteraciones realizadas = cantidad de caracteres copiados en total
	;Ahora, realizo esa cuenta

	mov rax, 5
	sub rax, rcx				;rax = cantidad de iteraciones que hice
	shl rax, 1					;rax = cantidad de caracteres que copie hasta el momento
	mov rcx, rbx
	sub rcx, rax				;rcx = cantidad de caracteres que me faltan copiar
	
	
.evaluarA:

	cmp QWORD rcx, 0
	je .fin 
	cmp BYTE [r13], NULL		;Chequeo que hayan caracteres para copiar
	je .fin
	
	mov r12b, BYTE [r13]
	mov BYTE [r15], r12b		;Copio 1 caracter del string A
	add r15, 1					;Avanzo los punteros
	add r13, 1
	sub rcx, 1
	
	jmp .evaluarA
	
	
.fin:

	mov BYTE [r15], NULL		;Finalizo el nuevo string
	sub r15, rbx				;Lo posiciono al principio del string
	mov rax, r15
	
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rsi
	pop rdi
	
	ret
	




