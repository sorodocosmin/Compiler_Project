%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"START_GLOBAL_DECLARATIONS"     {return _START_GLOBAL_DECLR;}
"END_GLOBAL_DECLARATIONS"       {return _END_GLOBAL_DECLR;}

"START_FUNCTION_DECLARATION"    {return _START_FUNCTION_DECLR;}
"END_FUNCTION_DECLARATION"      {return _END_FUNCTION_DECLR;}

"START_USER_DEFINED_TYPES"      {return _START_USR_DEFINED;}
"END_USER_DEFINED_TYPES"        {return _END_USR_DEFINED;}

"START_MAIN"                    {return _START_MAIN;}
"END_MAIN"                      {return _END_MAIN;}

"if"                            {return _IF;}
"else"                          {return _ELSE;}
"while"                         {return _WHILE;}
"my_type"                       {return _MY_TYPE;}
"~~"                            {return _FOR_DELIMITATOR;}
"for"                           {return _FOR;}

"true"                          {return _COND_TRUE;}
"false"                         {return _COND_FALSE;}

"<"                             {return _LESS_THAN;}  
"<="                            {return _LESS_OR_EQ;}
">"                             {return _GREATER_THAN;}
">="                            {return _GREATER_OR_EQ ;}
"==="                           {return _EQUAL;}
"++"                             {return _ADD;}
"//"                             {return _DIVIDE;}
"**"                             {return _MULTIPLY;}
"--"                             {return _SUBSTRACT;}

"&"                             {return _AND;}
"|"                             {return _OR;}
"!"                             {return _NOT;}

"int"|"float"|"char"|"string"|"bool"                { return _PREDEF_TYPE;}
@[_a-zA-Z][_a-zA-Z0-9]*         {return _NAME_VARIABLE;}
$[_a-zA-Z][_a-zA-Z0-9]*         {return _FUNCTION_NAME;}
#[_a-zA-Z][_a-zA-Z0-9]*         {return _MY_TYPE_NAME;}
"="                             {return _ASSIGN;}
([+]?[1-9][0-9]*)               {return _NUMBER_POS;}
0|(-[1-9][0-9]*)                {return _NUMBER_NEG;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
