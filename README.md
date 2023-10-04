# Lexical_Analysis
Lexical Analysis for C 

This code presents a Lexical Analyzer for a C compiler. Its primary objective is to identify various C tokens and construct a Symbol Table for storing information about identifiers and functions. The Lexical Analyzer also incorporates error-handling mechanisms for specific
lexical errors. The Symbol Table is designed using Hashing and Chaining techniques for efficient organization.

Instructions to run the code in Linux OS
1. Save the input.txt file in the same folder as the lexicalAnalyser.l file
2. Change the terminal Directory to the Directory having both the above files
3. Run the commands:
   flex lexicalAnalyser.l
   gcc lex.yy.c
   ./a.out
   
