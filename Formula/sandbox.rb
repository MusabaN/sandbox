class Sandbox < Formula
  desc "Host-side CLI that provisions a per-developer Sandbox container"
  homepage "https://github.com/MusabaN/sandbox"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-darwin-arm64.tar.gz"
      sha256 "60a89314b1f4e4e180c5e0cc982efaf4b17ac344d109d94b1d74080f471a93c3"
    end
    on_intel do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-darwin-x64.tar.gz"
      sha256 "3a986d51f841c0d60d91d2406f85ae578ecdf75528cd2374c7096ed59af5384d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/MusabaN/sandbox/releases/download/v0.1.0/sandbox-0.1.0-linux-x64.tar.gz"
      sha256 "838dd53077af0f58b1c8ebd7a5749d3623a6796d19318f4dbc65c8f4ab40fd9e"
    end
  end

  def install
    bin.install "sandbox"
  end

  test do
    assert_match "sandbox #{version}", shell_output("#{bin}/sandbox --version")
  end
end
