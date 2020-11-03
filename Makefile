all: ghd

ghd.tab.c ghd.tab.h:	ghd.y
	bison -t -v -d ghd.y

lex.yy.c: ghd.l ghd.tab.h
	flex ghd.l

ghd: lex.yy.c ghd.tab.c ghd.tab.h
	gcc -o ghd ghd.c ghd.tab.c

clean:
	rm ghd ghd.tab.c lex.yy.c ghd.tab.h ghd.output