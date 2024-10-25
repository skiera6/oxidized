module Oxidized
  module Models
    # @!visibility private
    # ECI Telecom Apollo
    # Tested on OPT9608 systems via SSH and telnet

    # Represents the ECIapollo model.
    #
    # Handles configuration retrieval and processing for ECIapollo devices.

    class ECIapollo < Oxidized::Models::Model
      using Refinements

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^([\w.@()-]+[#>]\s?)$/
      comment '# '

      cmd :all do |cfg|
        cfg.each_line.to_a[1..-2].join
      end

      cmd :secret do |cfg|
        cfg.gsub!(/community (\S+) {/, 'community <hidden> {')
        cfg.gsub!(/ "\$\d\$\S+; ## SECRET-DATA/, ' <secret removed>;')
        cfg
      end

      cfg :telnet do
        username(/^login:/)
        password(/^Password:/)
      end

      cfg :telnet, :ssh do
        post_login 'set cli screen-length 0'
        post_login 'set cli screen-width 0'
        pre_logout 'exit'
      end

      cmd('show version')           { |cfg| comment cfg }
      cmd('show system licenses')   { |cfg| comment cfg }
      cmd('show configuration')     { |cfg| comment cfg }
      cmd('show configuration | display-set') { |cfg| cfg }
      cmd('show chassis inventory') { |cfg| comment cfg }
    end
  end
end
