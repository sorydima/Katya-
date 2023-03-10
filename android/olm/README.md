# Olm

An implementation of the Double Ratchet cryptographic ratchet described by
https://whispersystems.org/docs/specifications/doubleratchet/, written in C and
C++11 and exposed as a C API.

The specification of the Olm ratchet can be found in [docs/olm.md](docs/olm.md).

This library also includes an implementation of the Megolm cryptographic
ratchet, as specified in [docs/megolm.md](docs/megolm.md).

## Installing

### Linux and other Unix-like systems

Your distribution may have pre-compiled packages available.  If not, or if you
need a newer version, you will need to compile from source.  See the "Building"
section below for more details.

### macOS

The easiest way to install on macOS is via Homebrew.  If you do not have
Homebrew installed, follow the instructions at https://brew.sh/ to install it.

You can then install libolm by running

```bash
brew install libolm
```

If you also need the Python packages, you can run

```bash
pip3 install python-olm --global-option="build_ext" --global-option="--include-dirs="`brew --prefix libolm`"/include" --global-option="--library-dirs="`brew --prefix libolm`"/lib"
```

Note that this will install an older version of the Python bindings, which may
be missing some functions.  If you need the latest version, you will need to
build from source.

### Windows

You will need to build from source.  See the "Building" section below for more
details.

### Bindings

#### JavaScript

You can use pre-built npm packages, available at
<https://gitlab.matrix.org/matrix-org/olm/-/packages?type=npm>.

#### Python

Pre-built packages for Python are available for certain architectures at
<https://gitlab.matrix.org/matrix-org/olm/-/packages?type=PyPI>.  They can be
installed by running

```bash
pip install python-olm --extra-index-url https://gitlab.matrix.org/api/v4/projects/27/packages/pypi/simple
```

Currently, we try to provide packages for all supported versions of Python on
x86-64, i686, and aarch64, but we cannot guarantee that packages for all
versions will be available on all architectures.

#### Android

Pre-built Android bindings are available at
<https://gitlab.matrix.org/matrix-org/olm/-/packages?type=Maven>.

## Building

To build olm as a shared library run:

```bash
cmake . -Bbuild
cmake --build build
```

To run the tests, run:

```bash
cd build/tests
ctest .
```

To build olm as a static library (which still needs libstdc++ dynamically) run:

```bash
cmake . -Bbuild -DBUILD_SHARED_LIBS=NO
cmake --build build
```

The library can also be used as a dependency with CMake using:

```cmake
find_package(Olm::Olm REQUIRED)
target_link_libraries(my_exe Olm::Olm)
```

### Bindings

#### JavaScript

The recommended way to build the JavaScript bindings is using
[Nix](https://nixos.org/).  With Nix, you can run

```bash
nix build .\#javascript
```

to build the bindings.

If you do not have Nix you can, install emscripten from https://emscripten.org/
and then run:

```bash
make js
```

Emscripten can also be run via Docker, in which case, you need to pass through
the EMCC_CLOSURE_ARGS environment variable.

#### Android

To build the android project for Android bindings, run:

```bash
cd android
./gradlew clean build
```

#### Objective-C

To build the Xcode workspace for Objective-C bindings, run:

```bash
cd xcode
pod install
open OLMKit.xcworkspace
```

#### Python

To build the Python 3 bindings, first build olm as a library as above, and
then run:

```bash
cd python
make
```

### Using make instead of cmake

**WARNING:** Using cmake is the preferred method for building the olm library;
the Makefile may be removed in the future or have functionality removed.  In
addition, the Makefile may make certain assumptions about your system and is
not as well tested.

To build olm as a dynamic library, run:

```bash
make
```

To run the tests, run:

```bash
make test
```

To build olm as a static library, run:

```bash
make static
```

## Bindings

libolm can be used in different environments using bindings. In addition to the
JavaScript, Python, Java (Android), and Objective-C bindings included in this
repository, some bindings are (in alphabetical order):

- [cl-megolm](https://github.com/K1D77A/cl-megolm) (MIT) Common Lisp bindings
- [dart-olm](https://gitlab.com/famedly/company/frontend/libraries/dart-olm) (AGPLv3) Dart bindings
- [Dhole/go-olm](https://github.com/Dhole/go-olm) (Apache-2.0) Go bindings
- [jOlm](https://github.com/brevilo/jolm) (Apache-2.0) Java bindings
- [libQtOlm](https://gitlab.com/b0/libqtolm/) (GPLv3) Qt bindings
- [matrix-kt](https://github.com/Dominaezzz/matrix-kt) (Apache-2.0) Kotlin
  library for Matrix, including Olm methods
- [maunium.net/go/mautrix/crypto/olm](https://github.com/tulir/mautrix-go/tree/master/crypto/olm)
  (Apache-2.0) fork of Dhole/go-olm
- [nim-olm](https://codeberg.org/BarrOff/nim-olm) (MIT) Nim bindings
- [olm-sys](https://gitlab.gnome.org/BrainBlasted/olm-sys) (Apache-2.0) Rust
  bindings
- [Trixnity](https://gitlab.com/trixnity/trixnity) (Apache-2.0) Kotlin SDK for
  Matrix, including Olm bindings

Note that bindings may have a different license from libolm, and are *not*
endorsed by the Matrix.org Foundation C.I.C.

## Release process

First: bump version numbers in ``common.mk``, ``CMakeLists.txt``,
``javascript/package.json``, ``python/olm/__version__.py``, ``OLMKit.podspec``,
``Package.swift``, and ``android/gradle.properties``.

Also, ensure the changelog is up to date, and that everything is committed to
git.

It's probably sensible to do the above on a release branch (``release-vx.y.z``
by convention), and merge back to master once the release is complete.

```bash
make clean

# build and test C library
make test

# build and test JS wrapper
make js
(cd javascript && \
     npm run test && \
     sha256sum olm.js olm_legacy.js olm.wasm > checksums.txt && \
     gpg -b -a -u F75FDC22C1DE8453 checksums.txt && \
     npm publish)

VERSION=x.y.z
git tag $VERSION -s
git push --tags

# OLMKit CocoaPod release
# Make sure the version OLMKit.podspec is the same as the git tag
# (this must be checked before git tagging)
pod spec lint OLMKit.podspec --use-libraries --allow-warnings
pod trunk push OLMKit.podspec --use-libraries --allow-warnings
# Check the pod has been successully published with:
pod search OLMKit
```

Python and JavaScript packages are published to the registry at
<https://gitlab.matrix.org/matrix-org/olm/-/packages>.  The GitLab
documentation contains instructions on how to set up twine (Python) and npm
(JavaScript) to upload to the registry.

To publish the Android library to MavenCentral (you will need some secrets), in the /android folder:
 - Run the command `./gradlew clean build publish --no-daemon --no-parallel --stacktrace`. The generated AAR must be approx 500 kb.
 - Connect to https://s01.oss.sonatype.org
 - Click on Staging Repositories and check the the files have been uploaded
 - Click on close
 - Wait (check Activity tab until step "Repository closed" is displayed)
 - Click on release. The staging repository will disappear
 - Check that the release is available in https://repo1.maven.org/maven2/org/matrix/android/olm-sdk/ (it can take a few minutes)

## Design

Olm is designed to be easy port to different platforms and to be easy
to write bindings for.

It was originally implemented in C++, with a plain-C layer providing the public
API. As development has progressed, it has become clear that C++ gives little
advantage, and new functionality is being added in C, with C++ parts being
rewritten as the need ariases.

### Error Handling

All C functions in the API for olm return ``olm_error()`` on error.
This makes it easy to check for error conditions within the language bindings.

### Random Numbers

Olm doesn't generate random numbers itself. Instead the caller must
provide the random data. This makes it easier to port the library to different
platforms since the caller can use whatever cryptographic random number
generator their platform provides.

### Memory

Olm avoids calling malloc or allocating memory on the heap itself.
Instead the library calculates how much memory will be needed to hold the
output and the caller supplies a buffer of the appropriate size.

### Output Encoding

Binary output is encoded as base64 so that languages that prefer unicode
strings will find it easier to handle the output.

### Dependencies

Olm uses pure C implementations of the cryptographic primitives used by
the ratchet. While this decreases the performance it makes it much easier
to compile the library for different architectures.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) when making contributions to the library.

## Security assessment

Olm 1.3.0 was independently assessed by NCC Group's Cryptography Services
Practive in September 2016 to check for security issues: you can read all
about it at
https://www.nccgroup.com/globalassets/our-research/us/public-reports/2016/november/ncc_group_olm_cryptogrpahic_review_2016_11_01.pdf
and https://matrix.org/blog/2016/11/21/matrixs-olm-end-to-end-encryption-security-assessment-released-and-implemented-cross-platform-on-riot-at-last/

## Security issues

If you think you found a security issue in libolm, any of its bindings or the Olm/Megolm protocols, please follow our [Security Disclosure Policy](https://matrix.org/security-disclosure-policy/) to report.

## Bug reports

For non-sensitive bugs, please file bug reports at https://github.com/matrix-org/olm/issues.

## What's an olm?

It's a really cool species of European troglodytic salamander.
http://www.postojnska-jama.eu/en/come-and-visit-us/vivarium-proteus/

## Legal Notice

The software may be subject to the U.S. export control laws and regulations
and by downloading the software the user certifies that he/she/it is
authorized to do so in accordance with those export control laws and
regulations.
