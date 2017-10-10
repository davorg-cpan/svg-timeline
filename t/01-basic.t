
use Test::More;

use SVG::Timeline;
use Time::Piece;

my $tl = SVG::Timeline->new;

$tl->add_event({
  start => 1987,
  end   => localtime->year,
  text  => 'Perl',
});

$tl->add_event({
  start => 2017.5726,
  end   => localtime->year + ( localtime->yday + 1 ) / ( localtime->is_leap_year ? 365: 366 ),
  text  => 'SVG::Timeline on CPAN',
});

is($tl->count_events, 2, 'Correct number of events');
is($tl->events->[0]->index, 1, 'Correct index for event');
isa_ok($tl->svg, 'SVG');

my $diag = $tl->draw;

ok($diag, 'Got a diagram');

done_testing();
