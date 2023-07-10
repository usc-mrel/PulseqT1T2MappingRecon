This recon is now obsolete. Here is a better, unified offline and online recon: https://github.com/usc-mrel/PulseqGadgetronRecon

# General pipeline


Siemens .dat -> MRD -> mrd2mat4mapping.m -> preproc4mapping.m -> main_XXmap.m -> NistPhantomTXROIAnalysis.m


1. Using **siemens_to_ismrmrd** command, raw data and noise measurements should be exported as following:

```
DATA_ROOT/
|- data_folder/
    |- dcm/ (if exists)
    |- raw/
        |- meas_XXXXX.dat
            .
            .
            .
        |- h5/
            |- meas_XXXXX.h5
                .
                .
                .
        |- noise/
            |- noise_meas_XXXXX.h5
                .
                .
                .
```

2. **mrd2mat4mapping.m** converts, reconstructs and shows the images using MRD acquisition and noise datasets for a given measurement.


3. **Preproc4Mapping.m** allows us to select the slice, extracts the vial masks and specify the vial set we are looking into (MnCl2 or NiCl2).


4. **main_XXmap.m** depending on the T1 T2 or B1 mapping, calculates the required map. B1 map is a dependency to T1 map.


5. **NistPhantomTXROIAnalysis.m** depending on T1 or T2 mapping, calculates the mean and std of individual vials, and compares them with given reference values.
