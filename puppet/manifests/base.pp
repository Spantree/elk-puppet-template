


include java7

class { 'elasticsearch':
  package_url => "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb",
  config      => {
    'node' => {
      'name' => $short_hostname
    },
    'http' => {
      'max_content_length'=> '500mb'
    },
    'network' => {
      'publish_host'  => $ipaddress_eth0
    },
    'cluster' => {
      'name' =>'elk'
    },
    'marvel' => {
      'agent' => {
        'enabled' => "true"
      }
    },
  },
  require => Class['java7']
}


#this can be done on a single call
elasticsearch::plugin{'mobz/elasticsearch-head':
  module_dir  => 'head',
}

elasticsearch::plugin { 'elasticsearch/marvel/latest':
  module_dir  => 'marvel',
}

elasticsearch::plugin { 'lukas-vlcek/bigdesk':
  module_dir  => 'bigdesk',
}
elasticsearch::plugin { 'elasticsearch/elasticsearch-cloud-aws/2.0.0.RC1':
  module_dir  => 'bigdesk',
}

class { 'nginx':
  confd_purge => true,
}
nginx::resource::upstream { 'elasticsearch':
  members => [
    'localhost:9200',
  ],
}
nginx::resource::vhost { 'VIRTUALHOSTNAME':
  proxy => 'http://elasticsearch',
  listen_port => 80,
}
htpasswd { 'HTTPASSWDUSERNAME':
  cryptpasswd => 'CRYPTEDPASSWORD',
  target      => '/etc/nginx/.htpasswd',
  require     => Class['nginx']
}
file { "/etc/nginx/.htpasswd":
  owner => "nginx",
  group => "nginx",
  require => Htpasswd['elasticsearch']
}

class { 'kibana':
  elasticsearch_url => "http://escluster.redparrot.com:80",
  webserver         => 'nginx',
  virtualhost       => 'VIRTUALHOSTNAME'# Default: kibana.${::domain},
}
nginx::resource::vhost { 'VIRTUALHOSTNAME':
  www_root => '/opt/kibana',
  auth_basic => "Restricted",
  auth_basic_user_file => "/etc/nginx/.htpasswd"
}
