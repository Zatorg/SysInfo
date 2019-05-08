
.data
buf:            .space 10
                .align 2
buff:            .space 12
                .align 2
const1e9:       .word 1000000000


        .text
main:                                   # Programmbeginn

# Zeichenkette einlesen
        add     a0, zero, 0             # stdin
        add     a1, zero, buf       	# Adresse des Puffers
        add     a2, zero, 10            # Maximal 10 Zeichen
        add     a7, zero, 63            # read
        scall
        nop                             # nach syscall 63 immer 3 Nops
        nop
        nop

# Zeichenkette in Zahl umwandeln
        add     a1, zero, a0           	# L�nge der Zeichenkette
        add     a0, zero, buf           # Adresse der Zeichenkette
        jal     str2int

# Fakult�t berechnen
		
		add		t0, zero, a0
		add		t1, zero, 1

loop:
		beq     t0, zero, fertig
		mul		t1, t1, t0
		add		t0, t0, -1
		j		loop

fertig:

# Ergebnis ausgeben
		add		a0, zero, t1
		add		a1, zero, buff
		jal		int2str

		add     a2, zero, a0            # L�nge steht in a0
        add     a0, zero, 1             # stdout
        add     a1, zero, buff          # Adresse des Puffers
        add     a7, zero, 64            # syscall 64: write
        scall

# Programm beenden
		add 	a0, zero, 0				# 0 als Exitcode
        add     a7, zero, 93            # sycall 93: exit
        scall

# -------------------------------------------------------------------------------
# str2int: Unterprogramm um eine Zeichenkette in eine Zahl umzuwandeln
#       a0: Adresse der Zeichenkette
#       a1: L�nge der Zeichenkette
# zur�ck:
#       a0: Umgewandelte Zahl
# -------------------------------------------------------------------------------

str2int:
        add     t2, zero, zero          # t2=0 (R�ckgabewert)
        add     t0, zero, 10            # t0=10 (Konstante)
        add     a1, a1, a0              # a1= Ende der Zeichenkette

_str2int_loop:
        lb      t1, 0(a0)
        add     t1, t1, -48
        bgeu    t1, t0, _str2int_exit   # Abbruch, wenn keine Ziffer
        mul     t2, t2, t0
        add     t2, t2, t1
        add     a0, a0, 1               # ein Zeichen weiter
        blt     a0, a1, _str2int_loop   # Solange Ende nicht erreicht

_str2int_exit:
        add     a0, zero, t2            # schreibe Zahl in R�ckgaberegister
        ret                             # kehre zum Aufrufer zur�ck


# -------------------------------------------------------------------------------
# int2str: Unterprogramm um eine Zahl in eine Zeichenkette umzuwandeln
#       a0: umzuwandelnde Zahl
#       a1: Adresse des Zeichenkettenpuffers, mindestens 10 Bytes lang, da die
#           Zahl maximal 2^31-1 = 4 294 967 295 sein kann.
# zur�ck:
#       a0: Tats�chliche L�nge der Zeichenkette
# -------------------------------------------------------------------------------

int2str:
        add     t0, zero, 10
        add     t3, zero, 1
        beq     a0, zero, _int2str_max  # Spezialfall: "0" ausgeben
        add     t3, zero, 10            # t3= Maximale L�nge der Ausgabe
        lui     t1, 0x3b9ad             # t1= 0x3b9ad000
        add     t1, t1, -0x600          # t1= 0x3b9ad000-0x600=0x3b9aca00
                                        #   = 1000000000 = 10^9
        bltu    t1, a0, _int2str_max    # Alle 10 Stellen ausgeben

_int2str_getlen:                        # Anzahl der Stellen ermitteln
        add     t3, t3, -1              # L�nge der Ausgabe reduzieren
        div     t1, t1, t0
        bltu    a0, t1, _int2str_getlen

_int2str_max:
        add     t2, t3, a1              # t2= Zeiger auf Ende des Puffers 

_int2str_loop:
        remu    t1, a0, t0
        divu    a0, a0, t0
        add     t1, t1, 48              # Zahl 0-9 in ASCII-Code '0'-'9' umwandeln
        add     t2, t2, -1
        sb      t1, 0(t2)
        blt     a1, t2, _int2str_loop

        add     a0, zero, t3            # L�nge aus t3 zur�ckliefern
        ret                             # kehre zum Aufrufer zur�ck
