#!/usr/bin/env perl

use Test::More;
use Test::LongString;
use Net::DNS::Packet;
use lib 'lib';

BEGIN { use_ok('Net::DNS::Abstract'); }

subtest 'Author Tests', sub {
    plan skip_all =>
        'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.'
        if (not $ENV{TEST_AUTHOR});

    my $zone = 'domain.tld.	3600	IN	SOA	( ns1.iwantmyname.net. email.domain.tld.
				1555319348	;serial
				86400		;refresh
				7200		;retry
				3600000		;expire
				86400		;minimum
	)
domain.tld.	3600	IN	A	50.112.122.158
mail.domain.tld.	3600	IN	A	62.116.130.8
www.domain.tld.	3600	IN	CNAME	domain.tld.
sub.domain.tld.	3600	IN	NS	ns02.net.
sub.domain.tld. 14400   IN  CAA 0 tag value
spf.domain.tld.	3600	IN	TXT	( "v=spf1 mx include:a.very.long.spf.record include:to.test.TXT.record.splitting at 255 characters and it is taking me way more time than epected to come up with a proper example for this totally ridiculous scenario. who uses such long records and what is wrong with you? ~all" )
domain.tld.	14400	IN	NS	ns1.iwantmyname.net.
domain.tld.	14400	IN	NS	ns2.iwantmyname.net.
domain.tld.	14400	IN	NS	ns3.iwantmyname.net.
domain.tld.	14400	IN	NS	ns4.iwantmyname.net.';

    my $zone_hash = {
        ns => [ {
                ttl  => 14400,
                name => 'ns1.iwantmyname.net'
            }, {
                ttl  => 14400,
                name => 'ns2.iwantmyname.net'
            }, {
                ttl  => 14400,
                name => 'ns3.iwantmyname.net'
            }, {
                ttl  => 14400,
                name => 'ns4.iwantmyname.net'
            }
        ],
        domain => 'domain.tld',
        rr     => [ {
                value => '50.112.122.158',
                ttl   => 3600,
                name  => undef,
                type  => 'A'
            }, {
                value => '62.116.130.8',
                ttl   => 3600,
                name  => 'mail',
                type  => 'A'
            }, {
                value => '0 tag value',
                ttl   => 14400,
                name  => 'sub',
                type  => 'CAA',
            }, {
                value => 'domain.tld',
                ttl   => 3600,
                name  => 'www',
                type  => 'CNAME'
            }, {
                value => 'ns02.net.',
                ttl   => 3600,
                name  => 'sub',
                type  => 'NS'
            }, {
                value =>
                    'v=spf1 mx include:a.very.long.spf.record include:to.test.TXT.record.splitting at 255 characters and it is taking me way more time than epected to come up with a proper example for this totally ridiculous scenario. who uses such long records and what is wrong with you? ~all',
                ttl  => 3600,
                name => 'spf',
                type => 'TXT'
            }
        ],
        soa => {
            email   => 'email@domain.tld',
            retry   => 7200,
            refresh => 86400,
            minimum => 86400,
            expire  => 3600000,
        },
    };

    my $dns = Net::DNS::Abstract->new(domain => 'domain.tld');
    isa_ok($dns, 'Net::DNS::Abstract', "created Net::DNS::Abstract object");

    my $b = $dns->zone(Net::DNS::Packet->new);
    ok($b, "loaded empty Net::DNS::Packet as zone");
    my $c = $dns->zone($zone);
    ok($c, "loaded zonefile as zone");

    # test zonefile import
    my $dns2 = Net::DNS::Abstract->new(domain => 'domain.tld');
    my $d = $dns2->zone($zone);
    is_string_nows($dns2, $zone, "round trip the zonefile");

    # test stringification
    is($dns, $dns2, "compare two DNS zones");
    my $dns_append = $dns . 'some random string here';
    isnt($dns, $dns_append, "compare two DNS zones for inequality");

    # test hash export
    my $hash = $dns->to_hash;
    ok($hash, "exported hash from NDA");
    is_deeply($hash, $zone_hash, "compare hash representation of zone");

    # test hash import
    my $dns3 = Net::DNS::Abstract->new(domain => 'domain.tld');
    my $e = $dns3->zone($zone_hash);
    ok($e, "loaded zone hash as zone");
    is($dns, $dns3, "compare two DNS zones");

    # test Net::DNS import
    my $dns4 = Net::DNS::Abstract->new(domain => 'domain.tld');
    my $f = $dns4->zone($e);
    ok($f, "loaded NDA zone as zone");
    is($dns, $dns4, "compare two DNS zones");

    # compare export of imported zone
    $hash = $dns4->to_hash;
    ok($hash, "exported hash from previously imported NDA");
    is_deeply($hash, $dns3->to_hash,
        "compare hash representation of previously imported zone");
};
done_testing();
