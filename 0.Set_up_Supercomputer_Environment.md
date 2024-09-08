[toc]

# NCI Gadi

As a Linux user, you need to replace the `{xs75}` in the commands with your own `project ID`.

## Workspace and cache directory preparation

To created some directories and links, making it easier to access project and application files, the following commands

1. Create symbolic link to `scratch` directory of MY project `{xs75}`
2. Move PIP and HuggingFace cache files to `scratch` directory
3. Replace my `cache` directory with a symbolic link 

```bash
ln -s /scratch/xs75 ${HOME}/scratch
mv ${HOME}/.cache ${HOME}/scratch/home_cache
ln -s scratch/home_cache .cache
```

## Setup Python environments

To Install a MiniConda to create Python environments, the following commands

1. Download latest `miniconda.sh` to scratch directory
2. Install miniconda to `${HOME}/miniconda`
3. Initialized `.bashrc` for the installed miniconda
4. Start a new bash shell with `conda` enabled

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${HOME}/scratch/miniconda.sh
time bash ${HOME}/scratch/miniconda.sh -b -p ${HOME}/miniconda
# real	1m13.541s
${HOME}/miniconda/bin/conda init
bash
```

# NSCC Singapore

{to be updated}