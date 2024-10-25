module Oxidized
  module Models
    # Represents the AEN model.
    #
    # Handles configuration retrieval and processing for AEN devices.

    class AEN < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Accedian

      comment '# '

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^([-\w.\/:?\[\]()]+:\s?)$/

      cmd 'configuration generate-script module all' do |cfg|
        cfg
      end

      cmd :all do |cfg|
        cfg.cut_both
      end

      cfg :ssh do
        pre_logout 'exit'
      end
    end
  end
end
