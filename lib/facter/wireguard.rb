wireguard = {}

Dir.glob('/etc/wireguard/*.conf') do |filename|

  interface = File.basename(filename).gsub('.conf', '')
  private_key_path = '/etc/wireguard/' + interface + '.key'

  if File.file?(private_key_path)
    wireguard[interface] = {}

    public_key = Puppet::Util::Execution.execute(['/usr/bin/wg', 'pubkey'], stdinfile: private_key_path).strip
    
    begin #... process, may raise an exception
      port = Puppet::Util::Execution.execute(['/usr/bin/wg', 'show', interface, 'listen-port']).strip
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
