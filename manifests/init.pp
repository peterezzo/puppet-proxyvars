# configure proxy settings for generic *nix operatingsystems
# http_proxy = url with proto and port (http://host:port) of http proxy
# https_proxy = url with proto and port of https proxy
# ftp_proxy = url with proto and port of ftp proxy
# no proxy = array of domains to not proxy (example.com, etc.com)
# configure_apt = setup apt proxy configuration
# configure_profile = setup global environment vars for proxy
# configure_sudo = add proxy vars to env_keep (all applicable)
class proxyvars (
  $http_proxy        = false,
  $https_proxy       = false,
  $ftp_proxy         = false,
  $no_proxy          = false,
  $configure_apt     = false,
  $configure_profile = true,
  $configure_sudo    = true,
  $file_profile_path = '/etc/profile.d/proxy.sh',
  $file_sudoenv_path = '/etc/sudoers.d/env_keep',
  $file_apt_path     = '/etc/apt/apt.conf.d/01proxy'
) {

  if $::kernel == 'windows' {
    fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
  }

  if ($http_proxy and $https_proxy and $ftp_proxy) == false {
    fail("${module_name} called without any proxy variables set")
  }

  # set basic shell variables through template
  file { $file_profile_path:
    ensure  => present,
    content => template("${module_name}/proxy_vars-profile.erb")
  }

  # keep proxy variables within sudo
  if $configure_sudo {
    file { $file_sudoenv_path:
      ensure => present,
      mode   => '0440',
      source => "puppet:///modules/${module_name}/sudoers-env_keep"
    }
  }

  # off by default as you can also use apt class for this
  if $configure_apt {
    file { $file_apt_path:
      ensure  => present,
      content => template("${module_name}/proxy_vars-apt.erb")
    }
  }
}
