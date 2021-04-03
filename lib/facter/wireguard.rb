if File.file?('/etc/wireguard/wg0.pub')
  wireguard = {}
  wireguard['wg0']['public_key'] = File.read('/etc/wireguard/wg0.pub')
  wireguard['wg0']['endpoint'] = Facter.value(:fqdn) + ':8080'

  Facter.add('wireguard') do
    setcode do
      wireguard
    end
  end
end
