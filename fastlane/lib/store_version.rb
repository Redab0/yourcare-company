require "json"
require "fileutils"
require "time"

module StoreVersion
  class Error < StandardError; end

  def self.parts(value)
    text = value.to_s
    raise Error, "Store version must contain two or three numeric components: #{text.inspect}" unless text.match?(/\A\d+\.\d+(?:\.\d+)?\z/)

    result = text.split(".").map { |part| Integer(part, 10) }
    result << 0 if result.length == 2
    result
  end

  def self.play_version(name)
    text = name.to_s.strip
    match = text.match(/\Av?(\d+\.\d+(?:\.\d+)?)\z/) ||
            text.match(/\A\d+\s*\(v?(\d+\.\d+(?:\.\d+)?)\)\z/) ||
            text.match(/\Av?(\d+\.\d+(?:\.\d+)?)\s*\(\d+\)\z/)
    raise Error, "Play release #{text.inspect} has no unambiguous app version. Rename active releases in Play Console to their numeric version (for example 3.0.0)." unless match

    match[1]
  end

  def self.next_version(versions:, build_numbers:, bump: "patch", platform:)
    raise Error, "Store has no version history. Initialize the app in its store first." if versions.empty?
    raise Error, "Version bump must be patch, minor or major." unless %w[patch minor major].include?(bump)

    previous = versions.map { |version| parts(version) }.max
    next_parts = previous.dup
    index = { "major" => 0, "minor" => 1, "patch" => 2 }.fetch(bump)
    next_parts[index] += 1
    ((index + 1)...3).each { |position| next_parts[position] = 0 }

    # An integer above the leading component also exceeds legacy dotted iOS builds.
    builds = build_numbers.map do |number|
      text = number.to_s
      pattern = platform == "android" ? /\A\d+\z/ : /\A\d+(?:\.\d+){0,2}\z/
      raise Error, "Invalid #{platform} store build number: #{text.inspect}" unless text.match?(pattern)

      Integer(text.split(".").first, 10)
    end
    next_build = (builds.max || 0) + 1
    raise Error, "Android versionCode exceeds the Play limit." if platform == "android" && next_build > 2_100_000_000

    {
      "platform" => platform,
      "previous_version" => previous.join("."),
      "previous_build_major_max" => builds.max || 0,
      "version" => next_parts.join("."),
      "build_number" => next_build,
      "bump" => bump
    }
  end

  def self.record(result, root:)
    directory = File.join(root, "build", "ci")
    FileUtils.mkdir_p(directory)
    evidence = result.merge("source_sha" => ENV["GITHUB_SHA"], "queried_at" => Time.now.utc.iso8601)
    File.write(File.join(directory, "#{result.fetch('platform')}-version.json"), JSON.pretty_generate(evidence) + "\n")
    if ENV["GITHUB_STEP_SUMMARY"]
      File.open(ENV.fetch("GITHUB_STEP_SUMMARY"), "a") do |file|
        file.puts("#{result.fetch('platform')}: #{result.fetch('previous_version')} → **#{result.fetch('version')} (#{result.fetch('build_number')})**")
      end
    end
    result
  end

  class PlayStore
    def initialize(client:, package_name:)
      @client = client
      @package_name = package_name
    end

    def snapshot
      # Query every track, not just internal/production; custom tracks also consume codes.
      edit = @client.insert_edit(@package_name)
      begin
        releases = Array(@client.list_edit_tracks(@package_name, edit.id).tracks).flat_map { |track| Array(track.releases) }
        releases = releases.reject { |release| Array(release.version_codes).empty? }
        versions = releases.map { |release| StoreVersion.play_version(release.name) }
        bundles = Array(@client.list_edit_bundles(@package_name, edit.id).bundles)
        apks = Array(@client.list_edit_apks(@package_name, edit.id).apks)
        codes = releases.flat_map { |release| Array(release.version_codes) } + bundles.map(&:version_code) + apks.map(&:version_code)
        { versions: versions, build_numbers: codes }
      ensure
        # Never commit the temporary edit used to read store state.
        @client.delete_edit(@package_name, edit.id)
      end
    end
  end

  class AppleStore
    def initialize(api:, bundle_id:)
      @api = api
      @bundle_id = bundle_id
    end

    def snapshot
      app = @api::App.find(@bundle_id)
      raise Error, "App not found in App Store Connect: #{@bundle_id}" unless app

      store_versions = app.get_app_store_versions(filter: { platform: "IOS" }, includes: "build")
      # Both methods paginate; include processing, expired and failed builds.
      builds = app.get_builds(includes: "preReleaseVersion", limit: 200)
      ios_builds = builds.select do |build|
        raise Error, "App Store Connect returned a build without its pre-release version." unless build.pre_release_version

        build.pre_release_version.platform == "IOS"
      end
      uploads = @api.get_build_uploads(app_id: app.id, filter: { platform: "IOS" }, limit: 200)
                    .all_pages.flat_map(&:to_models)
      versions = store_versions.map(&:version_string) + ios_builds.map(&:app_version) + uploads.map(&:cf_build_short_version_string)
      numbers = store_versions.filter_map { |version| version.build&.version } + ios_builds.map(&:version) + uploads.map(&:cf_build_version)
      { versions: versions, build_numbers: numbers }
    end
  end
end
