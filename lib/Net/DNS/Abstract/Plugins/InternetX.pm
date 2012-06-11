package Net::DNS::Abstract::Plugins::InternetX;

use 5.010;
use Any::Moose;

extends 'Net::DNS::Abstract';

=head2 register

Register in the Net::DNS dispatch table for backend calls

=cut

sub setup {
    my ($self) = @_;

    return { InternetX => { axfr => \&status_zone } };
}


=head2 status_zone

Query a DNS zone via InternetX

=cut

sub status_zone {
    my($self, $domain) = @_;

    my $zone = {
        domain => $domain,   
        interface => 'InternetX',
    };
    return $zone;
}

__PACKAGE__->meta->make_immutable();
