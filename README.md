# Project template

Modify Dockerfile according to AMD64 or ARM64.

https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh

Change `project_template` to the project image name.

```{bash}
docker build -t project_template --load .
docker run -it -p 8787:8787 -p 8888:8888 -v "$(pwd)":/home/rstudio project_template
```

Visit http://localhost:8787.
Username: rstudio
Password: 1234

Create standard folder structure.

```{bash}
mkdir -p data inst/extdata R
```

Use terminal in RStudio to run jupyter lab using this line of codes.

```{bash}
jupyter-lab --ip=0.0.0.0 --no-browser --allow-root
```

Click a link in the results to open jupyter lab in a browser.






