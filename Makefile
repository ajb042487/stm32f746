export SHELL:=/bin/bash
export PATH:=$(PATH):$(HOME)/.local/bin
export ZEPHYR_TOOLCHAIN_VARIANT:=cross-compile
export CROSS_COMPILE:=/opt/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-

.PHONY: prep-ubuntu-18.04
prep-ubuntu-18.04:
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install -y --no-install-recommends git ninja-build gperf \
		ccache cargo rustc curl bison flex pkg-config dfu-util wget \
		python3-pip python3-setuptools python3-tk python3-wheel python3-testresources \
		python3-widgetsnbextension libyaml-dev xz-utils file make gcc gcc-multilib
	sudo apt-get remove -y cmake device-tree-compiler
	python3 -m pip install --user cmake
	python3 -m pip install --user -U west
	#curl -L -O -C - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.3/zephyr-sdk-0.10.3-setup.run | true
	#chmod +x zephyr-sdk-0.10.3-setup.run
	#./zephyr-sdk-0.10.3-setup.run -- -d ~/zephyr-sdk-0.10.3
	west init zephyrproject
	pushd zephyrproject && \
		west update && \
		python3 -m pip install --user -r zephyr/scripts/requirements.txt && \
		wget -P ~/Downloads/ https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2 && \
		sudo tar -xjf ~/Downloads/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2 -C /opt/ && \
		git clone git://git.kernel.org/pub/scm/utils/dtc/dtc.git && \
		pushd dtc && \
			git checkout -f v1.5.1 && \
			make all && \
			sudo make install PREFIX=/ && \
			sudo ln -s /bin/dtc /usr/bin/dtc || true && \
		popd && \
	popd

.PHONY: build-samples
build-samples:
	pushd zephyrproject && \
		pushd zephyr && \
			source zephyr-env.sh && \
			west build -b stm32f746g_disco samples/hello_world && \
		popd && \
	popd

.PHONY: install-samples
install-samples:
	pushd zephyrproject && \
		pushd zephyr && \
			west flash && \
		popd && \
	popd

.PHONY: clean-samples
clean-samples:
	pushd zephyrproject && \
		pushd zephyr && \
			rm -rf build && \
		popd && \
	popd
