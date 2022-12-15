%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"START_GLOBAL_DECLARATIONS"     {return START_GLOBAL_DECLR;}
"END_GLOBAL_DECLARATIONS"       {return END_GLOBAL_DECLR;}
"START_FUNCTION_DECLARATION"    {return START_FUNCTION_DECLR;}
"END_FUNCTION_DECLARATION"      {return END_FUNCTION_DECLR;}
"START_USER_DEFINED_TYPES"      {return START_USR_DEFINED;}
"END_USER_DEFINED_TYPES"        {return END_USR_DEFINED;}
"START_MAIN"                    {return START_MAIN;}
"END_MAIN"                      {return END_MAIN;}
"if"                            {return IF;}
"else"                          {return ELSE;}
"while"                         {return WHILE;}
"my_type"                       {return MY_TYPE;}
"~~"                            {return FOR_DELIMITATOR;}
"for"                           {return FOR;}
"int"|"float"|"char"|"string"|"bool"                {return PREDEF_TYPE;}
@[_a-zA-Z][_a-zA-Z0-9]*         {return NAME_VARIABLE;}
$[_a-zA-Z][_a-zA-Z0-9]*         {return FUNCTION_NAME;}
#[_a-zA-Z][_a-zA-Z0-9]*         {return MY_TYPE_NAME;}
"=" {return ASSIGN;}
0|([+-]?[1-9][0-9]*) {return NUMBER;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
