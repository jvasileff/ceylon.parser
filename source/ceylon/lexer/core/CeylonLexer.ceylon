"A Lexer for the Ceylon programming language,
 turning a stream of [[characters]] into a stream of tokens."
shared class CeylonLexer(CharacterStream characters) {
    
    value terminator = '\{PRIVATE USE ONE}';
    
    "Returns the next token, or [[null]] if the [[character stream|characters]]
     is depleted.
     
     (There is no `EOF` token.)"
    shared Token? nextToken() {
        while (characters.peek() != terminator) {
            variable Character next;
            switch (next = characters.peek())
            case ('/') {
                // start of comment?
                switch (characters.peek(1))
                case ('/') {
                    // line comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("//");
                    while ((next = characters.peek()) != '\n' && next != terminator) {
                        characters.consume();
                        text.appendCharacter(next);
                    }
                    return token(lineComment, text.string);
                }
                case ('*') {
                    // multi comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("/*");
                    variable Integer level = 1;
                    while (level != 0) {
                        next = characters.peek();
                        if (next == '/' && characters.peek(1) == '*') {
                            level++;
                            text.append("/*");
                            characters.consume(2);
                            continue;
                        } else if (next == '*' && characters.peek(1) == '/') {
                            level--;
                            text.append("*/");
                            characters.consume(2);
                            continue;
                        } else if (next == terminator) {
                            // TODO unterminated multi comment – error?
                            return token(multiComment, text.string);
                        } else {
                            text.appendCharacter(next);
                            characters.consume();
                        }
                    }
                    return token(multiComment, text.string);
                }
                else {
                    // TODO division operator
                }
            }
            case ('#') {
                if ((next = characters.peek(1)) == '!') {
                    #! line comment
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("#!");
                    while ((next = characters.peek()) != '\n' && next != terminator) {
                        characters.consume();
                        text.appendCharacter(next);
                    }
                    return token(lineComment, text.string);
                } else {
                    // TODO hex literal
                }
            }
            case ('\\') {
                switch (next = characters.peek(1))
                case ('i') {
                    // forced lowercase identifier
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("\\i");
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(lidentifier, text.string);
                }
                case ('I') {
                    // forced uppercase identifier
                    characters.consume(2);
                    StringBuilder text = StringBuilder();
                    text.append("\\I");
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(uidentifier, text.string);
                }
                else {
                    // TODO error
                }
            }
            else {
                if (isIdentifierStart(next)) {
                    characters.consume();
                    StringBuilder text = StringBuilder();
                    text.appendCharacter(next);
                    Boolean lowercase = next.lowercase;
                    while (isIdentifierPart(next = characters.peek())) {
                        text.appendCharacter(next);
                        characters.consume();
                    }
                    return token(lowercase then lidentifier else uidentifier, text.string);
                } else {
                    if (next.whitespace) {
                        characters.consume();
                        StringBuilder text = StringBuilder();
                        text.appendCharacter(next);
                        while ((next = characters.peek()).whitespace) {
                            text.appendCharacter(next);
                            characters.consume();
                        }
                        return token(whitespace, text.string);
                    } else {
                        // TODO error
                    }
                }
            }
        }
        return null;
    }
    
    Token token(TokenType type, String text)
            => Token(type, text); // TODO count token index?
    
    Boolean isIdentifierStart(Character character)
            => character.letter || character == '_';
    
    Boolean isIdentifierPart(Character character)
            => character.letter || character.digit || character == '_';
}
