# Install mysql-server packages
class { 'mysql::server':
  config_hash => { 'root_password' => 'foo' }
}

# Create DB user
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['all'],
}
