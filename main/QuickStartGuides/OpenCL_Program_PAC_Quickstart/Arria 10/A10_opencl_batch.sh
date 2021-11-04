source /glob/development-tools/versions/fpgasupportstack/a10/1.2.1/intelFPGA_pro/hld/init_opencl.sh
source /glob/development-tools/versions/fpgasupportstack/a10/1.2.1/inteldevstack/init_env.sh
export FPGA_BBB_CCI_SRC=/usr/local/intel-fpga-bbb
export PATH=/glob/intel-python/python2/bin:${PATH}

#source /data/intel_fpga/devcloudLoginToolSetup.sh
#tools_setup -t A10DS
[ ! -d ./A10_OPENCL_AFU/v1.2.1 ] && mkdir -p ./A10_OPENCL_AFU/v1.2.1 || exit 0
# Copy Over sample design
cp -r /opt/intelFPGA_pro/quartus_19.2.0b57/hld/examples_aoc/hello_world ./A10_OPENCL_AFU/v1.2.1
cp -r /opt/intelFPGA_pro/quartus_19.2.0b57/hld/examples_aoc/common ./A10_OPENCL_AFU/v1.2.1
cd A10_OPENCL_AFU/v1.2.1

# Check Arria 10 PAC card connectivity
aocl diagnose

# Running project in Emulation mode
cd hello_world
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

################ntf "\\n%s\\n" "Running in Emulation Mode:"
aoc -march=emulator -v device/hello_world.cl -o bin/hello_world_emulation.aocx
# Creating symbolic link to emulation .aocx
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
make
# Run host code for version 1.2.1
./bin/host -emulator

# Running project in FPGA Hardware Mode (this takes approximately 1 hour)
printf "\\n%s\\n" "Running in FPGA Hardware Mode:"
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_a10
# Relink to hardware .aocx
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
# Availavility of Acceleration cards
aoc -list-boards
# Get device name
aocl diagnose

# Converting to an unsigned .aocx file
cd bin
printf "\\n%s\\n" "Converting to unsigned .aocx:"
printf "Y\\nY\\n" | source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i hello_world_fpga.aocx -r NULL -k NULL -o hello_world_fpga_unsigned.aocx
# Programmming PAC Card
aocl program acl0 hello_world_fpga_unsigned.aocx
./host
