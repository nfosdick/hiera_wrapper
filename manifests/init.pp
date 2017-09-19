#
class hiera_wrapper{

  $pkcs_private_key = 'pkcs7_private_key: /etc/puppetlabs/puppet/keys/private_key.pkcs7.pem'
  $pkcs_public_key  = 'pkcs7_public_key: /etc/puppetlabs/puppet/keys/public_key.pkcs7.pem'
  $config_yaml = "---\n${pkcs_private_key}\n${pkcs_public_key}"

  package { 'cli-hiera-eyaml':
    ensure   => present,
    name     => 'hiera-eyaml',
    provider => gem,
  }

  file{ '/etc/eyaml':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file{ '/etc/eyaml/config.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $config_yaml,
    require => File[ '/etc/eyaml' ],
  }

  class { 'hiera':
    manage_package     => true,
    puppet_conf_manage => false,
    datadir_manage     => false,
    eyaml              => true,
    eyaml_extension    => 'yaml',
    provider           => 'puppetserver_gem',
    master_service     => 'puppetserver',
    hierarchy          => [
      'nodes/%{::trusted.certname}',
      'role/%{::trusted.extensions.pp_role}',
      'role/%{::role}',
      'common',
    ],
  }
}
