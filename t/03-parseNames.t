use Text::Names 'parseNames','cleanName','composeName','parseName','parseName2','cleanParseName','reverseName','normalizeSuffixName','normalizeJrSuffix','normalizeAuthorSourceValue','authorValueLooksPlaceholder','looksCjkSingleTokenName','hasJrSuffix','hasInvertedJrSuffix';
use Test::More;
use utf8;
binmode(STDOUT,":utf8");

is(cleanName("T.H. Ho"),"Ho, T. H.");
is(cleanName("Ho, T. . ."),"Ho, T.");
is(cleanName("D.'Arms, D."), "D'Arms, D.");
is(cleanName("D.’Arms, D."), "D'Arms, D.");
is(cleanName("D’Arms, D."), "D’Arms, D.");
my @n = cleanParseName("T Nagel");
is($n[1], "Nagel", 'Nagel last name');
is($n[0], "T.", 'Nagel first name');
my ($f,$l) = parseName("D’Arms, D.");
is($l,"D’Arms");
is(normalizeSuffixName("Krotoszynski, Jr., Ronald J."), "Krotoszynski Jr, Ronald J.");
is(normalizeSuffixName("Hill, Jr., Thomas E."), "Hill Jr, Thomas E.");
is(normalizeSuffixName("Smith, John, Jr."), "Smith Jr, John");
is(normalizeSuffixName("Gautschi, III, Frederick H."), "Gautschi III, Frederick H.");
is(normalizeSuffixName("Henry E. Kyburg, Jr."), "Henry E. Kyburg, Jr.");
is(normalizeJrSuffix("Jr."), "Jr");
is(normalizeJrSuffix("jr"), "Jr");
is(normalizeJrSuffix("III"), undef);
ok(hasJrSuffix("Krotoszynski Jr, Ronald J."));
ok(hasJrSuffix("Henry E. Kyburg, Jr."));
ok(hasInvertedJrSuffix("Krotoszynski, Jr., Ronald J."));
ok(!hasInvertedJrSuffix("Krotoszynski Jr, Ronald J."));
my ($f2,$l2) = parseName("Krotoszynski, Jr., Ronald J.");
is($f2,"Ronald J.");
is($l2,"Krotoszynski Jr");
my ($f3,$l3) = parseName("Krotoszynski Jr, Ronald J.");
is($f3,"Ronald J.");
is($l3,"Krotoszynski Jr");
my ($f4,$l4) = parseName("Thomas E. Hill, Jr.");
is($f4,"Thomas E.");
is($l4,"Hill Jr");
my ($f5,$l5) = parseName("Henry E. Kyburg Jr.");
is($f5,"Henry E.");
is($l5,"Kyburg Jr");
my ($pf,$pi,$pl,$ps) = parseName2("Krotoszynski, Jr., Ronald J.");
is($pf,"Ronald");
is($pi,"J.");
is($pl,"Krotoszynski");
is($ps,"Jr");
my ($pf2,$pi2,$pl2,$ps2) = parseName2("Thomas E. Hill, Jr.");
is($pf2,"Thomas");
is($pi2,"E.");
is($pl2,"Hill");
is($ps2,"Jr");
my ($pf3,$pi3,$pl3,$ps3) = parseName2("Smith, John, Jr.");
is($pf3,"John");
is($pi3,undef);
is($pl3,"Smith");
is($ps3,"Jr");
is(reverseName("Krotoszynski Jr, Ronald J."),"Ronald J. Krotoszynski Jr");
is(reverseName("Krotoszynski, Jr., Ronald J."),"Ronald J. Krotoszynski Jr");
is(reverseName("Thomas E. Hill, Jr."),"Thomas E. Hill Jr");
is(reverseName("Smith, John, Jr."),"John Smith Jr");


my %tests = (
    'Kuehni, R. G., Hardin, C. L.' => 'Kuehni, R. G.; Hardin, C. L.',
	'Bourget, David; Doe, John' => 'Bourget, David; Doe, John',	
	'David Bourget & John Doe' => 'Bourget, David; Doe, John',	
	'David Bourget and John Doe' => 'Bourget, David; Doe, John',	
	'Bourget D, Doe J' => 'Bourget, D.; Doe, J.',	
	'Bourget DJR' => 'Bourget, D. J. R.',
    'Bourget, D.J.R.' => 'Bourget, D. J. R.',
    'Bourget D.J.R.' => 'Bourget, D. J. R.',
    'D.J. Bourget' => 'Bourget, D. J.',
	'Bourget, DAVID' => 'Bourget, DAVID',
	'David BOURGET' => 'BOURGET, David',
    'David Chalmers, David Bourget and John Doe' => 'Chalmers, David; Bourget, David; Doe, John',
    'Chalmers, David, Bourget, David, Doe, John' => 'Chalmers, David; Bourget, David; Doe, John',
    'Chalmers, David John, Bourget, David, Doe, John C.' => 'Chalmers, David John; Bourget, David; Doe, John C.',
	'DAVID BOURGET' => 'BOURGET, DAVID',
    'John Doe Jr' => 'Doe Jr, John',
    'John M. Doe Jr' => 'Doe Jr, John M.',
    'Smith, John, Jr.' => 'Smith Jr, John',
    'John Smith, Jr. and Jane Roe' => 'Smith Jr, John; Roe, Jane',
    'John Smith, Jr., and Jane Roe' => 'Smith Jr, John; Roe, Jane',
    'Smith, John, Jr. and Roe, Jane' => 'Smith Jr, John; Roe, Jane',
    'Smith, John, Jr., Roe, Jane' => 'Smith Jr, John; Roe, Jane',
    'Roe, Jane, Smith, John, Jr.' => 'Roe, Jane; Smith Jr, John',
    'Roe, Jane, Smith, Jr., John' => 'Roe, Jane; Smith Jr, John',
    'Jane Roe, John Smith, Jr.' => 'Roe, Jane; Smith Jr, John',
    'John Smith, Jr., Jane Roe' => 'Smith Jr, John; Roe, Jane',
    'Dr Afsar Abbas' => 'Abbas, Afsar',
    'R. de Sousa' => 'de Sousa, R.',
    'Jean Claude van Damme' => 'van Damme, Jean Claude',
    'Dr. Jean Claude van Damme, Prof R de Sousa' => 'van Damme, Jean Claude; de Sousa, R.',
    "Maureen A. O'Malley" => "O'Malley, Maureen A.",
    "Gusmão da Silva, Guilherme" => "Gusmão da Silva, Guilherme",
    "D Bourget, Zbigniew Z Lukasiak and John Doe" => "Bourget, D.; Lukasiak, Zbigniew Z.; Doe, John",
    "Bourget, D and John Doe" => "Bourget, D.; Doe, John",
    "Bourget, D, Chalmers C, and John Doe" => "Bourget, D.; Chalmers, C.; Doe, John",
    cleanName("Guilherme Gusmão da Silva") => "da Silva, Guilherme Gusmão",
    cleanName("van Untouched, Firstname") => "van Untouched, Firstname",
    cleanName("Van Untouched, Firstname") => "Van Untouched, Firstname",
    cleanName("VAN TOUCHED, firstname") => "van Touched, Firstname",
    cleanName("CL Adams") => "Adams, C. L.",
    cleanName("Hacker, PMS") => "Hacker, P. M. S.",
    cleanName("van fraassen b") => "van Fraassen, B.",
    cleanName("van fraassen b c") => "van Fraassen, B. C.",
    cleanName("RawlsJ.") => "Rawls, J.",
    cleanName("RawlsJ.C.") => "Rawls, J. C.",
    cleanName("RawlsJC") => "Rawls, J. C.",
    cleanName("McKim, John") => "McKim, John",
    cleanName("John McKim") => "McKim, John",
    cleanName("McKim") => "McKim, ",
    cleanName("DavidBourget") => "Bourget, David"
);
is(cleanName("Hacker, PMS"),"Hacker, P. M. S.");
is(cleanName("Doe, Bob"),"Doe, Bob");
is(cleanName("Krotoszynski, Jr., Ronald J."),"Krotoszynski Jr, Ronald J.");
is(cleanName("Krotoszynski Jr Ronald J."),"Krotoszynski Jr, Ronald J.");
is(cleanName("Thomas E. Hill, Jr."),"Hill Jr, Thomas E.");
is(cleanName("Henry E. Kyburg Jr."),"Kyburg Jr, Henry E.");
is(cleanName("Jr. Henry E. Kyburg"),"Kyburg Jr, Henry E.");
is(cleanName("Gautschi III, Frederick H."),"Gautschi III, Frederick H.");
is(normalizeAuthorSourceValue("Brophy, O.P., Justin Marie"), "Brophy, Justin Marie");
is(normalizeAuthorSourceValue("Frederick H. Gautschi, III"), "Gautschi III, Frederick H.");
is(normalizeAuthorSourceValue("D.Phil,, Stephen Hall,"), "Stephen Hall");
is(normalizeAuthorSourceValue("Stephen Hall, D.Phil, LL.B."), "Stephen Hall");
is(normalizeAuthorSourceValue("Papadimitriou, Ph.D., Christina"), "Papadimitriou, Christina");
is(normalizeAuthorSourceValue("David A. Stone Ph.D."), "David A. Stone");
ok(authorValueLooksPlaceholder(",, Romanus"));
ok(!authorValueLooksPlaceholder("Gautschi III, Frederick H."));
ok(looksCjkSingleTokenName("劉福增"));
ok(!looksCjkSingleTokenName("Fu-tseng Liu"));
#print cleanName("Guilherme Gusmão da Silva");
foreach my $t (keys %tests) {
	my $r = join('; ',parseNames($t));
    is( $r, $tests{$t}, "$t -> $r" );
}
done_testing;
