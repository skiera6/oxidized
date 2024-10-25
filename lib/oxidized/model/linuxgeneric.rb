module Oxidized
  module Models
    # # LinuxGeneric model notes
    #
    # To expand the usage of this model for more specific needs you can create a file in `~/.config/oxidized/model/linuxgeneric.rb`
    #
    # ```ruby
    # require 'oxidized/model/linuxgeneric.rb'
    #
    # class LinuxGeneric
    #
    #   cmd :secret, clear: true do |cfg|
    #     cfg.gsub! /^(default (\S+).* (expires) ).*/, '\\1 <redacted>'
    #     cfg
    #   end
    #
    #   post do
    #     cfg = add_comment 'THE MONKEY PATCH'
    #     cfg += cmd 'firewall-cmd --list-all --zone=public'
    #   end
    # end
    # ```
    #
    # See [Extending-Model](https://github.com/ytti/oxidized/blob/master/docs/Creating-Models.md#creating-and-extending-models)
    #
    # Back to [Model-Notes](README.md)

    # Represents the LinuxGeneric model.
    #
    # Handles configuration retrieval and processing for LinuxGeneric devices.

    class LinuxGeneric < Oxidized::Models::Model
      using Refinements

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^(\w.*|\W.*)[:#$] /
      comment '# '

      # @!visibility private
      # add a comment in the final conf
      def add_comment(comment)
        "\n###### #{comment} ######\n"
      end

      cmd :all do |cfg|
        cfg.gsub! /^(default (\S+).* (expires) ).*/, '\\1 <redacted>'
        cfg.cut_both
      end

      # @!visibility private
      # show the persistent configuration
      pre do
        cfg = add_comment 'THE HOSTNAME'
        cfg += cmd 'cat /etc/hostname'

        cfg += add_comment 'THE HOSTS'
        cfg += cmd 'cat /etc/hosts'

        cfg += add_comment 'THE INTERFACES'
        cfg += cmd 'ip link'

        cfg += add_comment 'RESOLV.CONF'
        cfg += cmd 'cat /etc/resolv.conf'

        cfg += add_comment 'IP Routes'
        cfg += cmd 'ip route'

        cfg += add_comment 'IPv6 Routes'
        cfg += cmd 'ip -6 route'

        cfg += add_comment 'MOTD'
        cfg += cmd 'cat /etc/motd'

        cfg += add_comment 'PASSWD'
        cfg += cmd 'cat /etc/passwd'

        cfg += add_comment 'GROUP'
        cfg += cmd 'cat /etc/group'

        cfg += add_comment 'nsswitch.conf'
        cfg += cmd 'cat /etc/nsswitch.conf'

        cfg += add_comment 'VERSION'
        cfg += cmd 'cat /etc/issue'

        cfg
      end

      cfg :telnet do
        username /^Username:/
        password /^Password:/
      end

      cfg :telnet, :ssh do
        post_login do
          if vars(:enable) == true
            cmd "sudo su -", /^\[sudo\] password/
            cmd @node.auth[:password]
          elsif vars(:enable)
            cmd "su -", /^Password:/
            cmd vars(:enable)
          end
        end

        pre_logout do
          cmd "exit" if vars(:enable)
        end
        pre_logout 'exit'
      end
    end
  end
end
