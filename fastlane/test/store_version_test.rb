require "minitest/autorun"
require "ostruct"
require "tmpdir"
require_relative "../lib/store_version"

class StoreVersionTest < Minitest::Test
  def next_version(versions: ["3.0.0"], build_numbers: [27], bump: "patch", platform: "android")
    StoreVersion.next_version(versions: versions, build_numbers: build_numbers, bump: bump, platform: platform)
  end

  def test_patch_increment_uses_store_values
    result = next_version
    assert_equal "3.0.1", result.fetch("version")
    assert_equal 28, result.fetch("build_number")
  end

  def test_versions_are_compared_numerically_across_tracks
    result = next_version(versions: ["3.9.9", "3.10.0", "3.2.0"], build_numbers: ["27", "41", "9"])
    assert_equal "3.10.1", result.fetch("version")
    assert_equal 42, result.fetch("build_number")
  end

  def test_minor_and_major_reset_lower_components
    assert_equal "3.11.0", next_version(versions: ["3.10.8"], bump: "minor").fetch("version")
    assert_equal "4.0.0", next_version(versions: ["3.10.8"], bump: "major").fetch("version")
  end

  def test_apple_two_component_versions_and_legacy_dotted_builds
    result = next_version(versions: ["4.1"], build_numbers: ["18.99.4", "9", "17.5"], platform: "ios")
    assert_equal "4.1.1", result.fetch("version")
    assert_equal 19, result.fetch("build_number")
  end

  def test_first_apple_build_can_use_existing_store_version_record
    assert_equal 1, next_version(versions: ["1.0"], build_numbers: [], platform: "ios").fetch("build_number")
  end

  def test_missing_store_history_is_not_replaced_with_pubspec
    assert_raises(StoreVersion::Error) { next_version(versions: []) }
  end

  def test_malformed_versions_and_builds_stop_delivery
    %w[release-3 1.2.3-beta 1.2.3+27 2026-10-15].each do |version|
      assert_raises(StoreVersion::Error) { next_version(versions: [version]) }
    end
    assert_raises(StoreVersion::Error) { next_version(build_numbers: ["1.2"]) }
    assert_raises(StoreVersion::Error) { next_version(bump: "none") }
    assert_raises(StoreVersion::Error) { next_version(build_numbers: [2_100_000_000]) }
  end

  def test_play_release_name_formats
    %w[3.10.2 v3.10.2].each { |name| assert_equal "3.10.2", StoreVersion.play_version(name) }
    assert_equal "3.10.2", StoreVersion.play_version("41 (3.10.2)")
    assert_equal "3.10.2", StoreVersion.play_version("3.10.2 (41)")
    assert_raises(StoreVersion::Error) { StoreVersion.play_version("October rollout") }
    assert_raises(StoreVersion::Error) { StoreVersion.play_version("2026-10-15") }
  end

  class PlayClient
    attr_reader :calls

    def initialize(fail_tracks: false, name: "3.10.0")
      @calls = []
      @fail_tracks = fail_tracks
      @name = name
    end

    def insert_edit(package)
      @calls << [:insert, package]
      OpenStruct.new(id: "read-edit")
    end

    def list_edit_tracks(package, edit)
      @calls << [:tracks, package, edit]
      raise "Permission denied" if @fail_tracks

      OpenStruct.new(tracks: [
        OpenStruct.new(track: "production", releases: [OpenStruct.new(name: "27 (3.0.0)", version_codes: [27])]),
        OpenStruct.new(track: "custom-qa", releases: [OpenStruct.new(name: @name, version_codes: [41])])
      ])
    end

    def list_edit_bundles(*)
      OpenStruct.new(bundles: [OpenStruct.new(version_code: 50)])
    end

    def list_edit_apks(*)
      OpenStruct.new(apks: [OpenStruct.new(version_code: 52)])
    end

    def delete_edit(package, edit)
      @calls << [:delete, package, edit]
    end
  end

  def test_play_includes_custom_tracks_and_unassigned_uploads
    client = PlayClient.new
    snapshot = StoreVersion::PlayStore.new(client: client, package_name: "example.app").snapshot
    result = StoreVersion.next_version(**snapshot, platform: "android")
    assert_equal "3.10.1", result.fetch("version")
    assert_equal 53, result.fetch("build_number")
    assert_equal [:delete, "example.app", "read-edit"], client.calls.last
  end

  def test_play_deletes_read_edit_and_propagates_authentication_failure
    client = PlayClient.new(fail_tracks: true)
    error = assert_raises(RuntimeError) { StoreVersion::PlayStore.new(client: client, package_name: "example.app").snapshot }
    assert_equal "Permission denied", error.message
    assert_equal :delete, client.calls.last.first
  end

  def test_unparseable_custom_release_does_not_silently_downgrade_version
    client = PlayClient.new(name: "QA rollout")
    assert_raises(StoreVersion::Error) { StoreVersion::PlayStore.new(client: client, package_name: "example.app").snapshot }
    assert_equal :delete, client.calls.last.first
  end

  def apple_api(app:, pages: [])
    api = Module.new
    app_model = Class.new
    app_model.define_singleton_method(:find) { |_bundle_id| app }
    api.const_set(:App, app_model)
    response = Object.new
    response.define_singleton_method(:all_pages) { pages }
    api.define_singleton_method(:get_build_uploads) { |**_arguments| response }
    api
  end

  def test_apple_includes_all_upload_pages_and_ignores_other_platform_builds
    app = Object.new
    app.define_singleton_method(:id) { "123" }
    app.define_singleton_method(:get_app_store_versions) do |**_arguments|
      [OpenStruct.new(version_string: "3.9.0", build: OpenStruct.new(version: "80"))]
    end
    app.define_singleton_method(:get_builds) do |**_arguments|
      [OpenStruct.new(version: "81", app_version: "3.10.0", pre_release_version: OpenStruct.new(platform: "IOS")),
       OpenStruct.new(version: "999", app_version: "99.0.0", pre_release_version: OpenStruct.new(platform: "MAC_OS"))]
    end
    pages = [OpenStruct.new(to_models: [OpenStruct.new(cf_build_version: "82", cf_build_short_version_string: "3.11.0")]),
             OpenStruct.new(to_models: [OpenStruct.new(cf_build_version: "90", cf_build_short_version_string: "3.12.0")])]
    snapshot = StoreVersion::AppleStore.new(api: apple_api(app: app, pages: pages), bundle_id: "example.app").snapshot
    result = StoreVersion.next_version(**snapshot, platform: "ios")
    assert_equal "3.12.1", result.fetch("version")
    assert_equal 91, result.fetch("build_number")
  end

  def test_missing_apple_app_fails_without_a_local_fallback
    assert_raises(StoreVersion::Error) do
      StoreVersion::AppleStore.new(api: apple_api(app: nil), bundle_id: "example.missing").snapshot
    end
  end

  def test_evidence_records_the_selected_store_version
    Dir.mktmpdir do |root|
      result = next_version
      StoreVersion.record(result, root: root)
      evidence = JSON.parse(File.read(File.join(root, "build/ci/android-version.json")))
      assert_equal "3.0.1", evidence.fetch("version")
      assert_equal 28, evidence.fetch("build_number")
      assert evidence.fetch("queried_at").end_with?("Z")
    end
  end
end
