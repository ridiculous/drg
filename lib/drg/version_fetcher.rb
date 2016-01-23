module DRG
  class VersionFetcher

    # @return Hash
    def perform(gems)
      gems = Array(gems)
      latest_versions = {}
      load_gem_versions(gems).scan(/^(#{gems.join('|')})\s\(([\d.\s,\w\-]+)\)$/).each do |gem_name, versions|
        latest_versions[gem_name] = versions.to_s.split(', ').map { |x| x[/([\d.\w\-]+)/, 1] }.compact
      end
      latest_versions
    end

    def load_gem_versions(gems)
      DRG.ui.say %Q(Searching for latest version of #{gems.join(', ')} ...)
      `gem query -ra #{gems.join(' ')}`
    end
  end
end