#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use YAML;
use 5.010;

#
# VARIABLES
#

# Environment variables shared vith nova via .novarc
my $USERNAME = $ENV{OS_USERNAME};
my $API_KEY  = $ENV{OS_PASSWORD};

#
# FUNCTIONS
#

# Create a user agent object - common for several functions
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1");

sub authenticate {

    # Create a request
    my $req =
      HTTP::Request->new(
        POST => 'https://identity.api.rackspacecloud.com/v2.0/tokens' );
    $req->content_type('application/json');

    my $json = {
        'auth' => {
            'RAX-KSKEY:apiKeyCredentials' => {
                'apiKey'   => $API_KEY,
                'username' => $USERNAME,
            }
        }
    };

    $req->content( encode_json $json );

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    my ( $account, $token );

    # Check the outcome of the response
    if ( $res->is_success ) {
        my $perl_ds = decode_json $res->content;
        $account = $perl_ds->{'access'}->{'token'}->{'tenant'}->{'id'};
        $token   = $perl_ds->{'access'}->{'token'}->{'id'};
    } else {
        print $res->status_line, "\n";
    }

    return $account, $token;
}

sub create_server {
    my ( $account, $token, $name ) = @_;

    my $server = {
        'server' => {
            'imageRef'  => '3afe97b2-26dc-49c5-a2cc-a2fc8d80c001',
            'flavorRef' => '2',
            'name'      => $name,
            'metadata'  => { 'My Server Name' => 'Ubuntu 11.10 server' }
        }
    };

    my $req = HTTP::Request->new( POST =>
          "https://dfw.servers.api.rackspacecloud.com/v2/$account/servers" );
    $req->header(
        "Content-Type"      => "application/json",
        "X-Auth-Token"      => $token,
        "X-Auth-Project-Id" => "test-project"
    );
    $req->content( encode_json $server);
    my $res = $ua->request($req);

    my ( $pass, $id );

    # Check the outcome of the response
    if ( $res->is_success ) {
        my $perl_ds = decode_json $res->content;
        $pass = $perl_ds->{server}->{adminPass};
        $id   = $perl_ds->{server}->{'id'};
    } else {
        print $res->status_line, "\n";
    }

    return $pass, $id;
}

sub ssh_to_server {
    my ( $ip, $pass ) = @_;

    system "ssh -o StrictHostKeyChecking=no root\@$ip 'ls -la'";
}

sub get_server_ip {
    my ( $account, $token, $id ) = @_;

    my $perl_ds = list_servers( $account, $token );
    for my $server ( @{ $perl_ds->{servers} } ) {
        if ( $server->{id} eq $id ) {
            return $server->{accessIPv4};
        }
    }
}

sub list_servers {
    my ( $account, $token ) = @_;

    my $req =
      HTTP::Request->new( GET =>
"https://dfw.servers.api.rackspacecloud.com/v2/$account/servers/detail"
      );
    $req->header( "X-Auth-Token" => "$token" );
    my $res = $ua->request($req);

    my ( $ip, $status, $id, $name );

    if ( $res->is_success ) {
        return decode_json $res->content;    # Perl data structure
    } else {
        return undef;
    }
}

sub delete_server {
    my ( $account, $token, $id ) = @_;

    my $req =
      HTTP::Request->new( DELETE =>
          "https://dfw.servers.api.rackspacecloud.com/v2/$account/servers/$id"
      );
    $req->header( "X-Auth-Token" => "$token" );
    my $res = $ua->request($req);

    if ( $res->is_success ) {
        print "Server with id '$id' deleted\n";
    } else {
        print $res->status_line, "\n";
        print "Server with id '$id' not found\n";
    }
}

#
# MAIN
#

my $cmd        = shift;
my $second_arg = shift; # ex. hostname
die "Usage: $0 <command>\n" unless $cmd;

my ( $account, $token ) = authenticate();

given ($cmd) {
    when (/create/) {
        my ( $pass, $id ) = create_server( $account, $token, $second_arg );

        my $n = 0;
        while (1) {

            # redo comes here
            my $perl_ds = list_servers( $account, $token );
            my $server = ${ $perl_ds->{servers} }[ $n++ ];
            unless ($server->{id} eq $id
                and $server->{'OS-EXT-STS:vm_state'} eq 'active' )
            {
                print $server->{name} . " - "
                  . $server->{'OS-EXT-STS:vm_state'} . " ("
                  . $server->{progress} . " %)\n";
                sleep 5;
                $n = 0 if $n >= @{ $perl_ds->{servers} };
                redo;
            }
            last;    # exit infinite while loop
        }

        my $ip = get_server_ip( $account, $token, $id );
        ssh_to_server( $ip, $pass );
    }
    when (/delete/) { delete_server( $account, $token, $second_arg ) }
    default { print "Uknown command '$cmd'.\n" }
}

