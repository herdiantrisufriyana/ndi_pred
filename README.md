# Early prediction of neonatal outcomes among very preterm infants using multivariable trajectories: Development and validation

## Vignette

[Progress report](https://herdiantrisufriyana.github.io/ndi_pred/index.html)

## System requirements

Install Docker desktop once in your machine. Start the service every time you build this project image or run the container.

## Installation guide

Build the project image once for a new machine (currently support AMD64 and ARM64).

```{bash}
docker build -t ndi_pred --load .
```

Run the container every time you start working on the project. Change left-side port numbers for either Rstudio or Jupyter lab if any of them is already used by other applications.

In terminal:

```{bash}
docker run -d -p 8787:8787 -p 8888:8888 -v "$(pwd)":/home/rstudio/project --name ndi_pred_container ndi_pred
```

In command prompt:

```{bash}
docker run -d -p 8787:8787 -p 8888:8888 -v "%cd%":/home/rstudio/project --name ndi_pred_container ndi_pred
```

## Instructions for use

### Rstudio

Change port number in the link, accordingly, if it is already used by other applications.

Visit http://localhost:8787.
Username: rstudio
Password: 1234

Your working directory is ~/project.

### Jupyter lab

Use terminal/command prompt to run the container terminal.

```{bash}
docker exec -it ndi_pred_container bash
```

In the container terminal, run jupyter lab using this line of codes.

```{bash}
jupyter-lab --ip=0.0.0.0 --no-browser --allow-root
```

Click a link in the results to open jupyter lab in a browser. Change port number in the link, accordingly, if it is already used by other applications.




