if exists("b:current_syntax")
    finish
endif

syn match     rsnIdentifier  contains=rsnIdentifierPrime "\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained
syn match     rsnFuncName    "\%(r#\)\=\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained

syn match rsnRawIdent "\<r#\h\w*" contains=NONE

syn keyword   rsnFloat       Inf NaN
syn keyword   rsnBoolean     true false

" If foo::bar changes to foo.bar, change this ("::" to "\.").
" If foo::bar changes to Foo::bar, change this (first "\w" to "\u").
syn match     rsnModPath     "\w\(\w\)*::[^<]"he=e-3,me=e-3
syn match     rsnModPathSep  "::"

syn match     rsnOperator     display "\%(+\|-\)"

syn match     rsnEscapeError   display contained /\\./
syn match     rsnEscape        display contained /\\\([nrt0\\'"]\|x\x\{2}\)/
syn match     rsnEscapeUnicode display contained /\\u{\%(\x_*\)\{1,6}}/
syn match     rsnStringContinuation display contained /\\\n\s*/
syn region    rsnString      matchgroup=rsnStringDelimiter start=+b"+ skip=+\\\\\|\\"+ end=+"+ contains=rsnEscape,rsnEscapeError,rsnStringContinuation
syn region    rsnString      matchgroup=rsnStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=rsnEscape,rsnEscapeUnicode,rsnEscapeError,rsnStringContinuation,@Spell
syn region    rsnString      matchgroup=rsnStringDelimiter start='b\?r\z(#*\)"' end='"\z1' contains=@Spell

" Match attributes with either arbitrary syntax or special highlighting for
" derives. We still highlight strings and comments inside of the attribute.
syn region    rsnAttribute   start="#!\?\[" end="\]" contains=@rsnAttributeContents,rsnAttributeParenthesizedParens,rsnAttributeParenthesizedCurly,rsnAttributeParenthesizedBrackets,rsnDerive
syn region    rsnAttributeParenthesizedParens matchgroup=rsnAttribute start="\w\%(\w\)*("rs=e end=")"re=s transparent contained contains=rsnAttributeBalancedParens,@rsnAttributeContents
syn region    rsnAttributeParenthesizedCurly matchgroup=rsnAttribute start="\w\%(\w\)*{"rs=e end="}"re=s transparent contained contains=rsnAttributeBalancedCurly,@rsnAttributeContents
syn region    rsnAttributeParenthesizedBrackets matchgroup=rsnAttribute start="\w\%(\w\)*\["rs=e end="\]"re=s transparent contained contains=rsnAttributeBalancedBrackets,@rsnAttributeContents
syn region    rsnAttributeBalancedParens matchgroup=rsnAttribute start="("rs=e end=")"re=s transparent contained contains=rsnAttributeBalancedParens,@rsnAttributeContents
syn region    rsnAttributeBalancedCurly matchgroup=rsnAttribute start="{"rs=e end="}"re=s transparent contained contains=rsnAttributeBalancedCurly,@rsnAttributeContents
syn region    rsnAttributeBalancedBrackets matchgroup=rsnAttribute start="\["rs=e end="\]"re=s transparent contained contains=rsnAttributeBalancedBrackets,@rsnAttributeContents
syn cluster   rsnAttributeContents contains=rsnString,rsnCommentLine,rsnCommentBlock,rsnCommentLineDocError,rsnCommentBlockDocError
syn region    rsnDerive      start="derive(" end=")" contained contains=rsnDeriveTrait
" Number literals
" syn match     rsnDecNumber   display "\<[0-9][0-9_]*\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
" syn match     rsnHexNumber   display "\<0x[a-fA-F0-9_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
" syn match     rsnOctNumber   display "\<0o[0-7_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
" syn match     rsnBinNumber   display "\<0b[01_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     rsnDecNumber   display "\<[0-9][0-9_]*"
syn match     rsnHexNumber   display "\<0x[a-fA-F0-9_]\+"
syn match     rsnOctNumber   display "\<0o[0-7_]\+"
syn match     rsnBinNumber   display "\<0b[01_]\+"

" Special case for numbers of the form "1." which are float literals, unless followed by
" an identifier, which makes them integer literals with a method call or field access,
" or by another ".", which makes them integer literals followed by the ".." token.
" (This must go first so the others take precedence.)
syn match     rsnFloat       display "\<[0-9][0-9_]*\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\|\.\)\@!"
" To mark a number as a normal float, it must have at least one of the three things integral values don't have:
" a decimal point and more numbers; an exponent; and a type suffix.
syn match     rsnFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)\="
syn match     rsnFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\(f32\|f64\)\="
syn match     rsnFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)"

syn match   rsnCharacterInvalid   display contained /b\?'\zs[\n\r\t']\ze'/
" The groups negated here add up to 0-255 but nothing else (they do not seem to go beyond ASCII).
syn match   rsnCharacterInvalidUnicode   display contained /b'\zs[^[:cntrl:][:graph:][:alnum:][:space:]]\ze'/
syn match   rsnCharacter   /b'\([^\\]\|\\\(.\|x\x\{2}\)\)'/ contains=rsnEscape,rsnEscapeError,rsnCharacterInvalid,rsnCharacterInvalidUnicode
syn match   rsnCharacter   /'\([^\\]\|\\\(.\|x\x\{2}\|u{\%(\x_*\)\{1,6}}\)\)'/ contains=rsnEscape,rsnEscapeUnicode,rsnEscapeError,rsnCharacterInvalid

syn region rsnCommentLine                                                  start="//"                      end="$"   contains=@Spell
syn region rsnCommentLineDoc                                               start="//\%(//\@!\|!\)"         end="$"   contains=@Spell
syn region rsnCommentLineDocError                                          start="//\%(//\@!\|!\)"         end="$"   contains=@Spell contained
syn region rsnCommentBlock             matchgroup=rsnCommentBlock         start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=rsnCommentBlockNest,@Spell
syn region rsnCommentBlockNest         matchgroup=rsnCommentBlock         start="/\*"                     end="\*/" contains=rsnCommentBlockNest,@Spell contained transparent

" FIXME: this is a really ugly and not fully correct implementation. Most
" importantly, a case like ``/* */*`` should have the final ``*`` not being in
" a comment, but in practice at present it leaves comments open two levels
" deep. But as long as you stay away from that particular case, I *believe*
" the highlighting is correct. Due to the way Vim's syntax engine works
" (greedy for start matches, unlike rsn's tokeniser which is searching for
" the earliest-starting match, start or end), I believe this cannot be solved.
" Oh you who would fix it, don't bother with things like duplicating the Block
" rules and putting ``\*\@<!`` at the start of them; it makes it worse, as
" then you must deal with cases like ``/*/**/*/``. And don't try making it
" worse with ``\%(/\@<!\*\)\@<!``, either...

" Folding rules {{{2
" Trivial folding rules to begin with.
" FIXME: use the AST to make really good folding
syn region rsnFoldBraces start="{" end="}" transparent fold

" Default highlighting {{{1
hi def link rsnDecNumber       rsnNumber
hi def link rsnHexNumber       rsnNumber
hi def link rsnOctNumber       rsnNumber
hi def link rsnBinNumber       rsnNumber
hi def link rsnIdentifierPrime rsnIdentifier

hi def link rsnSigil         StorageClass
hi def link rsnEscape        Special
hi def link rsnEscapeUnicode rsnEscape
hi def link rsnEscapeError   Error
hi def link rsnStringContinuation Special
hi def link rsnString        String
hi def link rsnStringDelimiter String
hi def link rsnCharacterInvalid Error
hi def link rsnCharacterInvalidUnicode rsnCharacterInvalid
hi def link rsnCharacter     Character
hi def link rsnNumber        Number
hi def link rsnBoolean       Boolean
hi def link rsnFloat         Float
hi def link rsnOperator      Operator
hi def link rsnModPath       Include
hi def link rsnModPathSep    Delimiter
hi def link rsnCommentLine   Comment
hi def link rsnCommentLineDoc SpecialComment
hi def link rsnCommentLineDocLeader rsnCommentLineDoc
hi def link rsnCommentLineDocError Error
hi def link rsnCommentBlock  rsnCommentLine
hi def link rsnCommentBlockDoc rsnCommentLineDoc
hi def link rsnCommentBlockDocStar rsnCommentBlockDoc
hi def link rsnCommentBlockDocError Error
hi def link rsnCommentDocCodeFence rsnCommentLineDoc
hi def link rsnAttribute     PreProc
hi def link rsnDerive        PreProc

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "rsn"
