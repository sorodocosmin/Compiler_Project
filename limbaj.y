%{
    #include <unistd.h>
    #include <stdbool.h>
    #include "tabel_symbols.h"
    

    int nr_var_in_list = 0;
    int nr_var_in_memory = 0 ;

    struct memory_variables * memory ;//here, we'll save the basic type variables and the user defined ones

    struct memory_user_defined_types * types_defined_by_user ;//here, we'll save the user defined types
    int nr_of_types_defined_by_user = 0;

    struct memory_functions * functions_tabel ;//here, we'll save all the functions
    int nr_of_functions = 0;
    int nr_parameters = 0;

    enum basic_types * list_of_types; 


    extern int yylineno;
    extern char *yytext;
    extern FILE *yyin;
%}

%union {
  int int_value;
  float float_value;
  char char_value;
  char *string_value;
  int bool_value;
  unsigned unsigned_value;
  struct memory_basic_types* variable_storage;
  struct memory_basic_types** list_variable_storage;
  struct memory_variables * list_parameters ;

  struct AST * ast_node;
}

%token START_USR_DEFINED_TYPES END_USR_DEFINED_TYPES
%token START_GLOBAL_DECLARATIONS END_GLOBAL_DECLARATIONS 
%token START_FUNCTION_DECLARATIONS END_FUNCTION_DECLARATIONS 
%token START_MAIN END_MAIN

%token INT_TYPE FLOAT_TYPE CHAR_TYPE STRING_TYPE BOOL_TYPE VOID_TYPE
%token STRUCT_TYPE
%token STRUCT_MEMBER_ACCESS
%token CONST_KEYWORD

%token EVAL_PREDEFINED
%token TYPEOF_PREDEFINED

%token SEMICOLON COMMA OPEN_SQUARE_PAR CLOSE_SQUARE_PAR 
%token OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR

%token IF ELSE FOR WHILE DO RETURN
%token AND OR NOT EQ NE LT GT LE GE
%token PLUS MINUS MULTIPLY DIVIDE MODULO


%token ASSIGN


%token <string_value>   IDENTIFIER_VARIABLE
%token <string_value>   IDENTIFIER_FUNCTION
%token <string_value>   IDENTIFIER_STRUCT

%token <int_value>      INT_LITERAL
%token <float_value>    FLOAT_LITERAL
%token <char_value>     CHAR_LITERAL
%token <string_value>   STRING_LITERAL
%token <unsigned_value> UNSIGNED_LITERAL
%token <bool_value>     BOOL_LITERAL

%type <variable_storage>     PREDEFINED_TYPE_DECLARATION 
%type<list_variable_storage> PREDEFINED_TYPE_DECLARATION_LIST
%type<list_parameters>  Parameters
%type<string_value>     FUNCTION_CALL
%type <ast_node>        EXPRESSION VALUE REF_VARIABLE my_type_VARIABLE
 

%left OR 
%left AND 
%left NOT 

%left EQ
%left NE
%left LT 
%left GT 
%left LE 
%left GE

%left PLUS
%left MINUS
%left MULTIPLY 
%left DIVIDE 
%left MODULO

%left OPEN_PAR 
%left CLOSE_PAR
%left OPEN_CURLY_PAR 
%left CLOSE_CURLY_PAR

%left STRUCT_MEMBER_ACCESS

%start PROGRAM

%%

PROGRAM :   USR_DEFINED_TYPES
            GLOBAL_DECLARATIONS
            FUNCTION_DECLARATIONS
            MAIN

          {
          printf("program corect sintactic\n");

          print_list_of_user_defined_types_to_file(types_defined_by_user,nr_of_types_defined_by_user);
          
          print_memory_to_file(memory,nr_var_in_memory);

          
          print_functions_to_file(functions_tabel,nr_of_functions);
          }
        ;

// User Defined Structures
USR_DEFINED_TYPES : START_USR_DEFINED_TYPES USR_DEFINED END_USR_DEFINED_TYPES
                  | START_USR_DEFINED_TYPES END_USR_DEFINED_TYPES
                  ;
USR_DEFINED : USR_DEFINED STRUCT_DEFINITION
            | STRUCT_DEFINITION
            ;
STRUCT_DEFINITION : STRUCT_TYPE IDENTIFIER_STRUCT OPEN_CURLY_PAR PREDEFINED_TYPE_DECLARATION_LIST FUNCTION_DECLARATION_LIST CLOSE_CURLY_PAR{
                    if(verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user) == NULL ){
                      add_to_user_defined_types(&types_defined_by_user,$4,functions_tabel,$2,nr_of_types_defined_by_user,nr_var_in_list,nr_of_functions);
                      nr_of_types_defined_by_user++;
                      nr_var_in_list = 0;
                      nr_of_functions = 0;
                      free(functions_tabel);
                    }
                    else{
                      printf("The structure %s is already defined (SEE line %d)\n",$2,yylineno);
                      exit(1);
                    }
                    }
                    | STRUCT_TYPE IDENTIFIER_STRUCT OPEN_CURLY_PAR PREDEFINED_TYPE_DECLARATION_LIST CLOSE_CURLY_PAR {
                    //we add to the tabel symbol this structure if it s not previously declared another structure with the same name
                    if(verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user) == NULL ){
                      add_to_user_defined_types(&types_defined_by_user,$4,NULL,$2,nr_of_types_defined_by_user,nr_var_in_list,0);
                      nr_of_types_defined_by_user++;
                      nr_var_in_list = 0;
                    }
                    else{
                      printf("The structure %s is already defined (SEE line %d)\n",$2,yylineno);
                      exit(1);
                    }
                    }
                  | STRUCT_TYPE IDENTIFIER_STRUCT OPEN_CURLY_PAR FUNCTION_DECLARATION_LIST CLOSE_CURLY_PAR{
                    if(verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user) == NULL ){
                      add_to_user_defined_types(&types_defined_by_user,NULL,functions_tabel,$2,nr_of_types_defined_by_user,nr_var_in_list,nr_of_functions);
                      nr_of_types_defined_by_user++;
                      nr_of_functions = 0;
                      free(functions_tabel);
                    }
                    else{
                      printf("The structure %s is already defined (SEE line %d)\n",$2,yylineno);
                      exit(1);
                    }
                    }
                  | STRUCT_TYPE IDENTIFIER_STRUCT OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                    if(verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user) == NULL ){
                      add_to_user_defined_types(&types_defined_by_user,NULL,NULL, $2,nr_of_types_defined_by_user,0,0);
                    
                      nr_of_types_defined_by_user++;
                    }
                    else{
                      printf("The structure %s is already defined (SEE line %d)\n",$2,yylineno);
                      exit(1);
                    }
                    }
                  ;


// Predefined Type Declarations
PREDEFINED_TYPE_DECLARATION_LIST : PREDEFINED_TYPE_DECLARATION_LIST PREDEFINED_TYPE_DECLARATION SEMICOLON {
	                                if (exists_another_variable_with_the_same_name($1,$2,nr_var_in_list)){
	                                printf("Error : it already exists a variable named %s (SEE line %d)\n",$2->name_variable,yylineno);
                                  exit(1);
                                  }
                                    $$ = add_to_list_of_variables($1,$2,nr_var_in_list);
                                    nr_var_in_list++;
                                  }
                                 | PREDEFINED_TYPE_DECLARATION SEMICOLON {
                                    nr_var_in_list = 0;
                                    $$ = initialize_list_of_variables($1);
                                    nr_var_in_list++;
                                  }
                                 ;
                                 
PREDEFINED_TYPE_DECLARATION : INT_TYPE      IDENTIFIER_VARIABLE     {  int a=0; $$=create_variable(INT, $2, false, &a);  }
                            | FLOAT_TYPE    IDENTIFIER_VARIABLE     {  float a=0.0; $$=create_variable( FLOAT, $2, false, &a ); }
                            | CHAR_TYPE     IDENTIFIER_VARIABLE     {  char a = 0; $$=create_variable( CHAR, $2, false, &a); }
                            | STRING_TYPE   IDENTIFIER_VARIABLE     {  char a[] = "\0"; $$=create_variable( STRING, $2, false, &a ); }
                            | BOOL_TYPE     IDENTIFIER_VARIABLE     {  bool a = false ; $$=create_variable(BOOL, $2, false, &a ); }

                            | INT_TYPE      IDENTIFIER_VARIABLE ASSIGN EXPRESSION{
                              enum basic_types type_expr = TypeOf($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != INT){
                                printf("Error : The expression is not of type int (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              struct termen* a1 = Eval($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              int a = a1->int_value; 
                               $$=create_variable(INT, $2, false, &a);  
                            }


                            | FLOAT_TYPE    IDENTIFIER_VARIABLE ASSIGN EXPRESSION{

                              enum basic_types type_expr = TypeOf($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != FLOAT){
                                printf("Error : The expression is not of type float (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              struct termen* a1 = Eval($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              float a = a1->float_value;
                               $$=create_variable(FLOAT, $2, false, &a ); 
                              }


                            | CHAR_TYPE     IDENTIFIER_VARIABLE ASSIGN EXPRESSION{

                              enum basic_types type_expr = TypeOf($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != CHAR){
                                printf("Error : The expression is not of type char (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                                struct termen *a1 = Eval($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                                char a = a1->char_value;
                                 $$=create_variable( CHAR, $2, false, &a); 
                              }


                            | STRING_TYPE   IDENTIFIER_VARIABLE ASSIGN EXPRESSION{
                                
                              enum basic_types type_expr = TypeOf($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != STRING){
                                printf("Error : The expression is not of type string (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              struct termen* a1 = Eval($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              char *a = a1->string_value;
                               $$=create_variable(STRING, $2, false, a ); }


                            | BOOL_TYPE     IDENTIFIER_VARIABLE ASSIGN EXPRESSION{

                              enum basic_types type_expr = TypeOf($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != BOOL){
                                printf("Error : The expression is not of type bool (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                                struct termen * a1 = Eval($4, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                                bool a = a1->bool_value;
                                 $$=create_variable(BOOL, $2, false, &a ); 
                              }
                            
                            | INT_TYPE      IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $4; $$ = create_array_variable(INT, $2, false, size); }
                            | FLOAT_TYPE    IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $4; $$ = create_array_variable(FLOAT, $2, false, size); }
                            | CHAR_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $4; $$ = create_array_variable(CHAR, $2, false, size); }
                            | STRING_TYPE   IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $4; $$ = create_array_variable(STRING, $2, false, size); }
                            | BOOL_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $4; $$ = create_array_variable(BOOL, $2, false, size); }

                            | INT_TYPE      IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $4; unsigned columns = $7; $$ = create_matrix_variable(INT, $2, false, lines, columns); }
                            | FLOAT_TYPE    IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $4; unsigned columns = $7; $$ = create_matrix_variable(FLOAT, $2, false, lines, columns); }
                            | CHAR_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $4; unsigned columns = $7; $$ = create_matrix_variable(CHAR, $2, false, lines, columns); }
                            | BOOL_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $4; unsigned columns = $7; $$ = create_matrix_variable(BOOL, $2, false, lines, columns); }
                            | STRING_TYPE   IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $4; unsigned columns = $7; $$ = create_matrix_variable(STRING, $2, false, lines, columns); }
                            

                            | CONST_KEYWORD INT_TYPE      IDENTIFIER_VARIABLE     { printf("A CONST variable needs to be initialized(SEE Line %d)\n",yylineno); exit(1);  }
                            | CONST_KEYWORD FLOAT_TYPE    IDENTIFIER_VARIABLE     { printf("A CONST variable needs to be initialized(SEE Line %d)\n",yylineno); exit(1);  }
                            | CONST_KEYWORD CHAR_TYPE     IDENTIFIER_VARIABLE     { printf("A CONST variable needs to be initialized(SEE Line %d)\n",yylineno); exit(1); }
                            | CONST_KEYWORD STRING_TYPE   IDENTIFIER_VARIABLE     {  printf("A CONST variable needs to be initialized(SEE Line %d)\n",yylineno); exit(1); }
                            | CONST_KEYWORD BOOL_TYPE     IDENTIFIER_VARIABLE     {  printf("A CONST variable needs to be initialized(SEE Line %d)\n",yylineno); exit(1); }
 
                            | CONST_KEYWORD INT_TYPE      IDENTIFIER_VARIABLE ASSIGN EXPRESSION   {
                              enum basic_types type_expr = TypeOf($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != INT){
                                printf("Error : The expression is not of type int (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              struct termen *a1 = Eval($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              int a = a1->int_value;
                               $$=create_variable(INT, $3, true, &a);  }
                            
                            
                            | CONST_KEYWORD FLOAT_TYPE    IDENTIFIER_VARIABLE ASSIGN EXPRESSION   { 
                               enum basic_types type_expr = TypeOf($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != FLOAT){
                                printf("Error : The expression is not of type float (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                                struct termen *a1 = Eval($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                                float a = a1->float_value;
                                $$=create_variable(FLOAT, $3, true, &a ); }
                            
                            
                            | CONST_KEYWORD CHAR_TYPE     IDENTIFIER_VARIABLE ASSIGN EXPRESSION{
                              
                              enum basic_types type_expr = TypeOf($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != CHAR){
                                printf("Error : The expression is not of type char (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              struct termen *a1 = Eval($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              char a = a1->char_value;
                              $$=create_variable( CHAR, $3, true, &a); }


                            | CONST_KEYWORD STRING_TYPE   IDENTIFIER_VARIABLE ASSIGN EXPRESSION{
                              
                              enum basic_types type_expr = TypeOf($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != STRING){
                                printf("Error : The expression is not of type string (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                                struct termen * a1 = Eval($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                                char * a = a1->string_value;
                                $$=create_variable(STRING, $3, true, a ); }
                            
                            
                            | CONST_KEYWORD BOOL_TYPE     IDENTIFIER_VARIABLE ASSIGN EXPRESSION{

                              enum basic_types type_expr = TypeOf($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                              if( type_expr == INVALID){
                                printf("Error : The expression is invalid! All variables need to have the same type (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                              if(type_expr != BOOL){
                                printf("Error : The expression is not of type bool (SEE line %d)\n",yylineno);
                                exit(1);
                              }
                                struct termen * a1 = Eval($5, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                                bool a = a1->bool_value;
                                $$=create_variable(BOOL, $3, true, &a ); }
                             
                            | CONST_KEYWORD INT_TYPE      IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $5; $$ = create_array_variable(INT, $3, true, size); }
                            | CONST_KEYWORD FLOAT_TYPE    IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $5; $$ = create_array_variable(FLOAT, $3, true, size); }
                            | CONST_KEYWORD CHAR_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $5; $$ = create_array_variable(CHAR, $3, true, size); }
                            | CONST_KEYWORD STRING_TYPE   IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $5; $$ = create_array_variable(STRING, $3, true, size); }
                            | CONST_KEYWORD BOOL_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'              {  unsigned size = $5; $$ = create_array_variable(BOOL, $3, true, size); }
 
                            | CONST_KEYWORD INT_TYPE      IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $5; unsigned columns = $8; $$ = create_matrix_variable(INT, $3, true, lines, columns); }
                            | CONST_KEYWORD FLOAT_TYPE    IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $5; unsigned columns = $8; $$ = create_matrix_variable(FLOAT, $3, true, lines, columns); }
                            | CONST_KEYWORD CHAR_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $5; unsigned columns = $8; $$ = create_matrix_variable(CHAR, $3, true, lines, columns); }
                            | CONST_KEYWORD BOOL_TYPE     IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $5; unsigned columns = $8; $$ = create_matrix_variable(BOOL, $3, true, lines, columns); }
                            | CONST_KEYWORD STRING_TYPE   IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'  { unsigned lines = $5; unsigned columns = $8; $$ = create_matrix_variable(STRING, $3, true, lines, columns); }
                            ;

// Global Declarations
GLOBAL_DECLARATIONS : START_GLOBAL_DECLARATIONS GLOBAL_DECLARATION_LIST END_GLOBAL_DECLARATIONS
                    | START_GLOBAL_DECLARATIONS END_GLOBAL_DECLARATIONS
                    ;
GLOBAL_DECLARATION_LIST : GLOBAL_DECLARATION_LIST PREDEFINED_TYPE_DECLARATION SEMICOLON {
                          if(verify_unique_name_of_param(memory,$2->name_variable, nr_var_in_memory) == false)
                          {
                            printf("Error: Variable %s is already declared(SEE line %d)\n", $2->name_variable, yylineno);
                            exit(1);
                          }
                          add_to_memory_list_of_variables(&memory,initialize_list_of_variables($2),"is_not_struct","is_not_struct",false,1,&nr_var_in_memory);
                          nr_var_in_memory ++;
                        }
                        | GLOBAL_DECLARATION_LIST STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_VARIABLE SEMICOLON{
                          struct memory_user_defined_types * aux ;
                          //(struct memory_user_defined_types *) malloc(sizeof(struct memory_user_defined_types));
                          aux = verify_if_exists_user_type(types_defined_by_user,$3,nr_of_types_defined_by_user);

                          if (aux == NULL){
                            printf("Error: Struct %s is not declared(SEE line %d)\n", $3,yylineno);
                            exit(1);
                          }
                          else{
                            if(verify_unique_name_of_param(memory,$4, nr_var_in_memory) == false)
                            {
                              printf("Error: Variable %s is already declared(SEE line %d)\n", $4, yylineno);
                              exit(1);
                            }
                            add_to_memory_list_of_variables(&memory,aux->members,$3,$4,true,aux->nr_of_members,&nr_var_in_memory);
                            nr_var_in_memory ++;
                          }
                        }
                        | PREDEFINED_TYPE_DECLARATION SEMICOLON{
                          if(verify_unique_name_of_param(memory,$1->name_variable, nr_var_in_memory) == false)
                          {
                            printf("Error: Variable %s is already declared(SEE line %d)\n", $1->name_variable, yylineno);
                            exit(1);
                          }
                          add_to_memory_list_of_variables(&memory,initialize_list_of_variables($1),"is_not_struct","is_not_struct",false,1,&nr_var_in_memory);
                          nr_var_in_memory ++;
                        }
                        | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_VARIABLE SEMICOLON{
                          struct memory_user_defined_types * aux ;
                          //(struct memory_user_defined_types *) malloc(sizeof(struct memory_user_defined_types));
                          aux = verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user);

                          if (aux == NULL){
                            printf("Error: Struct %s is not declared(SEE line %d)\n", $3,yylineno);
                            exit(1);
                          }
                          else{
                            if(verify_unique_name_of_param(memory,$3, nr_var_in_memory) == false)
                          {
                            printf("Error: Variable %s is already declared(SEE line %d)\n", $3, yylineno);
                            exit(1);
                          }
                            add_to_memory_list_of_variables(&memory,aux->members,$2,$3,true,aux->nr_of_members,&nr_var_in_memory);
                            nr_var_in_memory ++;
                          }
                        }
                        ;

// Functions
FUNCTION_DECLARATIONS : START_FUNCTION_DECLARATIONS FUNCTION_DECLARATION_LIST END_FUNCTION_DECLARATIONS
                      | START_FUNCTION_DECLARATIONS END_FUNCTION_DECLARATIONS
                      ;

FUNCTION_DECLARATION_LIST : FUNCTION_DECLARATION_LIST FUNCTION_DECLARATION
                          | FUNCTION_DECLARATION 
                          ;
FUNCTION_DECLARATION  :  INT_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"INT",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;

                      }
                      |  INT_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"INT",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                        }
                      |  INT_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR {
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"INT",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                        }
                      |  INT_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"INT",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }



                      |  FLOAT_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"FLOAT",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  FLOAT_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"FLOAT",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                        }
                      |  FLOAT_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"FLOAT",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  FLOAT_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"FLOAT",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }



                      |  STRING_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"STRING",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  STRING_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"STRING",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                        }
                      |  STRING_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"STRING",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  STRING_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"STRING",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;  
                      }



                      |  CHAR_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"CHAR",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  CHAR_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"CHAR",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                        }
                      |  CHAR_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"CHAR",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  CHAR_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"CHAR",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }


                      |  BOOL_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"BOOL",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  BOOL_TYPE IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,0, $2,"BOOL",NULL, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  BOOL_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"BOOL",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      |  BOOL_TYPE IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR {
                        if(verify_unique_name_of_function(functions_tabel, $2, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $2,yylineno);
                          exit(1);
                        }
                        add_function (&functions_tabel,nr_parameters, $2,"BOOL",$4, nr_of_functions);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                     
                      | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $3, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $3,yylineno);
                          exit(1);
                        }
                        char *my_type = (char*)malloc(strlen($2)+1+strlen("my_type "));
                        strcpy(my_type,"my_type ");
                        strcat(my_type,$2);
                        add_function (&functions_tabel,0, $3,my_type,NULL, nr_of_functions);
                        free(my_type);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $3, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $3,yylineno);
                          exit(1);
                        }
                        char *my_type = (char*)malloc(strlen($2)+1+strlen("my_type "));
                        strcpy(my_type,"my_type ");
                        strcat(my_type,$2);
                        add_function (&functions_tabel,0, $3,my_type,NULL, nr_of_functions);
                        free(my_type);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $3, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $3,yylineno);
                          exit(1);
                        }
                        char *my_type = (char*)malloc(strlen($2)+1+strlen("my_type "));
                        strcpy(my_type,"my_type ");
                        strcat(my_type,$2);
                        add_function (&functions_tabel,nr_parameters, $3,my_type,$5, nr_of_functions);
                        free(my_type);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_FUNCTION OPEN_PAR Parameters CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR{
                        if(verify_unique_name_of_function(functions_tabel, $3, nr_of_functions) == false){
                          printf("Error: Function %s is already declared(SEE line %d)\n", $3,yylineno);
                          exit(1);
                        }
                        char *my_type = (char*)malloc(strlen($2)+1+strlen("my_type "));
                        strcpy(my_type,"my_type ");
                        strcat(my_type,$2);
                        add_function (&functions_tabel,nr_parameters, $3,my_type,$5, nr_of_functions);
                        free(my_type);
                        nr_parameters=0;
                        nr_of_functions ++;
                      }
                      ;
Parameters : Parameters COMMA PREDEFINED_TYPE_DECLARATION{
              if(verify_unique_name_of_param($1,$3->name_variable,nr_parameters) == true){
              add_to_memory_list_of_variables(&$$,initialize_list_of_variables($3),"is_not_struct","is_not_struct",false,1,&nr_parameters);
                }
              else{
                  printf("Error: Variable %s was already declared in this function(SEE line %d)\n", $3->name_variable,yylineno);
                  exit(1);
              }
              nr_parameters ++;
            }

            | PREDEFINED_TYPE_DECLARATION {
              if(verify_unique_name_of_param($$,$1->name_variable,nr_parameters) == true){
                add_to_memory_list_of_variables(&$$,initialize_list_of_variables($1),"is_not_struct","is_not_struct",false,1,&nr_parameters);
              }
              else{
                  printf("Error: Variable %s was already declared in this function(SEE line %d)\n", $1->name_variable,yylineno);
                  exit(1);
              }
              nr_parameters++;
            }
            | Parameters COMMA STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_VARIABLE {
              struct memory_user_defined_types * aux ;
              aux = verify_if_exists_user_type(types_defined_by_user,$4,nr_of_types_defined_by_user);
              if(aux != NULL){
                if(verify_unique_name_of_param($1,$5,nr_parameters) == true){
                add_to_memory_list_of_variables(&$$,aux->members,$4, $5, true,aux->nr_of_members, &nr_parameters);
                }
                else{
                  printf("Error: Variable %s was already declared in this function(SEE line %d)\n", $5,yylineno);
                  exit(1);
                }
              }
              else{
                printf("Error: Struct %s was not previously declared(SEE line %d)\n", $4,yylineno);
                exit(1);
              }
                
              nr_parameters ++;
            }
            | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_VARIABLE {
              struct memory_user_defined_types * aux ;
              aux = verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user);
              if(aux != NULL){
                if(verify_unique_name_of_param($$,$3,nr_parameters) == true){
                  add_to_memory_list_of_variables(&$$,aux->members,$2, $3, true,aux->nr_of_members, &nr_parameters);
                }
                else{
                  printf("Error: Variable %s was already declared in this function(SEE line %d)\n", $3,yylineno);
                  exit(1);
                }
              }
              else{
                printf("Error: Struct %s was not previously declared(SEE line %d)\n", $2,yylineno);
                exit(1);
              }
                
              nr_parameters ++;
            }
           ;
//MAIN

MAIN : START_MAIN InstructionList END_MAIN
     ;

InstructionList  : STATEMENT InstructionList
                 | STATEMENT
                 ;
              ;
STATEMENT : PREDEFINED_TYPE_DECLARATION SEMICOLON {
            if(verify_unique_name_of_param(memory,$1->name_variable, nr_var_in_memory) == false){
            printf("Error: Variable %s is already declared (SEE line %d)\n", $1->name_variable,yylineno);
            exit(1);
            }
            add_to_memory_list_of_variables(&memory,initialize_list_of_variables($1),"is_not_struct","is_not_struct",false,1,&nr_var_in_memory);
            nr_var_in_memory ++;
            }
          | STRUCT_TYPE IDENTIFIER_STRUCT IDENTIFIER_VARIABLE SEMICOLON{
            struct memory_user_defined_types * aux ;
            //(struct memory_user_defined_types *) malloc(sizeof(struct memory_user_defined_types));
            aux = verify_if_exists_user_type(types_defined_by_user,$2,nr_of_types_defined_by_user);

            if (aux == NULL){
              printf("Error: Struct %s is not declared(SEE line %d)\n", $2,yylineno);
              exit(1);
            }
            else{
              if(verify_unique_name_of_param(memory,$3, nr_var_in_memory) == false)
              {
                printf("Error: Variable %s is already declared(SEE line %d)\n", $3, yylineno);
                exit(1);
              }
              add_to_memory_list_of_variables(&memory,aux->members,$2,$3,true,aux->nr_of_members,&nr_var_in_memory);
              nr_var_in_memory ++;
            }
          }
          | ASSIGNITION SEMICOLON
          | IF_INSTRUCTION
          | WHILE_INSTRUCTION
          | FOR_INSTRUCTION
          | TYPEOF_PREDEFINED OPEN_PAR EXPRESSION CLOSE_PAR SEMICOLON {
            enum basic_types type_of = TypeOf($3, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
            if( type_of == INVALID )
            {
              printf("Error: The expression is invalid! All variables need to have the same type(SEE line %d)\n", yylineno);
              exit(1);
            }
            //printf("The type of the expression is : %d\n", type_of);
          }
          | EVAL_PREDEFINED OPEN_PAR EXPRESSION CLOSE_PAR SEMICOLON {
            enum basic_types type_expr = TypeOf($3, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
            if(type_expr == INT)
            {
              struct termen * t = Eval($3,memory,nr_var_in_memory,types_defined_by_user,nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
              printf("%d\n", t->int_value);
 
            }
            else if(type_expr == INVALID)
            {
              printf("Error: The expression is invalid! All variables need to have the same type(SEE line %d)\n", yylineno);
              exit(1);
            }
          }
          ;

IF_INSTRUCTION : IF OPEN_PAR EXPRESSION CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR ELSE OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR
               | IF OPEN_PAR EXPRESSION CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR
               ;
WHILE_INSTRUCTION : WHILE OPEN_PAR EXPRESSION CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR
                  ;
FOR_INSTRUCTION : FOR OPEN_PAR ASSIGNITION SEMICOLON EXPRESSION SEMICOLON ASSIGNITION CLOSE_PAR OPEN_CURLY_PAR InstructionList CLOSE_CURLY_PAR
                ;

ASSIGNITION : REF_VARIABLE ASSIGN EXPRESSION{
            enum basic_types type_of_expr = TypeOf($3, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
            if ( type_of_expr == INVALID ){
              printf("Error: The expression is invalid! All variables need to have the same type(SEE line %d)\n", yylineno);
              exit(1);
            }
            enum basic_types type_of_var = TypeOf($1, memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
            if ( type_of_var == INVALID ){
              printf("Error: Invalid left value (SEE line %d)\n", yylineno);
              exit(1);
            }
            if( type_of_var != type_of_expr ){
              printf("Error: The types of the left and right values are different(SEE line %d)\n", yylineno);
              exit(1);
            }
            modify_variable_in_memory($1, $3, &memory, nr_var_in_memory, types_defined_by_user, nr_of_types_defined_by_user,functions_tabel,nr_of_functions,yylineno);
            }
            ;
//Expressions
                //Arithemetic
EXPRESSION :  OPEN_PAR EXPRESSION CLOSE_PAR { $$ = $2; }
            | EXPRESSION PLUS EXPRESSION    { $$ = buildAST_CHAR($1,$3,_PLUS,'+'); }
            | EXPRESSION MINUS EXPRESSION   { $$ = buildAST_CHAR($1,$3,_SUBSTRACTION,'-'); }
            | EXPRESSION MULTIPLY EXPRESSION{ $$ = buildAST_CHAR($1,$3,_MULTIPLY,'*');}
            | EXPRESSION DIVIDE EXPRESSION  { $$ = buildAST_CHAR($1,$3,_DIVISION,'/');}
            | EXPRESSION MODULO EXPRESSION  { $$ = buildAST_CHAR($1,$3,_MOD,'%');}

            //Boolean
            | EXPRESSION AND EXPRESSION     { $$ = buildAST_CHAR($1,$3,_AND,'&');}
            | EXPRESSION OR EXPRESSION      { $$ = buildAST_CHAR($1,$3,_OR,'|');}
            | EXPRESSION EQ EXPRESSION      { $$ = buildAST_CHAR($1,$3,_EQUAL,'=');}
            | EXPRESSION NE EXPRESSION      { $$ = buildAST_CHAR($1,$3,_NOT_EQUAL,'N');}
            | EXPRESSION LT EXPRESSION      { $$ = buildAST_CHAR($1,$3,_LESS,'<');}
            | EXPRESSION GT EXPRESSION      { $$ = buildAST_CHAR($1,$3,_GREATER,'>');}
            | EXPRESSION LE EXPRESSION      { $$ = buildAST_CHAR($1,$3,_LESS_EQUAL,'L');}
            | EXPRESSION GE EXPRESSION      { $$ = buildAST_CHAR($1,$3,_GREATER_EQUAL,'G');}
            | NOT EXPRESSION                { $$ = buildAST_CHAR($2,NULL,_NOT,'!');}

            //the value of a expression
            | VALUE                         {$$ = $1;}
            ;

// the value which a EXPRESSION can get
VALUE : REF_VARIABLE   { $$ = $1;}
      | INT_LITERAL    { $$ = buildAST_INT(NULL,NULL,_INT,$1);}
      | FLOAT_LITERAL  { $$ = buildAST_FLOAT(NULL,NULL,_FLOAT,$1);}
      | STRING_LITERAL { $$ = buildAST_STRING(NULL,NULL,_STRING,$1);}
      | CHAR_LITERAL   { $$ = buildAST_CHAR(NULL,NULL,_CHAR,$1);}
      | BOOL_LITERAL   { $$ = buildAST_BOOL(NULL,NULL,_BOOL,$1);}
      | FUNCTION_CALL {
        if(verify_unique_name_of_function(functions_tabel,$1,nr_of_functions) == true){
          printf("Error: Function %s was not declared(SEE line %d)\n", $1,yylineno);
          exit(1);
        }
        $$ = buildAST_STRING(NULL,NULL,_FUNCTION_CALL,$1);
      }
      | IDENTIFIER_VARIABLE STRUCT_MEMBER_ACCESS FUNCTION_CALL{
                          // first, we have to verify whether the variable exists
        if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
          printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
          exit(1);
        }
        if(verify_if_it_is_struct(memory,$1,nr_var_in_memory) == false){//if it's not a struct --> Error
          printf("Error: Variable %s is not a struct(SEE line %d)\n", $1,yylineno);
          exit(1);
        }
        if (verify_if_member_exists_in_struct(memory,nr_var_in_memory,types_defined_by_user,$1,$3,nr_of_types_defined_by_user,true) == false){//verify if the method exists in the struct
                    printf("Error: Variable %s does not have a method %s(SEE line %d)\n", $1,$3,yylineno);
                    exit(1);
        }
      }
      ;
  
//we can refer to a variable using this rule
REF_VARIABLE  : IDENTIFIER_VARIABLE {
                if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                  printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if(verify_if_it_is_array(memory,$1,nr_var_in_memory)==true){//if it's an array --> Error
                  printf("Error: Variable %s does not reference an array(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if(verify_if_it_is_matrix(memory,$1,nr_var_in_memory)==true){//if it's a matrix --> Error
                  printf("Error: Variable %s does not reference a matrix(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                $$ = buildAST_STRING(NULL,NULL,_VARIABLE,$1);
              }
              | IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'{
                if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                  printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if(verify_if_it_is_array(memory,$1,nr_var_in_memory)==false){//if it's a matrix --> Error
                  printf("Error: Variable %s does not reference an array(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                char concat[2048] ;
                sprintf(concat,"%s[%d]", $1, $3);
                $$ = buildAST_STRING(NULL,NULL,_ARRAY,concat);

              }
              | IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'{
                if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                  printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if(verify_if_it_is_matrix(memory,$1,nr_var_in_memory)==false){//if it's a matrix --> Error
                  printf("Error: Variable %s does not reference a matrix(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                char concat[2048] ;
                sprintf(concat,"%s[%d][%d]", $1, $3,$6);
                $$ = buildAST_STRING(NULL,NULL,_MATRIX,concat);
              }

              | my_type_VARIABLE {$$ = $1 ;}
              ;
//accessing a member/method of a class
my_type_VARIABLE : IDENTIFIER_VARIABLE STRUCT_MEMBER_ACCESS IDENTIFIER_VARIABLE {
                  // first, we have to verify whether the variable exists
                  if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                    printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  if(verify_if_it_is_struct(memory,$1,nr_var_in_memory) == false){//if it's not a struct --> Error
                    printf("Error: Variable %s is not a struct(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  // now, we have to verify whether it exists in the struct that member
                  if (verify_if_member_exists_in_struct(memory,nr_var_in_memory,types_defined_by_user,$1,$3,nr_of_types_defined_by_user,false) == false){
                    printf("Error: Variable %s does not have a member %s(SEE line %d)\n", $1,$3,yylineno);
                    exit(1);
                  }
                  // if(verify_if_member_is_array(types_defined_by_user,$1,$3,nr_of_types_defined_by_user) == true){//if it's an array --> Error
                  //   printf("Error: Variable %s does not reference an array(SEE line %d)\n", $1,yylineno);
                  //   exit(1);
                  // }
                  // if(verify_if_member_is_matrix(types_defined_by_user,$1,$3,nr_of_types_defined_by_user) == true){//if it's a matrix --> Error
                  //   printf("Error: Variable %s does not reference a matrix(SEE line %d)\n", $1,yylineno);
                  //   exit(1);
                  // }
                  char concat[2048] ;
                  sprintf(concat,"%s::%s", $1, $3);
                  $$ = buildAST_STRING(NULL,NULL,_MY_TYPE_MEMBER,concat);

                }
                 | IDENTIFIER_VARIABLE STRUCT_MEMBER_ACCESS IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']'{
                  // first, we have to verify whether the variable exists
                  if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                    printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  if(verify_if_it_is_struct(memory,$1,nr_var_in_memory) == false){//if it's not a struct --> Error
                    printf("Error: Variable %s is not a struct(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  if (verify_if_member_exists_in_struct(memory,nr_var_in_memory,types_defined_by_user,$1,$3,nr_of_types_defined_by_user,false) == false){
                    printf("Error: Variable %s does not have a member %s(SEE line %d)\n", $1,$3,yylineno);
                    exit(1);
                  }
                  char concat[2048] ;
                  sprintf(concat,"%s::%s[%d]", $1, $3,$5);
                  $$ = buildAST_STRING(NULL,NULL,_MY_TYPE_MEMBER_ARRAY,concat);
                 }
                 | IDENTIFIER_VARIABLE STRUCT_MEMBER_ACCESS IDENTIFIER_VARIABLE '[' UNSIGNED_LITERAL ']' '[' UNSIGNED_LITERAL ']'{
                  // first, we have to verify whether the variable exists
                  if(verify_unique_name_of_param(memory,$1,nr_var_in_memory) == true){//if it's unique --> it wasn t declared --> Error
                    printf("Error: Variable %s was not declared(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  if(verify_if_it_is_struct(memory,$1,nr_var_in_memory) == false){//if it's not a struct --> Error
                    printf("Error: Variable %s is not a struct(SEE line %d)\n", $1,yylineno);
                    exit(1);
                  }
                  if (verify_if_member_exists_in_struct(memory,nr_var_in_memory,types_defined_by_user,$1,$3,nr_of_types_defined_by_user,false) == false){
                    printf("Error: Variable %s does not have a member %s(SEE line %d)\n", $1,$3,yylineno);
                    exit(1);
                  }

                  char concat[2048] ;
                  sprintf(concat,"%s::%s[%d][%d]", $1, $3,$5,$8);
                  $$ = buildAST_STRING(NULL,NULL,_MY_TYPE_MEMBER_MATRIX,concat);
                 }
                 ;

FUNCTION_CALL : IDENTIFIER_FUNCTION OPEN_PAR EXPRESSION_LIST CLOSE_PAR {
                if (verify_if_function_exists($1,functions_tabel,nr_of_functions) == false){
                  printf("Error: Function %s does not exist(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if (verify_if_parameter_of_function_matches($1,functions_tabel,nr_of_functions,list_of_types,nr_parameters) == false){
                  printf("Error: The parameters of the function %s do not match(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                $$ = $1;
                free(list_of_types);
                nr_parameters = 0;
                }
              | IDENTIFIER_FUNCTION OPEN_PAR CLOSE_PAR {
                if (verify_if_function_exists($1,functions_tabel,nr_of_functions) == false){
                  printf("Error: Function %s does not exist(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                if(verify_if_function_has_parameters($1,functions_tabel,nr_of_functions) == true){
                  printf("Error: Function %s has parameters(SEE line %d)\n", $1,yylineno);
                  exit(1);
                }
                $$=$1;
                }
              ;

EXPRESSION_LIST : EXPRESSION {//EXPRESION_LIST will be a list of basic_types, with wich we'll check whether the types of parameters match
                if( TypeOf($1,memory,nr_var_in_memory,types_defined_by_user,nr_of_types_defined_by_user,functions_tabel,nr_of_functions) == INVALID){
                  printf("Error: One parameter of the function is invalid! All variables of that expresion to have the same type(SEE line %d)\n", yylineno);
                  exit(1);
                }
                nr_parameters = 1 ;
                init_list_expressions($1,&list_of_types,memory,nr_var_in_memory,types_defined_by_user,nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                }
                | EXPRESSION_LIST COMMA EXPRESSION{
                if( TypeOf($3,memory,nr_var_in_memory,types_defined_by_user,nr_of_types_defined_by_user,functions_tabel,nr_of_functions) == INVALID){
                  printf("Error: One parameter of the function is invalid! All variables of that expresion need to have the same type(SEE line %d)\n", yylineno);
                  exit(1);
                }
                add_expression_to_list($3,&list_of_types,nr_parameters,memory,nr_var_in_memory,types_defined_by_user,nr_of_types_defined_by_user,functions_tabel,nr_of_functions);
                nr_parameters++;
                }
                ;
%%

int yyerror(char* err_msg){
    printf("Error: %s, la linia %d\n", err_msg, yylineno);
}

int main(int argc, char **argv) {
    yyin  = fopen(argv[1], "r");
    yyparse();

    fclose(yyin);
    return 0;
}