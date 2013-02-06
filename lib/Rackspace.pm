package Rackspace;
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use MIME::Base64;

use Exporter qw(import);
our @EXPORT = qw( authenticate create_server list_servers delete_server source );

sub source {
    # Source environment variables by parsing config file
    my $conf = shift;

    my %env;

    open my $fh, "<", $conf;
    while (<$fh>) {
        chomp;
        next unless /=/;
        my ( $k, $v ) = split /=/, $_, 2;
        $v =~ s/^(['"])(.*)\1/$2/;             # fix possible quotes
        $v =~ s/\$([a-zA-Z]\w*)/$ENV{$1}/g;    # fix possible $variables
        $env{$k} = $v;
    }

    return \%env;
}

sub authenticate {
    my ( $username, $api_key ) = @_;

    # Create a request
    my $req =
      HTTP::Request->new(
        POST => 'https://identity.api.rackspacecloud.com/v2.0/tokens' );
    $req->content_type('application/json');

    my $json = {
        'auth' => {
            'RAX-KSKEY:apiKeyCredentials' => {
                'apiKey'   => $api_key,
                'username' => $username,
            }
        }
    };

    $req->content( encode_json $json );

    # Pass request to the user agent and get a response back
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1");
    my $res = $ua->request($req);

    my ( $account, $token );

    # Check the outcome of the response
    if ( $res->is_success ) {
        my $perl_ds = decode_json $res->content;
        $account = $perl_ds->{'access'}->{'token'}->{'tenant'}->{'id'};
        $token   = $perl_ds->{'access'}->{'token'}->{'id'};
        return $account, $token;
    }
}

sub create_server {
    my ( $account, $token, $name ) = @_;

    # Get my SSH public key
    open my ($ssh_key_fh), "$ENV{HOME}/.ssh/id_rsa.pub";
    chomp( my $ssh_key = <$ssh_key_fh> );
    close $ssh_key_fh;

    my $server = {
        'server' => {
            'imageRef'  => '8a3a9f96-b997-46fd-b7a8-a9e740796ffd',
            'flavorRef' => '2',
            'name'      => $name,
            'metadata' =>
              { 'My Server Name' => 'Ubuntu 12.10 (Quantal Quetzal)' },
            'personality' => [
                {
                    'path'     => '/root/.ssh/authorized_keys',
                    'contents' => encode_base64 $ssh_key,
                }
            ],
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
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1");
    my $res = $ua->request($req);

    my ( $pass, $id );

    # Check the outcome of the response
    if ( $res->is_success ) {
        my $perl_ds = decode_json $res->content;
        $pass = $perl_ds->{server}->{adminPass};
        $id   = $perl_ds->{server}->{'id'};
        return $pass, $id;
    } else {

        #print STDERR ">>>", $res->status_line, "<<<\n";
    }
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

sub get_server_id {
    my ( $account, $token, $hostname ) = @_;

    my $perl_ds = list_servers( $account, $token );
    for my $server ( @{ $perl_ds->{servers} } ) {
        if ( $server->{name} eq $hostname ) {
            return $server->{id};
        }
    }

    return 0;    # meaning noexistent server
}

sub list_servers {
    my ( $account, $token ) = @_;

    my $req =
      HTTP::Request->new( GET =>
"https://dfw.servers.api.rackspacecloud.com/v2/$account/servers/detail"
      );
    $req->header( "X-Auth-Token" => "$token" );
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1");
    my $res = $ua->request($req);

    my ( $ip, $status, $id, $name );

    if ( $res->is_success ) {
        return decode_json $res->content;    # Perl data structure
    } else {
        return undef;
    }
}

sub delete_server {
    my ( $account, $token, $hostname ) = @_;

    my $id = get_server_id( $account, $token, $hostname );

    my $req =
      HTTP::Request->new( DELETE =>
          "https://dfw.servers.api.rackspacecloud.com/v2/$account/servers/$id"
      );
    $req->header( "X-Auth-Token" => "$token" );
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1");
    my $res = $ua->request($req);

    if ( $res->is_success ) {

        #print "Server '$hostname' with id '$id' will be deleted\n";
    } else {

        #print STDERR $res->status_line, "\n";
        print STDERR "Server '$hostname' with id '$id' not found\n";
    }
}

1;
