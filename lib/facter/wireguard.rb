wireguard = {}
port = 'port' # default to "port"

Dir.glob('/etc/wireguard/*.conf') do |filename|

  interface = File.basename(filename).gsub('.conf', '')
  File.open(filename).each do |line|
    if line.match( /ListenPort = \d*/ )
      port = line.gsub('ListenPort = ', '')
    end
  end
  private_key_path = '/etc/wireguard/' + interface + '.key'

  wireguard[interface] = {}

  if File.file?(private_key_path)
    public_key = Puppet::Util::Execution.execute(['/usr/bin/wg', 'pubkey'], stdinfile: private_key_path)
    wireguard[interface]['public_key'] = public_key
    wireguard[interface]['endpoint'] = Facter.value(:fqdn) + ':' + port
  end
end

Facter.add('wireguard') do
  setcode do
    wireguard
  end
end
