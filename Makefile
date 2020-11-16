all: ghd

ghd.tab.c ghd.tab.h:	ghd.y
	bison -t -v -d ghd.y

lex.yy.c: ghd.l ghd.tab.h
	flex ghd.l

ghd: lex.yy.c ghd.tab.c ghd.tab.h ast.h ast.c
	gcc -g -Wall -o ghd lex.yy.c ghd.tab.c ast.c

clean:
	rm ghd ghd.tab.c lex.yy.c ghd.tab.h ghd.output