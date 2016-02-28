shared void run() {
    CeylonLexerTest().run();
    CharacterSourceStreamTest().run();
    FilteringTokenSourceTest().run();
    StringCharacterStreamTest().run();
    TokenSourceIterableTest().run();
    TokenSourceStreamTest().run();

    testNonIgnoredTokenSource();
    testIterableTokenSource();
}