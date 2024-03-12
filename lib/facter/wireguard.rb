wireguard = {}

Dir.glob('/etc/wireguard/*.conf') do |filename|

  interface = File.basename(filename).gsub('.conf', '')
  private_key_path = '/etc/wireguard/' + interface + '.key'

  if File.file?(private_key_path)
    wireguard[interface] = {}

    begin #... process, may raise an exception
      if File.exist?('/usr/bin/wg')
        public_key = Puppet::Util::Execution.execute(['/usr/bin/wg', 'pubkey'], stdinfile: private_key_path).strip
      else
        public_key = Puppet::Util::Execution.execute(['/usr/local/bin/wg', 'pubkey'], stdinfile: private_key_path).strip
      end
    rescue => e #... error handler
      public_key = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
    end
    
    begin #... process, may raise an exception
      if File.exist?('/usr/bin/wg')
        port = Puppet::Util::Execution.execute(['/usr/bin/wg', 'show', interface, 'listen-port']).strip
      else
        port = Puppet::Util::Execution.execute(['/usr/local/bin/wg', 'show', interface, 'listen-port']).strip
      end
    rescue => e #... error handler
      port = '51820'
    end

    begin #... process, may raise an exception
      local_ip = Facter.value(:networking)['interfaces'][interface]['ip'].strip
    rescue => e #... error handler
      local_ip = '0.0.0.0'
    end

    wireguard[interface]['public_key'] = public_key
    wireguard[interface]['endpoint'] = Facter.value(:fqdn) + ':' + port
    wireguard[interface]['local_ip'] =  local_ip + '/32'
  end
end

Facter.add('wireguard') do
  setcode do
    wireguard
  end
end
