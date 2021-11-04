

# Stratix 10 PAC: OpenCL Compilation and Programming on the FPGA devcloud using Stratix 10 Devstack version 2.0.1

  <br/>

## 1    Batch Submission

The batch script attached above (in this case S10_opencl_batch.sh) can be use to launch the OpenCL emulation flow, followed by the compilation and FPGA board programming flow using aocl commands. **Adjust commands within the script to your own needs.**

From the headnode login-2, run this command:

```bash
qsub -q batch@v-qsvr-fpga -l nodes=darby:ppn=2 -d . S10_opencl_batch.sh
```

 

To see the resulting terminal output, consult the files:

S10_opencl_batch.sh.exxxxxx
 S10_opencl_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

## 2   Interactive Walkthrough

If you are new to the Stratix 10 PAC card with OpenCL, check out this quick start guide:
 https://www.intel.com/content/www/us/en/programmable/documentation/qgu1548972652523.html

This demonstration will step the user through the following steps:

1. Select appropriate compute node machine on the FPGA devcloud
2. Load the appropriate tools
3. Copy over the sample OpenCL design
4. Take the sample design and compile for emulation mode (kernels will run on the CPU)
5. Compile the application software using the gcc C compiler
6. Execute in emulation mode
7. Convert the OpenCL code to RTL and into an FPGA executable
8. Download the OpenCL FPGA bitstream to the PAC card
9. Run the application software on the host and show that the host CPU and FPGA interact to solve heterogenous workloads. Results should be comparable to emulation mode, with improved throughput.




## 3    Assumptions

This lab assumes the following:

- Basic     FPGA knowledge
- Basic     OpenCL knowledge
- Intel     Devcloud registration and SSH key set up
- MobaXterm     installed and set up, X2Go optional




## 4    Walkthrough

#### 4.1 Initial Setup

Run 

```bash
pbsnodes -s v-qsvr-fpga
```

This will bring up a list of available open cl nodes on the fpga queue. Look for a node that has the “darby” property as well as a state of “state=free”. Keep track of the node name -- "sxxx-nxxx".

Open an interactive session with 

```bash
qsub -q batch@v-qsvr-fpga -I -l nodes=*node_name*:ppn=2
```

 

or to have qsub find you an appropriate node run

```bash
qsub -q batch@v-qsvr-fpga -I -l nodes=darby:ppn=2
```

 

Once on this node, run the commands

```bash
source /glob/development-tools/versions/fpgasupportstack/d5005/2.0.1/inteldevstack/init_env.sh

source /glob/development-tools/versions/fpgasupportstack/d5005/2.0.1/inteldevstack/hld/init_opencl.sh

export FPGA_BBB_CCI_SRC=/usr/local/intel-fpga-bbb

export PATH=/glob/intel-python/python2/bin:${PATH}
```

Make working directory

```
mkdir S10_OPENCL_AFU 
```

We will then copy the example folder into this project folder. Type this into the terminal:

```
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz S10_OPENCL_AFU
cd S10_OPENCL_AFU
tar xvf exm_opencl_hello_world_x64_linux.tgz
```

Check to make sure connectivity to the Stratix 10 PAC card looks ok:

```
aocl diagnose
```

Look for DIAGNOSTIC_PASSED. For the specific test on the installed board, use:

```
aocl diagnose acl0
```

Note that this shows a board name is pac_s10_dc. You will need this for a subsequent step.

#### 4.2 Running OpenCL in emulation mode

The first step of the OpenCL flow is to compile and execute the design for emulation mode. This step allows you to quickly verify the functionality of your code on the CPU without performing the conversion from OpenCL to RTL and from RTL to an FPGA executable, which takes up to an hour.

```
cd hello_world
aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
```

The next step is to compile the host code. Note: use make clean followed by make to force a recompile.

```
make
```

Now run emulation with the host code binary. Note that the with the environment setting shown, the host code runs the .aocx file for emulation execution on the CPU and not on the FPGA card.

```
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
```

You should see a list of parameters and Kernel execution is complete.

#### 4.3 Compiling OpenCL code into an FPGA executable

Now that you have emulated your design, you can run the steps to convert OpenCL to RTL, which will subsequently be compiled in Quartus to produce an FPGA executable .aocx file. This step will take approximately one hour.
 You can also copy or link over a prebuilt copy of the .aocx file from $OPAE_PLATFORM_ROOT/opencl/hello_world.aocx .

```
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
```

#### 4.4 Downloading the bit stream into the PAC card and running the host code

Similar to the prior step of running bin/host, but without the environment variable setting.

Run the following:

```
aocl program acl0 bin/hello_world.aocx
./bin/host
```

 <br/>

## 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Document Revision History

List the revision history for the application note.

| Name              | Date      | Changes                                                      |
| ----------------- | --------- | ------------------------------------------------------------ |
| Larry Landis      | 4/4/2020  | Initial Release                                              |
| Larry Landis      | 5/12/2020 | Symbolic links from hello_world.aocx                         |
| Damaris Renteria  | 6/8/2020  | Batch Command flow                                           |
| Jeffrey Okurowski | 11/4/2021 | New version. Batch Mode primary. Removed tools_setup & devcloud_login dependency |



 
