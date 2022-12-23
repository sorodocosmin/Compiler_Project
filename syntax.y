%{
#include <stdio.h>
extern FILE *  variables_file;
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token _START_GLOBAL_DECLR _END_GLOBAL_DECLR _START_FUNCTION_DECLR _END_FUNCTION_DECLR _START_USR_DEFINED _END_USR_DEFINED _START_MAIN _END_MAIN
%token _NAME_VARIABLE _PREDEF_TYPE _ASSIGN _NUMBER_NEG _NUMBER_POS _FUNCTION_NAME _MY_TYPE _MY_TYPE_NAME 
%token _IF _ELSE _WHILE _FOR _FOR_DELIMITATOR
%token _COND_TRUE _COND_FALSE
%token _LESS_THAN _LESS_OR_EQ _GREATER_THAN _GREATER_OR_EQ _EQUAL
%token _ADD _DIVIDE _MULTIPLY _SUBSTRACT
%token _AND _OR _NOT

%left _OR
%left _AND
%left _NOT
%left _LESS_THAN
%left _LESS_OR_EQ
%left _GREATER_THAN
%left _GREATER_OR_EQ
%left _EQUAL
%left _ADD
%left _SUBSTRACT
%left _MULTIPLY
%left _DIVIDE

%start PROGRAM
%%
PROGRAM:  
          USR_DEFINED_TYPES

          GLOBAL
          
          FUNCTIONS

          MAIN

          {printf("program corect sintactic\n");}
     ;

variable_declarations :  one_variable_declaration ';'
                      |  one_variable_declaration ';' variable_declarations 
	                 ;
one_variable_declaration :    _PREDEF_TYPE LIST_VARIABLES //incomplete ? + customized types 
                         ;  

LIST_VARIABLES : _NAME_VARIABLE 
               | _NAME_VARIABLE ARRAY
               | _NAME_VARIABLE ',' LIST_VARIABLES
               ;
ARRAY : '[' _NUMBER_POS ']'
      | '[' _NUMBER_POS ']'ARRAY  

function_declarations    : one_function_declaration ';'
                         | one_function_declaration ';' function_declarations
                         ;
one_function_declaration : _PREDEF_TYPE _FUNCTION_NAME '(' parameters_list ')' '{'
                              list
                              '}' 
                         | _PREDEF_TYPE _FUNCTION_NAME '(' ')' '{'
                              list
                              '}'
                         | _PREDEF_TYPE _FUNCTION_NAME '(' parameters_list ')' '{'
                              '}'
                         | _PREDEF_TYPE _FUNCTION_NAME '(' ')' '{'
                              '}'
                         ;

parameters_list : one_parameter
            | one_parameter ',' parameters_list    
            ;
            
one_parameter : _PREDEF_TYPE _NAME_VARIABLE
              ;

customized_type_declarations : one_mytype_declaration ';'
                             | one_mytype_declaration ';' customized_type_declarations
                             ;
one_mytype_declaration : _MY_TYPE _MY_TYPE_NAME '{'
                         list_mytype_declarations
                         '}'
                       | _MY_TYPE _MY_TYPE_NAME '{'
                       
                         '}'
                       ;
list_mytype_declarations : one_variable_declaration ';'
                         | one_function_declaration ';'
                         | one_function_declaration ';' list_mytype_declarations
                         | one_variable_declaration ';' list_mytype_declarations
                         ;
//GLOBAL DEFINITIONS
GLOBAL :  _START_GLOBAL_DECLR 
               variable_declarations 
          _END_GLOBAL_DECLR

       |
          _START_GLOBAL_DECLR 
                
          _END_GLOBAL_DECLR
     ;  
//FUNCTIONS
FUNCTIONS :    _START_FUNCTION_DECLR
                    function_declarations
               _END_FUNCTION_DECLR

          |    _START_FUNCTION_DECLR
                    
               _END_FUNCTION_DECLR
          ;
// User Defined Types
USR_DEFINED_TYPES : _START_USR_DEFINED
                         customized_type_declarations
                    _END_USR_DEFINED
                  |  _START_USR_DEFINED
                    
                    _END_USR_DEFINED
                    
                  ;
// MAIN
MAIN :    _START_MAIN
                list 
          _END_MAIN
     
     |    _START_MAIN
                 
          _END_MAIN
     ;
     
/* lista instructiuni */
list : statement ';'
     | statement ';' list
     ;

/* instructiune */
statement: one_variable_declaration 
         | ASSIGN_STATEMENT 
         | _FUNCTION_NAME '(' list_parameters_for_function ')'
         | _FUNCTION_NAME '(' ')'
         | IF_ELSE_STATEMENT
         | IF_THEN
         | WHILE_STATEMENT
         | FOR_STATEMENT
         ;
ASSIGN_STATEMENT : _NAME_VARIABLE _ASSIGN EVAL_ARITHM_EXPR
                 | _NAME_VARIABLE _ASSIGN COND //if the variable is a bool
                 ;
IF_ELSE_STATEMENT : _IF '(' COND ')' '{' list '}' _ELSE '{' list '}'
                  | _IF '(' COND ')' '{'  '}' _ELSE '{' list '}' {printf("WARNING: You don't have any statement between brackets at the IF_ELSE statement which ends at line %d\n(You might wanna take into cosideration to use the IF_THEN statement)\n",yylineno);}
                  | _IF '(' COND ')' '{' list '}' _ELSE '{'  '}'
                  | _IF '(' COND ')' '{'  '}' _ELSE '{'  '}'
                  ;
IF_THEN   : _IF '(' COND ')' '{' list '}'
          | _IF '(' COND ')' '{'  '}' {printf("WARNING: You don't have any statement between brackets at line %d\n",yylineno);}
          ;
WHILE_STATEMENT : _WHILE '(' COND ')' '{' list '}'
                | _WHILE '(' COND ')' '{'  '}'
                ;
FOR_STATEMENT  : _FOR '(' list _FOR_DELIMITATOR COND _FOR_DELIMITATOR list ')' '{' list '}'//1111
               | _FOR '(' list _FOR_DELIMITATOR COND _FOR_DELIMITATOR list ')' '{'      '}'//1110
               | _FOR '(' list _FOR_DELIMITATOR COND _FOR_DELIMITATOR      ')' '{' list '}'//1101
               | _FOR '(' list _FOR_DELIMITATOR COND _FOR_DELIMITATOR      ')' '{'      '}'//1100
               | _FOR '(' list _FOR_DELIMITATOR      _FOR_DELIMITATOR list ')' '{' list '}'//1011
               | _FOR '(' list _FOR_DELIMITATOR      _FOR_DELIMITATOR list ')' '{'      '}'//1010
               | _FOR '(' list _FOR_DELIMITATOR      _FOR_DELIMITATOR      ')' '{' list '}'//1001
               | _FOR '(' list _FOR_DELIMITATOR      _FOR_DELIMITATOR      ')' '{'      '}'//1000
               | _FOR '('      _FOR_DELIMITATOR COND _FOR_DELIMITATOR list ')' '{' list '}'//0111
               | _FOR '('      _FOR_DELIMITATOR COND _FOR_DELIMITATOR list ')' '{'      '}'//0110
               | _FOR '('      _FOR_DELIMITATOR COND _FOR_DELIMITATOR      ')' '{' list '}'//0101
               | _FOR '('      _FOR_DELIMITATOR COND _FOR_DELIMITATOR      ')' '{'      '}'//0100
               | _FOR '('      _FOR_DELIMITATOR      _FOR_DELIMITATOR list ')' '{' list '}'//0011
               | _FOR '('      _FOR_DELIMITATOR      _FOR_DELIMITATOR list ')' '{'      '}'//0010
               | _FOR '('      _FOR_DELIMITATOR      _FOR_DELIMITATOR      ')' '{' list '}'//0001
               | _FOR '('      _FOR_DELIMITATOR      _FOR_DELIMITATOR      ')' '{'      '}'//0000
               ;
COND : _COND_TRUE
     | _COND_FALSE
     | COND _AND COND
     | COND _OR COND
     | _NOT COND
     | EVAL_ARITHM_EXPR _EQUAL EVAL_ARITHM_EXPR
     | EVAL_ARITHM_EXPR _LESS_THAN EVAL_ARITHM_EXPR
     | EVAL_ARITHM_EXPR _LESS_OR_EQ EVAL_ARITHM_EXPR
     | EVAL_ARITHM_EXPR _GREATER_THAN EVAL_ARITHM_EXPR
     | EVAL_ARITHM_EXPR _GREATER_OR_EQ EVAL_ARITHM_EXPR
     | '(' COND ')'
     ;

EVAL_ARITHM_EXPR : EVAL_ARITHM_EXPR _ADD EVAL_ARITHM_EXPR
                 | EVAL_ARITHM_EXPR _SUBSTRACT EVAL_ARITHM_EXPR
                 | EVAL_ARITHM_EXPR _MULTIPLY EVAL_ARITHM_EXPR
                 | EVAL_ARITHM_EXPR _DIVIDE EVAL_ARITHM_EXPR
                 | EV_TO_NR 
                 | '(' EVAL_ARITHM_EXPR ')'
                 ;

EV_TO_NR : _NUMBER_NEG
         | _NUMBER_POS
         | _NAME_VARIABLE
         | _FUNCTION_NAME '(' list_parameters_for_function ')'
         | _FUNCTION_NAME '(' ')'
         ;


list_parameters_for_function: _NUMBER_POS
                            | _NUMBER_NEG
                            | _NAME_VARIABLE
                            | _NUMBER_POS ',' list_parameters_for_function
                            | _NUMBER_NEG ',' list_parameters_for_function
                            | _NAME_VARIABLE ',' list_parameters_for_function
           ;
%%

int yyerror(char * s){
    printf("eroare: %s la linia:%d\n",s,yylineno);
}
FILE * variables_file;
int main(int argc, char** argv){
    yyin=fopen(argv[1],"r");
    variables_file = fopen ("symbol_table.txt", "w+");
    yyparse();
    return 0;
} 
