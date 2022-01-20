# reV demo
## 1. Set up the development environment
> **If you wish to do everything yourself, start by following step 1.1 below
> <br>Otherwise, you can skip to step 1.2 for the semi-automated approach**
### 1.1 Manual setup
#### 1.1.1 Clone (copy) the source code for rev into the directory "rev-src"
`$ git clone https://github.com/NREL/reV.git rev-src`
#### 1.1.2 Create a "virtual environment"
`$ conda create -n rev-test python=3.8`
#### 1.1.3 Activate the virtual environment
`$ conda activate rev-test`
#### 1.1.4 Change into the directory of the source code
`$ cd rev-src`
#### 1.1.5 Install `reV`
`$ pip install -e .`
#### 1.1.6 Verify that the package was successfully installed
`$ python -c 'import reV'`

### 1.2 Automated setup
> This approach uses a script to handle the setup of the development environment.
><br>It performs all the same steps as outlined in step 1.1 above; but you won't have to type as much!
#### 1.2.1 Make the script 'executable'
`$ chmod +x configure-dev-env.sh`
#### 1.2.2 Execute the script
`$ ./configure-dev-env.sh`
#### 1.2.3 Activate the virtual environment
`$ conda activate rev-test`

## Working with the test data
> `rex` is a package that comes with `reV`. it handles the "behind-the-scenes" for resource data
### Load test data (Rhode Island)
#### Import 'Resource' from the package rex 
> The *class* `Resource` helps us read and process `h5` resource files
```py
from rex import Resource
```

#### Get the path to the test data directory
> The `.h5` resource file contains the datasets and metadata

> *Hierarchical Data Format (HDF) [...] [are] designed to store and organize large amounts of data.* [*from [Wikipedia](https://en.wikipedia.org/wiki/Hierarchical_Data_Format)*] It contains multidimensional arrays of scientific data.

```py
# Import the "pathlib" package, which helps us work with file- and directory paths
import pathlib

# Get the path of the project's root directory
project_root = pathlib.Path('.').parent
# Get the path of the test data directory (found in the reV source code we cloned in step 1)
# The test data can be seen at https://github.com/NREL/reV/tree/main/tests/data
test_data_dir = project_root.joinpath('rev-src/tests/data')
# this directory contains the 'h5' resource files
wtk_dir = test_data_dir.joinpath('wtk')
# this directory contains the SAM parameter files
sam_dir = test_data_dir.joinpath('SAM')

# this builds a list of all the Resource (h5) files inside the "wtk" directory
resource_files = [filepath for filepath in wtk_dir.iterdir() if filepath.match("*.h5")]
# this builds a list of all the SAM (csv or JSON) files inside the "SAM" directory
sam_files = [filepath for filepath in sam_dir.iterdir() if filepath.match("*.(json|csv)")]

print(f'Found {len(resource_files)} resource files. Using the first match as resource.')
print(f'Found {len(sam_files)} SAM files.')
resource_path = resource_files[0]
sam_path = sam_files[0]
```

#### Read and process the Resource file
```py
with Resource(path) as f:
	print(f.datasets)
	meta = f.meta
```

> `f.datasets` are 2D arrays: time (0 axis) and value (1 axis)
> `meta` is equivalent to Project Points examples


### Run the reV example jupyter notebook
> See [Running locally](https://github.com/NREL/reV/tree/main/examples/running_locally)
> Example data for rev can be found at [NREL/reV/tests/data](https://github.com/NREL/reV/tree/main/tests/data)

>**In the code below; we're using 'reV-gen' to compute wind capacity factors for a given set of latitude and longitude coordinates:**
```py
import pathlib
from reV.config.project_points import ProjectPoints
from reV.generation.generation import Gen

# Define an array (list) of coordinate pairs (latitude/longitude)
lat_lons = np.array([[ 41.25, -71.66],
                        [ 41.05, -71.74],
                        [ 41.97, -71.78],
                        [ 41.65, -71.74],
                        [ 41.25, -71.7 ],
                        [ 41.05, -71.78]])

# Store the paths to the test files we need
project_root = pathlib.Path('.').parent
test_data_dir = project_root.joinpath('rev-src/tests/data')
res_file = test_data_dir.joinpath('wtk/ri_100_wtk_2012.h5')
sam_file = test_data_dir.joinpath('SAM/wind_gen_standard_losses_0.json')

# Set up project points from the coordinates and test files
pp = ProjectPoints.lat_lon_coords(lat_lons, res_file, sam_file)

# Run reV-gen for the technology "windpower", using the project points and test files
gen = Gen.reV_run(
    'windpower',
    pp, # project points
    sam_file,   # the SAM parameter file
    res_file,   # the resource (h5) file
    max_workers=1,
    out_fpath="./windpower_cf_output_test",  # a file name to save the output as
    output_request=('cf_mean', 'cf_profile')    # the type of output we want
)
# print the generated results of the 'cf_profile' output
print(gen.out['cf_profile'])
```

## [Optional] Extras
### Some example commands
#### Display the help message
`$ rev --help`
### Run tests
#### Test the 'pv generation' module
`$ pytest -v -disable-warnings test_gen_pv.py`
