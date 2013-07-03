.PHONY : all clean lex

all : dreamcatcher
lex : dreamlex

dreamcatcher : lex.yy.c parse.tab.c
	cc -o dreamcatcher parse.tab.c lex.yy.c -ll
	
dreamlex : lex.yy.c parse.tab.h
	cc -o dreamlex lex.yy.c -ll

lex.yy.c : lex.l
	flex lex.l

parse.tab.c : parse.y
	bison -dv parse.y
	
parse.tab.h : parse.y
	bison -dv -r=solved parse.y

clean:
	rm dreamcatcher lex.yy.c parse.tab.c parse.tab.h parse.output
