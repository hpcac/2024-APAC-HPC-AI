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

## Configure SSH authentication

On the login node, run the following command

```bash
ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no localhost
```

If it works successfully, SSH authentication is configured.

Otherwise, run the following two ssh-keygen commands to configure SSH keys, then run the above "ssh localhost" to confirm SSH authentication has been configured successfully.

```bash
ssh-keygen -t ecdsa -f ${HOME}/.ssh/id_ecdsa -N "" -vvv
ssh-keygen -y -f ${HOME}/.ssh/id_ecdsa >> ${HOME}/.ssh/authorized_keys
```

# NSCC Singapore

## Workspace and cache directory preparation

To created some directories and links, making it easier to access project and application files, the following commands

1. Verify `scratch` directory existence
2. Create symbolic link to `scratch` directory of MY project `{apacsc22}` if it doesn't exist
3. No need to Move PIP and HuggingFace cache files
4. No need to create symbolic link for `cache` directory  

```bash
file ${HOME}/scratch
#/home/users/industry/ai-hpc/apacsc22/scratch: symbolic link to /scratch/users/industry/ai-hpc/apacsc22
ln -s /scratch/users/industry/ai-hpc/apacsc22 ${HOME}/scratch
#mv ${HOME}/.cache ${HOME}/scratch/home_cache
#ln -s scratch/home_cache .cache
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
# real	1m20.568s
${HOME}/miniconda/bin/conda init
bash
```
