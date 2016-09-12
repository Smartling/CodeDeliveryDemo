cron { 'cron1':
  command => '/bin/sh /path/to/push_to_gecko.sh',
  minute  => '*/15',
}

cron { 'cron2':
  command => '/bin/sh /path/to/check_new_users.sh dbs base',
  minute  => 1,
  hour    => 12,
}

cron { 'cron3':
  command => '/bin/sh /path/to/tests_stats.sh',
  minute  => 10,
  hour    => 0,
}

cron { 'cron4':
  command => '/bin/sh /path/to/tests_stats_weekly.sh',
  minute  => 0,
}

cron { 'cron5':
  command => '/bin/sh /path/to/repos_stats.sh',
  minute  => 0,
}

cron { 'cron6':
  command => '/bin/sh /path/to/send_emails_to_d.sh',
  minute  => 50,
  hour    => 23,
  weekday => 7,
}

cron { 'cron7':
  command => '/bin/sh /path/to/create_daily_job.sh',
  minute  => 0,
  hour    => 10,
  weekday => [1, 2, 3, 4, 5],
}

cron { 'cron8':
  command => '/bin/sh /path/to/create_d_job.sh',
  minute  => 0,
  hour    => [13, 21],
  weekday => [1, 2, 3, 4, 5],
}

cron { 'cron9':
  command => '/bin/sh /path/to/synch_all.sh dbm',
  minute  => 0,
  hour    => [12, 0],
}
