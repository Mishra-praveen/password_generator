define puppet::our_gemset() {
  rvm_gemset { "$tools_ruby_version@$name":
    ensure => present,
    require => Rvm_system_ruby[$tools_ruby_version],
  }

  file { "/usr/local/rvm/wrappers/tools_ruby_version@$name":
    ensure => "/usr/local/rvm/wrappers/$tools_ruby_version@$name",
    require => Rvm_gemset["$tools_ruby_version@$name"],
  }

  file { "/usr/local/rvm/gems/tools_ruby_version@$name":
    ensure => "/usr/local/rvm/gems/$tools_ruby_version@$name",
    require => Rvm_gemset["$tools_ruby_version@$name"],
  }
}

class puppet {
  # Main puppet script
  file { '/usr/local/bin/puppet5':
    owner => puppet,
    group => puppet,
    mode => '755',
    content => template('puppet/puppet5.erb'),
  }

  file { '/usr/local/bin/facter5':
    owner => puppet,
    group => puppet,
    mode => '755',
    content => template('puppet/facter5.erb'),
  }

  # Individual puppet for ops testing
  file { '/usr/local/bin/mypuppet5':
    owner => puppet,
    group => puppet,
    mode => '755',
    source => 'puppet:///modules/puppet/mypuppet5.sh',
  }

  file { '/opt/puppet5/etc/puppet.conf':
    source => 'puppet:///modules/puppet/puppet.conf',
    owner => 'puppet',
    group => 'puppet',
    mode => '644',
    require => [ File['/opt/puppet5/etc'], ],
  }

  file { '/opt/puppet5':
    ensure => 'directory',
    owner => 'puppet',
    group => 'puppet',
    mode => '755',
  }

  file { '/opt/puppet5/etc':
    ensure  => 'directory',
    owner   => 'puppet',
    group   => 'puppet',
    replace => false,
    mode    => '755',
  }

  file { '/usr/local/bin/puppet_maybe_mail_ops':
    owner => 'root',
    group => 'root',
    mode => '755',
    source => 'puppet:///modules/puppet/puppet_maybe_mail_ops.sh',
  }

  # Mostly used by the BTM image generator
  file { '/usr/local/bin/puppet5_bootstrap':
    content => template('puppet/puppet5_bootstrap.sh.erb'),
    owner => 'root',
    group => 'root',
    mode => '755',
    require => [ File['/opt/puppet5/etc'], ],
  }

  cron { 'puppet run cron':
    ensure => absent,
  }

  file { '/usr/local/bin/puppet5_daily':
    content => template('puppet/puppet5_daily.sh.erb'),
    owner => 'root',
    group => 'root',
    mode => '755',
  }
  file { '/etc/cron.d/puppet5':
    content => "PATH=/usr/sbin:/usr/bin:/bin
MAILTO=monitoring@cytobank.org
<%= rand_minute('puppet_daily') %> <%= rand_hour_daytime('puppet_daily') %> * * *        root         /usr/local/bin/puppet5_daily >/dev/null 2>&1
",
    require => [ File['/usr/local/bin/puppet5', '/usr/local/bin/puppet5_daily'] ],
  }
}
  #*****************
  # RVM setup.  Reprises the bootstrapping
  #*****************
ensure_packages( [ 'gnupg2' ] )
  file { '/tmp/mpapis.asc':
    source => 'puppet:///modules/puppet/mpapis.asc',
    owner => 'root',
    group => 'root',
    mode => 644,
  }
  exec { "setup-rvm-gpg":
    command => 'curl -sSL https://rvm.io/mpapis.asc | gpg2 --import /tmp/mpapis.asc >/dev/null 2>&1',
    require => [ Package['gnupg2'], File['/tmp/mpapis.asc'] ],
    before  => [ Class['rvm::system'], Exec["fetch-rvm-$tools_rvm_version"] ],
  }

  exec { "fetch-rvm-$tools_rvm_version":
    command => "wget http://prod-deploy.cytobank.cn/rvm/rvm-$tools_rvm_version.tar.gz -O /usr/local/rvm/archives/rvm-$tools_rvm_version.tar.gz ; true",
    unless  => "test -f /usr/local/rvm/archives/rvm-$tools_rvm_version.tar.gz",
    before  => [ Class['rvm::system'] ],
  }

  # Old rvms can't update properly, so force a fresh install
  exec { 'maybe-remove-rvm':
    command => 'rm /usr/local/rvm/bin/rvm ; echo "SUPER OLD rvm purged"',
    onlyif => 'test -f /usr/local/rvm/bin/rvm && /usr/local/rvm/bin/rvm --version | grep -q rvm.beginrescueend.com',
  }

  exec { 'fix security libs':
    command => 'yum distro-sync -y openssl-libs krb5-libs openssl-devel krb5-devel openssl',
    onlyif => 'yum list installed krb5-libs | grep updates-testing || yum list installed openssl-libs | grep updates-testing',
    before => Package[ 'openssl-devel', 'krb5-devel', 'openssl-libs', 'krb5-libs' ],
  }

  ensure_packages( [ 'libyaml-devel', 'autoconf', 'readline-devel', 'libffi-devel', 'openssl-devel', 'bzip2', 'automake', 'libtool', 'bison', 'sqlite-devel', 'selinux-policy', 'krb5-devel', 'krb5-libs', 'openssl-libs' ] )

  class { rvm:
    version => $tools_rvm_version,
    require => [ Exec["fetch-rvm-$tools_rvm_version"], Exec['maybe-remove-rvm'],
                Package[ 'libyaml-devel', 'autoconf', 'readline-devel', 'libffi-devel', 'openssl-devel', 'bzip2', 'automake', 'libtool', 'bison', 'sqlite-devel', 'selinux-policy', 'krb5-devel', 'krb5-libs', 'openssl-libs' ] ],
  }

  exec { "fetch-$tools_ruby_version":
    command     => "wget http://prod-deploy.cytobank.cn/rvm/$tools_ruby_version.tar.bz2 -O /usr/local/rvm/archives/$tools_ruby_version.tar.bz2 ; true",
    unless      => "test -f /usr/local/rvm/archives/$tools_ruby_version.tar.bz2",
    require => [ Class['rvm'], Class['rvm::system'] ],
  }

  rvm_system_ruby { "$tools_ruby_version":
    ensure => 'present',
    default_use => true,
    require => Exec["fetch-$tools_ruby_version"],
  }

  # exec { "fetch-ruby-$older_ruby_version":
  #   command   => "wget http://prod-deploy.cytobank.cn/rvm/$older_ruby_version.tar.bz2 -O /usr/local/rvm/archives/$older_ruby_version.tar.bz2 ; true",
  #   unless => "test -f /usr/local/rvm/archives/$older_ruby_version.tar.bz2",
  # }

  # rvm_system_ruby { "$older_ruby_version":
  #   ensure => 'present',
  #   default_use => false,
  #   require => Exec["fetch-ruby-$older_ruby_version"],
  # }

  file { "/usr/local/rvm/wrappers/tools_ruby_version":
    ensure => "/usr/local/rvm/wrappers/$tools_ruby_version",
    require => Rvm_system_ruby[$tools_ruby_version],
  }

  puppet::our_gemset { "puppet5": }

  rvm_gem { "$tools_ruby_version@puppet5/puppet":
    ensure  => '5.5.21',
    require => Rvm_gemset["$tools_ruby_version@puppet5"],
  }

  rvm_gem { [ "$tools_ruby_version@puppet5/deep_merge", "$tools_ruby_version@puppet5/ruby-shadow", "$tools_ruby_version@puppet5/hiera-eyaml", "$tools_ruby_version@puppet5/ruby-augeas"]:
    ensure  => present,
    require => Rvm_gemset["$tools_ruby_version@puppet5"],
  }

  ensure_packages( [ 'libselinux-ruby', 'msgpack-devel', 'ruby-devel' ] )

  #*****************
  # Clean out old crap
  #*****************
  file { [ '/usr/local/bin/puppetstoredconfigclean.rb', '/usr/local/bin/puppetd', '/usr/local/bin/puppet', '/opt/puppet5/etc/puppet5_bootstrap.pp' ]: 
    ensure => absent,
  }
}