#
# <your_project> build script.
#

.PHONY: default test install uninstall clean realclean

PLATFORM = $(shell uname)

ifeq ($(PLATFORM), Darwin)
  CONDA_INSTALLER = miniconda_macosx-x86_64.sh
  CONDA_REQUIREMENTS = conda_requirements_osx.txt
else
  CONDA_INSTALLER = miniconda_linux-x86_64.sh
  CONDA_REQUIREMENTS = conda_requirements_linux.txt
endif


CONDA_HOME = $(HOME)/miniconda
CONDA_BIN_DIR = $(CONDA_HOME)/bin
CONDA = $(CONDA_BIN_DIR)/conda

ENV_NAME = <your_project_name>
ENV_DIR = $(CONDA_HOME)/envs/$(ENV_NAME)
ENV_BIN_DIR = $(ENV_DIR)/bin
ENV_LIB_DIR = $(ENV_DIR)/lib
ENV_PYTHON = $(ENV_BIN_DIR)/python


default:
	@echo $(ENV_NAME)' build script'
	@echo
	@echo 'usage: make <target>'
	@echo
	@echo 'conda installer: $(CONDA_INSTALLER)'
	@echo 'conda requirements: $(CONDA_REQUIREMENTS)'
	@echo 'conda command: $(CONDA)'
	@echo 'python command: $(ENV_PYTHON)'
	@echo


conda_shell_setup:
	@echo
	@echo '*** Make sure you modify you environment to include the following ***'
	@echo
	@echo '1) Add conda bin directory to you PATH'
	@echo
	@echo '    export PATH='$(CONDA_BIN_DIR)':$$PATH'
	@echo
	@echo '2) Add aliases to your login profile'
	@echo
	@echo "    alias workon='source activate'"
	@echo "    alias workoff='source deactivate'"
	@echo "    alias mkvirtualenv='conda create -n'"
	@echo '    alias cdproject="cd $${HOME}/workspace/<your_project>"'
	@echo
	@echo "3) For conda BASH completion, add the following to your .bash_profile"
	@echo
	@echo '    eval "$$(register-python-argcomplete conda)"'
	@echo


conda_update:
	@echo 'downloading latest version of conda binaries'
	@echo
	wget http://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O miniconda_macosx-x86_64.sh
	wget http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda_linux-x86_64.sh


conda_install:
	@echo 'installing the conda package manager'
	@echo
	bash $(CONDA_INSTALLER) -b -p $(CONDA_HOME)
	$(CONDA) install --yes conda-build
	$(CONDA) install --yes argcomplete
	@echo


conda_env_create:
	@echo 'creating the '$(ENV_NAME)' environment'
	@echo
	$(CONDA) env create --file $(CONDA_REQUIREMENTS)
	@echo


python_setup_develop:
	@echo 'adding project sources to '$(ENV_NAME)' environment'
	@echo
	$(ENV_PYTHON) setup.py develop
	@echo


conda_env_remove:
	@echo 'uninstalling the '$(ENV_NAME)' environment'
	@echo
	$(CONDA) remove --yes --name $(ENV_NAME) --all
	@echo


conda_uninstall:
	@echo 'uninstalling conda package manager'
	@echo
	rm -rf $(CONDA_HOME)
	@echo


install: conda_install conda_env_create python_setup_develop test conda_shell_setup


install_linux: conda_install conda_env_create python_setup_develop test conda_shell_setup


uninstall: conda_env_remove conda_uninstall


rebuild: conda_env_remove conda_env_create python_setup_develop test


clean:
	@echo 'cleaning up temporary files'
	find . -name '*.pyc' -type f -exec rm {} ';'
	find . -name '__pycache__' -type d -print | xargs rm -rf
	@echo 'NOTE: you should clean up the following occasionally (by hand)'
	git clean -fdn


realclean: clean rebuild


unit_tests:
	@echo
	@echo '>>> Running '$(ENV_NAME)' UNIT test suite'
	@echo
	$(ENV_BIN_DIR)/py.test -vv $(PWD)/test/unit


integration_tests:
	@echo
	@echo '>>> Running '$(ENV_NAME)' INTEGRATION test suite'
	@echo
	$(ENV_BIN_DIR)/py.test -vv $(PWD)/test/integration


test: unit_tests integration_tests


test_with_junitxml:
	@echo
	@echo '>>> Running all '$(ENV_NAME)' tests with JUnit XML output'
	@echo
	$(ENV_BIN_DIR)/py.test -vv --junitxml=$$CI_REPORTS/junit.xml $(PWD)/test


update_deps:
	@echo 'updating conda dependencies file'
	@echo
	$(CONDA) env export --name $(ENV_NAME) | grep -v "<your_project_name>" > $(CONDA_REQUIREMENTS)
	@echo


diff_deps:
	@echo 'compare current dependencies with '$(ENV_NAME)' environment'
	@echo
	@echo 'diff -u <(cat '$(CONDA_REQUIREMENTS)') <('$(CONDA)' env export --name '$(ENV_NAME)')'
	@echo


ipynb:
	$(ENV_BIN_DIR)/ipython notebook --notebook-dir <your_project_name>/notebooks