module Oxidized
  module Models
    # Represents the Nodegrid model.
    #
    # Handles configuration retrieval and processing for Nodegrid devices.

    class Nodegrid < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # ZPE Nodegrid (Tested with Nodegrid Gate/Bold/NSR)
      # https://www.zpesystems.com/products/

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /(?<!@)\[(.*?\s\/)\]#/
      comment '# '

      cmd 'show system/about/' do |cfg|
        comment cfg # Show System, Model, Software Version
      end

      cmd 'show settings/license/' do |cfg|
        comment cfg # Show License information
      end

      cmd 'export_settings settings/ --plain-password' do |cfg|
        cfg # Print all system config including keys to be importable via import_settings function
      end

      cfg :ssh do
        pre_logout 'exit'
      end
    end
  end
end
