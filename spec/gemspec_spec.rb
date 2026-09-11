require "spec_helper"

# What the packaged gem carries. Held here because the failure is invisible in this repo —
# every consumer in the workspace is a path dependency with the whole checkout on disk, so a
# file that should never have been packaged behaves exactly like one that should.
#
# `app/assets/builds` is gitignored, and `Dir` — which `spec.files` uses — does not read
# .gitignore. Whatever a releaser's working copy holds there gets shipped. 4.2.2 shipped four
# artifacts of the build scripts as they stood before #3971 (which moved their output into
# `avo/`), left behind on one machine since July 2025: 22MB of dead weight, and a stray
# top-level `avo.custom.js` that took over that Sprockets logical path in host apps with an
# `avo.custom.js` of their own — replacing the host's file with ours, silently.
RSpec.describe "the avo gem package" do
  root = Pathname.new(File.expand_path("..", __dir__))

  # Loaded fresh each time rather than through Gem::Specification.load, which memoizes by path
  # and would hand back the same file list before and after a stray file is planted.
  def packaged_files(root)
    Dir.chdir(root) { eval(root.join("avo.gemspec").read, TOPLEVEL_BINDING, root.join("avo.gemspec").to_s).files } # standard:disable Security/Eval
  end

  it "ships the compiled assets the panel serves" do
    expect(packaged_files(root)).to include(
      "app/assets/builds/avo/application.js",
      "app/assets/builds/avo/application.css",
      "app/assets/builds/avo/late-registration.js"
    )
  end

  # The regression itself: a file directly under app/assets/builds is never ours to ship.
  it "leaves a stray build artifact out, whatever a working copy holds" do
    stray = root.join("app", "assets", "builds", "avo.custom.js")
    raise "#{stray} exists — refusing to overwrite it" if stray.exist?

    stray.write("// planted by #{__FILE__}\n")

    begin
      expect(packaged_files(root)).not_to include("app/assets/builds/avo.custom.js")
    ensure
      stray.delete
    end
  end
end
