module Oxidized
  module Models
    class EdgeSwitch < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Ubiquiti EdgeSwitch #

      comment '!'

      prompt /\(.*\)\s[#>]/

      cmd 'show running-config' do |cfg|
        cfg.each_line.to_a[2..-2].reject { |line| line.match(/System Up Time.*/) || line.match(/Current SNTP Synchronized Time.*/) }.join
      end

      cfg :telnet do
        username /User(name)?:\s?/
        password /^Password:\s?/
      end

      cfg :telnet, :ssh do
        post_login do
          if vars(:enable) == true
            cmd "enable"
          elsif vars(:enable)
            cmd "enable", /^[pP]assword:/
            cmd vars(:enable)
          end
          cmd 'terminal length 0'
        end
        pre_logout 'quit'
        pre_logout 'n'
      end
    end
  end
end
