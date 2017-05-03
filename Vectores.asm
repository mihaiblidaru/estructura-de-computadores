######################################################################
## Fichero: Vector.asm
## Descripción: Hace la operación C[i] = A[i] + B[i]*4 en un bucle desde 0 hasta i
## Autores: Mihai Blidaru & Juan Felipe Carreto 
## Asignatura: E.C. 1º grado
## Grupo de Prácticas: 2121
## Grupo de Teoría: 212
## Práctica: 4
## Ejercicio: 1
## Pareja: 6
######################################################################

.text 
    lw $t1, N            # $t1 = N (valor máximo del contador del bucle)
    add $t1, $t1, $t1    # $t1 = N + N
    add $t1, $t1, $t1    # $t1 = (N + N) + (N + N) = N *4
for:     
    beq $t4, $t1, Fin    # Equivalente a Si i = 10, saltar al final
    lw $t2, A($t4)       # Carga A en $t2
    lw $t3, B($t4)       # Carga B en $t3
    add $t3, $t3, $t3    # t3 = B + B
    add $t3, $t3, $t3    # t3 = (B + B) + (B+B) = B * 4
    add $t2, $t2, $t3    # $t2 = A + B * 4
    sw $t2, C($t4)       # Guardan en memoria
    addi $t4, $t4, 4     # Incrementar el indice del bucle
    j for                # Volver a ejecutar el bucle
    
Fin:    
    j Fin                # Fin del programa
    
.data
N: .word 6     # número de iteraciones del bucle
A: .word  2,  4, 6,  8, 10, 12    # array A
B: .word -1, -5, 4, 10,  1, -5    # array B
C: .space 24    # array C


