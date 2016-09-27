use ExtUtils::MakeMaker;

WriteMakeFile(
  NAME => 'Timeline::SVG',
  VERSION_FROM => 'lib/Timeline/SVG.pm',
  BUILD_REQUIRES => {
    'Test::More' => 0,
    'ExtUtils::MakeMaker' => 0,
    SVG => 0,
    Moose => 0,
    'Time::Piece' => 0,
    'List::Util' => 0,
    Carp => 0,
  },
  REQUIRES => {
    SVG => 0,
    Moose => 0,
    'Time::Piece' => 0,
    'List::Util' => 0,
    Carp => 0,
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'git://github.com/davorg/timeline-svg.git',
        web => 'https://github.com/davorg/timeline-svg',
      },
    },
  },
  EXE_FILES => [ 'bin/timeline' ],
);
