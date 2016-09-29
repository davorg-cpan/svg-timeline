package Timeline::SVG;

use 5.010;

use Moose;
use SVG;
use List::Util qw[min max];
use Carp;

has events => (
  traits  => ['Array'],
  isa     => 'ArrayRef[HashRef]',
  is      => 'rw',
  default => sub { [] },
  handles => {
    all_events   => 'elements',
    add_event    => 'push',
    count_events => 'count',
    has_events   => 'count',
  },
);

has width => (
  is      => 'ro',
  isa     => 'Str',
  default => '100%',
);

has height => (
  is      => 'ro',
  isa     => 'Str',
  default => '100%',
);

has viewbox => (
  is         => 'ro',
  isa        => 'Str',
  lazy_build => 1,
);

sub _build_viewbox {
  my $self = shift;
  return join ' ',
    $self->min_year,
    0,
    $self->years,
    ($self->bar_height * $self->count_events) + $self->bar_height
    + (($self->count_events - 1) * $self->bar_height * $self->bar_spacing);
}

has svg => (
  is         => 'ro',
  isa        => 'SVG',
  lazy_build => 1,
  handles    => [qw[xmlify line text rect cdata]],
);

sub _build_svg {
  my $self = shift;

  $_->{end} //= (localtime)[5] + 1900 foreach $self->all_events;

  return SVG->new(
    width   => $self->width,
    height  => $self->height,
    viewBox => $self->viewbox,
  );
}

has default_colour => (
  is         => 'ro',
  isa        => 'Str',
  lazy_build => 1,
);

sub _build_default_colour {
  return 'rgb(255,127,127)';
}

# The number of years between vertical grid lines
has years_per_grid => (
  is      => 'ro',
  isa     => 'Int',
  default => 10, # One decade by default
);

has bar_height => (
  is      => 'ro',
  isa     => 'Int',
  default => 50,
);

# Size of the vertical gap between bars (as a fraction of a bar)
has bar_spacing => (
  is      => 'ro',
  isa     => 'Num',
  default => 0.25,
);

# The colour that the decade lines are drawn on the chart
has decade_line_colour => (
  is      => 'ro',
  isa     => 'Str',
  default => 'rgb(127,127,127)',
);

# The colour that the bars are outlined
has bar_outline_colour => (
  is      => 'ro',
  isa     => 'Str',
  default => 'rgb(0,0,0)',
);

sub draw_grid{
  my $self = shift;

  my $curr_year = $self->min_year;

  # Draw the grid lines
  while ( $curr_year <= $self->max_year ) {
    unless ( $curr_year % $self->years_per_grid ) {
      $self->line(
        x1           => $curr_year,
        y1           => 0,
        x2           => $curr_year,
        y2           => ($self->bar_height * ($self->count_events + 1))
                      + ($self->bar_height * $self->bar_spacing
                         * ($self->count_events - 1)),
        stroke       => $self->decade_line_colour,
        stroke_width => 1
      );
      $self->text(
        x           => $curr_year + 1,
        y           => 20,
        'font-size' => $self->bar_height / 2
      )->cdata($curr_year);
    }
    $curr_year++;
  }

  $self->rect(
     x             => $self->min_year,
     y             => 0,
     width         => $self->years,
     height        => ($self->bar_height * ($self->count_events + 1))
                    + ($self->bar_height * $self->bar_spacing
                       * ($self->count_events - 1)),
     stroke        => $self->bar_outline_colour,
    'stroke-width' => 1,
    fill           => 'none',
  );

  return $self;
}

sub draw {
  my $self = shift;
  my %args = @_;

  croak "Can't draw a timeline with no events"
    unless $self->has_events;

  $self->draw_grid;

  my $curr_event_idx = 1;
  foreach ($self->all_events) {
    my $x = $_->{start};
    my $y = ($self->bar_height * $curr_event_idx)
          + ($self->bar_height * $self->bar_spacing
             * ($curr_event_idx - 1));

    $self->rect(
      x              => $x,
      y              => $y,
      width          => $_->{end} - $_->{start},
      height         => $self->bar_height,
      fill           => $_->{colour} // $self->default_colour,
      stroke         => $self->bar_outline_colour,
      'stroke-width' => 1
    );

    $self->text(
      x => $x + $self->bar_height * 0.2,
      y => $y + $self->bar_height * 0.8,
      'font-size' => $self->bar_height * 0.8,
    )->cdata($_->{text});

    $curr_event_idx++;
  }

  return $self->xmlify;
}

sub min_year {
  my $self = shift;
  return unless $self->has_events;
  my @years = map { $_->{start} } $self->all_events;
  return min(@years);
}

sub max_year {
  my $self = shift;
  return unless $self->has_events;
  my @years = map { $_->{end} // (localtime)[5] } $self->all_events;
  return max(@years);
}

sub years {
  my $self = shift;
  return $self->max_year - $self->min_year;
}

1;
