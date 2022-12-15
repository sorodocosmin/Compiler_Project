%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token START_GLOBAL_DECLR END_GLOBAL_DECLR START_FUNCTION_DECLR END_FUNCTION_DECLR START_USR_DEFINED END_USR_DEFINED START_MAIN END_MAIN
%token NAME_VARIABLE PREDEF_TYPE ASSIGN NUMBER FUNCTION_NAME MY_TYPE MY_TYPE_NAME 
%token IF ELSE WHILE FOR FOR_DELIMITATOR
%start PROGRAM
%%
PROGRAM:  
          GLOBAL
          
          FUNCTIONS
          
          USR_DEFINED_TYPES

          MAIN

          {printf("program corect sintactic\n");}
     ;

variable_declarations :  one_variable_declaration ';'
                      |  one_variable_declaration ';' variable_declarations 
	                 ;
one_variable_declaration :    PREDEF_TYPE LIST_VARIABLES //incoplete ? + customized types 
                         ;

LIST_VARIABLES : NAME_VARIABLE 
               | NAME_VARIABLE ',' LIST_VARIABLES
               ;


function_declarations    : one_function_declaration ';'
                         | one_function_declaration ';' function_declarations
                         ;
one_function_declaration : PREDEF_TYPE FUNCTION_NAME '(' parameters_list ')' '{'
                              list
                              '}'
                         | PREDEF_TYPE FUNCTION_NAME '(' ')' '{'
                              list
                              '}'
                         | PREDEF_TYPE FUNCTION_NAME '(' parameters_list ')' '{'
                              '}'
                         | PREDEF_TYPE FUNCTION_NAME '(' ')' '{'
                              '}'
                         ;

parameters_list : one_parameter
            | one_parameter ',' parameters_list    
            ;
            
one_parameter : PREDEF_TYPE NAME_VARIABLE
              ;

customized_type_declarations : one_mytype_declaration ';'
                             | one_mytype_declaration ';' customized_type_declarations
                             ;
one_mytype_declaration : MY_TYPE MY_TYPE_NAME '{'
                         variable_declarations
                         '}'
                       | MY_TYPE MY_TYPE_NAME '{'
                    
                         '}'
                       ;
//GLOBAL DEFINITIONS
GLOBAL :  START_GLOBAL_DECLR 
               variable_declarations 
          END_GLOBAL_DECLR

       |
          START_GLOBAL_DECLR 
                
          END_GLOBAL_DECLR
     ;  
//FUNCTIONS
FUNCTIONS :    START_FUNCTION_DECLR
                    function_declarations
               END_FUNCTION_DECLR

          |    START_FUNCTION_DECLR
                    
               END_FUNCTION_DECLR
          ;
// User Defined Types
USR_DEFINED_TYPES : START_USR_DEFINED
                         customized_type_declarations
                    END_USR_DEFINED
                  /*| START_USR_DEFINED
                    
                    END_USR_DEFINED
                    */
                  ;
// MAIN
MAIN :    START_MAIN
                list 
          END_MAIN
     
     |    START_MAIN
                 
          END_MAIN
     ;
     
/* lista instructiuni */
list : statement ';'
     | statement ';' list
     ;

/* instructiune */
statement: one_variable_declaration 
         | NAME_VARIABLE ASSIGN NAME_VARIABLE
         | NAME_VARIABLE ASSIGN NUMBER
         | NAME_VARIABLE ASSIGN FUNCTION_NAME '(' list_parameters_for_function ')'
         | NAME_VARIABLE ASSIGN FUNCTION_NAME '(' ')'
         | FUNCTION_NAME '(' list_parameters_for_function ')'
         | FUNCTION_NAME '(' ')'
         | IF_ELSE_STATEMENT
         | IF_THEN
         | WHILE_STATEMENT
         | FOR_STATEMENT
         ;
IF_ELSE_STATEMENT : IF '(' COND ')' '{' list '}' ELSE '{' list '}'
                  | IF '(' COND ')' '{'  '}' ELSE '{' list '}'
                  | IF '(' COND ')' '{' list '}' ELSE '{'  '}'
                  | IF '(' COND ')' '{'  '}' ELSE '{'  '}'
                  ;
IF_THEN   : IF '(' COND ')' '{' list '}'
          | IF '(' COND ')' '{'  '}'
          ;
WHILE_STATEMENT : WHILE '(' COND ')' '{' list '}'
                | WHILE '(' COND ')' '{'  '}'
                ;
FOR_STATEMENT  : FOR '(' list FOR_DELIMITATOR COND FOR_DELIMITATOR list ')' '{' list '}'//1111
               | FOR '(' list FOR_DELIMITATOR COND FOR_DELIMITATOR list ')' '{'      '}'//1110
               | FOR '(' list FOR_DELIMITATOR COND FOR_DELIMITATOR      ')' '{' list '}'//1101
               | FOR '(' list FOR_DELIMITATOR COND FOR_DELIMITATOR      ')' '{'      '}'//1100
               | FOR '(' list FOR_DELIMITATOR      FOR_DELIMITATOR list ')' '{' list '}'//1011
               | FOR '(' list FOR_DELIMITATOR      FOR_DELIMITATOR list ')' '{'      '}'//1010
               | FOR '(' list FOR_DELIMITATOR      FOR_DELIMITATOR      ')' '{' list '}'//1001
               | FOR '(' list FOR_DELIMITATOR      FOR_DELIMITATOR      ')' '{'      '}'//1000
               | FOR '('      FOR_DELIMITATOR COND FOR_DELIMITATOR list ')' '{' list '}'//0111
               | FOR '('      FOR_DELIMITATOR COND FOR_DELIMITATOR list ')' '{'      '}'//0110
               | FOR '('      FOR_DELIMITATOR COND FOR_DELIMITATOR      ')' '{' list '}'//0101
               | FOR '('      FOR_DELIMITATOR COND FOR_DELIMITATOR      ')' '{'      '}'//0100
               | FOR '('      FOR_DELIMITATOR      FOR_DELIMITATOR list ')' '{' list '}'//0011
               | FOR '('      FOR_DELIMITATOR      FOR_DELIMITATOR list ')' '{'      '}'//0010
               | FOR '('      FOR_DELIMITATOR      FOR_DELIMITATOR      ')' '{' list '}'//0001
               | FOR '('      FOR_DELIMITATOR      FOR_DELIMITATOR      ')' '{'      '}'//0000
               ;
COND : NAME_VARIABLE
     | NUMBER
     ;
list_parameters_for_function: NUMBER
                            | NAME_VARIABLE
                            | NUMBER ',' list_parameters_for_function
                            | NAME_VARIABLE ',' list_parameters_for_function
           ;
%%

int yyerror(char * s){
    printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    yyparse();
    return 0;
} 