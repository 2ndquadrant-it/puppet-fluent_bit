class fluent_bit::config inherits fluent_bit {

  file { $fluent_bit::config_path:
    ensure  => directory,
    owner   => $fluent_bit::config_owner,
    group   => $fluent_bit::config_group,
    mode    => '0750',
    recurse => true,
    force   => true,
    purge   => true,
  } ->

  file { "${fluent_bit::config_file}":
    ensure  => present,
    content => fluent_bit_config($fluent_bit::configs),
    require => Class['Fluent_bit::Install'],
    notify  => Class['Fluent_bit::Service'],
  }

  # Write the parser file only if we defined parsers on our own.
  # This allows us to use the default one if we do not define anything.
  if $fluent_bit::parsers {
    file { $fluent_bit::parsers_file:
      ensure  => present,
      content => fluent_bit_config($fluent_bit::parsers),
      require => File[$fluent_bit::config_file],
      notify  => Class['Fluent_bit::Service'],
    }
  }

  # Create upstreams when defined.
  if $fluent_bit::upstreams {
    $fluent_bit::upstreams.each |$name, $config| {
      file { "${fluent_bit::config_path}/upstream_${name}.conf":
        ensure  => present,
        content => fluent_bit_config($config),
        require => File[$fluent_bit::config_file],
        notify  => Class['Fluent_bit::Service'],
      }
    }
  }
}
