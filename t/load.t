use Test::More;

BEGIN {
  use_ok 'Timeline::SVG';
}

ok(my $tl = Timeline::SVG->new);
isa_ok($tl, 'Timeline::SVG');

done_testing;
