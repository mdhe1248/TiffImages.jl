# ---
# title: Writing ImageJ compatible metadata
# description: This demo shows how to write XYZT information that works with ImageJ
# julia: 1.0
# ---

# ImageJ is a commonly used image processing software for working with TIFFs.
# You might want to add X and Y resolution information to your `TiffImages.jl`
# TIFFs that works with ImageJ. 

# Among Tifftags, updating x and y resolution may be useful. First, we need to assign the resolution unit `RESOLUTIONUNIT`.

using Images, TiffImages, Unitful
img0 = zeros(Gray{N0f8}, 10, 10, 12) #example image
img = TiffImages.DenseTaggedImage(img0)

resunit = UInt8(3) # 1: No absolute unit of measurement, 2: Inch, 3: Centimeter
[ifd[TiffImages.RESOLUTIONUNIT] = resunit for ifd in ifds(img)]

# Then, tifftags `XRESOLUTION` and `YRESOLUTION` display the number of pixels
# per `RESOLUTIONUNIT`. 

resxy = Rational{UInt32}(round(1u"cm"/0.653u"μm", digits = 3)) # Type must be rational. In this example, the pixel size is 0.653 μm x 0.653 μm.
[ifd[TiffImages.XRESOLUTION] = resxy for ifd in ifds(img)]
[ifd[TiffImages.YRESOLUTION] = resxy for ifd in ifds(img)]

# Now if we want to add Z and time information to a TIFF, it's a bit more
# complicated because the TIFF spec doesn't have a standard way of representing
# this information. ImageJ has a poorly documented way to add this information
# by writing to an IMAGEDESCRIPTION tag in the first IFD. 

# The following tells ImageJ that it is a hyperstack with 3 timepoints and 4 Z
# slices with a 0.2 interval (in secs) between frames and a 5 micron spacing,
# respectively. 

first(ifds(img))[TiffImages.IMAGEDESCRIPTION] = # only in the first IFD
"ImageJ=1.51d
images=12
frames=3
slices=4
hyperstack=true
spacing=5.0
unit=um
finterval=0.2
axes=TZYX"

# Then write the image to disk

TiffImages.save("imagej.tiff", img)