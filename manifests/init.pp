class rsyncssh (
  $configfile = '/etc/rsyncssh.conf',
  $basedir    = '/backup',
  $sshport    = '22',
  $source     = 'puppet:///modules/rsyncssh/rsyncssh.conf',
  $user       = 'rsyncssh',
  ) {

  $backupdir = "${basedir}/BACKUP"
  $archivedir = "${basedir}/ARCHIVE"
  $snapshotdir = "${basedir}/SNAPSHOT"

  file { '/usr/local/bin/rsyncssh.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('rsyncssh/rsyncssh.sh.erb'),
  }

  file { [ "$rsyncssh::basedir" , "$rsyncssh::backupdir" , "$rsyncssh::archivedir" , "$rsyncssh::snapshotdir" ] : 
    ensure  => directory,
    owner   => $rsyncssh::user,
    group   => 'root',
    mode    => '0750',
  }

  file { $rsyncssh::configfile:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $rsyncssh::source,
  }

  cron { 'rsyncssh-snapshot-latest':
    command => '/usr/local/bin/rsyncssh.sh latest daily',
    user    => $rsyncssh::user,
    hour    => 0,
    minute  => 40,
  }

  cron { 'rsyncssh-hourly':
    command => '/usr/local/bin/rsyncssh.sh backup hourly',
    user    => $rsyncssh::user,
    minute  => 10,
  }

  cron { 'rsyncssh-daily':
    command => '/usr/local/bin/rsyncssh.sh backup daily',
    user    => $rsyncssh::user,
    hour    => 0,
    minute  => 0,
  }

  cron { 'rsyncssh-weekly':
    command => '/usr/local/bin/rsyncssh.sh backup weekly',
    user    => $rsyncssh::user,
    hour    => 2,
    minute  => 0,
    weekday => 0,
  }

  cron { 'rsyncssh-monthly':
    command  => '/usr/local/bin/rsyncssh.sh backup monthly',
    user     => $rsyncssh::user,
    hour     => 4,
    minute   => 0,
    monthday => 1,
  }

}
