class Sandbox < Formula
  desc "Host-side CLI that provisions a per-developer Sandbox container"
  homepage "https://github.com/MusabaN/sandbox"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
    on_intel do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-darwin-x64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-linux-x64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "sandbox"
  end

  test do
    assert_match "sandbox #{version}", shell_output("#{bin}/sandbox --version")
  end
end
