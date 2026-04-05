when defined(macosx):
  --passL:"/opt/local/lib/libssl.a"
  --passL:"/opt/local/lib/libcrypto.a"
  --passL:"/opt/local/lib/libevent.a"
  --passL:"/opt/local/lib/libevent_pthreads.a"
  --passL:"/usr/local/lib/libmonocypher.a"
  --passC:"-I /opt/local/include"
elif defined(linux):
  --passL:"/usr/local/lib/libssl.so"
  --passL:"/usr/local/lib/libcrypto.so"
  --passL:"/usr/local/lib/libssl.so"
  --passL:"/usr/local/lib/libevent_pthreads.a"
  --passC:"-I /usr/local/include"

--mm:arc
--define:webapp # todo supWebApp
--define:ssl
--define:supraFileserver

when not defined release:
  --define:timHotCode
else:
  --passC:"-O3 -flto" # Optimize for speed
  --passL:"-flto"     # Link Time Optimization for smaller/faster binaries

  # Embed assets in production for better performance and easier deployment
  const embedAssetsPath {.strdefine.} = ""
  when defined supraEmbedAssets:
    let outputEmbedAssets = getProjectPath().parentDir() / ".cache" / "embed_assets.nim"
    let assetsPath = absolutePath(joinPath(getProjectPath() / "storage", "assets"))
    if dirExists(assetsPath):
      exec "supra bundle.assets \"" & assetsPath & "\" \"" & outputEmbedAssets & "\""