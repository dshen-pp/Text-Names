use Text::Names 'parseName','parseName2','parseNames','parseNameList','cleanName','normalizeAuthorSourceValue','samePerson';
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
is_deeply([parseNameList("Jorge J.E. Gracia")], ["Gracia, Jorge J. E."]);

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
# parseName2 (first, initials, last, suffix) is what xPapers' cleanAll rebuilds author names from
is_deeply([parseName2("Gurtler, S.J., Gary M.")], ["Gary", "M.", "Gurtler", undef]);
is_deeply([parseName2("R. Stoeger, S. J.")], ["R.", undef, "Stoeger", undef]);
is_deeply([parseName2("Harrison, S. J.")], ["S.", "J.", "Harrison", undef]);
is(normalizeAuthorSourceValue("Fr. Allan D. Fitzgerald, O.S.A."), "Allan D. Fitzgerald");
is(normalizeAuthorSourceValue("Gary M. Gurtler, S.J."), "Gary M. Gurtler");
is(normalizeAuthorSourceValue("Romanus Cessario, O.P."), "Romanus Cessario");
is(normalizeAuthorSourceValue("Albino Barrera O.P."), "Albino Barrera");

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

# Brother, Father, Fr. or Rev. before initials goes only when a name is left: in "Rev. J. A. Smith" the initials
# are the person's own, and a lone "Smith" makes xPapers drop the record as Defective. The name then stays as
# written, the form already stored for these authors. ("Sister M." before a name in religion still goes.)
is(normalizeAuthorSourceValue("Rev. J. A. Smith"), "Rev. J. A. Smith");
is(normalizeAuthorSourceValue("Smith, Rev. J. A."), "Smith, Rev. J. A.");
is(normalizeAuthorSourceValue("Father J. Smith"), "Father J. Smith");
is(normalizeAuthorSourceValue("Robert, Brother S."), "Robert, Brother S.");
# "Fr W. Foerster" is Friedrich Wilhelm Foerster.
is(normalizeAuthorSourceValue("Foerster, Fr W."), "Foerster, Fr W.");
is(normalizeAuthorSourceValue("Fr W. Foerster"), "Fr W. Foerster");
# With an order postnominal the title alone goes and the initials stay.
is(normalizeAuthorSourceValue("Fr. J. Murphy, S.J."), "J. Murphy");
# Titles still go when a name is left.
is(normalizeAuthorSourceValue("Rev. J. A. Smith Jones"), "Smith Jones");
is(normalizeAuthorSourceValue("Sister M. Cleophas Smith, R.S.M."), "Cleophas Smith");
is(normalizeAuthorSourceValue("Sr Albert Marie Surmanski, O. P."), "Albert Marie Surmanski");

# Roman numeral suffixes run from II to IX; "Vi", "Ix" and a lone V or X are name parts or initials.
is(parsed("Nguyen Thi Vi"), "Vi | Nguyen Thi");
is(cleanName("Nguyen Thi Vi"), "Vi, Nguyen Thi");
is(cleanName("Tran Vi Anh"), "Anh, Tran Vi");
is(cleanName("Vi Nguyen"), "Nguyen, Vi");
is(cleanName("Li Ix"), "Ix, Li");
# Stored names carry suffixes title-cased by cleanName ("Soles Iii, Donald E."); those still read as suffixes.
is(parsed("Donald E. Soles Iii"), "Soles III | Donald E.");
is(cleanName("Soles Iii, Donald E."), "Soles III, Donald E.");
is(parsed("John Henry Ring Iv"), "Ring IV | John Henry");
is(parsed("Joao Barros Ii"), "Barros II | Joao");
is(cleanName("Smith VI, John"), "Smith VI, John");
is_deeply([parseNames("Smith, John, Doe, V")], ["Smith, John", "Doe, V."]);
is_deeply([parseNames("Kim, J, Lee, X")], ["Kim, J.", "Lee, X."]);
is(parsed("John M. Doe II"), "Doe II | John M.");
is(parsed("Frederick H. Gautschi, III"), "Gautschi III | Frederick H.");
is(parsed("Pope John Paul II"), "Paul II | Pope John");
is(parsed("Smith JR, John"), "Smith Jr | John");
is(parsed("John Smith jr."), "Smith Jr | John");

# Before a name suffix, postnominal letters are the person's initials.
is(parsed("Smith, S. J., Jr."), "Smith Jr | S. J.");
is(parsed("Smith, Jr., S. J."), "Smith Jr | S. J.");
is(parsed("Harrison, O. P., III"), "Harrison III | O. P.");
is_deeply([parseName2("Smith, S. J., Jr.")], ["S.", "J.", "Smith", "Jr"]);
is(normalizeAuthorSourceValue("Smith, S. J., Jr."), "Smith Jr, S. J.");
is(normalizeAuthorSourceValue("Smith, Jr., S. J."), "Smith Jr, S. J.");
is(normalizeAuthorSourceValue("Harrison, O. P., III"), "Harrison III, O. P.");
is(normalizeAuthorSourceValue("Smith, John, Jr., S.J."), "Smith Jr, John");

done_testing;
