# Docker images for 3D Slicer

## Images

- slicer/slicer-notebook
  [![slicer-notebook-images](https://img.shields.io/docker/image-size/slicer/slicer-notebook/latest)](https://hub.docker.com/r/slicer/slicer-notebook)
  Ready-to-run Docker images containing Slicer and Jupyter. See [usage](#usage-of-slicer-notebook-image) information below.

- slicer/slicer-base
  [![slicer-base-images](https://img.shields.io/docker/image-size/slicer/slicer-base/latest)](https://hub.docker.com/r/slicer/slicer-base)
  The image used to build Slicer each time a Pull Request is submitted.
  For more details, see [GitHub Actions workflow](https://github.com/Slicer/Slicer/tree/main/.github)

### Unmaintained Images

Information about unmaintained images are available [here](unmaintained-images.md).

## Usage of `slicer-notebook` image

> [!WARNING]
> `slicer/slicer-notebook` images on dockerhub are outdated, therefore the
> examples below uses latest images from `lassoan/slicer-notebook`.

1. Start a Jupyter server by running this command:

    Linux or macOS:

    ```
    docker run -p 8888:8888 -p 49053:49053 -v "$PWD":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:latest
    ```

    Windows:

    ```
    docker run -p 8888:8888 -p 49053:49053 -v "%USERPROFILE%":/home/sliceruser/work --rm -ti lassoan/slicer-notebook:latest
    ```

2. Open the link shown at the end of the command-line output (`http://127.0.0.1:8888/?token=...`) in a web browser.
