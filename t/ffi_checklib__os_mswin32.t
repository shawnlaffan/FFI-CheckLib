use lib 't/lib';
use Test2::V0 -no_srand => 1;
use Test2::Plugin::FauxOS 'MSWin32';
use FFI::CheckLib;
use Env qw( @PATH );

@$FFI::CheckLib::system_path = (
  'corpus/windows/bin',
);

subtest 'find_lib (good)' => sub {
  my($path) = find_lib( lib => 'dinosaur' );
  ok -r $path, "path = $path is readable";
  
  my $path2 = find_lib( lib => 'dinosaur' );
  is $path, $path2, 'scalar context';
};

subtest 'find_lib (fail)' => sub {
  my @path = find_lib( lib => 'foobar' );
  
  ok @path == 0, 'libfoobar not found';
};

subtest 'find_lib (good) with lib and version' => sub {
  my($path) = find_lib( lib => 'apatosaurus' );
  ok -r $path, "path = $path is readable";
  
  my $path2 = find_lib( lib => 'apatosaurus' );
  is $path, $path2, 'scalar context';
};

subtest 'in sync with $ENV{PATH}' => sub {

  local $ENV{PATH} = $ENV{PATH};
  @PATH = qw( foo bar baz );
  
  is(
    $FFI::CheckLib::system_path,
    [qw( foo bar baz )],
  );

};

subtest '_cmp' => sub {

  my $process = sub {
    [
      sort { FFI::CheckLib::_cmp($a,$b) }
      map  { FFI::CheckLib::_matches($_, 'c:/bin') }
      @_
    ];
  };
  
  is(
    $process->(qw( foo-1.dll bar-2.dll baz-0.dll )),
    [
      [ 'bar', 'c:/bin/bar-2.dll', 2 ],
      [ 'baz', 'c:/bin/baz-0.dll', 0 ],
      [ 'foo', 'c:/bin/foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( baz-0.dll foo-1.dll bar-2.dll )),
    [
      [ 'bar', 'c:/bin/bar-2.dll', 2 ],
      [ 'baz', 'c:/bin/baz-0.dll', 0 ],
      [ 'foo', 'c:/bin/foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( bar-2.dll foo-1.dll baz-0.dll )),
    [
      [ 'bar', 'c:/bin/bar-2.dll', 2 ],
      [ 'baz', 'c:/bin/baz-0.dll', 0 ],
      [ 'foo', 'c:/bin/foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( foo-2.dll foo-0.dll foo-1.dll )),
    [
      [ 'foo', 'c:/bin/foo-2.dll', 2, ],
      [ 'foo', 'c:/bin/foo-1.dll', 1, ],
      [ 'foo', 'c:/bin/foo-0.dll', 0, ],
    ],
    'newer version first',
  );

};

done_testing;
