Cron {
  environment => [
    'MAILTO=foobar',
  ],
}

cron { 'cron1':
  command => '/bin/sh /custom/scripts/script1.sh',
  minute  => '*/15',
}

cron { 'cron2':
  command => '/bin/sh /custom/scripts/script2.sh',
  minute  => 1,
  hour    => 12,
}

cron { 'cron3':
  command => '/bin/sh /custom/scripts/script3.sh',
  minute  => 10,
  hour    => 0,
}

cron { 'cron4':
  command => '/bin/sh /custom/scripts/script4.sh',
  minute  => 0,
}

cron { 'cron5':
  command => '/bin/sh /custom/scripts/script5.sh',
  minute  => 0,
}

cron { 'cron6':
  command => '/bin/sh /custom/scripts/script6.sh',
  minute  => 50,
  hour    => 23,
  weekday => 7,
}

cron { 'cron7':
  command => '/bin/sh /custom/scripts/script7.sh',
  minute  => 0,
  hour    => 10,
  weekday => [1, 2, 3, 4, 5],
}

cron { 'cron8':
  command => '/bin/sh /custom/scripts/script8.sh',
  minute  => 0,
  hour    => [13, 21],
  weekday => [1, 2, 3, 4, 5],
}

cron { 'cron9':
  command => '/bin/sh /custom/scripts/script9.sh',
  minute  => 0,
  hour    => [12, 0],
}
