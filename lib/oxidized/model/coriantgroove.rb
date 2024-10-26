module Oxidized
  module Models
    # Represents the CoriantGroove model.
    #
    # Handles configuration retrieval and processing for CoriantGroove devices.

    class CoriantGroove < Oxidized::Models::Model
      using Refinements

      comment '# '

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^(\w+@.*>\s*)$/

      cmd :all do |cfg|
        cfg.each_line.to_a[1..-3].map { |line| line.delete("\r").rstrip }.join("\n") + "\n"
      end

      cmd 'show inventory' do |cfg|
        comment cfg.cut_tail
      end

      cmd 'show softwareload' do |cfg|
        comment cfg.cut_tail
      end

      cmd 'show config | display commands' do |cfg|
        cfg.cut_head
      end

      cfg :ssh do
        post_login 'set -f cli-config cli-columns 4000'
        pre_logout 'quit -f'
      end
    end
  end
end
