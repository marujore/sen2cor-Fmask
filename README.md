# Sen2cor and FMASK 4.2

Sentinel-2 Sen2cor atmospheric correction and FMASK (4.2) cloud masking.

## Dependencies

- Docker


## Sen2cor 2.8.0 Parameters
Sen2cor parameters can be changing by modifing the /sen2cor_2.8.0/2.8/L2A_GIPP.xml file and mounting it.
This repository L2A_GIPP.xml only set DEM_Terrain_Correction to FALSE.
If you wish to use sen2cor default parameters, don't mount the parameters folder (-v /path/to/sen2cor_2.8.0/2.8:/root/sen2cor/2.8).

More info regarding Sen2Cor can be found on its Configuration and User Manual (http://step.esa.int/thirdparties/sen2cor/2.8.0/docs/S2-PDGS-MPC-L2A-SUM-V2.8.pdf).


## Sen2cor 2.5.5 Parameters
Sen2cor parameters can be changing by modifing the /sen2cor_2.5.5/2.5/L2A_GIPP.xml file and mounting it.
If you wish to use sen2cor default parameters, don't mount the parameters folder (-v /path/to/sen2cor_2.5.5/2.5:/root/sen2cor/2.5).

More info regarding Sen2Cor can be found on its Configuration and User Manual (https://step.esa.int/thirdparties/sen2cor/2.5.5/docs/S2-PDGS-MPC-L2A-SUM-V2.5.5_V2.pdf).


## Downloading Sen2cor auxiliarie files:
  Download from http://maps.elie.ucl.ac.be/CCI/viewer/download.php (fill info on the right and download "ESACCI-LC for Sen2Cor data package")
  extract the downloaded file and the files within. It will contain two files and one directory:

  Example on Ubuntu (Linux) installation:

    $ ls home/user/sen2cor/CCI4SEN2COR

  ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif

  ESACCI-LC-L4-Snow-Cond-500m-P13Y7D-2000-2012-v2.0

  ESACCI-LC-L4-WB-Map-150m-P13Y-2000-v4.0.tif


## Downloading FMASK auxiliarie files:

1. [Download FMask 4.2 standalone Linux installer](https://github.com/GERSL/Fmask)
   and copy it into the root of this repository.

2. Run

   ```bash
   $ docker build -t sen2cor_2.5.5-fmask_4.2 .
   ```

   from the root of this repository.


## Usage


To process a Sentinel-2 scene (e.g. `S2A_MSIL1C_20190105T132231_N0207_R038_T23LLF_20190105T145859.SAFE`) run

```bash
    $ docker run --rm \
    -v /path/to/CCI4SEN2COR:/home/lib/python2.7/site-packages/sen2cor/aux_data \
    -v /path/to/sen2cor/2.5:/root/sen2cor/2.5 \
    -v /path/to/folder/containing/.SAFEfile:/app \
    -v /path/to/output:/mnt/output-dir:rw \
    sen2cor-fmask yourFile.SAFE
```

Results are written on mounted `/mnt/output-dir/`.
