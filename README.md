# Neonatal Outcomes AI Prediction using Multimodal Trajectory Database

## Installation

Modify Dockerfile according to AMD64 or ARM64.

https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh

Change `$(pwd)` with the absolute path of the project folder.

```{bash}
docker build -t ndi_pred --load .
docker run -it -p 8787:8787 -p 8888:8888 -v "$(pwd)":/home/rstudio ndi_pred
```

Visit http://localhost:8787.
Username: rstudio
Password: 1234

Use terminal in RStudio to run jupyter lab using this line of codes.

```{bash}
jupyter-lab --ip=0.0.0.0 --no-browser --allow-root
```

Click a link in the results to open jupyter lab in a browser.






