all:
	lex limbaj.l
	yacc -d limbaj.y -Wcounterexamples
	gcc tabel_symbols.c lex.yy.c y.tab.c -o limbaj
