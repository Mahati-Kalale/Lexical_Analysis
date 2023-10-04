%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// Define the maximum size of the symbol table
#define MAX_TABLE_SIZE 25
// Define the structure for an identifier entry
struct LineReference {
    int line;
    struct LineReference* next;
};
struct IdentifierEntry {
    char name[64];   // You can adjust the size as needed
    char data_type[64];   // You can adjust the size as needed
    int dimension;
    int size;
    int scope;
    struct LineReference* line_references;//LinkedList of line numbers where the identifier was referenced
    struct IdentifierEntry* next;
};
// Declare a symbol table as an array of linked lists
struct IdentifierEntry* symbolTable[MAX_TABLE_SIZE] = { NULL };

// Define a simple hash function
unsigned int hash(const char* str) {
    unsigned int sum = 0;
    while (*str) {
        sum = sum + *str++;
    }
    return sum % MAX_TABLE_SIZE;
}

// Function to insert an identifier into the symbol table
void insertIdentifier(const char* name, const char* type, int dimension, int size, int scope, int line) {
    unsigned int index = hash(name);
    // Check if the identifier already exists in the symbol table
    struct IdentifierEntry* current = symbolTable[index];
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // Identifier already exists; update the line of reference
            struct LineReference* newLineRef = (struct LineReference*)malloc(sizeof(struct LineReference));
            if (!newLineRef) {
                fprintf(stderr, "Memory allocation error\n");
                exit(EXIT_FAILURE);
            }
            newLineRef->line = line;
            newLineRef->next = NULL;

            // Find the last line reference node
            struct LineReference* lastLineRef = current->line_references;
            while (lastLineRef->next != NULL) {
                lastLineRef = lastLineRef->next;
            }

            // Add the new line reference node to the end
            lastLineRef->next = newLineRef;
            return; // Exit the function since the identifier has been updated
        }
        current = current->next;
    }
    
    // If the identifier does not exist, create a new entry
    struct IdentifierEntry* newEntry = (struct IdentifierEntry*)malloc(sizeof(struct IdentifierEntry));
    if (!newEntry) {
        fprintf(stderr, "Memory allocation error\n");
        exit(EXIT_FAILURE);
    }
    strcpy(newEntry->name, name);
    strcpy(newEntry->data_type, type);
    newEntry->dimension = dimension;
    newEntry->size = size;
    newEntry->scope = scope;
    
    // Create the first line reference node
    struct LineReference* newLineRef = (struct LineReference*)malloc(sizeof(struct LineReference));
    if (!newLineRef) {
        fprintf(stderr, "Memory allocation error\n");
        exit(EXIT_FAILURE);
    }
    newLineRef->line = line;
    newLineRef->next = NULL;
    
    newEntry->line_references = newLineRef;
    
    // Add the new entry to the symbol table
    newEntry->next = NULL;
    if(symbolTable[index]==NULL){
        symbolTable[index]=newEntry;
    }
    else{
        current=symbolTable[index];
        while(current->next!=NULL){
            current=current->next;
        }
        current->next=newEntry;
    }
}

%}

%option noyywrap
%option yylineno

KEYWORD     main|return|include|for|if|else|while|case|default|switch|continue|break|extern|const|typedef
DIGIT       [0-9]
LETTER      [a-zA-Z_]

ID          {LETTER}({LETTER}|{DIGIT})*
DATA_TYPE   int|char|float|double|void|bool
WS          [ \t]+
HEADER      #include[ ]*<[a-z\/_]+\.h>

ARTH_OPERATOR   "+"|"-"|"*"|"/"|"++"|"--"|"?"
ASSGN_OPERATOR  =
REL_OPERATOR   (>=)|(<=)|(==)|(!=)|(>)|(<)
BIT_OPERATOR    (&&)|(\|\|)|(\!)
SEPARATOR      ;|,|:
BRACKET		   "("|")"|"{"|"}"|"["|"]"  

BOOL_CONST  true|false
BINARY      0b[0-1]+
OCTAL       0[0-7]+
HEX         0x[0-9A-F]+|0X[0-9A-F]+
INT_CONST   [+-]?[0-9]+
FLOAT_CONST [+-]?[0-9]*[.][0-9]+  
STR_LIT      \"(\\.|[^"])*\"
EXPONENT    [+-]?[0-9]*[.]?[0-9]+[eE][+-]?[0-9]*[.]?[0-9]+
CHAR_LIT    ("\'")[a-zA-Z]("\'")


SC    ~|@|#|$|%|^|&|*|-|+|;|;|=|,|<|>
incomplete_str	    \"[^"\n]*
wrong_identifier	 ([{SC}0-9]+[A-Za-z_]+)+
open_comment		"/*"
close_comment		"*/"

%%
\n ;
\/\/(.)*    ;
"/*"([^*]|\*+[^*/])*\*+"/"  ;

{HEADER}    printf("Line no: %d Header: %s\n", yylineno, yytext);
{DATA_TYPE} printf("Line no: %d DataType: %s\n", yylineno, yytext);
{KEYWORD}   printf("Line no: %d KeyWord: %s\n", yylineno, yytext);

{ARTH_OPERATOR}  printf("Line no: %d Arithmetic Operator: %s\n", yylineno, yytext);
{ASSGN_OPERATOR} printf("Line no: %d Assignment Operator: %s\n", yylineno, yytext);
{REL_OPERATOR}   printf("Line no: %d Relational Operator: %s\n", yylineno, yytext);
{BIT_OPERATOR}   printf("Line no: %d BitWise Operator: %s\n", yylineno, yytext);

{BOOL_CONST}    printf("Line no: %d Boolean Constant: %s\n", yylineno, yytext);
{BINARY}        printf("Line no: %d Binary Constant: %s\n", yylineno, yytext);
{OCTAL}         printf("Line no: %d Octal Constant: %s\n", yylineno, yytext);
{HEX}           printf("Line no: %d Hexadecimal Constant: %s\n", yylineno, yytext);
{INT_CONST}     printf("Line no: %d Integer Constant: %s\n", yylineno, yytext);
{FLOAT_CONST}   printf("Line no: %d Float Constant: %s\n", yylineno, yytext);
{STR_LIT}       printf("Line no: %d String Literal: %s\n", yylineno, yytext);
{EXPONENT}      printf("Line no: %d Exponential Constant: %s\n", yylineno, yytext);
{CHAR_LIT}      printf("Line no: %d Character Constant: %s\n", yylineno, yytext);

{SEPARATOR}      printf("Line no: %d Separator: %s\n", yylineno, yytext);
{BRACKET}        printf("Line no: %d Braces: %s\n", yylineno, yytext);
{ID}    {   if (strlen(yytext) > 31) {
                printf("Error: Identifier '%s' at line %d is too long (max 31 characters).\n", yytext, yylineno);
                exit(0);
            } else {
                insertIdentifier(yytext, "unknown", 0, 0, 0, yylineno); // Adjust type, scope, and line accordingly
                printf("Line no: %d Identifier: %s\n", yylineno, yytext);
            }
        }
{incomplete_str}    {printf("Line no: %d ERROR:Missing Terminating character: %s\n", yylineno, yytext);
                     exit(0);}
{open_comment}      {printf("Line no: %d ERROR:Missing Terminating comment: %s\n", yylineno, yytext);
                    exit(0);}
{close_comment}     {printf("Line no: %d ERROR:Missing Opening comment: %s\n", yylineno, yytext);
                    exit(0);}
{wrong_identifier}  {printf("Line no: %d ERROR:Invalid Identifier: %s\n", yylineno, yytext);
                    exit(0);}
{WS}        ; // Ignore whitespace
.           {printf("Line no: %d ERROR ILLEGAL CHARACTER - %s\n", yylineno, yytext);exit(0);}

%%

int main() {
    FILE* inputFile = fopen("input.txt", "r"); // Replace "input.txt" with your input file name

    // Set Flex to read from the input file
    yyin = inputFile;

    // Perform lexical analysis
    yylex();

    // Print the symbol table
    printf("\nSYMBOL TABLE:\n\n");
    printf("Name:\t  DataType:\t  Scope:\t  Size:\t  Dimension:\t  Line of declaration:\t  Line of reference:\n");

    for (int i = 0; i < MAX_TABLE_SIZE; i++) {
        struct IdentifierEntry* entry = symbolTable[i];
        while (entry) {
            printf("%s\t  %s\t   %d\t\t    %d\t   %d\t\t\t  %d\t\t\t", entry->name, entry->data_type, entry->scope, entry->size, entry->dimension,entry->line_references->line);
            
            // Print the line references for the identifier
            struct LineReference* lineRef = entry->line_references;
            while (lineRef) {
                printf("%d ", lineRef->line);
                lineRef = lineRef->next;
            }
            printf("\n"); // Move to the next line for the next entry
            entry = entry->next;
        }
    }
    return 0;
}