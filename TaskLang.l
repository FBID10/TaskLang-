%{
#include "TaskLang.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option yylineno

%%
[ \n\t\r]                { ; }
"TASK"                  { return TASK; }
"RUN"                   { return RUN; }
"EVERY"                 { return EVERY; }
"DAY"                   { return DAY; }
"WEEK"                  { return WEEK; }
"ON"                    { return ON; }
"AT"                    { return AT; }
"AFTER"                 { return AFTER; }
"BEFORE"                { return BEFORE; }
"DEPENDS ON"            { return DEPENDS_ON; }
"IF"                    { return IF; }
"success"               { return SUCCESS; }
"fail"                  { return FAIL; }

"{"                     { return '{'; }
"}"                     { return '}'; }
","                     { return ','; }


[a-zA-Z][a-zA-Z0-9_]*   { yylval.str = strdup(yytext);
                                return IDENTIFIER;
                        }

[0-2][0-9]:[0-5][0-9]   { yylval.str = strdup(yytext);
                                return TIME_LITERAL;
                        }

\"[^\"]*\"              { yylval.str = strdup(yytext);
                                return STRING_LITERAL;
                        }

.                       { fprintf(stderr, "Lexical Error at line %d: Undefined character '%s'\n", yylineno, yytext); }

%%


int yywrap() { return 1; }