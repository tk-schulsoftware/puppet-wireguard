if File.file?('/etc/wireguard/wg0.pub')
  wireguard = {}
  wireguard['wg0'] = File.read('/etc/wireguard/wg0.pub')
  Facter.add('wireguard') do
    setcode do
      wireguard
    end
  end
end
