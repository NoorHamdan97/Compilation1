%{
/* Declarations section */ 
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int showToken(const char * name);
void remove_leading_zeros();
int line_num = 1;
int i;
#define MAX_LEN 1026
char string_buf[MAX_LEN];
char *string_buf_ptr;
int undefined = 0;

%} 

%option yylineno
%option noyywrap
%x comment
%x STR

digit [0-9]
real ("."{digit}+|{digit}+"."{digit}*)
letter [a-zA-Z]
relop ((==)|(!=)|(<=)|(>=)|(<)|(>))
logop (\&\&|\|\|)
binop [%+*/-]
cmt_printable [\x20-\x29\x2B-\x7E \t]
cmt_no_slash [\x20-\x29\x2B-\x2E\x30-\x7E \t]
whitespace [\r\t\n ]
unp1 [\x00-\x08]
unp2 [\x0b-\x0c]
unp3 [\x0e-\x1F]
unp4 [\x7f]

%%


"Int"|"UInt"|"Double"|"Float"|"Bool"|"String"|"Character"	return showToken("TYPE");
"var" return showToken("VAR");
"let" return showToken("LET");
"func" return showToken("FUNC");
"import" 	 return showToken("IMPORT");
"nil" return showToken("NIL");
"true" return showToken("TRUE");
"false" return showToken("FALSE");
"->"	return showToken("ARROW");
":"	return showToken("COLON");
"return" return showToken("RETURN");
"if" return showToken("IF");
"else" return showToken("ELSE");
"while" return showToken("WHILE");
";" return showToken("SC");
"," return showToken("COMMA");
"(" return showToken("LPAREN");
")" return showToken("RPAREN");
"{" return showToken("LBRACE");
"}" return showToken("RBRACE");
"[" return showToken("LBRACKET");
"]" return showToken("RBRACKET");
"=" return showToken("ASSIGN");
{relop} return showToken("RELOP");
{logop} return showToken("LOGOP");
{real}[Ee](("+")|("-")){digit}+	return showToken("DEC_REAL");
"0x"[a-fA-F0-7]+[Pp](("+")|("-")){digit}+	   return showToken("HEX_FP");
{binop} return showToken("BINOP");
{real}	return showToken("DEC_REAL");
"0b"[0-1]+	 {sprintf(yytext, "%d", strtol(yytext+2, NULL, 2));return showToken("BIN_INT");}
"0o"[0-7]+	 {sprintf(yytext, "%d",strtol(yytext+2, NULL, 8));return showToken("OCT_INT");}
"0x"[a-fA-F0-7]+	{sprintf(yytext, "%d", strtol(yytext+2, NULL, 16));return showToken("HEX_INT");}
[0]|[1-9][0-9]*		return showToken("DEC_INT");
[0]+[1-9][0-9]*		{remove_leading_zeros();return showToken("DEC_INT");}

{letter}[a-zA-Z0-9]*	return showToken("ID");
"_"[a-zA-Z0-9]+ return showToken("ID");

"/*"         BEGIN(comment);
<comment>{
	<<EOF>> 		{printf("Error unclosed comment\n");exit(0);}
	{cmt_printable}*"/*"	{printf("Warning nested comment\n");exit(0);}
	{cmt_printable}*[\r\n]		   ++line_num;
	{cmt_printable}*  	      ;
	"*"+{cmt_no_slash}*   ;
	"*"+{cmt_no_slash}*[\n\r]	 ++line_num;
	"*"+"/"         {sprintf(yytext, "%d", line_num);line_num=1;showToken("COMMENT");BEGIN(INITIAL);}
	
   {unp1}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp2}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp3}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp4}  {printf("Error %c\n",yytext[0]);exit(0);}
}
"//"[\x20-\x7e \t]* {yytext="1";return showToken("COMMENT");}

\" 										{string_buf_ptr = string_buf; BEGIN(STR); }
<STR>{
	<<EOF>>								{BEGIN(INITIAL); printf("Error unclosed string\n");exit(0);}		
	\"    								{ 
										BEGIN(INITIAL);
											yytext = string_buf;
											*string_buf_ptr = '\0';
											if (strlen(string_buf_ptr)+1>= MAX_LEN){printf("Error unclosed string\n");exit(0);}
											return showToken("STRING");
										}
									
	 
	\\u"{"[0]{0,5}[0-9a-fA-F]"}"     {                                               
												/* hex escape sequence */
													int result;
													int len = strlen(yytext)+1;
													char text[len-4];
													
													for(i=0;i<len-5;i++){
														text[i]= yytext[i+3];
														if (i+1>=len-5)
															text[i+1]='\0';
													}
													(void) sscanf(text , "%x", &result );
													*string_buf_ptr++ = result;
											}
	
	\\u"{"[0]{0,4}[0-7][0-9a-fA-F]"}"     {                                               
												/* hex escape sequence */
													int result;
													int len = strlen(yytext)+1;
													char text[len-4];
													
													for(i=0;i<len-5;i++){
														text[i]= yytext[i+3];
														if (i+1>=len-5)
															text[i+1]='\0';
													}
													(void) sscanf(text , "%x", &result );
													*string_buf_ptr++ = result;
											}
	
	\\u"{"[0-9a-zA-Z]{0,6}"}"			{	
											printf("Error undefined escape sequence %c\n",yytext[1]);
											exit(0);
										}

	
	\\n 									{*string_buf_ptr++ = '\n';}
	\\t										{*string_buf_ptr++ = '\t';}
	\\r 									{*string_buf_ptr++ = '\r';}
	\\\\ 									    {*string_buf_ptr++ = '\\';}
	\\0  									{*string_buf_ptr++ = '\0';}
	\\\"			  						    {*string_buf_ptr++ = '\"';}
	\\(.|\n|\r)										{
												printf("Error undefined escape sequence %c\n",yytext[1]);
												exit(0);
											}


   
   {unp1}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp2}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp3}  {printf("Error %c\n",yytext[0]);exit(0);}
   {unp4}  {printf("Error %c\n",yytext[0]);exit(0);}
	
	[^\r\n\"]{0,1023}[\n\r] {;printf("Error unclosed string\n");exit(0);}
	.										{
												if(undefined) {printf("Error undefined escape sequence %c\n",yytext[1]);exit(0);}
												*string_buf_ptr++ = *yytext;
											}
	

}
{whitespace} ;
. printf("Error %s\n",yytext);exit(0);
%%

int showToken(const char* name){
	printf("%d %s %s\n",yylineno,name,yytext);
	return 1;
}

void remove_leading_zeros(){
	int i=0;
	while(yytext[i]=='0')
		++i;
	yytext = yytext+i;
}
