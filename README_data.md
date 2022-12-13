# Data files

## Common

All data files have the following fields common:
```
acq_header: MRD acquisition header containing information about raw data.

data: Raw (k-space) data.

img_header: MRD XML header, containing information about system, sequence, etc. (WARNING: Not all information is correct for Pulseq sequences. Example: Flip Angle)

noise_header: MRD acquisition header for noise data.

noise: Raw noise data.

recon_header: Summary information about the image and reconstruction parameters.

image: Reconstructed image.

slc: Selected slice of the image.

D: Selected single slice of the image to be used in mapping.

vial_masks: Mask for each vial.

union_mask: Combined masks of the vials.

vialset: 'MnCl2' or 'NiCl2'

site_name: Which site the data is coming from.

```
## T2 measurement data

T2 data contains following additional fields:

```
T2: T2 map

amp: Unitless amplitude map.

B1: Estimated B1 map.

opt: StimFit options structure.
```

## T1 measurement data

T1 data contains following additional fields:

```
T1: T1 map.

M: Estimated magnetization map.
```

## B1 measurement data

B1 data contains following additional fields:

```
B1map_struct: Contains B1 mapping result as returned from qMRLab.
```