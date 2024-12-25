class puppet (String $version) {
  package { 'puppet-agent':
    ensure => $version,
  }

  service { 'puppet':
    enable  => false,
    ensure  => stopped,
    require => Package['puppet-agent'],
  }

  file { '/usr/local/sbin/puppet':
    ensure => 'link',
    require => Package['puppet-agent'],
    target => '/opt/puppetlabs/bin/puppet',
  }

  file { [ '/var/lib/puppet', '/var/lib/puppet/reports', ]:
    ensure => directory,
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    require => Package['puppet-agent'],
    source => 'puppet:///modules/puppet/puppet.conf'
  }

  file { '/usr/local/sbin/puppet-reports-cleanup':
    mode => '0755',
    source => 'puppet:///modules/puppet/puppet-reports-cleanup',
  }

  file { '/etc/cron.d/puppet-reports-cleanup':
    source => 'puppet:///modules/puppet/puppet-reports-cleanup.cron',
  }

  exec { 'install_librarian_puppet':
    command => '/opt/puppetlabs/puppet/bin/gem install librarian-puppet -v 5.0.0 && /opt/puppetlabs/puppet/bin/gem uninstall minitar -I && /opt/puppetlabs/puppet/bin/gem install minitar -v 0.12',
    creates => '/opt/puppetlabs/puppet/bin/librarian-puppet',
    require => Package['puppet-agent'],
  }

  file { '/usr/local/sbin/librarian-puppet':
    ensure => 'link',
    require => Exec['install_librarian_puppet'],
    target => '/opt/puppetlabs/puppet/bin/librarian-puppet',
  }

  file { '/usr/local/sbin/puppet-apply':
    mode => '0755',
    source => 'puppet:///modules/puppet/puppet-apply',
  }

  file { '/etc/cron.d/puppet-apply':
    source => 'puppet:///modules/puppet/puppet-apply.cron',
  }
}
