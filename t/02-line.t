use warnings;
use strict;
use Test::More;
use Socket qw(AF_UNIX SOCK_STREAM PF_UNSPEC);
use POE::Filter::Line;

BEGIN
{
    use_ok('Reflexive::Stream::Filtering');
}

my ($socket1, $socket2);
socketpair($socket1, $socket2, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die $!;
my $line1 = POE::Filter::Line->new();
my $line2 = POE::Filter::Line->new();

my $filtered_stream1 = Reflexive::Stream::Filtering->new(handle => $socket1, filter => $line1);
my $filtered_stream2 = Reflexive::Stream::Filtering->new(handle => $socket2, filter => $line2);

$filtered_stream1->put("Here is some test data\n1\n2\n3\n");

my $e_count = 0;
while(my $e = $filtered_stream2->next())
{
    $e_count++;
    is($e->{name}, 'data', 'make sure the event we get is data 1/5');
    if($e_count == 1)
    {
        is($e->{arg}->{data}, 'Here is some test data', 'and that the data is correct 2/5');
    }
    elsif($e_count == 2)
    {
        is($e->{arg}->{data}, '1', 'Got the next element 3/5');
    }
    elsif($e_count == 3)
    {
        is($e->{arg}->{data}, '2', 'Got the next element 4/5');
    }
    elsif($e_count == 4)
    {
        is($e->{arg}->{data}, '3', 'Got the next element 5/5');
        last;
    }
}

is($e_count, 4, 'Got the right number of events');

$filtered_stream2->put("And here is some data back\n3\n2\n1\n");

my $e_count2 = 0;
while(my $e2 = $filtered_stream1->next())
{
    $e_count2++;
    is($e2->{name}, 'data', 'make sure the return event we get is data 1/5');
    if($e_count2 == 1)
    {
        is($e2->{arg}->{data}, 'And here is some data back', 'and that the return data is correct 2/5');
    }
    elsif($e_count2 == 2)
    {
        is($e2->{arg}->{data}, '3', 'Got the next element 3/5');
    }
    elsif($e_count2 == 3)
    {
        is($e2->{arg}->{data}, '2', 'Got the next element 4/5');
    }
    elsif($e_count2 == 4)
    {
        is($e2->{arg}->{data}, '1', 'Got the next element 5/5');
        last;
    }
}

is($e_count2, 4, 'Got the right number of events');

done_testing();
