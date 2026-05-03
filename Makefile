all:
	flex TaskLang.l
	bison -d TaskLang.y
	gcc lex.yy.c TaskLang.tab.c -o TaskLang -lfl

test: all
	./test.sh

clean:
	rm lex.yy.c TaskLang.tab.c TaskLang.tab.h TaskLang