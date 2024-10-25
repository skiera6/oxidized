module Oxidized
  module Models
    # Represents the Enterasys800 model.
    #
    # Handles configuration retrieval and processing for Enterasys800 devices.

    class Enterasys800 < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Enterasys 800 models #
      # Tested with 08H20G4-24 Fast Ethernet Switch Firmware: Build 01.01.01.0017
      comment '# '

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /([\w \(:.@-]+[#>]\s?)$/

      cfg :telnet do
        username /UserName:/
        password /PassWord:/
      end

      cfg :telnet do
        post_login 'disable clipaging'
      end

      cfg :telnet do
        pre_logout 'logout'
      end

      cmd :all do |cfg|
        cfg = cfg.cut_both
        cfg = cfg.gsub /^[\r\n]|^\s\s\s/, ''
        cfg = cfg.gsub "Command: show config effective", ''
        cfg
      end

      cmd 'show config effective'
    end
  end
end
