
# Project: Blog Article - How To Reduce the Number of VIP Instances using Accessor Classes
### Date: 27.04.2017
### Author: stefan

### How To run a test:
- clone the GitHub repo for the article

$> cd /path/to/article/scripts
$> chmod 777 *.sh
$> ./<sim>_run.sh

<sim> can be one of *irun*, *questa* or *vcs*, depending on the simulator you want to use.


### Customization
You can further customize the example by defining the following macros in top:

- **EX_USE_UVMO_ACCESSOR**: if it's defined the abstract accessor class will be inheriting the uvm_object, otherwise it will use the interface class construct

- **EX_USE_SIGNAL_ARRAY**: if it's defined the signals inside the interface will be defined using array of signals instead of a long bit vector

