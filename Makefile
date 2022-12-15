all:
	lex syntax.l
	yacc -d syntax.y -Wcounterexamples
	gcc lex.yy.c y.tab.c -o syntax
