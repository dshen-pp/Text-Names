use Text::Names 'parseName','parseNames','cleanName','normalizeAuthorSourceValue','samePerson';
use Test::More;
use utf8;
binmode(STDOUT,":utf8");
binmode(Test::More->builder->output,":utf8");
binmode(Test::More->builder->failure_output,":utf8");

sub parsed {
    my ($given, $last) = parseName(shift);
    return "$last | $given";
}

# A middle or first initial E. or Y. is an initial, not the particle "e" or "y".
is(parsed("Thomas E. Hill"), "Hill | Thomas E.");
is(parsed("Henry E. Kyburg"), "Kyburg | Henry E.");
is(parsed("Jorge J. E. Gracia"), "Gracia | Jorge J. E.");
is(parsed("Jorge J.E. Gracia"), "Gracia | Jorge J. E.");
is(parsed("George E. McCarthy"), "McCarthy | George E.");
is(parsed("Thomas E Hill"), "Hill | Thomas E.");
is(parsed("William Y. Smith"), "Smith | William Y.");
is(parsed("John Y. E. Smith"), "Smith | John Y. E.");
is(parsed("E. Harrison"), "Harrison | E.");
is(parsed("Y. Wang"), "Wang | Y.");
is(parsed("Thomas E. Hill, Jr."), "Hill Jr | Thomas E.");
is(cleanName("Thomas E. Hill"), "Hill, Thomas E.");
is(cleanName("Henry E. Kyburg Jr."), "Kyburg Jr, Henry E.");
is(cleanName("Hill, Thomas E."), "Hill, Thomas E.");
is_deeply([parseNames("Thomas E. Hill and Ana Y. Lee")], ["Hill, Thomas E.", "Lee, Ana Y."]);

# The lowercase particles "e" and "y" join two surnames. They come out as "E."/"Y.", as in every
# other parse of these names (normalizeNameWhitespace).
is(parsed("José Ortega y Gasset"), "Ortega Y. Gasset | José");
is(parsed("Ortega y Gasset, José"), "Ortega Y. Gasset | José");
is(parsed("Paula Oliveira e Silva"), "Oliveira E. Silva | Paula");
is(parsed("Maria E. Oliveira e Silva"), "Oliveira E. Silva | Maria E.");
is(parsed("Juan de la Torre y Pérez"), "de la Torre Y. Pérez | Juan");
is(parsed("Antonio e Silva"), "E. Silva | Antonio");
is(parsed("Guilherme Gusmão da Silva"), "da Silva | Guilherme Gusmão");

# Religious-order postnominals and the titles that go with them are not part of the name.
is(parsed("Fr. Allan D. Fitzgerald, O.S.A."), "Fitzgerald | Allan D.");
is(parsed("Allan D. Fitzgerald, O. S. A."), "Fitzgerald | Allan D.");
is(parsed("Gary M. Gurtler, S.J."), "Gurtler | Gary M.");
is(parsed("Gurtler, S.J., Gary M."), "Gurtler | Gary M.");
is(parsed("Gurtler, Gary M., S.J."), "Gurtler | Gary M.");
is(parsed("R. Stoeger, S. J."), "Stoeger | R.");
is(parsed("William R. Stoeger, S.J."), "Stoeger | William R.");
is(parsed("Brian E. Daley, S. J."), "Daley | Brian E.");
is(parsed("J. William Harmless, S. J."), "Harmless | J. William");
is(parsed("Patrick Riordan, SJ"), "Riordan | Patrick");
is(parsed("Paul Murray, Op"), "Murray | Paul");
is(parsed("Columba Stewart, O.S.B."), "Stewart | Columba");
is(parsed("Romanus Cessario, O.P."), "Cessario | Romanus");
is(parsed("Sr Albert Marie Surmanski, O. P."), "Surmanski | Albert Marie");
is(cleanName("Fr. Allan D. Fitzgerald, O.S.A."), "Fitzgerald, Allan D.");
is(cleanName("R. Stoeger, S. J."), "Stoeger, R.");
is_deeply([parseNames("R. Stoeger, S. J.")], ["Stoeger, R."]);
is_deeply([parseNames("Allan D. Fitzgerald, O. S. A.")], ["Fitzgerald, Allan D."]);
is_deeply([parseNames("Fr. Allan D. Fitzgerald, O.S.A.")], ["Fitzgerald, Allan D."]);
is_deeply([parseNames("John J. Cleary and Gary M. Gurtler, S.J.")], ["Cleary, John J.", "Gurtler, Gary M."]);
is_deeply([parseNames("Gary M. Gurtler, S.J., John J. Cleary")], ["Gurtler, Gary M.", "Cleary, John J."]);
ok(samePerson("Gary M. Gurtler, S.J.", "Gurtler, Gary M."));
is(normalizeAuthorSourceValue("Fr. Allan D. Fitzgerald, O.S.A."), "Allan D. Fitzgerald");
is(normalizeAuthorSourceValue("Gary M. Gurtler, S.J."), "Gary M. Gurtler");
is(normalizeAuthorSourceValue("Romanus Cessario, O.P."), "Romanus Cessario");

# After a lone surname, a compound surname or a surname with a particle, the same letters may be
# the person's initials, so they stay.
is(parsed("Harrison, S. J."), "Harrison | S. J.");
is(parsed("Harrison, S.J."), "Harrison | S. J.");
is(parsed("S. J. Harrison"), "Harrison | S. J.");
is(parsed("Smith, O. P."), "Smith | O. P.");
is(parsed("Herrera Molina, S. J."), "Herrera Molina | S. J.");
is(parsed("van Enk, S. J."), "van Enk | S. J.");
is(parsed("De Strycker, S. J."), "De Strycker | S. J.");
is(parsed("Rodriguez Artacho, C. M."), "Rodriguez Artacho | C. M.");
is(parsed("Johnson, Osa"), "Johnson | Osa");
is(cleanName("Harrison, S. J."), "Harrison, S. J.");
is_deeply([parseNames("Harrison, S. J.")], ["Harrison, S. J."]);
is_deeply([parseNames("Thomas Smith, S. J. Harrison")], ["Smith, Thomas", "Harrison, S. J."]);
is_deeply([parseNames("John Cleary and Harrison, S. J.")], ["Cleary, John", "Harrison, S. J."]);
is(normalizeAuthorSourceValue("Harrison, S. J."), "Harrison, S. J.");
is(normalizeAuthorSourceValue("Smith, John M. A."), "Smith, John M. A.");
is(normalizeAuthorSourceValue("Badia Cabrera, M. A."), "Badia Cabrera, M. A.");
is(normalizeAuthorSourceValue("Aalders, G. J. D."), "Aalders, G. J. D.");
is(normalizeAuthorSourceValue("Smith, John, Ph.D."), "Smith, John");
is(normalizeAuthorSourceValue("Joseph Ma"), "Joseph Ma");
is(normalizeAuthorSourceValue("S. J., Harrison"), "S. J., Harrison");
is(normalizeAuthorSourceValue("Csj, Mary Beth Ingham"), "Mary Beth Ingham");
# C.M., C.P. and L.C. are left alone: "E. Nothaft, C. P." is C. Philipp E. Nothaft.
is(parsed("E. Nothaft, C. P."), "E. Nothaft | C. P.");
is(normalizeAuthorSourceValue("Cp, J."), "Cp, J.");

# Without a postnominal a title stays: "Fr." is also an abbreviated given name ("Fr. Nietzsche").
is(parsed("Fr. John Smith"), "Smith | Fr. John");

done_testing;
