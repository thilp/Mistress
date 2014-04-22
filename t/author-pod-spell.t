
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.006007
use Test::Spelling 0.12;
use Pod::Wordlist;


add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib  ) );
__DATA__
Thibaut
Le
Page
thilp
lib
Mistress
Env
Config
Role
DistGatherer
App
Command
smoke
Hash
lol
File
HasPlugins
Plugin
UploadGatherer
Obj
DistSet
Fs
Disk
report
Report
Dist
PerlInterpreter
Util
PerlLib
consider
