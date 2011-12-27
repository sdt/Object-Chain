package KVStore::Body::Check;

use feature 'say';

use Moose;
use namespace::autoclean;

use KVStore;

# Can't do this(?) - chicken and egg problem
#has '+tail' => (
    #handles => 'get',
#);

{
    package MC::Util;

    # This is a workaround for has '+tail' => ( handles =>  ... );
    sub tail_handles {
        my $class = shift;
        my $caller = scalar caller;
        for my $method_name (@_) {
            $caller->meta->add_method($method_name, sub {
                    my $self = shift;
                    return $self->tail->$method_name(@_);
                });
        }
    }
}

MC::Util->tail_handles qw( get );

with 'KVStore::Role::Body';

sub set {
    my ($self, $head, $key, $value) = @_;
    print STDERR ref $head, "\n";
    $self->tail->set($head, $key, $value);
    return;
}

1;
