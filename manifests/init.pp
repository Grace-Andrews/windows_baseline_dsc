class profile::windows::baseline_dsc {

  #Features
  dsc_windowsfeature{'iis':
      dsc_ensure => 'Present',
      dsc_name => 'Web-Server',
  }
  dsc_windowsfeature{'aspnet45':
      dsc_ensure => 'Present',
      dsc_name => 'Web-Asp-Net45',
  }

  # PACKAGES
  Package {
    ensure   => installed,
    provider => chocolatey,
  }
  
  package { 'Firefox': }
  package { 'notepadplusplus': }
  package { '7zip': }
  package { 'git': }

  #  Setup sample share
  file { 'c:\shares':
    ensure => 'directory',
    before => Dsc_xsmbshare['sample share'],
  }

  dsc_xsmbshare { 'sample share':
    dsc_name       => 'sample share',
    dsc_path       => 'c:\shares',
    dsc_fullaccess => "everyone",
  }

  # FIREWALL
  windows_firewall::exception { 'TSErule':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    protocol     => 'TCP',
    local_port   => '8080',
    display_name => 'TSE PUPPET DEMO',
    description  => 'Inbound rule example for demo purposes',
  }

  # USERS
  user { 'Puppet Demo':
    ensure => present,
    groups => ['Administrators'],
    before => Service['ssh'],
  }

  # SERVICE
  dsc_service { 'ssh':
    dsc_ensure     => present,
    dsc_state      => 'running',
    dsc_name       => 'BvSshServer',
    dsc_credential => 'Puppet Demo',
  }

  # REG KEYS
  registry_key { 'HKEY_LOCAL_MACHINE\Software\Demonstration':
    ensure       => present,
    purge_values => true,
  }

  registry_value { 'HKEY_LOCAL_MACHINE\Software\Demonstration\value1':
    type => string,
    data => 'this is a value',
  }

  registry_value { 'HKEY_LOCAL_MACHINE\Software\Demonstration\value2':
    type         => dword,
    data         => '0xFFFFFFFF',
  }

}
