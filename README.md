# opencv-build
opencv build script

# Install

```bash:
curl -sL https://github.com/kawaz/opencv-build/raw/master/build-on-amazonlinux.sh | bash
```

# Usage

```bash:
g++ -o sample sample.cpp $(pkg-config --cflags --libs opencv)
```
