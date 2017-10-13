use lib 't/lib';
use Test2::V0 -no_srand => 1;
use Test2::Plugin::FauxOS 'msys';
use FFI::CheckLib;

subtest '_cmp' => sub {

  my $process = sub {
    [
      sort { FFI::CheckLib::_cmp($a,$b) }
      map  { FFI::CheckLib::_matches($_, '/bin') }
      @_
    ];
  };
  
  is(
    $process->(qw( msys-foo-1.dll msys-bar-2.dll msys-baz-0.dll )),
    [
      [ 'bar', '/bin/msys-bar-2.dll', 2 ],
      [ 'baz', '/bin/msys-baz-0.dll', 0 ],
      [ 'foo', '/bin/msys-foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( msys-baz-0.dll msys-foo-1.dll msys-bar-2.dll )),
    [
      [ 'bar', '/bin/msys-bar-2.dll', 2 ],
      [ 'baz', '/bin/msys-baz-0.dll', 0 ],
      [ 'foo', '/bin/msys-foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( msys-bar-2.dll msys-foo-1.dll msys-baz-0.dll )),
    [
      [ 'bar', '/bin/msys-bar-2.dll', 2 ],
      [ 'baz', '/bin/msys-baz-0.dll', 0 ],
      [ 'foo', '/bin/msys-foo-1.dll', 1 ],
    ],
    'name first 1',
  );

  is(
    $process->(qw( msys-foo-2.dll msys-foo-0.dll msys-foo-1.dll )),
    [
      [ 'foo', '/bin/msys-foo-2.dll', 2, ],
      [ 'foo', '/bin/msys-foo-1.dll', 1, ],
      [ 'foo', '/bin/msys-foo-0.dll', 0, ],
    ],
    'newer version first',
  );

};

done_testing;
