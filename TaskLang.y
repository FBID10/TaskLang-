%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Function prototypes */
int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
extern int yylineno;
extern char *yytext;
%}


%union {
    char* str;
}


%token TASK RUN EVERY DAY WEEK ON AT AFTER BEFORE DEPENDS_ON IF SUCCESS FAIL
%token <str> IDENTIFIER STRING_LITERAL TIME_LITERAL
%type <str> identifier_list


%start program

%%


program : task_def 
        | program task_def 
        ;

task_def : TASK IDENTIFIER { printf("\nExecuting Task: %s\n", $2); } '{' run_statement schedule_statement dependency_statement conditional_statement '}' ;

run_statement : RUN STRING_LITERAL { 
    printf("    Script: %s\n", $2); 
} ;

schedule_statement : EVERY DAY AT TIME_LITERAL { 
    printf("    Schedule: EVERY DAY AT %s\n", $4); 
}
| EVERY WEEK ON IDENTIFIER AT TIME_LITERAL { 
    printf("    Schedule: EVERY WEEK ON %s AT %s\n", $4, $6); 
}
| AT TIME_LITERAL {
    printf("    Schedule: AT %s\n", $2);
}
| /* empty*/
;

dependency_statement : AFTER identifier_list { printf("    Depends on: %s\n", $2); } 
                     | BEFORE identifier_list { printf("    Depends on: %s\n", $2); } 
                     | DEPENDS_ON identifier_list { printf("    Depends on: %s\n", $2); } 
                     | /* empty */
                     ;

identifier_list : IDENTIFIER { $$ = $1; }
                | identifier_list ',' IDENTIFIER { 
                    size_t len = strlen($1) + strlen($3) + 3;
                    $$ = malloc(len);
                    snprintf($$, len, "%s, %s", $1, $3);
                }
                ;

conditional_statement : IF SUCCESS { printf("    Condition: success\n"); }
                      | IF FAIL { printf("    Condition: fail\n"); }
                      |/* empty */
                      ;

%%



extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Could not open file");
            return 1;
        }
        yyin = file;
    } else {
        if (isatty(fileno(stdin))) {
            char *input = NULL;
            size_t input_size = 0;
            char *line = NULL;
            size_t linecap = 0;
            ssize_t linelen;
            printf("Enter TaskLang input. Submit an empty line to finish.\n");
            while ((linelen = getline(&line, &linecap, stdin)) != -1) {
                if (linelen == 1 && (line[0] == '\n' || line[0] == '\r')) break;
                char *newbuf = realloc(input, input_size + linelen + 1);
                if (!newbuf) { free(input); free(line); perror("realloc"); return 1; }
                input = newbuf;
                memcpy(input + input_size, line, linelen);
                input_size += linelen;
                input[input_size] = '\0';
            }
            free(line);
            if (!input) input = strdup("");
            FILE *mem = fmemopen(input, input_size, "r");
            if (!mem) { perror("fmemopen failed"); free(input); return 1; }
            yyin = mem;

            printf("Parsing TaskLang++ input...\n");
            printf("--- EXECUTION START ---\n\n");
            int result = yyparse();

            fclose(mem);
            free(input);

            printf("\n--- EXECUTION COMPLETE ---\n");
            return result;
        } else {
            yyin = stdin;
        }
    }

    printf("Parsing TaskLang++ input...\n");
    printf("--- EXECUTION START ---\n\n");
    int result = yyparse();
    printf("\n--- EXECUTION COMPLETE ---\n");

    return result;
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s near '%s'\n", yylineno, s, yytext);
}